import 'package:flutter_application_1/models/smart_device.dart';

class DeviceService {
  DeviceService._internal() {
    _devices.addAll(_seedDevices());
  }
  static final DeviceService instance = DeviceService._internal();

  final List<SmartDevice> _devices = [];

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

  void addDevice(SmartDevice device) {
    _devices.add(device);
  }

  void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
  }

  void removeDevicesInRoom(String room) {
    _devices.removeWhere((d) => d.room == room);
  }

  String generateId() => 'dev-${DateTime.now().microsecondsSinceEpoch}';

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
      ),
      SmartDevice(
        id: 'dev-ac-1',
        name: 'Air Conditioner',
        room: 'Living Room',
        type: DeviceType.ac,
        isOn: true,
        temperature: 24,
      ),
      SmartDevice(
        id: 'dev-lamp-1',
        name: 'Lamp',
        room: 'Living Room',
        type: DeviceType.lamp,
        isOn: true,
        level: 40,
      ),
      SmartDevice(
        id: 'dev-fan-1',
        name: 'Kipas Kamar',
        room: 'Kamar Tidur',
        type: DeviceType.fan,
        isOn: false,
        level: 55,
      ),
    ];
  }
}