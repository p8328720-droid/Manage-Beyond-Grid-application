import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../_role_home_scaffold.dart';

class TeknisiHomeScreen extends StatelessWidget {
  static const routeName = '/teknisi-home';

  const TeknisiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleHomeScaffold(
      roleLabel: 'Teknisi / Maintenance',
      welcomeName: AuthService.instance.currentUser?.name ?? 'Teknisi',
      menuItems: const [
        RoleMenuItem(icon: Icons.monitor_heart_outlined, label: 'Monitoring Perangkat'),
        RoleMenuItem(icon: Icons.build_outlined, label: 'Jadwal Maintenance'),
        RoleMenuItem(icon: Icons.report_gmailerrorred_outlined, label: 'Laporan Gangguan'),
        RoleMenuItem(icon: Icons.sensors_outlined, label: 'Kalibrasi Sensor'),
        RoleMenuItem(icon: Icons.history_outlined, label: 'Riwayat Perbaikan'),
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