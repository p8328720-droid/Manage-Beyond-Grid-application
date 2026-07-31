import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'device_service.dart';

class SystemMonitoringService extends ChangeNotifier {
  SystemMonitoringService._();
  static final SystemMonitoringService instance = SystemMonitoringService._();

  final DateTime _startedAt = DateTime.now();
  final Random _random = Random();
  Timer? _timer;

  double cpuUsage = 32;
  double memoryUsage = 48;
  double networkLatencyMs = 40;

  final List<double> cpuHistory = [];
  final List<double> memoryHistory = [];

  bool get isRunning => _timer != null;

  Duration get uptime => DateTime.now().difference(_startedAt);

  int get totalUsers => AuthService.instance.allUsers.length;

  int get activeUsers =>
      AuthService.instance.allUsers.where((u) => u.isActive).length;

  int get inactiveUsers => totalUsers - activeUsers;

  int get totalDevices => DeviceService.instance.all.length;

  int get devicesOnline =>
      DeviceService.instance.all.where((d) => d.isOn).length;

  void start() {
    if (_timer != null) return;
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    cpuUsage = _walk(cpuUsage, minValue: 12, maxValue: 92);
    memoryUsage = _walk(memoryUsage, minValue: 20, maxValue: 88);
    networkLatencyMs = _walk(networkLatencyMs, minValue: 15, maxValue: 180);

    _pushHistory(cpuHistory, cpuUsage);
    _pushHistory(memoryHistory, memoryUsage);

    notifyListeners();
  }

  double _walk(double current, {required double minValue, required double maxValue}) {
    final delta = (_random.nextDouble() - 0.5) * 14;
    return (current + delta).clamp(minValue, maxValue).toDouble();
  }

  void _pushHistory(List<double> history, double value) {
    history.add(value);
    if (history.length > 16) history.removeAt(0);
  }

  String get healthLabel {
    if (cpuUsage > 85 || memoryUsage > 85) return 'Kritis';
    if (cpuUsage > 65 || memoryUsage > 65) return 'Waspada';
    return 'Normal';
  }
}
