import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/ai_insight.dart';
import 'package:flutter_application_1/services/ai_insight_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class AiInsightsScreen extends StatefulWidget {
  static const routeName = '/ai-insights';

  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  InsightCategory? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AiInsightService.instance,
          builder: (context, _) {
            final service = AiInsightService.instance;
            final insights = _filter == null
                ? service.insights
                : service.insights
                    .where((i) => i.category == _filter)
                    .toList();
            final snapshots = List.of(service.snapshots)
              ..sort((a, b) => a.healthScore.compareTo(b.healthScore));

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                      const Expanded(
                        child: Text(
                          'AI Smart Insights',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Analisis statistik langsung terhadap data perangkat untuk mendeteksi kondisi tidak normal, memprediksi potensi gangguan, dan memberikan rekomendasi tindakan.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _InsightsHeroSection(),
                  const SizedBox(height: 20),
                  _HealthScoreCard(
                    score: service.systemHealthScore,
                    criticalCount: service.criticalCount,
                    warningCount: service.warningCount,
                    lastAnalyzedAt: service.lastAnalyzedAt,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Insight Terkini'),
                  const SizedBox(height: 12),
                  AdminChipGroup<InsightCategory?>(
                    options: const [
                      null,
                      InsightCategory.anomaly,
                      InsightCategory.prediction,
                      InsightCategory.recommendation,
                    ],
                    labels: const ['Semua', 'Anomali', 'Prediksi', 'Rekomendasi'],
                    selected: _filter,
                    onSelected: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(height: 16),
                  if (insights.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Tidak ada insight pada kategori ini. Sistem tetap memantau seluruh perangkat secara real-time.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    )
                  else
                    Column(
                      children: insights
                          .map(
                            (insight) => Padding(
                              key: ValueKey(insight.id),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _InsightCard(insight: insight),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 28),
                  const _SectionTitle('Kesehatan Perangkat'),
                  const SizedBox(height: 12),
                  if (snapshots.isEmpty)
                    const Text(
                      'Belum ada perangkat untuk dianalisis.',
                      style: TextStyle(color: AppColors.textMuted),
                    )
                  else
                    Column(
                      children: snapshots
                          .map(
                            (snap) => Padding(
                              key: ValueKey(snap.deviceId),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DeviceHealthCard(snapshot: snap),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.query_stats_rounded, size: 20, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Setiap insight dihasilkan dari perhitungan langsung terhadap telemetri perangkat, meliputi rata-rata bergerak, deviasi standar, regresi tren sinyal, dan deteksi perubahan status koneksi. Total ${service.totalAnalyzedSamples} titik data telah dianalisis pada sesi ini.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InsightsHeroSection extends StatelessWidget {
  const _InsightsHeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: AssetImage('assets/images/living_room.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black45,
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Insight Room Background',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gambar ruangan sebagai latar memberikan konteks visual untuk insight perangkat.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  final double score;
  final int criticalCount;
  final int warningCount;
  final DateTime lastAnalyzedAt;

  const _HealthScoreCard({
    required this.score,
    required this.criticalCount,
    required this.warningCount,
    required this.lastAnalyzedAt,
  });

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  String get _label {
    if (score >= 80) return 'Sistem berjalan normal';
    if (score >= 50) return 'Perlu perhatian';
    return 'Kondisi kritis terdeteksi';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(lastAnalyzedAt);
    final updatedLabel =
        elapsed.inSeconds < 5 ? 'baru saja' : '${elapsed.inSeconds} detik lalu';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skor Kesehatan Sistem',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Diperbarui $updatedLabel',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.round().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  '/100',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: TextStyle(color: _color, fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final ratio = score.clamp(0, 100).toDouble() / 100;
                return Stack(
                  children: [
                    Container(height: 8, color: Colors.white12),
                    Container(
                      height: 8,
                      width: constraints.maxWidth * ratio,
                      color: _color,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(label: 'Kritis', value: '$criticalCount', color: AppColors.danger),
              const SizedBox(width: 20),
              _MiniStat(label: 'Perhatian', value: '$warningCount', color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final AiInsight insight;

  const _InsightCard({required this.insight});

  Color _colorFor(BuildContext context) {
    switch (insight.severity) {
      case InsightSeverity.critical:
        return AppColors.danger;
      case InsightSeverity.warning:
        return AppColors.warning;
      case InsightSeverity.info:
        return AppColors.link;
    }
  }

  IconData get _icon {
    switch (insight.category) {
      case InsightCategory.anomaly:
        return Icons.report_gmailerrorred_outlined;
      case InsightCategory.prediction:
        return Icons.trending_down_rounded;
      case InsightCategory.recommendation:
        return Icons.lightbulb_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
          ),
          if (insight.metrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: insight.metrics.entries
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${e.key}: ${e.value}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${insight.category.label} · ${insight.severity.label}',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
              Text(
                'Keyakinan ${insight.confidence.round()}%',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceHealthCard extends StatelessWidget {
  final DeviceHealthSnapshot snapshot;

  const _DeviceHealthCard({required this.snapshot});

  Color get _color {
    if (snapshot.healthScore >= 80) return AppColors.success;
    if (snapshot.healthScore >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.deviceName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snapshot.room,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${snapshot.healthScore.round()}',
                  style: TextStyle(color: _color, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (snapshot.recentSignals.length >= 2)
            AdminHistoryBars(
              values: snapshot.recentSignals.map((v) => v.toDouble()).toList(),
              color: _color,
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _MetricLabel(label: 'Rata-rata sinyal', value: '${snapshot.signalMean.toStringAsFixed(1)}%'),
              _MetricLabel(
                label: 'Tren',
                value:
                    '${snapshot.signalTrendPerMinute >= 0 ? '+' : ''}${snapshot.signalTrendPerMinute.toStringAsFixed(2)}%/mnt',
              ),
              _MetricLabel(label: 'Status', value: snapshot.isOnline ? 'Online' : 'Offline'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$label ', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
