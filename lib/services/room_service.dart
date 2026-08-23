import 'package:flutter_application_1/models/room.dart';
import 'package:flutter_application_1/services/device_service.dart';

class RoomService {
  RoomService._internal() {
    _rooms.addAll(_seedRooms());
  }
  static final RoomService instance = RoomService._internal();

  final List<Room> _rooms = [];

  List<Room> get rooms => List.unmodifiable(_rooms);

  List<String> get roomNames => _rooms.map((r) => r.name).toList();

  Room? byName(String name) {
    for (final r in _rooms) {
      if (r.name == name) return r;
    }
    return null;
  }

  Room ensureRoom(String name, {RoomBackground background = RoomBackground.livingRoom}) {
    final existing = byName(name);
    if (existing != null) return existing;
    final room = Room(id: generateId(), name: name, background: background);
    _rooms.add(room);
    return room;
  }

  Room addRoom(String name, RoomBackground background) {
    final room = Room(id: generateId(), name: name, background: background);
    _rooms.add(room);
    return room;
  }

  void renameRoom(String id, String newName) {
    final room = _rooms.firstWhere((r) => r.id == id);
    final oldName = room.name;
    room.name = newName;
    for (final device in DeviceService.instance.all) {
      if (device.room == oldName) device.room = newName;
    }
  }

  void updateBackground(String id, RoomBackground background) {
    _rooms.firstWhere((r) => r.id == id).background = background;
  }

  void deleteRoom(String id) {
    final room = _rooms.firstWhere((r) => r.id == id);
    DeviceService.instance.removeDevicesInRoom(room.name);
    _rooms.removeWhere((r) => r.id == id);
  }

  String generateId() => 'room-${DateTime.now().microsecondsSinceEpoch}';

  static List<Room> _seedRooms() => [
        Room(id: 'room-living', name: 'Living Room', background: RoomBackground.livingRoom),
        Room(id: 'room-bedroom', name: 'Kamar Tidur', background: RoomBackground.bedroom),
      ];
}