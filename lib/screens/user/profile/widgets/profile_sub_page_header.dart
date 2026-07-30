import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';

class ProfileSubPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ProfileSubPageHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}