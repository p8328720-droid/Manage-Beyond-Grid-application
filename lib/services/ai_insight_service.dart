import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flutter_application_1/models/ai_insight.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/usage_analytics_service.dart';

class _Sample {
  final DateTime time;
  final int signal;
  final bool online;
  const _Sample(this.time, this.signal, this.online);
}

class _DeviceHistory {
  final List<_Sample> samples = [];
  final List<DateTime> transitions = [];
  bool? lastOnline;
}

class _RegressionResult {
  final double slope;
  final double intercept;
  final double rSquared;
  const _RegressionResult(this.slope, this.intercept, this.rSquared);
}

class AiInsightService extends ChangeNotifier {
  AiInsightService._internal() {
    DeviceService.instance.addListener(_onTick);
    _onTick();
  }
  static final AiInsightService instance = AiInsightService._internal();

  static const int _maxSamples = 80;
  static const Duration _flapWindow = Duration(minutes: 20);
  static const int _minSamplesForTrend = 6;
  static const double _signalDropThreshold = 20;

  final Map<String, _DeviceHistory> _history = {};
  List<AiInsight> _insights = [];
  List<DeviceHealthSnapshot> _snapshots = [];
  double _healthScore = 100;
  DateTime _lastAnalyzedAt = DateTime.now();

  List<AiInsight> get insights => List.unmodifiable(_insights);
  List<DeviceHealthSnapshot> get snapshots => List.unmodifiable(_snapshots);
  double get systemHealthScore => _healthScore;
  DateTime get lastAnalyzedAt => _lastAnalyzedAt;

  int get criticalCount =>
      _insights.where((i) => i.severity == InsightSeverity.critical).length;
  int get warningCount =>
      _insights.where((i) => i.severity == InsightSeverity.warning).length;
  int get totalAnalyzedSamples =>
      _history.values.fold(0, (sum, h) => sum + h.samples.length);

  void _onTick() {
    final devices = DeviceService.instance.all;
    final now = DateTime.now();

    for (final device in devices) {
      final history = _history.putIfAbsent(device.id, () => _DeviceHistory());
      history.samples.add(_Sample(now, device.signalStrength, device.isOnline));
      if (history.samples.length > _maxSamples) {
        history.samples.removeAt(0);
      }
      if (history.lastOnline != null && history.lastOnline != device.isOnline) {
        history.transitions.add(now);
      }
      history.lastOnline = device.isOnline;
      history.transitions.removeWhere((t) => now.difference(t) > _flapWindow);
    }
    _history.removeWhere((id, _) => !devices.any((d) => d.id == id));

    _analyze(devices, now);
    _lastAnalyzedAt = now;
    notifyListeners();
  }

