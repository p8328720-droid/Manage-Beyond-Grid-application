import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../_role_home_scaffold.dart';


class AdminHomeScreen extends StatelessWidget {
  static const routeName = '/admin-home';

  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleHomeScaffold(
      roleLabel: 'Administrator',
      welcomeName: AuthService.instance.currentUser?.name ?? 'Admin',
      menuItems: const [
        RoleMenuItem(icon: Icons.people_outline, label: 'Kelola Pengguna'),
        RoleMenuItem(icon: Icons.developer_board, label: 'Kelola Perangkat'),
        RoleMenuItem(icon: Icons.tune, label: 'Kelola Konfigurasi Sistem'),
        RoleMenuItem(icon: Icons.monitor_heart_outlined, label: 'Monitoring Sistem'),
        RoleMenuItem(icon: Icons.summarize_outlined, label: 'Lihat Laporan Sistem'),
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
