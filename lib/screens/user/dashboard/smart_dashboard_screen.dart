import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/smart_device.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_application_1/services/room_service.dart';
import 'package:flutter_application_1/services/usage_analytics_service.dart';
import 'package:flutter_application_1/screens/user/remote_device/device_detail_screen.dart';

class SmartDashboardScreen extends StatefulWidget {
  static const routeName = '/smart-dashboard';

  const SmartDashboardScreen({super.key});

  @override
  State<SmartDashboardScreen> createState() => _SmartDashboardScreenState();
}

class _SmartDashboardScreenState extends State<SmartDashboardScreen> {
  String _roomFilter = 'Semua';
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _openDevice(SmartDevice device) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceDetailScreen(device: device)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DeviceService.instance,
      builder: (context, _) {
        final service = DeviceService.instance;
        final allDevices = service.all;
        final roomNames = RoomService.instance.roomNames;
        final filters = ['Semua', ...roomNames];

        final visibleDevices = _roomFilter == 'Semua'
            ? allDevices
            : allDevices.where((d) => d.room == _roomFilter).toList();

        final grouped = <String, List<SmartDevice>>{};
        for (final device in visibleDevices) {
          grouped.putIfAbsent(device.room, () => []).add(device);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.accentDim,
              onRefresh: () async {
                service.refreshNow();
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  _DashboardHeader(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 18),
                  _LiveSummaryGrid(
                    online: service.onlineCount,
                    total: allDevices.length,
                    active: service.activeCount,
                    avgSignal: service.averageSignal,
                    attention: service.attentionCount,
                    energyToday:
                        UsageAnalyticsService.instance.totalEnergyToday,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final label = filters[index];
                        final selected = label == _roomFilter;
                        return _RoomFilterChip(
                          label: label,
                          selected: selected,
                          onTap: () => setState(() => _roomFilter = label),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (allDevices.isEmpty)
                    const _EmptyState()
                  else if (visibleDevices.isEmpty)
                    const _EmptyFilterState()
                  else
                    for (final room in grouped.keys) ...[
                      _RoomSectionHeader(
                        room: room,
                        activeCount:
                            grouped[room]!.where((d) => d.isOn).length,
                        total: grouped[room]!.length,
                      ),
                      const SizedBox(height: 10),
                      for (final device in grouped[room]!) ...[
                        _LiveDeviceCard(
                          device: device,
                          onToggle: (v) => service.setPower(device.id, v),
                          onTap: () => _openDevice(device),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _DashboardHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Seluruh perangkat, satu layar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const _LivePulse(),
      ],
    );
  }
}

class _LivePulse extends StatefulWidget {
  const _LivePulse();

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Live',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveSummaryGrid extends StatelessWidget {
  final int online;
  final int total;
  final int active;
  final double avgSignal;
  final int attention;
  final double energyToday;

  const _LiveSummaryGrid({
    required this.online,
    required this.total,
    required this.active,
    required this.avgSignal,
    required this.attention,
    required this.energyToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.72,
          children: [
            _SummaryTile(
              icon: Icons.wifi_rounded,
              label: 'Perangkat Online',
              value: '$online/$total',
              highlighted: true,
            ),
            _SummaryTile(
              icon: Icons.power_settings_new_rounded,
              label: 'Sedang Aktif',
              value: '$active',
            ),
            _SummaryTile(
              icon: Icons.signal_cellular_alt_rounded,
              label: 'Rata-rata Sinyal',
              value: total == 0 ? '—' : '${avgSignal.round()}%',
            ),
            _SummaryTile(
              icon: attention == 0
                  ? Icons.verified_outlined
                  : Icons.report_gmailerrorred_outlined,
              label: 'Perlu Perhatian',
              value: '$attention',
              warning: attention > 0,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.night,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Konsumsi energi hari ini',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${energyToday.toStringAsFixed(2)} kWh',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlighted;
  final bool warning;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlighted = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted
        ? AppColors.accent
        : warning
            ? AppColors.danger.withValues(alpha: 0.12)
            : AppColors.surfaceElevated;
    final fg = highlighted
        ? AppColors.textPrimary
        : warning
            ? AppColors.danger
            : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 20,
            color: warning
                ? AppColors.danger
                : highlighted
                    ? AppColors.textPrimary
                    : AppColors.accentDim,
          ),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: highlighted
                  ? AppColors.textPrimary.withValues(alpha: 0.75)
                  : AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoomFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.night : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomSectionHeader extends StatelessWidget {
  final String room;
  final int activeCount;
  final int total;

  const _RoomSectionHeader({
    required this.room,
    required this.activeCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            room,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
            ),
          ),
        ),
        Text(
          '$activeCount/$total aktif',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LiveDeviceCard extends StatelessWidget {
  final SmartDevice device;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  const _LiveDeviceCard({
    required this.device,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final offline = !device.isOnline;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: offline
                ? Border.all(
                    color: AppColors.danger.withValues(alpha: 0.35),
                    width: 1.2,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: device.isOn
                      ? AppColors.accent.withValues(alpha: 0.16)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  device.type.icon,
                  color: offline
                      ? AppColors.textMuted
                      : AppColors.accentDim,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusDot(online: device.isOnline),
                        const SizedBox(width: 5),
                        Text(
                          device.lastSeenLabel,
                          style: TextStyle(
                            color: offline
                                ? AppColors.danger
                                : AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (device.isOnline) ...[
                          const SizedBox(width: 8),
                          _SignalBars(quality: device.signalQuality),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: device.isOn,
                onChanged: device.isOnline ? onToggle : null,
                activeColor: Colors.white,
                activeTrackColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool online;

  const _StatusDot({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: online ? AppColors.success : AppColors.danger,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final SignalQuality quality;

  const _SignalBars({required this.quality});

  @override
  Widget build(BuildContext context) {
    final activeBars = switch (quality) {
      SignalQuality.excellent => 3,
      SignalQuality.good => 2,
      SignalQuality.weak => 1,
    };
    final color = switch (quality) {
      SignalQuality.excellent => AppColors.success,
      SignalQuality.good => AppColors.warning,
      SignalQuality.weak => AppColors.danger,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < activeBars;
        return Container(
          margin: const EdgeInsets.only(right: 2),
          width: 3,
          height: 5.0 + (index * 3),
          decoration: BoxDecoration(
            color: isActive ? color : AppColors.border,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.dashboard_customize_outlined,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Belum ada perangkat terhubung.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada perangkat di ruangan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}