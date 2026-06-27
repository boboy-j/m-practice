import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ScorePracticePage extends StatelessWidget {
  const ScorePracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('曲谱练习'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: colors.card,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.library_music, size: 64,
                          color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('曲谱练习模式',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                      const SizedBox(height: 8),
                      Text('跟随简谱演奏/演唱\n系统实时评估音准和节拍',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.6)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('计划功能', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _FeatureItem(icon: Icons.music_note, title: '简谱显示', subtitle: '支持数字简谱渲染，音高和时值可视化', status: '开发中', colors: colors),
              _FeatureItem(icon: Icons.speed, title: '实时跟谱', subtitle: '光标跟随当前音符，自动翻页', status: '规划中', colors: colors),
              _FeatureItem(icon: Icons.assessment, title: '综合评分', subtitle: '音准 + 节拍双重评估，分维度展示', status: '规划中', colors: colors),
              _FeatureItem(icon: Icons.history, title: '练习记录', subtitle: '历史成绩追踪，可视化进步曲线', status: '规划中', colors: colors),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.warningColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '此模块将在音准和节拍检测引擎验证完成后开发。\n当前阶段请先体验音准练习和节拍练习。',
                        style: TextStyle(color: colors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final ThemeColors colors;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status == '开发中' ? AppTheme.warningColor : colors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
