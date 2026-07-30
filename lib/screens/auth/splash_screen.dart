import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/brand_widgets.dart';
import 'login_screen.dart';


class SplashScreen extends StatelessWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.38;
    const iconSize = 84.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                child: SizedBox(
                  height: headerHeight,
                  width: double.infinity,
                  child: const CustomPaint(painter: _SignalWavesPainter()),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          Positioned(
            top: headerHeight - iconSize / 2,
            left: 0,
            right: 0,
            child: Center(child: BrandIcon(size: iconSize)),
          ),
          Positioned(
            top: headerHeight + iconSize / 2 + 28,
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Text(
                    'MBG',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 44,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'A new way to control your home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15.5,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          LoginScreen.routeName,
                        );
                      },
                      child: const Text('GET STARTED'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SignalWavesPainter extends CustomPainter {
  const _SignalWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.night);

    final bands = [
      (color: AppColors.nightSoft, depth: 0.62, phase: 0.0),
      (color: AppColors.nightSofter, depth: 0.78, phase: 0.5),
      (color: const Color(0xFF313135), depth: 0.92, phase: 1.0),
    ];

    for (final band in bands) {
      final path = Path()..moveTo(0, size.height * band.depth);
      path.quadraticBezierTo(
        size.width * 0.25,
        size.height * (band.depth - 0.10 + band.phase * 0.02),
        size.width * 0.5,
        size.height * (band.depth - 0.02),
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        size.height * (band.depth + 0.06 - band.phase * 0.02),
        size.width,
        size.height * band.depth,
      );
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, Paint()..color = band.color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}