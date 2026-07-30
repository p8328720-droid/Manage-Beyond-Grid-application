import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
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
  bool _alertEnabled = true;

  AppUser? get _user => AuthService.instance.currentUser;

  void _logout() {
    AuthService.instance.logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (_) => false,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — segera hadir')),
    );
  }

  void _openProfileSheet() {
    final user = _user;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
        name: user?.name ?? 'Pengguna',
        email: user?.email ?? '-',
        roleLabel: user?.role.label ?? UserRole.pengguna.label,
        onLogout: () {
          Navigator.of(context).pop();
          _logout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.name ?? 'Pengguna';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderBar(name: name, onTapProfile: _openProfileSheet),
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
                onChanged: (v) => setState(() => _alertEnabled = v),
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
                    onTap: () => _showComingSoon('Smart Dashboard'),
                  ),
                  _FeatureCard(
                    icon: Icons.settings_remote_outlined,
                    title: 'Remote Device Control',
                    subtitle: 'Kontrol perangkat dari mana saja',
                    onTap: () => _showComingSoon('Remote Device Control'),
                  ),
                  _FeatureCard(
                    icon: Icons.insights_outlined,
                    title: 'AI Smart Insights',
                    subtitle: 'Deteksi & prediksi gangguan otomatis',
                    onTap: () => _showComingSoon('AI Smart Insights'),
                  ),
                  _FeatureCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'Analytics & Reports',
                    subtitle: 'Grafik energi & riwayat aktivitas',
                    onTap: () => _showComingSoon('Analytics & Reports'),
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
        onSelect: (index) {
          if (index == 2) {
            _openProfileSheet();
            return;
          }
          setState(() => _navIndex = index);
          if (index == 1) _showComingSoon('Laporan');
        },
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
                  color:
                      highlighted ? AppColors.textPrimary : AppColors.textSecondary,
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

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accentDim, size: 22),
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

class _ProfileSheet extends StatelessWidget {
  final String name;
  final String email;
  final String roleLabel;
  final VoidCallback onLogout;

  const _ProfileSheet({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
          const SizedBox(height: 22),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.accent,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleLabel,
              style: const TextStyle(
                color: AppColors.accentDim,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: const Text(
                'Keluar',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}