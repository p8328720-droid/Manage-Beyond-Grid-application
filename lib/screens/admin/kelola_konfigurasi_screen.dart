import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/system_config_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';
import 'package:flutter_application_1/widgets/mbg_text_field.dart';

class KelolaKonfigurasiScreen extends StatefulWidget {
  static const routeName = '/admin-kelola-konfigurasi';

  const KelolaKonfigurasiScreen({super.key});

  @override
  State<KelolaKonfigurasiScreen> createState() => _KelolaKonfigurasiScreenState();
}

class _KelolaKonfigurasiScreenState extends State<KelolaKonfigurasiScreen> {
  late final TextEditingController _appNameController;

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController(text: SystemConfigService.instance.appName);
  }

  @override
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SystemConfigService.instance,
          builder: (context, _) {
            final config = SystemConfigService.instance;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminScreenHeader(
                    title: 'Kelola Konfigurasi Sistem',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),

                  const AdminSectionLabel('Umum'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nama aplikasi',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 10),
                        MbgTextField(controller: _appNameController, label: 'Nama aplikasi', showIcon: false),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => config.setAppName(_appNameController.text),
                            child: const Text('Simpan Nama'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AdminSwitchTile(
                    icon: Icons.build_circle_outlined,
                    label: 'Mode Pemeliharaan',
                    subtitle: 'Batasi akses pengguna sementara aplikasi diperbarui',
                    value: config.maintenanceMode,
                    onChanged: config.setMaintenanceMode,
                  ),
                  const SizedBox(height: 12),
                  AdminSwitchTile(
                    icon: Icons.how_to_reg_outlined,
                    label: 'Izinkan Pendaftaran Baru',
                    subtitle: 'Pengguna baru dapat mendaftar mandiri lewat aplikasi',
                    value: config.allowRegistration,
                    onChanged: config.setAllowRegistration,
                  ),
                  const SizedBox(height: 24),

                  const AdminSectionLabel('Keamanan'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Batas waktu sesi tidak aktif',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 10),
                        AdminChipGroup<int>(
                          options: SystemConfigService.sessionTimeoutOptions,
                          labels: SystemConfigService.sessionTimeoutOptions
                              .map((m) => '$m menit')
                              .toList(),
                          selected: config.sessionTimeoutMinutes,
                          onSelected: config.setSessionTimeoutMinutes,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const AdminSectionLabel('Perangkat'),
                  const SizedBox(height: 10),
                  Container(
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
                            const Text('Batas perangkat per pengguna',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('${config.maxDevicesPerUser}',
                                style: const TextStyle(
                                    color: AppColors.accentDim, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Slider(
                          value: config.maxDevicesPerUser.toDouble(),
                          min: 1,
                          max: 20,
                          divisions: 19,
                          activeColor: AppColors.accent,
                          onChanged: (v) => config.setMaxDevicesPerUser(v.round()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const AdminSectionLabel('Notifikasi'),
                  const SizedBox(height: 10),
                  AdminSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    label: 'Notifikasi Peringatan Sistem',
                    subtitle: 'Kirim peringatan saat metrik sistem melewati ambang batas',
                    value: config.alertNotificationsEnabled,
                    onChanged: config.setAlertNotificationsEnabled,
                  ),
                  const SizedBox(height: 24),

                  const AdminSectionLabel('Backup'),
                  const SizedBox(height: 10),
                  AdminSwitchTile(
                    icon: Icons.backup_outlined,
                    label: 'Backup Otomatis',
                    value: config.autoBackupEnabled,
                    onChanged: config.setAutoBackupEnabled,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Frekuensi backup',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 10),
                        AdminChipGroup<int>(
                          options: SystemConfigService.backupFrequencyOptions,
                          labels: const ['Harian', 'Mingguan', 'Bulanan'],
                          selected: config.backupFrequencyDays,
                          onSelected: config.setBackupFrequencyDays,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          config.lastBackupAt == null
                              ? 'Belum pernah dilakukan backup.'
                              : 'Backup terakhir: ${AppSettings.instance.formatDateTime(config.lastBackupAt!)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await config.runBackupNow();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Backup sistem berhasil dijalankan.')),
                              );
                            },
                            child: const Text('Jalankan Backup Sekarang'),
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
