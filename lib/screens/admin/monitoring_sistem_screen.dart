import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/system_config_service.dart';
import 'package:flutter_application_1/services/system_monitoring_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class MonitoringSistemScreen extends StatefulWidget {
  static const routeName = '/admin-monitoring-sistem';

  const MonitoringSistemScreen({super.key});

  @override
  State<MonitoringSistemScreen> createState() => _MonitoringSistemScreenState();
}

class _MonitoringSistemScreenState extends State<MonitoringSistemScreen> {
  @override
  void initState() {
    super.initState();
    SystemMonitoringService.instance.start();
  }

  @override
  void dispose() {
    SystemMonitoringService.instance.stop();
    super.dispose();
  }

  String _formatUptime(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${hours}j ${minutes}m ${seconds}d';
  }

  Color _healthColor(String label) {
    switch (label) {
      case 'Kritis':
        return AppColors.danger;
      case 'Waspada':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            SystemMonitoringService.instance,
            SystemConfigService.instance,
          ]),
          builder: (context, _) {
            final monitor = SystemMonitoringService.instance;
            final config = SystemConfigService.instance;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminScreenHeader(
                    title: 'Monitoring Sistem',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),

                  if (config.maintenanceMode)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sistem sedang dalam Mode Pemeliharaan.',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      AdminStatCard(
                        icon: Icons.people_outline,
                        label: 'Total Pengguna',
                        value: '${monitor.totalUsers}',
                      ),
                      AdminStatCard(
                        icon: Icons.verified_user_outlined,
                        label: 'Pengguna Aktif',
                        value: '${monitor.activeUsers}',
                        accentColor: AppColors.success,
                      ),
                      AdminStatCard(
                        icon: Icons.developer_board,
                        label: 'Perangkat Online',
                        value: '${monitor.devicesOnline}/${monitor.totalDevices}',
                      ),
                      AdminStatCard(
                        icon: Icons.timer_outlined,
                        label: 'Waktu Aktif Aplikasi',
                        value: _formatUptime(monitor.uptime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AdminSectionLabel('Kesehatan Sistem'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _healthColor(monitor.healthLabel).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          monitor.healthLabel,
                          style: TextStyle(
                            color: _healthColor(monitor.healthLabel),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        AdminProgressBar(
                          label: 'Penggunaan CPU',
                          percent: monitor.cpuUsage,
                          color: AppColors.accentDim,
                        ),
                        const SizedBox(height: 6),
                        AdminHistoryBars(values: monitor.cpuHistory, color: AppColors.accentDim),
                        const SizedBox(height: 18),
                        AdminProgressBar(
                          label: 'Penggunaan Memori',
                          percent: monitor.memoryUsage,
                          color: AppColors.link,
                        ),
                        const SizedBox(height: 6),
                        AdminHistoryBars(values: monitor.memoryHistory, color: AppColors.link),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Latensi Jaringan',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(
                              '${monitor.networkLatencyMs.round()} ms',
                              style: const TextStyle(
                                  color: AppColors.accentDim, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const AdminSectionLabel('Status Perangkat'),
                  const SizedBox(height: 10),
                  ...DeviceService.instance.all.map(
                    (d) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: d.isOn ? AppColors.success : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${d.name} · ${d.room}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                          ),
                          Text(
                            d.isOn ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: d.isOn ? AppColors.success : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
