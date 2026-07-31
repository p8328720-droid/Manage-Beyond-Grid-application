import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/smart_device.dart';
import 'audit_log_service.dart';
import 'auth_service.dart';
import 'device_service.dart';

class DeviceUsageStat {
  final String deviceId;
  final String deviceName;
  final String room;
  final DeviceType type;
  final List<double> dailyEnergyKwh;
  final List<double> dailyActiveHours;

  const DeviceUsageStat({
    required this.deviceId,
    required this.deviceName,
    required this.room,
    required this.type,
    required this.dailyEnergyKwh,
    required this.dailyActiveHours,
  });

  double get energyToday => dailyEnergyKwh.last;
  double get activeHoursToday => dailyActiveHours.last;
  double get energyWeekTotal => dailyEnergyKwh.fold(0.0, (a, b) => a + b);
}

class UsageActivityEntry {
  final String deviceName;
  final String room;
  final bool turnedOn;
  final DateTime time;

  const UsageActivityEntry({
    required this.deviceName,
    required this.room,
    required this.turnedOn,
    required this.time,
  });
}

class UsageAnalyticsService extends ChangeNotifier {
  UsageAnalyticsService._internal() {
    _seed();
  }
  static final UsageAnalyticsService instance = UsageAnalyticsService._internal();

  final List<DeviceUsageStat> _stats = [];
  final List<UsageActivityEntry> _activity = [];

  List<DeviceUsageStat> get stats => List.unmodifiable(_stats);

  List<UsageActivityEntry> get activity {
    final list = List<UsageActivityEntry>.from(_activity);
    list.sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  List<double> get weeklyEnergyTotals {
    final totals = List<double>.filled(7, 0);
    for (final stat in _stats) {
      for (var i = 0; i < 7; i++) {
        totals[i] += stat.dailyEnergyKwh[i];
      }
    }
    return totals;
  }

  double get totalEnergyToday => _stats.fold(0.0, (sum, s) => sum + s.energyToday);

  double get totalEnergyWeek => _stats.fold(0.0, (sum, s) => sum + s.energyWeekTotal);

  double get totalActiveHoursToday =>
      _stats.fold(0.0, (sum, s) => sum + s.activeHoursToday);

  int get onlineDeviceCount => DeviceService.instance.all.where((d) => d.isOn).length;

  int get totalDeviceCount => DeviceService.instance.all.length;

  DeviceUsageStat? get topEnergyConsumer {
    if (_stats.isEmpty) return null;
    return _stats.reduce((a, b) => a.energyToday >= b.energyToday ? a : b);
  }

  void recordToggle(SmartDevice device, bool isOn) {
    _activity.insert(
      0,
      UsageActivityEntry(
        deviceName: device.name,
        room: device.room,
        turnedOn: isOn,
        time: DateTime.now(),
      ),
    );
    if (_activity.length > 200) {
      _activity.removeRange(200, _activity.length);
    }
    notifyListeners();

    AuditLogService.instance.log(
      actor: AuthService.instance.currentUser?.name ?? 'Pengguna',
      category: AuditCategory.sistem,
      action: isOn ? 'Menyalakan perangkat' : 'Mematikan perangkat',
      detail: '${device.name} (${device.room}).',
    );
  }

  void _seed() {
    final devices = DeviceService.instance.all;
    final now = DateTime.now();

    for (final device in devices) {
      final rnd = Random(device.id.hashCode);
      final energyRange = _energyRangeFor(device.type);
      final hoursRange = _hoursRangeFor(device.isOn);

      _stats.add(
        DeviceUsageStat(
          deviceId: device.id,
          deviceName: device.name,
          room: device.room,
          type: device.type,
          dailyEnergyKwh: List.generate(
            7,
            (_) => double.parse(
              (energyRange.$1 + rnd.nextDouble() * (energyRange.$2 - energyRange.$1))
                  .toStringAsFixed(2),
            ),
          ),
          dailyActiveHours: List.generate(
            7,
            (_) => double.parse(
              (hoursRange.$1 + rnd.nextDouble() * (hoursRange.$2 - hoursRange.$1))
                  .toStringAsFixed(1),
            ),
          ),
        ),
      );
    }

    for (var i = 0; i < devices.length && i < 3; i++) {
      final device = devices[i];
      _activity.add(
        UsageActivityEntry(
          deviceName: device.name,
          room: device.room,
          turnedOn: device.isOn,
          time: now.subtract(Duration(hours: 2 + i * 3)),
        ),
      );
    }
  }

  (double, double) _energyRangeFor(DeviceType type) {
    switch (type) {
      case DeviceType.ac:
        return (1.2, 2.6);
      case DeviceType.tv:
        return (0.3, 0.7);
      case DeviceType.fan:
        return (0.1, 0.3);
      case DeviceType.lamp:
        return (0.05, 0.15);
      case DeviceType.speaker:
        return (0.05, 0.2);
      case DeviceType.other:
        return (0.1, 0.4);
    }
  }

  (double, double) _hoursRangeFor(bool isOn) {
    return isOn ? (5, 14) : (0.5, 4);
  }
}