import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/rhythm_pattern.dart';

class MetronomeWidget extends StatelessWidget {
  final int bpm;
  final RhythmPattern? pattern;
  final int? currentBeat;
  final int totalBeats;
  final bool isRunning;
  final bool isCountingIn;
  final int beatInCycle;
  final bool isDark;

  const MetronomeWidget({
    super.key,
    required this.bpm,
    this.pattern,
    this.currentBeat,
    required this.totalBeats,
    required this.isRunning,
    required this.isCountingIn,
    required this.beatInCycle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _MetronomePainter(
          bpm: bpm,
          pattern: pattern,
          currentBeat: currentBeat,
          totalBeats: totalBeats,
          isRunning: isRunning,
          isCountingIn: isCountingIn,
          beatInCycle: beatInCycle,
          isDark: isDark,
        ),
        size: const Size(double.infinity, 160),
      ),
    );
  }
}

class _MetronomePainter extends CustomPainter {
  final int bpm;
  final RhythmPattern? pattern;
  final int? currentBeat;
  final int totalBeats;
  final bool isRunning;
  final bool isCountingIn;
  final int beatInCycle;
  final bool isDark;

  _MetronomePainter({
    required this.bpm,
    this.pattern,
    this.currentBeat,
    required this.totalBeats,
    required this.isRunning,
    required this.isCountingIn,
    required this.beatInCycle,
    required this.isDark,
  });

  Color get _subColor => isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == null) return;

    final centerX = size.width / 2;
    final dotRadius = 12.0;
    final spacing = 50.0;
    final totalWidth = (totalBeats - 1) * spacing;
    final startX = centerX - totalWidth / 2;
    final y = size.height / 2;

    // 连线
    canvas.drawLine(
      Offset(startX - 20, y), Offset(startX + totalWidth + 20, y),
      Paint()..color = _subColor.withValues(alpha: 0.3)..strokeWidth = 2,
    );

    // 节拍点
    for (int i = 0; i < totalBeats; i++) {
      final x = startX + i * spacing;
      final isCurrent = isRunning && !isCountingIn && i == beatInCycle;
      final isAccent = i == 0;

      double r = isAccent ? dotRadius + 2 : dotRadius;
      if (isCurrent) r += 6;

      Color color;
      if (isCurrent) {
        color = AppTheme.correctColor;
      } else if (isAccent) {
        color = AppTheme.primaryColor;
      } else {
        color = _subColor.withValues(alpha: 0.5);
      }

      if (isCurrent) {
        canvas.drawCircle(Offset(x, y), r + 8,
            Paint()..color = AppTheme.correctColor.withValues(alpha: 0.2)..style = PaintingStyle.fill);
      }

      canvas.drawCircle(Offset(x, y), r, Paint()..color = color);

      if (isCurrent) {
        canvas.drawCircle(Offset(x, y), r + 4,
            Paint()..color = AppTheme.correctColor.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
      }

      // 时值标签
      final fraction = pattern!.beatFractions[i];
      final label = fraction == 1.0 ? '♩' : fraction == 0.75 ? '♩.' : '♪';
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(color: _subColor, fontSize: 14)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + r + 8));
    }

    // 预备拍
    if (isCountingIn && currentBeat != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: '预备拍 ${4 + currentBeat! + 1} / 4',
          style: const TextStyle(color: AppTheme.warningColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(centerX - tp.width / 2, y - 50));
    }
  }

  @override
  bool shouldRepaint(covariant _MetronomePainter oldDelegate) =>
      oldDelegate.currentBeat != currentBeat || oldDelegate.isRunning != isRunning ||
      oldDelegate.isCountingIn != isCountingIn || oldDelegate.bpm != bpm ||
      oldDelegate.isDark != isDark;
}
