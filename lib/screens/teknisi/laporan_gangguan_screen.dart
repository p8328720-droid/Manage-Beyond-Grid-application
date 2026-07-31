import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/teknisi_models.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/teknisi_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';

class LaporanGangguanScreen extends StatefulWidget {
  static const routeName = '/teknisi-laporan-gangguan';

  const LaporanGangguanScreen({super.key});

  @override
  State<LaporanGangguanScreen> createState() => _LaporanGangguanScreenState();
}

class _LaporanGangguanScreenState extends State<LaporanGangguanScreen> {
  GangguanStatus? _filter;

  Future<void> _openCreateSheet(BuildContext context) async {
    final devices = DeviceService.instance.all;
    String? selectedDeviceId = devices.isNotEmpty ? devices.first.id : null;
    GangguanSeverity severity = GangguanSeverity.sedang;
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporkan Gangguan',
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      const AdminSectionLabel('Perangkat'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDeviceId,
                        items: devices
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text('${d.name} · ${d.room}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setSheetState(() => selectedDeviceId = value),
                        validator: (value) =>
                            value == null ? 'Pilih perangkat terlebih dahulu.' : null,
                      ),
                      const SizedBox(height: 16),
                      const AdminSectionLabel('Tingkat Keparahan'),
                      const SizedBox(height: 8),
                      AdminChipGroup<GangguanSeverity>(
                        options: GangguanSeverity.values,
                        labels: GangguanSeverity.values.map((s) => s.label).toList(),
                        selected: severity,
                        onSelected: (value) => setSheetState(() => severity = value),
                      ),
                      const SizedBox(height: 16),
                      const AdminSectionLabel('Deskripsi Gangguan'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Jelaskan gejala atau kondisi perangkat',
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Deskripsi wajib diisi.'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: devices.isEmpty
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) return;
                                final device =
                                    devices.firstWhere((d) => d.id == selectedDeviceId);
                                TeknisiService.instance.createGangguanReport(
                                  deviceName: device.name,
                                  room: device.room,
                                  severity: severity,
                                  description: descriptionController.text.trim(),
                                );
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Laporan gangguan terkirim.')),
                                );
                              },
                        child: const Text('KIRIM LAPORAN'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openDetailSheet(BuildContext context, GangguanReport report) async {
    final controller = TextEditingController(text: report.resolutionNotes ?? '');

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
                '${report.deviceName} · ${report.room}',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                report.description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Catatan penanganan',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (report.status != GangguanStatus.diproses)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          TeknisiService.instance.updateGangguanStatus(
                            report.id,
                            GangguanStatus.diproses,
                          );
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('TANGANI'),
                      ),
                    ),
                  if (report.status != GangguanStatus.diproses) const SizedBox(width: 12),
                  if (report.status != GangguanStatus.selesai)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          TeknisiService.instance.updateGangguanStatus(
                            report.id,
                            GangguanStatus.selesai,
                            resolutionNotes: controller.text,
                          );
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('SELESAIKAN'),
                      ),
                    ),
                ],
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
            final reports = service.gangguanReports
                .where((g) => _filter == null || g.status == _filter)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminScreenHeader(
                        title: 'Laporan Gangguan',
                        onBack: () => Navigator.of(context).pop(),
                        trailing: IconButton(
                          onPressed: () => _openCreateSheet(context),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.accentDim,
                          tooltip: 'Laporkan gangguan baru',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.report_gmailerrorred_outlined,
                              label: 'Gangguan Terbuka',
                              value: '${service.openGangguanCount}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AdminStatCard(
                              icon: Icons.priority_high_rounded,
                              label: 'Tingkat Kritis',
                              value: '${service.criticalGangguanCount}',
                              accentColor: AppColors.danger,
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
                            ...GangguanStatus.values.map(
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
                  child: reports.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada laporan gangguan.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: reports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return _GangguanCard(
                              report: report,
                              onTap: () => _openDetailSheet(context, report),
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

class _GangguanCard extends StatelessWidget {
  final GangguanReport report;
  final VoidCallback onTap;

  const _GangguanCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.report_gmailerrorred_outlined,
                  size: 20,
                  color: report.severity.color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${report.deviceName} · ${report.room}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: report.status.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            report.status.label,
                            style: TextStyle(
                              color: report.status.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${report.severity.label} · ${AppSettings.instance.formatDateTime(report.reportedAt)}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
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