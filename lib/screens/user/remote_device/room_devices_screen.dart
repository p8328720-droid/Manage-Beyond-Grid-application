import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/usage_analytics_service.dart';
import 'package:flutter_application_1/screens/user/remote_device/add_device_sheet.dart';
import 'package:flutter_application_1/screens/user/remote_device/device_detail_screen.dart';
import 'package:flutter_application_1/widgets/device_control_widgets.dart';

class RoomDevicesScreen extends StatefulWidget {
  final String room;

  const RoomDevicesScreen({super.key, required this.room});

  @override
  State<RoomDevicesScreen> createState() => _RoomDevicesScreenState();
}

class _RoomDevicesScreenState extends State<RoomDevicesScreen> {
  Future<void> _openDevice(SmartDevice device) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceDetailScreen(device: device)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addDevice() async {
    final device = await showAddDeviceSheet(context, fixedRoom: widget.room);
    if (device != null && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final devices = DeviceService.instance.devicesInRoom(widget.room);

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
                  Expanded(
                    child: Text(
                      widget.room,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: devices.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada perangkat di ruangan ini.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: devices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return DeviceTile(
                            icon: device.type.icon,
                            name: device.name,
                            subtitle: '1 Device',
                            isOn: device.isOn,
                            onToggle: (v) {
                              setState(() => device.isOn = v);
                              UsageAnalyticsService.instance.recordToggle(device, v);
                            },
                            onTap: () => _openDevice(device),
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