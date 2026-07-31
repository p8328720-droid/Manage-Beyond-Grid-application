import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../_role_home_scaffold.dart';
import 'jadwal_maintenance_screen.dart';
import 'laporan_gangguan_screen.dart';
import 'kalibrasi_sensor_screen.dart';
import 'riwayat_perbaikan_screen.dart';

class TeknisiHomeScreen extends StatelessWidget {
  static const routeName = '/teknisi-home';

  const TeknisiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleHomeScaffold(
      roleLabel: 'Teknisi / Maintenance',
      welcomeName: AuthService.instance.currentUser?.name ?? 'Teknisi',
      menuItems: [
        RoleMenuItem(
          icon: Icons.build_outlined,
          label: 'Jadwal Maintenance',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const JadwalMaintenanceScreen()),
          ),
        ),
        RoleMenuItem(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'Laporan Gangguan',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LaporanGangguanScreen()),
          ),
        ),
        RoleMenuItem(
          icon: Icons.sensors_outlined,
          label: 'Kalibrasi Sensor',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KalibrasiSensorScreen()),
          ),
        ),
        RoleMenuItem(
          icon: Icons.history_outlined,
          label: 'Riwayat Perbaikan',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RiwayatPerbaikanScreen()),
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