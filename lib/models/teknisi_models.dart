import 'package:flutter/material.dart';

enum TaskStatus { terjadwal, berlangsung, selesai }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.terjadwal => 'Terjadwal',
        TaskStatus.berlangsung => 'Berlangsung',
        TaskStatus.selesai => 'Selesai',
      };

  Color get color => switch (this) {
        TaskStatus.terjadwal => const Color(0xFFFFB020),
        TaskStatus.berlangsung => const Color(0xFF3D4FCB),
        TaskStatus.selesai => const Color(0xFF2FD9A0),
      };
}

enum GangguanSeverity { ringan, sedang, kritis }

extension GangguanSeverityX on GangguanSeverity {
  String get label => switch (this) {
        GangguanSeverity.ringan => 'Ringan',
        GangguanSeverity.sedang => 'Sedang',
        GangguanSeverity.kritis => 'Kritis',
      };

  Color get color => switch (this) {
        GangguanSeverity.ringan => const Color(0xFF2FD9A0),
        GangguanSeverity.sedang => const Color(0xFFFFB020),
        GangguanSeverity.kritis => const Color(0xFFE5484D),
      };
}

enum GangguanStatus { baru, diproses, selesai }

extension GangguanStatusX on GangguanStatus {
  String get label => switch (this) {
        GangguanStatus.baru => 'Baru',
        GangguanStatus.diproses => 'Diproses',
        GangguanStatus.selesai => 'Selesai',
      };

  Color get color => switch (this) {
        GangguanStatus.baru => const Color(0xFFE5484D),
        GangguanStatus.diproses => const Color(0xFF3D4FCB),
        GangguanStatus.selesai => const Color(0xFF2FD9A0),
      };
}

class MaintenanceTask {
  final String id;
  final String deviceName;
  final String room;
  DateTime scheduledAt;
  TaskStatus status;
  String? notes;
  DateTime? startedAt;
  DateTime? completedAt;

  MaintenanceTask({
    required this.id,
    required this.deviceName,
    required this.room,
    required this.scheduledAt,
    this.status = TaskStatus.terjadwal,
    this.notes,
    this.startedAt,
    this.completedAt,
  });
}

class GangguanReport {
  final String id;
  final String deviceName;
  final String room;
  final GangguanSeverity severity;
  final String description;
  final DateTime reportedAt;
  final String reportedBy;
  GangguanStatus status;
  String? resolutionNotes;
  DateTime? resolvedAt;

  GangguanReport({
    required this.id,
    required this.deviceName,
    required this.room,
    required this.severity,
    required this.description,
    required this.reportedAt,
    required this.reportedBy,
    this.status = GangguanStatus.baru,
    this.resolutionNotes,
    this.resolvedAt,
  });
}

class SensorCalibration {
  final String id;
  final String sensorName;
  final String room;
  final String unit;
  DateTime? lastCalibratedAt;
  DateTime dueAt;
  double? lastReadingBefore;
  double? lastReadingAfter;

  SensorCalibration({
    required this.id,
    required this.sensorName,
    required this.room,
    required this.unit,
    required this.dueAt,
    this.lastCalibratedAt,
    this.lastReadingBefore,
    this.lastReadingAfter,
  });

  bool get isDue => DateTime.now().isAfter(dueAt);
}

enum RepairHistoryType { maintenance, gangguan, kalibrasi }

extension RepairHistoryTypeX on RepairHistoryType {
  String get label => switch (this) {
        RepairHistoryType.maintenance => 'Maintenance',
        RepairHistoryType.gangguan => 'Perbaikan Gangguan',
        RepairHistoryType.kalibrasi => 'Kalibrasi Sensor',
      };

  IconData get icon => switch (this) {
        RepairHistoryType.maintenance => Icons.build_outlined,
        RepairHistoryType.gangguan => Icons.report_gmailerrorred_outlined,
        RepairHistoryType.kalibrasi => Icons.sensors_outlined,
      };
}

class RepairHistoryEntry {
  final RepairHistoryType type;
  final String title;
  final String subtitle;
  final String detail;
  final DateTime time;

  const RepairHistoryEntry({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.time,
  });
}