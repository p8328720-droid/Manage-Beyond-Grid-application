import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/room.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/widgets/mbg_text_field.dart';
import 'package:flutter_application_1/widgets/room_widgets.dart';

Future<Room?> showAddRoomFlow(BuildContext context) {
  return showDialog<Room>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AddRoomDialog(),
  );
}

class _AddRoomDialog extends StatefulWidget {
  const _AddRoomDialog();

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  int _step = 0;
  final _nameController = TextEditingController();
  RoomBackground? _background;
  final Set<String> _selectedDeviceIds = {};
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _error = 'Nama ruangan wajib diisi');
        return;
      }
      if (RoomService.instance.byName(_nameController.text.trim()) != null) {
        setState(() => _error = 'Nama ruangan sudah digunakan');
        return;
      }
    }
    if (_step == 1 && _background == null) {
      setState(() => _error = 'Pilih background terlebih dahulu');
      return;
    }
    setState(() => _error = null);
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _step -= 1;
        _error = null;
      });
    }
  }

  void _finish() {
    final room = RoomService.instance.addRoom(
      _nameController.text.trim(),
      _background ?? RoomBackground.livingRoom,
    );
    for (final device in DeviceService.instance.all) {
      if (_selectedDeviceIds.contains(device.id)) device.room = room.name;
    }
    Navigator.of(context).pop(room);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _step == 0
                        ? 'Room Name'
                        : _step == 1
                            ? 'Pilih Background'
                            : 'Tambah Perangkat',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: SingleChildScrollView(child: _buildStep()),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12.5),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_step < 2 ? 'Continue' : 'Selesai'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(onPressed: _back, child: const Text('Back')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: MbgTextField(
            controller: _nameController,
            label: 'Nama ruangan',
            icon: Icons.meeting_room_outlined,
          ),
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final bg in RoomBackground.values)
                RoomBackgroundTile(
                  background: bg,
                  selected: _background == bg,
                  onTap: () => setState(() => _background = bg),
                ),
            ],
          ),
        );
      default:
        final devices = DeviceService.instance.all;
        if (devices.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Belum ada perangkat yang bisa ditambahkan.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              for (final device in devices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SelectableDeviceTile(
                    icon: device.type.icon,
                    label: device.name,
                    subtitle: device.room,
                    selected: _selectedDeviceIds.contains(device.id),
                    onTap: () => setState(() {
                      if (_selectedDeviceIds.contains(device.id)) {
                        _selectedDeviceIds.remove(device.id);
                      } else {
                        _selectedDeviceIds.add(device.id);
                      }
                    }),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

Future<void> showManageRoomSheet(BuildContext context, Room room) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                room.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          RoomManageOption(
            icon: Icons.drive_file_rename_outline_rounded,
            label: 'Ubah Nama Ruangan',
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await _showRenameDialog(context, room);
            },
          ),
          RoomManageOption(
            icon: Icons.image_outlined,
            label: 'Ganti Background',
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await _showBackgroundPickerDialog(context, room);
            },
          ),
          RoomManageOption(
            icon: Icons.delete_outline_rounded,
            label: 'Hapus Ruangan',
            color: AppColors.danger,
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await _confirmDeleteRoom(context, room);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _showRenameDialog(BuildContext context, Room room) async {
  final controller = TextEditingController(text: room.name);
  final newName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ubah Nama Ruangan'),
      content: MbgTextField(
        controller: controller,
        label: 'Nama ruangan',
        icon: Icons.meeting_room_outlined,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
  if (newName != null && newName.isNotEmpty) {
    RoomService.instance.renameRoom(room.id, newName);
  }
}

Future<void> _showBackgroundPickerDialog(BuildContext context, Room room) async {
  RoomBackground selected = room.background;
  final result = await showDialog<RoomBackground>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Background',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final bg in RoomBackground.values)
                    RoomBackgroundTile(
                      background: bg,
                      selected: selected == bg,
                      onTap: () => setState(() => selected = bg),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(selected),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (result != null) {
    RoomService.instance.updateBackground(room.id, result);
  }
}

Future<void> _confirmDeleteRoom(BuildContext context, Room room) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hapus Ruangan'),
      content: Text(
        'Ruangan "${room.name}" dan semua perangkat di dalamnya akan dihapus. Lanjutkan?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    RoomService.instance.deleteRoom(room.id);
  }
}