  void _analyze(List<SmartDevice> devices, DateTime now) {
    final insights = <AiInsight>[];
    final snapshots = <DeviceHealthSnapshot>[];

    for (final device in devices) {
      final history = _history[device.id];
      if (history == null || history.samples.isEmpty) continue;

      final signals = history.samples.map((s) => s.signal.toDouble()).toList();
      final mean = _mean(signals);
      final std = _stdDev(signals, mean);
      final latest = signals.last;
      final z = std > 0 ? (latest - mean) / std : 0.0;

      double slopePerMinute = 0;
      double rSquared = 0;
      if (history.samples.length >= _minSamplesForTrend) {
        final t0 = history.samples.first.time;
        final xs = history.samples
            .map((s) => s.time.difference(t0).inSeconds.toDouble())
            .toList();
        final regression = _linearRegression(xs, signals);
        slopePerMinute = regression.slope * 60;
        rSquared = regression.rSquared;
      }

      final flapCount = history.transitions.length;

      double deviceScore = 100;
      if (!device.isOnline) deviceScore -= 45;
      if (z < 0) deviceScore -= min(30.0, z.abs() * 8);
      deviceScore -= min(20.0, flapCount * 3.5);
      if (slopePerMinute < 0) {
        deviceScore -= min(15.0, slopePerMinute.abs() * 8);
      }
      deviceScore = deviceScore.clamp(0, 100).toDouble();

      final allSignals = history.samples.map((s) => s.signal).toList();
      final recent =
          allSignals.length <= 20 ? allSignals : allSignals.sublist(allSignals.length - 20);

      snapshots.add(
        DeviceHealthSnapshot(
          deviceId: device.id,
          deviceName: device.name,
          room: device.room,
          healthScore: deviceScore,
          signalMean: mean,
          signalStdDev: std,
          signalTrendPerMinute: slopePerMinute,
          flapCount: flapCount,
          sampleCount: history.samples.length,
          isOnline: device.isOnline,
          recentSignals: recent,
        ),
      );

      if (device.isOnline &&
          std > 0 &&
          z <= -2.0 &&
          history.samples.length >= _minSamplesForTrend) {
        insights.add(
          AiInsight(
            id: 'sig-${device.id}',
            deviceId: device.id,
            deviceName: device.name,
            category: InsightCategory.anomaly,
            severity:
                z <= -3 ? InsightSeverity.critical : InsightSeverity.warning,
            title: 'Sinyal ${device.name} menurun signifikan',
            description:
                'Kekuatan sinyal saat ini ${latest.round()}%, berada jauh di bawah rata-rata historisnya ${mean.toStringAsFixed(1)}%. Penyimpangan ini setara skor-Z ${z.toStringAsFixed(2)} dari ${history.samples.length} sampel terakhir.',
            confidence: (55 + z.abs() * 12).clamp(0, 98).toDouble(),
            detectedAt: now,
            metrics: {
              'Skor-Z': z.toStringAsFixed(2),
              'Rata-rata historis': '${mean.toStringAsFixed(1)}%',
              'Sampel dianalisis': '${history.samples.length}',
            },
          ),
        );
      }

      if (device.isOnline &&
          slopePerMinute < -0.3 &&
          latest > _signalDropThreshold &&
          rSquared >= 0.35) {
        final minutesToThreshold =
            (latest - _signalDropThreshold) / (-slopePerMinute);
        if (minutesToThreshold <= 30) {
          insights.add(
            AiInsight(
              id: 'pred-${device.id}',
              deviceId: device.id,
              deviceName: device.name,
              category: InsightCategory.prediction,
              severity: minutesToThreshold <= 10
                  ? InsightSeverity.critical
                  : InsightSeverity.warning,
              title: 'Prediksi gangguan koneksi ${device.name}',
              description:
                  'Tren sinyal menurun stabil ${slopePerMinute.abs().toStringAsFixed(2)}% per menit. Jika pola ini berlanjut, perangkat diperkirakan terputus dalam sekitar ${minutesToThreshold.round()} menit.',
              confidence: (rSquared * 100).clamp(0, 95).toDouble(),
              detectedAt: now,
              metrics: {
                'Kemiringan tren': '${slopePerMinute.toStringAsFixed(2)}%/menit',
                'Kecocokan model': rSquared.toStringAsFixed(2),
                'Estimasi waktu': '${minutesToThreshold.round()} menit',
              },
            ),
          );
        }
      }

      if (flapCount >= 4) {
        final windowMinutes = _flapWindow.inMinutes;
        final ratePerHour = flapCount / (windowMinutes / 60);
        insights.add(
          AiInsight(
            id: 'flap-${device.id}',
            deviceId: device.id,
            deviceName: device.name,
            category: InsightCategory.anomaly,
            severity: flapCount >= 8
                ? InsightSeverity.critical
                : InsightSeverity.warning,
            title: 'Koneksi ${device.name} tidak stabil',
            description:
                'Terdeteksi $flapCount perubahan status online/offline dalam $windowMinutes menit terakhir, setara ${ratePerHour.toStringAsFixed(1)} kali per jam. Pola ini biasanya menandakan gangguan jaringan atau penempatan perangkat yang kurang optimal.',
            confidence: (40 + flapCount * 7).clamp(0, 97).toDouble(),
            detectedAt: now,
            metrics: {
              'Perubahan status': '$flapCount kali',
              'Jendela pengamatan': '$windowMinutes menit',
            },
          ),
        );
      }

      if (!device.isOnline) {
        final offlineDuration = now.difference(device.lastSeen);
        insights.add(
          AiInsight(
            id: 'off-${device.id}',
            deviceId: device.id,
            deviceName: device.name,
            category: InsightCategory.anomaly,
            severity: offlineDuration.inMinutes >= 15
                ? InsightSeverity.critical
                : InsightSeverity.warning,
            title: '${device.name} sedang offline',
            description:
                'Perangkat terputus sejak ${_formatDuration(offlineDuration)} yang lalu. Kekuatan sinyal terakhir yang tercatat adalah ${device.signalStrength}%.',
            confidence: 92,
            detectedAt: now,
            metrics: {
              'Durasi offline': _formatDuration(offlineDuration),
              'Sinyal terakhir': '${device.signalStrength}%',
            },
          ),
        );
      }
    }

    final stats = UsageAnalyticsService.instance.stats;
    if (stats.length >= 3) {
      final energies = stats.map((s) => s.energyToday).toList();
      final energyMean = _mean(energies);
      final energyStd = _stdDev(energies, energyMean);
      if (energyStd > 0) {
        for (final stat in stats) {
          final z = (stat.energyToday - energyMean) / energyStd;
          if (z >= 1.8) {
            insights.add(
              AiInsight(
                id: 'energy-${stat.deviceId}',
                deviceId: stat.deviceId,
                deviceName: stat.deviceName,
                category: InsightCategory.recommendation,
                severity: z >= 2.5 ? InsightSeverity.warning : InsightSeverity.info,
                title: 'Konsumsi energi ${stat.deviceName} di atas normal',
                description:
                    'Energi yang terpakai hari ini ${stat.energyToday.toStringAsFixed(2)} kWh, lebih tinggi ${z.toStringAsFixed(1)} standar deviasi dibanding rata-rata perangkat lain (${energyMean.toStringAsFixed(2)} kWh). Pertimbangkan memeriksa kondisi perangkat atau menjadwalkan penggunaan agar lebih efisien.',
                confidence: (50 + z * 15).clamp(0, 95).toDouble(),
                detectedAt: now,
                metrics: {
                  'Energi hari ini': '${stat.energyToday.toStringAsFixed(2)} kWh',
                  'Rata-rata perangkat lain': '${energyMean.toStringAsFixed(2)} kWh',
                  'Skor-Z': z.toStringAsFixed(2),
                },
              ),
            );
          }
        }
      }
    }

    insights.sort((a, b) {
      final severityCompare =
          _severityWeight(b.severity).compareTo(_severityWeight(a.severity));
      if (severityCompare != 0) return severityCompare;
      return b.confidence.compareTo(a.confidence);
    });

    _insights = insights;
    _snapshots = snapshots;
    _healthScore = _computeHealthScore(devices, insights);
  }

