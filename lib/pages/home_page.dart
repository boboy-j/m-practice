import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../core/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶栏：主题切换 + 空白
              Row(
                children: [
                  // 主题切换按钮
                  IconButton(
                    onPressed: () => context.read<ThemeNotifier>().toggle(),
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? AppTheme.warningColor : AppTheme.primaryColor,
                    ),
                    tooltip: isDark ? '切换浅色模式' : '切换深色模式',
                    style: IconButton.styleFrom(
                      backgroundColor: (isDark ? AppTheme.darkSurface : AppTheme.lightCard)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const Spacer(flex: 1),
              // App 标题
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'M-Practice',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '音乐练习助手',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // 练习模块卡片
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: _ModuleCard(
                        icon: Icons.mic,
                        title: '音准练习',
                        subtitle: '标准音对比 · 实时检测 · 5个八度钢琴键盘',
                        color: AppTheme.primaryColor,
                        colors: colors,
                        onTap: () => context.push('/pitch'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _ModuleCard(
                        icon: Icons.timer,
                        title: '节拍练习',
                        subtitle: '节拍器 · 8种节奏型 · 钢琴音色节拍声',
                        color: AppTheme.secondaryColor,
                        colors: colors,
                        onTap: () => context.push('/rhythm'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _ModuleCard(
                        icon: Icons.library_music,
                        title: '曲谱练习',
                        subtitle: '简谱跟奏 · 综合评分 · 练习记录',
                        color: AppTheme.warningColor,
                        colors: colors,
                        onTap: () => context.push('/score'),
                        isComingSoon: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'v1.0.0 · POC 技术验证版',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ThemeColors colors;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colors,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '规划中',
                              style: TextStyle(
                                color: AppTheme.warningColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.6), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
