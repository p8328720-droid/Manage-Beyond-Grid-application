import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class BrandIcon extends StatelessWidget {
  final double size;

  const BrandIcon({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.wifi_rounded,
        color: AppColors.textPrimary,
        size: size * 0.56,
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandIcon(size: 48),
        const SizedBox(width: 12),
        Text(
          'MBG',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 30,
              ),
        ),
      ],
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class SocialSignInButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceElevated,
          disabledBackgroundColor: AppColors.surfaceElevated,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF1F2937)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleGlyph extends StatelessWidget {
  final double size;

  const GoogleGlyph({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [
              Color(0xFF4285F4),
              Color(0xFFEA4335),
              Color(0xFFFBBC05),
              Color(0xFF34A853),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size, size)),
      ),
    );
  }
}