  double _computeHealthScore(List<SmartDevice> devices, List<AiInsight> insights) {
    if (devices.isEmpty) return 100;
    final onlineRatio =
        devices.where((d) => d.isOnline).length / devices.length;
    final avgSignal =
        devices.map((d) => d.signalStrength).reduce((a, b) => a + b) /
            devices.length;
    final criticalN =
        insights.where((i) => i.severity == InsightSeverity.critical).length;
    final warningN =
        insights.where((i) => i.severity == InsightSeverity.warning).length;

    double score = onlineRatio * 55 + (avgSignal / 100) * 35 + 10;
    score -= criticalN * 9 + warningN * 4;
    return score.clamp(0, 100).toDouble();
  }

  int _severityWeight(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return 3;
      case InsightSeverity.warning:
        return 2;
      case InsightSeverity.info:
        return 1;
    }
  }

  static double _mean(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _stdDev(List<double> values, double mean) {
    if (values.length < 2) return 0;
    final variance = values.fold<double>(
          0,
          (sum, v) => sum + (v - mean) * (v - mean),
        ) /
        (values.length - 1);
    return sqrt(variance);
  }

  static _RegressionResult _linearRegression(List<double> xs, List<double> ys) {
    final n = xs.length;
    final meanX = _mean(xs);
    final meanY = _mean(ys);
    double sxy = 0, sxx = 0, syy = 0;
    for (var i = 0; i < n; i++) {
      final dx = xs[i] - meanX;
      final dy = ys[i] - meanY;
      sxy += dx * dy;
      sxx += dx * dx;
      syy += dy * dy;
    }
    if (sxx == 0) return _RegressionResult(0, meanY, 0);
    final slope = sxy / sxx;
    final intercept = meanY - slope * meanX;
    final rSquared = syy == 0 ? 0.0 : (sxy * sxy) / (sxx * syy);
    return _RegressionResult(slope, intercept, rSquared);
  }

  static String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '${duration.inSeconds} detik';
    if (duration.inMinutes < 60) return '${duration.inMinutes} menit';
    return '${duration.inHours} jam ${duration.inMinutes % 60} menit';
  }

  @override
  void dispose() {
    DeviceService.instance.removeListener(_onTick);
    super.dispose();
  }
}
