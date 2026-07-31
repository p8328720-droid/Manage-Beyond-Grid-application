import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/usage_analytics_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: UsageAnalyticsService.instance,
        builder: (context, _) {
          final service = UsageAnalyticsService.instance;
          final stats = List.of(service.stats)
            ..sort((a, b) => b.energyToday.compareTo(a.energyToday));
          final topDevice = service.topEnergyConsumer;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics & Reports',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Grafik energi, waktu aktif, dan riwayat aktivitas perangkat.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.bolt_outlined,
                        label: 'Energi Hari Ini',
                        value: '${service.totalEnergyToday.toStringAsFixed(1)} kWh',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.timelapse_outlined,
                        label: 'Waktu Aktif Hari Ini',
                        value: '${service.totalActiveHoursToday.toStringAsFixed(1)} jam',
                        accentColor: AppColors.link,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.developer_board,
                        label: 'Perangkat Online',
                        value: '${service.onlineDeviceCount}/${service.totalDeviceCount}',
                        accentColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.calendar_view_week_outlined,
                        label: 'Energi 7 Hari',
                        value: '${service.totalEnergyWeek.toStringAsFixed(1)} kWh',
                        accentColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Konsumsi Energi 7 Hari Terakhir'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _WeeklyEnergyChart(values: service.weeklyEnergyTotals),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Waktu Aktif per Perangkat'),
                const SizedBox(height: 12),
                if (stats.isEmpty)
                  const Text(
                    'Belum ada perangkat untuk dianalisis.',
                    style: TextStyle(color: AppColors.textMuted),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0) const SizedBox(height: 16),
                          AdminProgressBar(
                            label: '${stats[i].deviceName} · ${stats[i].room}',
                            percent: (stats[i].activeHoursToday / 24 * 100).clamp(0, 100),
                            color: stats[i] == topDevice ? AppColors.danger : AppColors.accentDim,
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                const _SectionTitle('Riwayat Aktivitas'),
                const SizedBox(height: 12),
                if (service.activity.isEmpty)
                  const Text(
                    'Nyalakan atau matikan perangkat untuk melihat riwayat di sini.',
                    style: TextStyle(color: AppColors.textMuted),
                  )
                else
                  Column(
                    children: service.activity
                        .take(20)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AdminTileShell(
                              icon: entry.turnedOn
                                  ? Icons.power_settings_new_rounded
                                  : Icons.power_off_outlined,
                              iconColor: entry.turnedOn ? AppColors.success : AppColors.textMuted,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.deviceName} · ${entry.room}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.turnedOn ? 'Dinyalakan' : 'Dimatikan',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppSettings.instance.formatDateTime(entry.time),
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
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

class _WeeklyEnergyChart extends StatelessWidget {
  final List<double> values;

  const _WeeklyEnergyChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final labels = _lastSevenDayLabels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final value = values[i];
              final ratio = maxVal <= 0 ? 0.0 : value / maxVal;
              final isToday = i == values.length - 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isToday ? AppColors.accentDim : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 90 * ratio,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.accent
                              : AppColors.accent.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  List<String> _lastSevenDayLabels() {
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return names[day.weekday - 1];
    });
  }
}