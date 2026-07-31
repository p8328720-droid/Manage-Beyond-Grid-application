import 'package:flutter/foundation.dart';

import '../models/teknisi_models.dart';
import 'audit_log_service.dart';
import 'auth_service.dart';
import 'device_service.dart';

class TeknisiService extends ChangeNotifier {
  TeknisiService._internal() {
    _seed();
  }
  static final TeknisiService instance = TeknisiService._internal();

  final List<MaintenanceTask> _maintenanceTasks = [];
  final List<GangguanReport> _gangguanReports = [];
  final List<SensorCalibration> _calibrations = [];

  List<MaintenanceTask> get maintenanceTasks {
    final list = List<MaintenanceTask>.from(_maintenanceTasks);
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return List.unmodifiable(list);
  }

  List<GangguanReport> get gangguanReports {
    final list = List<GangguanReport>.from(_gangguanReports);
    list.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return List.unmodifiable(list);
  }

  List<SensorCalibration> get calibrations {
    final list = List<SensorCalibration>.from(_calibrations);
    list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return List.unmodifiable(list);
  }

  int get pendingMaintenanceCount =>
      _maintenanceTasks.where((t) => t.status != TaskStatus.selesai).length;

  int get maintenanceDoneTodayCount {
    final now = DateTime.now();
    return _maintenanceTasks
        .where((t) =>
            t.completedAt != null &&
            t.completedAt!.year == now.year &&
            t.completedAt!.month == now.month &&
            t.completedAt!.day == now.day)
        .length;
  }

  int get openGangguanCount =>
      _gangguanReports.where((g) => g.status != GangguanStatus.selesai).length;

  int get criticalGangguanCount => _gangguanReports
      .where((g) =>
          g.status != GangguanStatus.selesai &&
          g.severity == GangguanSeverity.kritis)
      .length;

  int get dueCalibrationCount => _calibrations.where((c) => c.isDue).length;

  int get totalCalibrationCount => _calibrations.length;

  List<RepairHistoryEntry> get repairHistory {
    final entries = <RepairHistoryEntry>[];

    for (final t in _maintenanceTasks) {
      if (t.status == TaskStatus.selesai && t.completedAt != null) {
        entries.add(RepairHistoryEntry(
          type: RepairHistoryType.maintenance,
          title: '${t.deviceName} · ${t.room}',
          subtitle: (t.notes != null && t.notes!.isNotEmpty)
              ? t.notes!
              : 'Maintenance terjadwal selesai dilakukan.',
          detail: 'Dijadwalkan ${_shortDate(t.scheduledAt)}',
          time: t.completedAt!,
        ));
      }
    }

    for (final g in _gangguanReports) {
      if (g.status == GangguanStatus.selesai && g.resolvedAt != null) {
        entries.add(RepairHistoryEntry(
          type: RepairHistoryType.gangguan,
          title: '${g.deviceName} · ${g.room}',
          subtitle: (g.resolutionNotes != null && g.resolutionNotes!.isNotEmpty)
              ? g.resolutionNotes!
              : g.description,
          detail: 'Tingkat: ${g.severity.label}',
          time: g.resolvedAt!,
        ));
      }
    }

    for (final c in _calibrations) {
      if (c.lastCalibratedAt != null) {
        entries.add(RepairHistoryEntry(
          type: RepairHistoryType.kalibrasi,
          title: '${c.sensorName} · ${c.room}',
          subtitle: (c.lastReadingBefore != null && c.lastReadingAfter != null)
              ? 'Pembacaan ${c.lastReadingBefore} ${c.unit} -> ${c.lastReadingAfter} ${c.unit}'
              : 'Kalibrasi selesai dilakukan.',
          detail: 'Jadwal berikutnya ${_shortDate(c.dueAt)}',
          time: c.lastCalibratedAt!,
        ));
      }
    }

    entries.sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(entries);
  }

  String get _actor => AuthService.instance.currentUser?.name ?? 'Teknisi';

