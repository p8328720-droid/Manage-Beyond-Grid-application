import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/teknisi/teknisi_home_screen.dart';
import 'screens/user/user_home_screen.dart';

void main() {
  runApp(const MbgApp());
}

/// Root widget for MBG (Manage Beyond Grid).
class MbgApp extends StatelessWidget {
  const MbgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBG - Manage Beyond Grid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        AdminHomeScreen.routeName: (_) => const AdminHomeScreen(),
        UserHomeScreen.routeName: (_) => const UserHomeScreen(),
        TeknisiHomeScreen.routeName: (_) => const TeknisiHomeScreen(),
      },
    );
  }
}