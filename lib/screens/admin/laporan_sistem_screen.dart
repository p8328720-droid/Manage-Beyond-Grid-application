import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/audit_log_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class LaporanSistemScreen extends StatefulWidget {
  static const routeName = '/admin-laporan-sistem';

  const LaporanSistemScreen({super.key});

  @override
  State<LaporanSistemScreen> createState() => _LaporanSistemScreenState();
}

class _LaporanSistemScreenState extends State<LaporanSistemScreen> {
  AuditCategory? _filter;

  IconData _iconFor(AuditCategory c) {
    switch (c) {
      case AuditCategory.pengguna:
        return Icons.people_outline;
      case AuditCategory.konfigurasi:
        return Icons.tune;
      case AuditCategory.autentikasi:
        return Icons.login_rounded;
      case AuditCategory.sistem:
        return Icons.dns_outlined;
    }
  }

  String _labelFor(AuditCategory c) {
    switch (c) {
      case AuditCategory.pengguna:
        return 'Pengguna';
      case AuditCategory.konfigurasi:
        return 'Konfigurasi';
      case AuditCategory.autentikasi:
        return 'Autentikasi';
      case AuditCategory.sistem:
        return 'Sistem';
    }
  }

  void _copySummary(BuildContext context, List<AuditLogEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('Laporan Kinerja Sistem MBG');
    buffer.writeln('Total pengguna: ${AuthService.instance.allUsers.length}');
    buffer.writeln('Total perangkat: ${DeviceService.instance.all.length}');
    buffer.writeln('Total aktivitas tercatat: ${AuditLogService.instance.totalCount}');
    buffer.writeln('---');
    for (final e in entries.take(20)) {
      buffer.writeln(
        '${AppSettings.instance.formatDateTime(e.time)} · ${e.actor} · ${e.action} - ${e.detail}',
      );
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ringkasan laporan disalin ke clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuditLogService.instance,
          builder: (context, _) {
            final log = AuditLogService.instance;
            final entries = log.byCategory(_filter);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminScreenHeader(
                        title: 'Laporan Kinerja Sistem',
                        onBack: () => Navigator.of(context).pop(),
                        trailing: IconButton(
                          onPressed: () => _copySummary(context, entries),
                          icon: const Icon(Icons.copy_all_outlined),
                          color: AppColors.accentDim,
                          tooltip: 'Salin ringkasan',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.event_note_outlined,
                              label: 'Total Aktivitas',
                              value: '${log.totalCount}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.today_outlined,
                              label: 'Aktivitas Hari Ini',
                              value: '${log.todayCount}',
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
                            ...AuditCategory.values.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _FilterChip(
                                  label: _labelFor(c),
                                  selected: _filter == c,
                                  onTap: () => setState(() => _filter = c),
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
                          child: Text('Belum ada aktivitas.', style: TextStyle(color: AppColors.textMuted)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final e = entries[index];
                            return AdminTileShell(
                              icon: _iconFor(e.category),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.action,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    e.detail,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${e.actor} · ${AppSettings.instance.formatDateTime(e.time)}',
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
