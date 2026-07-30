import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/screens/user/remote_device/add_device_sheet.dart';
import 'package:flutter_application_1/screens/user/remote_device/room_devices_screen.dart';
import 'package:flutter_application_1/widgets/device_control_widgets.dart';

class RemoteDeviceControlScreen extends StatefulWidget {
  static const routeName = '/remote-device-control';

  const RemoteDeviceControlScreen({super.key});

  @override
  State<RemoteDeviceControlScreen> createState() =>
      _RemoteDeviceControlScreenState();
}

class _RemoteDeviceControlScreenState
    extends State<RemoteDeviceControlScreen> {
  Future<void> _openRoom(String room) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomDevicesScreen(room: room)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addDevice() async {
    final device = await showAddDeviceSheet(context);
    if (device != null && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final rooms = DeviceService.instance.rooms;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Remote Device Control',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Kontrol perangkat di setiap ruangan dari mana saja',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: rooms.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada ruangan atau perangkat.\nTambahkan perangkat pertamamu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          final devices = DeviceService.instance.devicesInRoom(room);
                          return RoomSummaryCard(
                            room: room,
                            deviceCount: devices.length,
                            activeCount:
                                DeviceService.instance.activeCountInRoom(room),
                            previewIcons:
                                devices.map((d) => d.type.icon).toList(),
                            onTap: () => _openRoom(room),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDevice,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Perangkat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}