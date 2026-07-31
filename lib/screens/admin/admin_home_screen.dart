import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../_role_home_scaffold.dart';
import 'kelola_pengguna_screen.dart';
import 'kelola_konfigurasi_screen.dart';
import 'monitoring_sistem_screen.dart';
import 'laporan_sistem_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  static const routeName = '/admin-home';

  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleHomeScaffold(
      roleLabel: 'Administrator',
      welcomeName: AuthService.instance.currentUser?.name ?? 'Admin',
      menuItems: [
        RoleMenuItem(
          icon: Icons.people_outline,
          label: 'Kelola Pengguna',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KelolaPenggunaScreen()),
          ),
        ),
        RoleMenuItem(
          icon: Icons.tune,
          label: 'Kelola Konfigurasi Sistem',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KelolaKonfigurasiScreen()),
          ),
        ),
        RoleMenuItem(
          icon: Icons.monitor_heart_outlined,
          label: 'Monitoring Sistem',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MonitoringSistemScreen()),
          ),
        ),
        RoleMenuItem(
          icon: Icons.summarize_outlined,
          label: 'Lihat Laporan Sistem',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LaporanSistemScreen()),
          ),
        ),
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
