import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/user/dashboard/smart_dashboard_screen.dart';
import 'package:flutter_application_1/screens/user/insights/ai_insights_screen.dart';
import 'package:flutter_application_1/screens/user/profile/profile_tab.dart';
import 'package:flutter_application_1/screens/user/remote_device/remote_device_control_screen.dart';
import 'package:flutter_application_1/screens/user/banner_preview_screen.dart';
import 'package:flutter_application_1/screens/user/reports/reports_tab.dart';
import 'package:flutter_application_1/services/ai_insight_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/user-home';

  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _navIndex = 0;
  bool _cloudSyncEnabled = true;

  AppUser? get _user => AuthService.instance.currentUser;

  bool get _alertEnabled => _user?.pushNotificationsEnabled ?? true;

  void _logout() {
    AuthService.instance.logout();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.name ?? 'Pengguna';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _navIndex == 2
            ? ProfileTab(onLogout: _logout)
            : _navIndex == 1
            ? const ReportsTab()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderBar(
                      name: name,
                      onTapProfile: () => setState(() => _navIndex = 2),
                    ),
                    const SizedBox(height: 18),
                    const _InternetImagePair(),
                    const SizedBox(height: 22),
                    const _StatusChips(),
                    const SizedBox(height: 28),
                    const _SectionTitle('Status Sistem'),
                    const SizedBox(height: 12),
                    _ToggleRow(
                      icon: Icons.cloud_sync_outlined,
                      label: 'Cloud Synchronization',
                      subtitle: 'Sinkronisasi data perangkat otomatis',
                      value: _cloudSyncEnabled,
                      onChanged: (v) => setState(() => _cloudSyncEnabled = v),
                    ),
                    const SizedBox(height: 12),
                    _ToggleRow(
                      icon: Icons.notifications_active_outlined,
                      label: 'Smart Alert & Notification',
                      subtitle: 'Notifikasi kondisi penting secara real-time',
                      value: _alertEnabled,
                      onChanged: (v) => setState(
                        () => AuthService.instance.updatePushNotifications(v),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Kelola & Pantau'),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.98,
                      children: [
                        _FeatureCard(
                          icon: Icons.dashboard_outlined,
                          title: 'Smart Dashboard',
                          subtitle: 'Semua status perangkat, satu layar',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SmartDashboardScreen(),
                            ),
                          ),
                        ),
                        _FeatureCard(
                          icon: Icons.settings_remote_outlined,
                          title: 'Remote Device Control',
                          subtitle: 'Kontrol perangkat dari mana saja',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RemoteDeviceControlScreen(),
                            ),
                          ),
                        ),
                        ListenableBuilder(
                          listenable: AiInsightService.instance,
                          builder: (context, _) {
                            final alerts =
                                AiInsightService.instance.criticalCount +
                                AiInsightService.instance.warningCount;
                            return _FeatureCard(
                              icon: Icons.insights_outlined,
                              title: 'AI Smart Insights',
                              subtitle: 'Deteksi & prediksi gangguan otomatis',
                              badgeCount: alerts,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AiInsightsScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                        _FeatureCard(
                          icon: Icons.photo_library_outlined,
                          title: 'Banner Preview',
                          subtitle: 'Lihat semua asset ruangan yang tersedia',
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(BannerPreviewScreen.routeName),
                        ),
                        _FeatureCard(
                          icon: Icons.bar_chart_outlined,
                          title: 'Analytics & Reports',
                          subtitle: 'Grafik energi & riwayat aktivitas',
                          onTap: () => setState(() => _navIndex = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _navIndex,
        onSelect: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final String name;
  final VoidCallback onTapProfile;

  const _HeaderBar({required this.name, required this.onTapProfile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang di MBG',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTapProfile,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips();

  @override
  Widget build(BuildContext context) {
    const items = [
      _StatusChipData(
        icon: Icons.developer_board,
        label: 'Perangkat Aktif',
        value: '8',
      ),
      _StatusChipData(
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Peringatan',
        value: '2',
      ),
      _StatusChipData(
        icon: Icons.cloud_done_outlined,
        label: 'Tersinkron',
        value: 'Live',
      ),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final highlighted = index == 0;
          return Container(
            width: 132,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: highlighted ? AppColors.accent : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: highlighted
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                Text(
                  item.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  item.label,
                  style: TextStyle(
                    color: highlighted
                        ? AppColors.textPrimary.withValues(alpha: 0.75)
                        : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusChipData {
  final IconData icon;
  final String label;
  final String value;

  const _StatusChipData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.accentDim),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.accentDim, size: 22),
                  ),
                  if (badgeCount > 0) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _BottomNavBar({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.night,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _NavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Laporan',
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.night : Colors.white70,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.night,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InternetImagePair extends StatelessWidget {
  const _InternetImagePair();

  static const _images = [
    'https://images.unsplash.com/photo-1558008258-3256797b43f3?w=900&q=80',
    'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=900&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Row(
        children: [
          for (var index = 0; index < _images.length; index++) ...[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceElevated,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
            if (index == 0) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}
