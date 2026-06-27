import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// 音准仪表盘 — 模拟调音器 UI
class PitchMeter extends StatelessWidget {
  final double? currentCents;
  final double? targetFrequency;
  final double? currentFrequency;

  const PitchMeter({
    super.key,
    this.currentCents,
    this.targetFrequency,
    this.currentFrequency,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: CustomPaint(
        painter: _PitchMeterPainter(currentCents: currentCents),
        size: const Size(double.infinity, 240),
      ),
    );
  }
}

class _PitchMeterPainter extends CustomPainter {
  final double? currentCents;

  _PitchMeterPainter({this.currentCents});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = min(size.width, size.height) * 1.0;

    // 绘制刻度弧线
    _drawArc(canvas, center, radius, -50, 50, AppTheme.correctColor.withValues(alpha: 0.1));
    _drawArc(canvas, center, radius, -50, -15, AppTheme.warningColor.withValues(alpha: 0.15));
    _drawArc(canvas, center, radius, 15, 50, AppTheme.warningColor.withValues(alpha: 0.15));
    _drawArc(canvas, center, radius, -15, 15, AppTheme.correctColor.withValues(alpha: 0.3));

    // 绘制刻度线
    for (int i = -50; i <= 50; i += 5) {
      final angle = _centsToAngle(i.toDouble()) - pi / 2;
      final isMajor = i % 10 == 0;
      final inner = radius - (isMajor ? 30 : 20);
      final outer = radius - 10;

      final innerPoint = Offset(
        center.dx + inner * cos(angle),
        center.dy + inner * sin(angle),
      );
      final outerPoint = Offset(
        center.dx + outer * cos(angle),
        center.dy + outer * sin(angle),
      );

      final paint = Paint()
        ..color = i.abs() <= 15 ? AppTheme.correctColor : AppTheme.warningColor
        ..strokeWidth = isMajor ? 2 : 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(innerPoint, outerPoint, paint);

      if (isMajor) {
        final labelPoint = Offset(
          center.dx + (inner - 16) * cos(angle),
          center.dy + (inner - 16) * sin(angle),
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '${i.abs()}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, labelPoint - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // 绘制中心线
    final centerPaint = Paint()
      ..color = AppTheme.textSecondary
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx, 10),
      Offset(center.dx, center.dy + radius * 0.3),
      centerPaint,
    );

    // 绘制指针
    if (currentCents != null) {
      final clamped = currentCents!.clamp(-50.0, 50.0);
      final pointerAngle = _centsToAngle(clamped) - pi / 2;
      final pointerLength = radius - 10;
      final pointerEnd = Offset(
        center.dx + pointerLength * cos(pointerAngle),
        center.dy + pointerLength * sin(pointerAngle),
      );

      final pointerPaint = Paint()
        ..color = clamped.abs() <= 15 ? AppTheme.correctColor : AppTheme.warningColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, pointerEnd, pointerPaint);

      // 指针圆点
      canvas.drawCircle(
        pointerEnd,
        6,
        Paint()..color = pointerPaint.color,
      );
    }

    // 中心标签
    final labelPainter = TextPainter(
      text: TextSpan(
        text: currentCents != null
            ? '${currentCents!.toStringAsFixed(1)} 音分'
            : '--',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(center.dx - labelPainter.width / 2, center.dy + 10),
    );
  }

  void _drawArc(Canvas canvas, Offset center, double radius,
      double fromCents, double toCents, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      _centsToAngle(fromCents) - pi / 2,
      _centsToAngle(toCents) - _centsToAngle(fromCents),
      false,
      paint,
    );
  }

  double _centsToAngle(double cents) {
    // 映射: -50 ~ +50 cents → -pi/2 ~ +pi/2
    return (cents / 50) * (pi / 2);
  }

  @override
  bool shouldRepaint(covariant _PitchMeterPainter oldDelegate) {
    return oldDelegate.currentCents != currentCents;
  }
}