  void startMaintenance(String id) {
    final task = _maintenanceTasks.firstWhere((t) => t.id == id);
    task.status = TaskStatus.berlangsung;
    task.startedAt = DateTime.now();
    notifyListeners();
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.sistem,
      action: 'Memulai maintenance',
      detail: '${task.deviceName} (${task.room}).',
    );
  }

  void completeMaintenance(String id, {String? notes}) {
    final task = _maintenanceTasks.firstWhere((t) => t.id == id);
    task.status = TaskStatus.selesai;
    task.completedAt = DateTime.now();
    if (notes != null && notes.trim().isNotEmpty) task.notes = notes.trim();
    notifyListeners();
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.sistem,
      action: 'Menyelesaikan maintenance',
      detail: '${task.deviceName} (${task.room}).',
    );
  }

  GangguanReport createGangguanReport({
    required String deviceName,
    required String room,
    required GangguanSeverity severity,
    required String description,
  }) {
    final report = GangguanReport(
      id: 'gg-${DateTime.now().microsecondsSinceEpoch}',
      deviceName: deviceName,
      room: room,
      severity: severity,
      description: description,
      reportedAt: DateTime.now(),
      reportedBy: _actor,
    );
    _gangguanReports.add(report);
    notifyListeners();
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.sistem,
      action: 'Melaporkan gangguan',
      detail: '$deviceName ($room) - ${severity.label}.',
    );
    return report;
  }

  void updateGangguanStatus(
    String id,
    GangguanStatus status, {
    String? resolutionNotes,
  }) {
    final report = _gangguanReports.firstWhere((g) => g.id == id);
    report.status = status;
    if (status == GangguanStatus.selesai) {
      report.resolvedAt = DateTime.now();
      if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty) {
        report.resolutionNotes = resolutionNotes.trim();
      }
    }
    notifyListeners();
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.sistem,
      action: 'Memperbarui status gangguan',
      detail: '${report.deviceName} (${report.room}) menjadi ${status.label}.',
    );
  }

  void calibrateSensor(
    String id, {
    double? readingBefore,
    double? readingAfter,
  }) {
    final sensor = _calibrations.firstWhere((c) => c.id == id);
    sensor.lastCalibratedAt = DateTime.now();
    sensor.dueAt = DateTime.now().add(const Duration(days: 30));
    sensor.lastReadingBefore = readingBefore;
    sensor.lastReadingAfter = readingAfter;
    notifyListeners();
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.sistem,
      action: 'Mengkalibrasi sensor',
      detail: '${sensor.sensorName} (${sensor.room}).',
    );
  }

  String _shortDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  void _seed() {
    final devices = DeviceService.instance.all;
    final now = DateTime.now();

    String deviceNameAt(int index, String fallback) =>
        devices.length > index ? devices[index].name : fallback;
    String roomAt(int index, String fallback) =>
        devices.length > index ? devices[index].room : fallback;

    _maintenanceTasks.addAll([
      MaintenanceTask(
        id: 'mt-001',
        deviceName: deviceNameAt(0, 'Smart TV'),
        room: roomAt(0, 'Living Room'),
        scheduledAt: now.add(const Duration(days: 1)),
      ),
      MaintenanceTask(
        id: 'mt-002',
        deviceName: deviceNameAt(1, 'Air Conditioner'),
        room: roomAt(1, 'Living Room'),
        scheduledAt: now.subtract(const Duration(hours: 3)),
        status: TaskStatus.berlangsung,
        startedAt: now.subtract(const Duration(hours: 2)),
      ),
      MaintenanceTask(
        id: 'mt-003',
        deviceName: deviceNameAt(3, 'Kipas Kamar'),
        room: roomAt(3, 'Kamar Tidur'),
        scheduledAt: now.subtract(const Duration(days: 2)),
        status: TaskStatus.selesai,
        startedAt: now.subtract(const Duration(days: 2, hours: 1)),
        completedAt: now.subtract(const Duration(days: 2)),
        notes: 'Pembersihan kipas dan pengecekan baling-baling.',
      ),
      MaintenanceTask(
        id: 'mt-004',
        deviceName: deviceNameAt(2, 'Lamp'),
        room: roomAt(2, 'Living Room'),
        scheduledAt: now.add(const Duration(days: 3)),
      ),
    ]);

    _gangguanReports.addAll([
      GangguanReport(
        id: 'gg-001',
        deviceName: deviceNameAt(1, 'Air Conditioner'),
        room: roomAt(1, 'Living Room'),
        severity: GangguanSeverity.kritis,
        description: 'Perangkat tidak merespons perintah remote maupun aplikasi.',
        reportedAt: now.subtract(const Duration(hours: 6)),
        reportedBy: 'Teknisi MBG',
      ),
      GangguanReport(
        id: 'gg-002',
        deviceName: deviceNameAt(0, 'Smart TV'),
        room: roomAt(0, 'Living Room'),
        severity: GangguanSeverity.sedang,
        description: 'Koneksi jaringan sering terputus saat streaming.',
        reportedAt: now.subtract(const Duration(days: 1, hours: 4)),
        reportedBy: 'Teknisi MBG',
        status: GangguanStatus.diproses,
      ),
      GangguanReport(
        id: 'gg-003',
        deviceName: deviceNameAt(3, 'Kipas Kamar'),
        room: roomAt(3, 'Kamar Tidur'),
        severity: GangguanSeverity.ringan,
        description: 'Suara berisik pada kecepatan tinggi.',
        reportedAt: now.subtract(const Duration(days: 4)),
        reportedBy: 'Teknisi MBG',
        status: GangguanStatus.selesai,
        resolvedAt: now.subtract(const Duration(days: 3)),
        resolutionNotes: 'Mengganti bearing motor kipas.',
      ),
    ]);

    _calibrations.addAll([
      SensorCalibration(
        id: 'cal-001',
        sensorName: 'Sensor Suhu',
        room: 'Living Room',
        unit: '°C',
        dueAt: now.subtract(const Duration(days: 2)),
        lastCalibratedAt: now.subtract(const Duration(days: 32)),
        lastReadingBefore: 24.8,
        lastReadingAfter: 24.0,
      ),
      SensorCalibration(
        id: 'cal-002',
        sensorName: 'Sensor Kelembaban',
        room: 'Kamar Tidur',
        unit: '%RH',
        dueAt: now.add(const Duration(days: 12)),
        lastCalibratedAt: now.subtract(const Duration(days: 18)),
        lastReadingBefore: 61.0,
        lastReadingAfter: 60.0,
      ),
      SensorCalibration(
        id: 'cal-003',
        sensorName: 'Sensor Arus Listrik',
        room: 'Panel Utama',
        unit: 'A',
        dueAt: now.add(const Duration(days: 5)),
      ),
      SensorCalibration(
        id: 'cal-004',
        sensorName: 'Sensor Gerak',
        room: 'Koridor',
        unit: 'lux',
        dueAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }
}