import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/screens/user/profile/profile_details_view.dart';
import 'package:flutter_application_1/screens/user/profile/push_notifications_view.dart';
import 'package:flutter_application_1/screens/user/profile/settings_view.dart';

enum _ProfilePage { main, details, notifications, settings }

// WhatsApp number for Support, in international format without symbols.
const String _supportWhatsAppNumber = '6285717458151';

/// Hosts the Profile hub and its sub-pages (Profile details, Push
/// Notifications, Settings) as an internal stack, so the bottom nav bar
/// owned by [UserHomeScreen] stays visible the whole time.
class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.onLogout});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  _ProfilePage _page = _ProfilePage.main;

  AppUser? get _user => AuthService.instance.currentUser;

  void _goTo(_ProfilePage page) => setState(() => _page = page);

  Future<void> _openWhatsAppSupport() async {
    final uri = Uri.parse(
      'https://wa.me/$_supportWhatsAppNumber'
      '?text=${Uri.encodeComponent('Halo, saya butuh bantuan terkait aplikasi MBG.')}',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_page) {
      case _ProfilePage.details:
        return ProfileDetailsView(onBack: () => _goTo(_ProfilePage.main));
      case _ProfilePage.notifications:
        return PushNotificationsView(onBack: () => _goTo(_ProfilePage.main));
      case _ProfilePage.settings:
        return SettingsView(
          onBack: () => _goTo(_ProfilePage.main),
          onAccountDeleted: widget.onLogout,
        );
      case _ProfilePage.main:
        final user = _user;
        return _ProfileMainView(
          name: user?.name ?? 'Pengguna',
          email: user?.email ?? '-',
          onTapDetails: () => _goTo(_ProfilePage.details),
          onTapSettings: () => _goTo(_ProfilePage.settings),
          onTapNotifications: () => _goTo(_ProfilePage.notifications),
          onTapSupport: _openWhatsAppSupport,
          onLogout: widget.onLogout,
        );
    }
  }
}

// Profile hub: avatar, identity, and the menu list.
class _ProfileMainView extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTapDetails;
  final VoidCallback onTapSettings;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapSupport;
  final VoidCallback onLogout;

  const _ProfileMainView({
    required this.name,
    required this.email,
    required this.onTapDetails,
    required this.onTapSettings,
    required this.onTapNotifications,
    required this.onTapSupport,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Center(child: _ProfileAvatar(name: name)),
          const SizedBox(height: 14),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _ProfileMenuTile(
            icon: Icons.person_outline,
            label: 'Profile details',
            onTap: onTapDetails,
          ),
          const SizedBox(height: 12),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: onTapSettings,
          ),
          const SizedBox(height: 12),
          _ProfileMenuTile(
            icon: Icons.notifications_none_rounded,
            label: 'Push Notifications',
            onTap: onTapNotifications,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 20),
          _ProfileMenuTile(
            icon: Icons.support_agent_outlined,
            label: 'Support',
            onTap: onTapSupport,
          ),
          const SizedBox(height: 12),
          _ProfileMenuTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: onLogout,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;

  const _ProfileAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 2.4),
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceElevated,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 30,
              ),
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ganti foto — segera hadir')),
            ),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.textPrimary;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (!destructive)
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}