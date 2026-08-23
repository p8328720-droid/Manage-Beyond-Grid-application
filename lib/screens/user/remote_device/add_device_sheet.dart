import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/widgets/device_control_widgets.dart';
import 'package:flutter_application_1/widgets/mbg_text_field.dart';

Future<SmartDevice?> showAddDeviceSheet(
  BuildContext context, {
  String? fixedRoom,
}) {
  return showModalBottomSheet<SmartDevice>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AddDeviceSheet(fixedRoom: fixedRoom),
  );
}

class AddDeviceSheet extends StatefulWidget {
  final String? fixedRoom;

  const AddDeviceSheet({super.key, this.fixedRoom});

  @override
  State<AddDeviceSheet> createState() => _AddDeviceSheetState();
}

class _AddDeviceSheetState extends State<AddDeviceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _roomController;
  DeviceType? _selectedType;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _roomController = TextEditingController(text: widget.fixedRoom ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Pilih jenis perangkat terlebih dahulu.');
      return;
    }

    final device = SmartDevice(
      id: DeviceService.instance.generateId(),
      name: _nameController.text.trim(),
      room: _roomController.text.trim(),
      type: _selectedType!,
    );
    DeviceService.instance.addDevice(device);
    RoomService.instance.ensureRoom(device.room);
    Navigator.of(context).pop(device);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = RoomService.instance.roomNames;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tambah Perangkat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 18),
                MbgTextField(
                  controller: _nameController,
                  label: 'Nama perangkat',
                  icon: Icons.edit_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                MbgTextField(
                  controller: _roomController,
                  label: 'Ruangan',
                  icon: Icons.meeting_room_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ruangan wajib diisi' : null,
                ),
                if (widget.fixedRoom == null && rooms.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final room in rooms)
                        DeviceTypeChip(
                          icon: Icons.meeting_room_outlined,
                          label: room,
                          selected: _roomController.text.trim() == room,
                          onTap: () =>
                              setState(() => _roomController.text = room),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Jenis perangkat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final type in DeviceType.values)
                      DeviceTypeChip(
                        icon: type.icon,
                        label: type.label,
                        selected: _selectedType == type,
                        onTap: () => setState(() {
                          _selectedType = type;
                          _errorMessage = null;
                        }),
                      ),
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Tambah Perangkat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}