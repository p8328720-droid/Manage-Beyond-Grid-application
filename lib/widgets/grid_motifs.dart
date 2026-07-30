import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CircuitGridBackground extends StatelessWidget {
  final double spacing;
  final double opacity;

  const CircuitGridBackground({
    super.key,
    this.spacing = 26,
    this.opacity = 0.14,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircuitGridPainter(spacing: spacing, opacity: opacity),
      size: Size.infinite,
    );
  }
}

class _CircuitGridPainter extends CustomPainter {
  final double spacing;
  final double opacity;

  const _CircuitGridPainter({required this.spacing, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: opacity * 0.6)
      ..strokeWidth = 1;
    final dotPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: opacity);

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitGridPainter oldDelegate) =>
      oldDelegate.spacing != spacing || oldDelegate.opacity != opacity;
}

class GridNodeMark extends StatelessWidget {
  final double size;

  const GridNodeMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GridNodePainter()),
    );
  }
}

class _GridNodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;

    final leadPaint = Paint()
      ..color = AppColors.accentDim
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    for (final angleDeg in [90.0, 210.0, 330.0]) {
      final angle = angleDeg * math.pi / 180;
      final start = Offset(
        center.dx + radius * 0.95 * math.cos(angle),
        center.dy + radius * 0.95 * math.sin(angle),
      );
      final end = Offset(
        center.dx + size.width * 0.5 * math.cos(angle),
        center.dy + size.width * 0.5 * math.sin(angle),
      );
      canvas.drawLine(start, end, leadPaint);
      canvas.drawCircle(end, size.width * 0.035, leadPaint..style = PaintingStyle.fill);
    }

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 90) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        hexPath.moveTo(point.dx, point.dy);
      } else {
        hexPath.lineTo(point.dx, point.dy);
      }
    }
    hexPath.close();

    canvas.drawPath(hexPath, Paint()..color = AppColors.surfaceElevated);
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.045,
    );

    canvas.drawCircle(center, radius * 0.28, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}