import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/screens/user/profile/widgets/profile_sub_page_header.dart';

class PushNotificationsView extends StatefulWidget {
  final VoidCallback onBack;

  const PushNotificationsView({super.key, required this.onBack});

  @override
  State<PushNotificationsView> createState() => _PushNotificationsViewState();
}

class _PushNotificationsViewState extends State<PushNotificationsView> {
  bool get _enabled =>
      AuthService.instance.currentUser?.pushNotificationsEnabled ?? true;

  void _toggle(bool value) {
    // Persists on the current user so it stays in effect anywhere the app
    // checks pushNotificationsEnabled (e.g. the dashboard's smart alerts).
    setState(() => AuthService.instance.updatePushNotifications(value));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSubPageHeader(
            title: 'Push Notifications',
            onBack: widget.onBack,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Push Notifications',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Allow app to send you push notifications on '
                        'your lockscreen',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _enabled,
                  onChanged: _toggle,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}