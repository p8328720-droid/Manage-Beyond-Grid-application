enum InsightSeverity { critical, warning, info }

enum InsightCategory { anomaly, prediction, recommendation }

extension InsightCategoryX on InsightCategory {
  String get label => switch (this) {
        InsightCategory.anomaly => 'Anomali',
        InsightCategory.prediction => 'Prediksi',
        InsightCategory.recommendation => 'Rekomendasi',
      };
}

extension InsightSeverityX on InsightSeverity {
  String get label => switch (this) {
        InsightSeverity.critical => 'Kritis',
        InsightSeverity.warning => 'Perhatian',
        InsightSeverity.info => 'Informasi',
      };
}

class AiInsight {
  final String id;
  final String? deviceId;
  final String deviceName;
  final InsightCategory category;
  final InsightSeverity severity;
  final String title;
  final String description;
  final double confidence;
  final DateTime detectedAt;
  final Map<String, String> metrics;

  const AiInsight({
    required this.id,
    this.deviceId,
    required this.deviceName,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    required this.confidence,
    required this.detectedAt,
    this.metrics = const {},
  });
}

class DeviceHealthSnapshot {
  final String deviceId;
  final String deviceName;
  final String room;
  final double healthScore;
  final double signalMean;
  final double signalStdDev;
  final double signalTrendPerMinute;
  final int flapCount;
  final int sampleCount;
  final bool isOnline;
  final List<int> recentSignals;

  const DeviceHealthSnapshot({
    required this.deviceId,
    required this.deviceName,
    required this.room,
    required this.healthScore,
    required this.signalMean,
    required this.signalStdDev,
    required this.signalTrendPerMinute,
    required this.flapCount,
    required this.sampleCount,
    required this.isOnline,
    required this.recentSignals,
  });
}
