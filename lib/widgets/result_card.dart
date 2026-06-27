import 'package:flutter/material.dart';
import '../core/theme.dart';

class ResultCard extends StatelessWidget {
  final double accuracy;
  final int correct;
  final int total;
  final Duration duration;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final bool isDark;

  const ResultCard({
    super.key,
    required this.accuracy,
    required this.correct,
    required this.total,
    required this.duration,
    required this.onRetry,
    required this.onHome,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors(isDark);
    final percent = (accuracy * 100).toStringAsFixed(1);

    return Card(
      color: colors.card,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 48, color: AppTheme.warningColor),
            const SizedBox(height: 12),
            Text('练习完成！',
                style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.correctColor, width: 4),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$percent%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.correctColor)),
                  Text('准确率', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('$correct / $total 正确', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
            Text('用时 ${duration.inSeconds} 秒', style: TextStyle(color: colors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: onHome,
                  icon: const Icon(Icons.home),
                  label: const Text('返回'),
                  style: OutlinedButton.styleFrom(foregroundColor: colors.textSecondary),
                ),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.replay),
                  label: const Text('再练一次'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
