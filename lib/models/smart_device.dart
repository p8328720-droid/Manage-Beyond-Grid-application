import 'package:flutter/material.dart';

enum DeviceType { tv, ac, lamp, fan, speaker, other }

extension DeviceTypeX on DeviceType {
  String get label => switch (this) {
        DeviceType.tv => 'Smart TV',
        DeviceType.ac => 'Air Conditioner',
        DeviceType.lamp => 'Lamp',
        DeviceType.fan => 'Fan',
        DeviceType.speaker => 'Speaker',
        DeviceType.other => 'Perangkat Lain',
      };

  IconData get icon => switch (this) {
        DeviceType.tv => Icons.tv_outlined,
        DeviceType.ac => Icons.air_outlined,
        DeviceType.lamp => Icons.lightbulb_outline,
        DeviceType.fan => Icons.cyclone,
        DeviceType.speaker => Icons.speaker,
        DeviceType.other => Icons.devices_other,
      };
}

enum SwingMode { vertical, horizontal }

class SmartDevice {
  final String id;
  String name;
  String room;
  DeviceType type;
  bool isOn;

  int level;

  int channel;
  bool muted;
  bool casting;

  int temperature;
  SwingMode? swingMode;

  bool isOnline;
  int signalStrength;
  DateTime lastSeen;

  SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    this.isOn = true,
    this.level = 40,
    this.channel = 1,
    this.muted = false,
    this.casting = false,
    this.temperature = 24,
    this.swingMode,
    this.isOnline = true,
    this.signalStrength = 80,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();
}

enum SignalQuality { excellent, good, weak }

extension SmartDeviceStatusX on SmartDevice {
  SignalQuality get signalQuality {
    if (signalStrength >= 70) return SignalQuality.excellent;
    if (signalStrength >= 35) return SignalQuality.good;
    return SignalQuality.weak;
  }

  bool get needsAttention => !isOnline || signalQuality == SignalQuality.weak;

  String get lastSeenLabel {
    if (isOnline) return 'Online';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inSeconds < 60) return 'Terputus ${diff.inSeconds} dtk lalu';
    if (diff.inMinutes < 60) return 'Terputus ${diff.inMinutes} mnt lalu';
    return 'Terputus ${diff.inHours} jam lalu';
  }
}