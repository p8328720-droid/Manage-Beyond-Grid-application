import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'services/app_settings.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/teknisi/teknisi_home_screen.dart';
import 'screens/user/user_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  runApp(const MbgApp());
}

class MbgApp extends StatelessWidget {
  const MbgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'MBG - Manage Beyond Grid',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(AppSettings.instance.fontScale),
              ),
              child: child!,
            );
          },
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => SplashScreen(),
            LoginScreen.routeName: (_) => LoginScreen(),
            RegisterScreen.routeName: (_) => RegisterScreen(),
            AdminHomeScreen.routeName: (_) => const AdminHomeScreen(),
            UserHomeScreen.routeName: (_) => UserHomeScreen(),
            TeknisiHomeScreen.routeName: (_) => const TeknisiHomeScreen(),
          },
        );
      },
    );
  }
}