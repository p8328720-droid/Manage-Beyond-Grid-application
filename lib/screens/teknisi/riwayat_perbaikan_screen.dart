import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/teknisi_models.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/teknisi_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class RiwayatPerbaikanScreen extends StatefulWidget {
  static const routeName = '/teknisi-riwayat-perbaikan';

  const RiwayatPerbaikanScreen({super.key});

  @override
  State<RiwayatPerbaikanScreen> createState() => _RiwayatPerbaikanScreenState();
}

class _RiwayatPerbaikanScreenState extends State<RiwayatPerbaikanScreen> {
  RepairHistoryType? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: TeknisiService.instance,
          builder: (context, _) {
            final service = TeknisiService.instance;
            final entries = service.repairHistory
                .where((e) => _filter == null || e.type == _filter)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminScreenHeader(
                        title: 'Riwayat Perbaikan',
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),
                      AdminStatCard(
                        icon: Icons.history_outlined,
                        label: 'Total Riwayat Tercatat',
                        value: '${service.repairHistory.length}',
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
                            ...RepairHistoryType.values.map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _FilterChip(
                                  label: t.label,
                                  selected: _filter == t,
                                  onTap: () => setState(() => _filter = t),
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
                  child: entries.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada riwayat perbaikan.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return AdminTileShell(
                              icon: entry.type.icon,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.subtitle,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${entry.type.label} · ${entry.detail} · ${AppSettings.instance.formatDateTime(entry.time)}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
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