import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/teknisi_models.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/teknisi_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class KalibrasiSensorScreen extends StatefulWidget {
  static const routeName = '/teknisi-kalibrasi-sensor';

  const KalibrasiSensorScreen({super.key});

  @override
  State<KalibrasiSensorScreen> createState() => _KalibrasiSensorScreenState();
}

class _KalibrasiSensorScreenState extends State<KalibrasiSensorScreen> {
  bool _onlyDue = false;

  Future<void> _openCalibrateSheet(BuildContext context, SensorCalibration sensor) async {
    final beforeController = TextEditingController(
      text: sensor.lastReadingBefore?.toString() ?? '',
    );
    final afterController = TextEditingController(
      text: sensor.lastReadingAfter?.toString() ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${sensor.sensorName} · ${sensor.room}',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: beforeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  hintText: 'Pembacaan sebelum (${sensor.unit})',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: afterController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  hintText: 'Pembacaan setelah (${sensor.unit})',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  TeknisiService.instance.calibrateSensor(
                    sensor.id,
                    readingBefore: double.tryParse(beforeController.text),
                    readingAfter: double.tryParse(afterController.text),
                  );
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sensor berhasil dikalibrasi.')),
                  );
                },
                child: const Text('SIMPAN KALIBRASI'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: TeknisiService.instance,
          builder: (context, _) {
            final service = TeknisiService.instance;
            final sensors = service.calibrations.where((c) => !_onlyDue || c.isDue).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminScreenHeader(
                        title: 'Kalibrasi Sensor',
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.sensors_outlined,
                              label: 'Total Sensor',
                              value: '${service.totalCalibrationCount}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.warning_amber_rounded,
                              label: 'Perlu Kalibrasi',
                              value: '${service.dueCalibrationCount}',
                              accentColor: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilterChip(
                          label: const Text('Hanya perlu kalibrasi'),
                          selected: _onlyDue,
                          onSelected: (value) => setState(() => _onlyDue = value),
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.surfaceElevated,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: sensors.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada sensor untuk ditampilkan.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: sensors.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final sensor = sensors[index];
                            return _SensorCard(
                              sensor: sensor,
                              onCalibrate: () => _openCalibrateSheet(context, sensor),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final SensorCalibration sensor;
  final VoidCallback onCalibrate;

  const _SensorCard({required this.sensor, required this.onCalibrate});

  @override
  Widget build(BuildContext context) {
    final statusColor = sensor.isDue ? AppColors.danger : AppColors.success;
    final statusLabel = sensor.isDue ? 'Perlu Kalibrasi' : 'Terkalibrasi';

    return AdminTileShell(
      icon: Icons.sensors_outlined,
      iconColor: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${sensor.sensorName} · ${sensor.room}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sensor.lastCalibratedAt == null
                ? 'Belum pernah dikalibrasi'
                : 'Terakhir: ${AppSettings.instance.formatDateTime(sensor.lastCalibratedAt!)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          Text(
            'Jatuh tempo: ${AppSettings.instance.formatDateTime(sensor.dueAt)}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCalibrate,
              child: const Text('KALIBRASI SEKARANG'),
            ),
          ),
        ],
      ),
    );
  }
}