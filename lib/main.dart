import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'services/app_settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/system_config_service.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/teknisi/teknisi_home_screen.dart';
import 'screens/user/banner_preview_screen.dart';
import 'screens/user/user_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load environment (expects a .env in project root with SUPABASE_URL and SUPABASE_ANON_KEY)
  await dotenv.load(fileName: '.env');

  // Initialize Supabase if env present
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl != null && supabaseKey != null && supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  await AppSettings.instance.load();
  await SystemConfigService.instance.load();
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
            BannerPreviewScreen.routeName: (_) => const BannerPreviewScreen(),
            TeknisiHomeScreen.routeName: (_) => const TeknisiHomeScreen(),
          },
        );
      },
    );
  }
}