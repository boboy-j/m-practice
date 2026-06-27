import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// 音准仪表盘 — 调音器 UI，适配双主题
class PitchMeter extends StatelessWidget {
  final double? currentCents;
  final bool isDark;

  const PitchMeter({
    super.key,
    this.currentCents,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: CustomPaint(
        painter: _PitchMeterPainter(currentCents: currentCents, isDark: isDark),
        size: const Size(double.infinity, 240),
      ),
    );
  }
}

class _PitchMeterPainter extends CustomPainter {
  final double? currentCents;
  final bool isDark;

  _PitchMeterPainter({this.currentCents, required this.isDark});

  Color get _textColor => isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get _subColor => isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = min(size.width, size.height) * 1.0;

    // 刻度弧线
    _drawArc(canvas, center, radius, -50, 50, AppTheme.correctColor.withValues(alpha: 0.08));
    _drawArc(canvas, center, radius, -50, -15, AppTheme.warningColor.withValues(alpha: 0.12));
    _drawArc(canvas, center, radius, 15, 50, AppTheme.warningColor.withValues(alpha: 0.12));
    _drawArc(canvas, center, radius, -15, 15, AppTheme.correctColor.withValues(alpha: 0.25));

    // 刻度线
    for (int i = -50; i <= 50; i += 5) {
      final angle = _centsToAngle(i.toDouble()) - pi / 2;
      final isMajor = i % 10 == 0;
      final inner = radius - (isMajor ? 30 : 20);
      final outer = radius - 10;

      final innerPoint = Offset(center.dx + inner * cos(angle), center.dy + inner * sin(angle));
      final outerPoint = Offset(center.dx + outer * cos(angle), center.dy + outer * sin(angle));

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
            style: TextStyle(color: _subColor, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, labelPoint - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // 中心线
    final centerPaint = Paint()..color = _subColor..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx, 10), Offset(center.dx, center.dy + radius * 0.3), centerPaint);

    // 指针
    if (currentCents != null) {
      final clamped = currentCents!.clamp(-50.0, 50.0);
      final pointerAngle = _centsToAngle(clamped) - pi / 2;
      final pointerLength = radius - 10;
      final pointerEnd = Offset(
        center.dx + pointerLength * cos(pointerAngle),
        center.dy + pointerLength * sin(pointerAngle),
      );

      final pointerColor = clamped.abs() <= 15 ? AppTheme.correctColor : AppTheme.warningColor;
      canvas.drawLine(center, pointerEnd, Paint()..color = pointerColor..strokeWidth = 3..strokeCap = StrokeCap.round);
      canvas.drawCircle(pointerEnd, 6, Paint()..color = pointerColor);
    }

    // 中心数值
    final labelPainter = TextPainter(
      text: TextSpan(
        text: currentCents != null ? '${currentCents!.toStringAsFixed(1)} 音分' : '--',
        style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(center.dx - labelPainter.width / 2, center.dy + 10));
  }

  void _drawArc(Canvas canvas, Offset center, double radius,
      double fromCents, double toCents, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, _centsToAngle(fromCents) - pi / 2,
        _centsToAngle(toCents) - _centsToAngle(fromCents), false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round);
  }

  double _centsToAngle(double cents) => (cents / 50) * (pi / 2);

  @override
  bool shouldRepaint(covariant _PitchMeterPainter oldDelegate) =>
      oldDelegate.currentCents != currentCents || oldDelegate.isDark != isDark;
}
