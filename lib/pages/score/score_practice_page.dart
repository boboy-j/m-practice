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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 模拟简谱展示
              Card(
                color: colors.card,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.music_note, color: AppTheme.primaryColor, size: 28),
                          SizedBox(width: 4),
                          Icon(Icons.music_note, color: AppTheme.secondaryColor, size: 24),
                          SizedBox(width: 4),
                          Icon(Icons.music_note, color: AppTheme.warningColor, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('小星星', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                      const SizedBox(height: 12),
                      // 简谱 demo
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 8,
                        children: [
                          _note('1', '♩', colors),
                          _note('1', '♩', colors),
                          _note('5', '♩', colors),
                          _note('5', '♩', colors),
                          _note('6', '♩', colors),
                          _note('6', '♩', colors),
                          _note('5', '♪', colors),
                          _bar(colors),
                          _note('4', '♩', colors),
                          _note('4', '♩', colors),
                          _note('3', '♩', colors),
                          _note('3', '♩', colors),
                          _note('2', '♩', colors),
                          _note('2', '♩', colors),
                          _note('1', '♪', colors),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('do do sol sol  la la sol —\nfa fa mi mi  re re do —',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 即将支持
              Text('🎵 即将支持', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _feat('自定义简谱导入', '支持数字简谱录入，自由编辑', colors),
              _feat('光标跟随演奏', '实时高亮当前音符，自动翻页', colors),
              _feat('音准+节拍综合评分', '演奏完成后分维度展示成绩', colors),
              _feat('练习记录追踪', '历史数据可视化，见证进步', colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _note(String solfege, String duration, ThemeColors c) {
    return Column(
      children: [
        Text(solfege, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.textPrimary)),
        Text(duration, style: TextStyle(fontSize: 11, color: c.textSecondary)),
      ],
    );
  }

  Widget _bar(ThemeColors c) {
    return Container(width: 2, height: 32, color: c.textSecondary.withValues(alpha: 0.3));
  }

  Widget _feat(String title, String desc, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check_circle_outline, color: AppTheme.secondaryColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(desc, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}
