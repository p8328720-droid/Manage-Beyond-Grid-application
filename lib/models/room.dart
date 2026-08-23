import 'package:flutter/material.dart';

enum RoomBackground {
  livingRoom,
  bedroom,
  lounge,
  sunsetLounge,
  minimalStudio,
  creativeDesk;

  String get label => switch (this) {
        RoomBackground.livingRoom => 'Living Room',
        RoomBackground.bedroom => 'Bedroom',
        RoomBackground.lounge => 'Lounge',
        RoomBackground.sunsetLounge => 'Sunset Lounge',
        RoomBackground.minimalStudio => 'Minimalist Studio',
        RoomBackground.creativeDesk => 'Creative Desk',
      };

  IconData get icon => switch (this) {
        RoomBackground.livingRoom => Icons.weekend_outlined,
        RoomBackground.bedroom => Icons.bed_outlined,
        RoomBackground.lounge => Icons.chair_outlined,
        RoomBackground.sunsetLounge => Icons.wb_twilight_outlined,
        RoomBackground.minimalStudio => Icons.crop_square_outlined,
        RoomBackground.creativeDesk => Icons.computer_outlined,
      };

  List<Color> get gradient => switch (this) {
        RoomBackground.livingRoom => const [Color(0xFF3A3F47), Color(0xFF15171B)],
        RoomBackground.bedroom => const [Color(0xFF5C6B73), Color(0xFF1E252A)],
        RoomBackground.lounge => const [Color(0xFF6B5B4B), Color(0xFF221B15)],
        RoomBackground.sunsetLounge => const [Color(0xFFE08A4B), Color(0xFF291F16)],
        RoomBackground.minimalStudio => const [Color(0xFFBFC4C9), Color(0xFF3A3F44)],
        RoomBackground.creativeDesk => const [Color(0xFFE0A63A), Color(0xFF2B2110)],
      };

  String get assetPath => switch (this) {
        RoomBackground.livingRoom => 'assets/images/living room.png',
        RoomBackground.bedroom => 'assets/images/bed room.png',
        RoomBackground.lounge => 'assets/images/launge.png',
        RoomBackground.sunsetLounge => 'assets/images/susnset launge.png',
        RoomBackground.minimalStudio => 'assets/images/minimalist studio.png',
        RoomBackground.creativeDesk => 'assets/images/creative desk.png',
      };
}

class Room {
  final String id;
  String name;
  RoomBackground background;

  Room({
    required this.id,
    required this.name,
    this.background = RoomBackground.livingRoom,
  });
}