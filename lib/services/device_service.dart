import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flutter_application_1/models/smart_device.dart';

class DeviceService extends ChangeNotifier {
  DeviceService._internal() {
    _devices.addAll(_seedDevices());
    _startRealtimeFeed();
  }
  static final DeviceService instance = DeviceService._internal();

  final List<SmartDevice> _devices = [];
  final Random _rnd = Random();
  Timer? _feedTimer;

  List<SmartDevice> get all => List.unmodifiable(_devices);

  List<String> get rooms {
    final seen = <String>[];
    for (final d in _devices) {
      if (!seen.contains(d.room)) seen.add(d.room);
    }
    return seen;
  }

  List<SmartDevice> devicesInRoom(String room) =>
      _devices.where((d) => d.room == room).toList();

  int activeCountInRoom(String room) =>
      devicesInRoom(room).where((d) => d.isOn).length;

  int get onlineCount => _devices.where((d) => d.isOnline).length;

  int get activeCount => _devices.where((d) => d.isOn).length;

  int get attentionCount => _devices.where((d) => d.needsAttention).length;

  double get averageSignal {
    final online = _devices.where((d) => d.isOnline).toList();
    if (online.isEmpty) return 0;
    final total = online.fold<int>(0, (sum, d) => sum + d.signalStrength);
    return total / online.length;
  }

  void addDevice(SmartDevice device) {
    _devices.add(device);
    notifyListeners();
  }

  void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void removeDevicesInRoom(String room) {
    _devices.removeWhere((d) => d.room == room);
    notifyListeners();
  }

  void setPower(String id, bool value) {
    final device = _devices.firstWhere((d) => d.id == id);
    device.isOn = value;
    if (value && !device.isOnline) {
      device.isOnline = true;
      device.signalStrength = 55 + _rnd.nextInt(35);
    }
    device.lastSeen = DateTime.now();
    notifyListeners();
  }

  String generateId() => 'dev-${DateTime.now().microsecondsSinceEpoch}';

  void refreshNow() => _tick();

  void _startRealtimeFeed() {
    _feedTimer?.cancel();
    _feedTimer = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  void _tick() {
    if (_devices.isEmpty) return;

    for (final device in _devices) {
      if (device.isOnline) {
        device.lastSeen = DateTime.now();

        if (device.isOn) {
          final drift = _rnd.nextInt(9) - 4;
          device.signalStrength =
              (device.signalStrength + drift).clamp(10, 100).toInt();
        }

        if (_rnd.nextDouble() < 0.03) {
          device.isOnline = false;
        }
      } else {
        if (_rnd.nextDouble() < 0.4) {
          device.isOnline = true;
          device.signalStrength = 50 + _rnd.nextInt(45);
          device.lastSeen = DateTime.now();
        }
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _feedTimer?.cancel();
    super.dispose();
  }

  static List<SmartDevice> _seedDevices() {
    return [
      SmartDevice(
        id: 'dev-tv-1',
        name: 'Smart tv',
        room: 'Living Room',
        type: DeviceType.tv,
        isOn: true,
        level: 40,
        channel: 5,
        muted: true,
        signalStrength: 92,
      ),
      SmartDevice(
        id: 'dev-ac-1',
        name: 'Air Conditioner',
        room: 'Living Room',
        type: DeviceType.ac,
        isOn: true,
        temperature: 24,
        signalStrength: 78,
      ),
      SmartDevice(
        id: 'dev-lamp-1',
        name: 'Lamp',
        room: 'Living Room',
        type: DeviceType.lamp,
        isOn: true,
        level: 40,
        signalStrength: 88,
      ),
      SmartDevice(
        id: 'dev-fan-1',
        name: 'Kipas Kamar',
        room: 'Kamar Tidur',
        type: DeviceType.fan,
        isOn: false,
        level: 55,
        isOnline: false,
        signalStrength: 20,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 47)),
      ),
    ];
  }
}