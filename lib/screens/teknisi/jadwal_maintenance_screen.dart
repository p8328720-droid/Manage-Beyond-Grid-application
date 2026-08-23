import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/teknisi_models.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/teknisi_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class JadwalMaintenanceScreen extends StatefulWidget {
  static const routeName = '/teknisi-jadwal-maintenance';

  const JadwalMaintenanceScreen({super.key});

  @override
  State<JadwalMaintenanceScreen> createState() => _JadwalMaintenanceScreenState();
}

class _JadwalMaintenanceScreenState extends State<JadwalMaintenanceScreen> {
  TaskStatus? _filter;

  Future<void> _completeTask(BuildContext context, MaintenanceTask task) async {
    final controller = TextEditingController(text: task.notes ?? '');
    final confirmed = await showModalBottomSheet<bool>(
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
                'Selesaikan Maintenance',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${task.deviceName} · ${task.room}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Catatan pekerjaan (opsional)',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: const Text('TANDAI SELESAI'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      TeknisiService.instance.completeMaintenance(task.id, notes: controller.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintenance ditandai selesai.')),
        );
      }
    }
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
            final tasks = service.maintenanceTasks
                .where((t) => _filter == null || t.status == _filter)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminScreenHeader(
                        title: 'Jadwal Maintenance',
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.pending_actions_outlined,
                              label: 'Tugas Berjalan',
                              value: '${service.pendingMaintenanceCount}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.task_alt_outlined,
                              label: 'Selesai Hari Ini',
                              value: '${service.maintenanceDoneTodayCount}',
                              accentColor: AppColors.link,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'Semua',
                              selected: _filter == null,
                              onTap: () => setState(() => _filter = null),
                            ),
                            ...TaskStatus.values.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _FilterChip(
                                  label: s.label,
                                  selected: _filter == s,
                                  onTap: () => setState(() => _filter = s),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada tugas maintenance.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return _MaintenanceCard(
                              task: task,
                              onStart: () => TeknisiService.instance.startMaintenance(task.id),
                              onComplete: () => _completeTask(context, task),
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

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceTask task;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _MaintenanceCard({
    required this.task,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminTileShell(
      icon: Icons.build_outlined,
      iconColor: task.status.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${task.deviceName} · ${task.room}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.status.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.status.label,
                  style: TextStyle(
                    color: task.status.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Jadwal: ${AppSettings.instance.formatDateTime(task.scheduledAt)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.notes!,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
          if (task.status != TaskStatus.selesai) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (task.status == TaskStatus.terjadwal)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onStart,
                      child: const Text('MULAI'),
                    ),
                  ),
                if (task.status == TaskStatus.berlangsung)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onComplete,
                      child: const Text('SELESAIKAN'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}