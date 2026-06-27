import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

/// 首页 — 三大练习模块入口
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // App 标题
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'M-Practice',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '音乐练习助手',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // 练习模块卡片
              Expanded(
                child: Column(
                  children: [
                    // 音准练习
                    Expanded(
                      child: _ModuleCard(
                        icon: Icons.mic,
                        title: '音准练习',
                        subtitle: '标准音对比 · 实时检测 · 音准仪表盘',
                        color: AppTheme.primaryColor,
                        onTap: () => context.push('/pitch'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 节拍练习
                    Expanded(
                      child: _ModuleCard(
                        icon: Icons.timer,
                        title: '节拍练习',
                        subtitle: '节拍器 · 8种节奏型 · 预备拍引导',
                        color: AppTheme.secondaryColor,
                        onTap: () => context.push('/rhythm'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 曲谱练习（开发中）
                    Expanded(
                      child: _ModuleCard(
                        icon: Icons.library_music,
                        title: '曲谱练习',
                        subtitle: '简谱跟奏 · 综合评分 · 练习记录',
                        color: AppTheme.warningColor,
                        onTap: () => context.push('/score'),
                        isComingSoon: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 版本信息
              const Center(
                child: Text(
                  'v1.0.0 · POC 技术验证版',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
  final VoidCallback onTap;
  final bool isComingSoon;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
