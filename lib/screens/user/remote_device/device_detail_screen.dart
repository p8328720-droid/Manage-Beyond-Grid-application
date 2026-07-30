import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/widgets/device_control_widgets.dart';
import 'package:flutter_application_1/widgets/device_sliders.dart';

class DeviceDetailScreen extends StatefulWidget {
  final SmartDevice device;

  DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  SmartDevice get _device => widget.device;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          _device.room,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                  SizedBox(height: 18),
                  DeviceHeaderCard(
                    icon: _device.type.icon,
                    name: _device.name,
                    subtitle: '1 Device',
                    isOn: _device.isOn,
                    onToggle: (v) {
                      AppSettings.instance.feedback();
                      setState(() => _device.isOn = v);
                    },
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: _buildControls(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    switch (_device.type) {
      case DeviceType.tv:
        return _TvControls(device: _device, onChanged: () => setState(() {}));
      case DeviceType.ac:
        return _AcControls(device: _device, onChanged: () => setState(() {}));
      case DeviceType.lamp:
        return _LampControls(device: _device, onChanged: () => setState(() {}));
      case DeviceType.fan:
      case DeviceType.speaker:
      case DeviceType.other:
        return _GenericLevelControls(
          device: _device,
          onChanged: () => setState(() {}),
        );
    }
  }
}

class _TvControls extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onChanged;

  _TvControls({required this.device, required this.onChanged});

  void _setChannel(int delta) {
    device.channel = (device.channel + delta).clamp(1, 999);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleStepButton(icon: Icons.remove, onTap: () => _setChannel(-1)),
            Column(
              children: [
                Text(
                  '${device.channel}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
                Text(
                  'Channel',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            CircleStepButton(icon: Icons.add, onTap: () => _setChannel(1)),
          ],
        ),
        SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Volume',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
        ),
        SizedBox(height: 10),
        PercentDragBar(
          value: device.level / 100,
          label: '${device.level}%',
          onChanged: (p) {
            device.level = (p * 100).round();
            onChanged();
          },
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ToggleActionCard(
                icon: Icons.volume_off_outlined,
                label: 'Mute',
                value: device.muted,
                onChanged: (v) {
                  device.muted = v;
                  onChanged();
                },
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: ToggleActionCard(
                icon: Icons.cast_outlined,
                label: 'Cast',
                value: device.casting,
                onChanged: (v) {
                  device.casting = v;
                  onChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AcControls extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onChanged;

  static int _minTemp = 16;
  static int _maxTemp = 30;

  _AcControls({required this.device, required this.onChanged});

  void _setSwing(SwingMode mode) {
    device.swingMode = device.swingMode == mode ? null : mode;
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final range = (_maxTemp - _minTemp).toDouble();
    final percent = (device.temperature - _minTemp) / range;
    final displayTemp = settings.celsiusToDisplay(device.temperature);
    final unitLabel = settings.tempUnit == 'f' ? 'Fahrenheit' : 'Celsius';

    return Column(
      children: [
        SizedBox(height: 28),
        Column(
          children: [
            Text(
              '$displayTemp°',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 56,
                height: 1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              unitLabel,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 28),
        PercentDragBar(
          value: percent,
          label: '$displayTemp°',
          onChanged: (p) {
            device.temperature = (_minTemp + p * range).round();
            onChanged();
          },
        ),
        SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Swing',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            SwingOptionCard(
              icon: Icons.height_rounded,
              label: 'Vertikal',
              selected: device.swingMode == SwingMode.vertical,
              onTap: () => _setSwing(SwingMode.vertical),
            ),
            SizedBox(width: 14),
            SwingOptionCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Horizontal',
              selected: device.swingMode == SwingMode.horizontal,
              onTap: () => _setSwing(SwingMode.horizontal),
            ),
          ],
        ),
      ],
    );
  }
}

class _LampControls extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onChanged;

  _LampControls({required this.device, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32),
        Center(
          child: SizedBox(
            height: 340,
            width: 190,
            child: VerticalPercentDragBar(
              value: device.level / 100,
              label: '${device.level}%',
              onChanged: (p) {
                device.level = (p * 100).round();
                onChanged();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GenericLevelControls extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onChanged;

  _GenericLevelControls({required this.device, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = device.type == DeviceType.fan
        ? 'Kecepatan'
        : device.type == DeviceType.speaker
            ? 'Volume'
            : 'Level';

    return Column(
      children: [
        SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
        ),
        SizedBox(height: 10),
        PercentDragBar(
          value: device.level / 100,
          label: '${device.level}%',
          onChanged: (p) {
            device.level = (p * 100).round();
            onChanged();
          },
        ),
      ],
    );
  }
}