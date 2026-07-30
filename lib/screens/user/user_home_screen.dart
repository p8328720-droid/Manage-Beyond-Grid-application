import 'package:flutter/material.dart';

import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/_role_home_scaffold.dart';

class UserHomeScreen extends StatelessWidget {
  static const routeName = '/user-home';

  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleHomeScaffold(
      roleLabel: 'Pengguna',
      welcomeName: AuthService.instance.currentUser?.name ?? 'Pengguna',
      menuItems: const [
        RoleMenuItem(icon: Icons.dashboard_outlined, label: 'Smart Dashboard'),
        RoleMenuItem(icon: Icons.toggle_on_outlined, label: 'Kontrol Perangkat'),
        RoleMenuItem(icon: Icons.cloud_sync_outlined, label: 'Sinkronisasi Cloud'),
        RoleMenuItem(icon: Icons.insights_outlined, label: 'AI Smart Insights'),
        RoleMenuItem(icon: Icons.notifications_active_outlined, label: 'Smart Alert'),
        RoleMenuItem(icon: Icons.bar_chart_outlined, label: 'Analytics & Reports'),
      ],
      onLogout: () {
        AuthService.instance.logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (_) => false,
        );
      },
    );
  }
}