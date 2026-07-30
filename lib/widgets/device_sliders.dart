import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';

class PercentDragBar extends StatelessWidget {
  final double value; // 0..1
  final String label;
  final ValueChanged<double> onChanged;
  final double height;

  const PercentDragBar({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.height = 64,
  });

  void _handle(double dx, double width) {
    onChanged((dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fillWidth = width * clamped;

        return GestureDetector(
          onTapDown: (d) => _handle(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) => _handle(d.localPosition.dx, width),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: fillWidth,
                  height: height,
                  color: AppColors.accent,
                ),
                Positioned(
                  left: (fillWidth - 5).clamp(0.0, width - 5),
                  child: Container(
                    width: 3,
                    height: height * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VerticalPercentDragBar extends StatelessWidget {
  final double value; // 0..1
  final String label;
  final ValueChanged<double> onChanged;

  const VerticalPercentDragBar({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  void _handle(double dy, double height) {
    onChanged((1 - (dy / height)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final fillHeight = height * clamped;

        return GestureDetector(
          onTapDown: (d) => _handle(d.localPosition.dy, height),
          onVerticalDragUpdate: (d) => _handle(d.localPosition.dy, height),
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: fillHeight,
                  width: width,
                  color: AppColors.accent,
                ),
                Positioned(
                  bottom: (fillHeight - 46).clamp(14.0, height - 46),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}