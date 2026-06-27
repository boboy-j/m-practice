import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/rhythm_pattern.dart';
import '../../services/metronome_service.dart';
import '../../widgets/metronome_widget.dart';

/// 节拍练习页面 — 内置节拍器 + 多种节奏型
class RhythmPracticePage extends StatefulWidget {
  const RhythmPracticePage({super.key});

  @override
  State<RhythmPracticePage> createState() => _RhythmPracticePageState();
}

class _RhythmPracticePageState extends State<RhythmPracticePage> {
  StreamSubscription<List<int>>? _beatSub;
  bool _flashActive = false;

  @override
  void initState() {
    super.initState();
    // 默认选择四分音符节奏型，启动时自动初始化
    final metronome = context.read<MetronomeService>();
    final defaultPattern = RhythmPattern(
      name: '四分音符',
      beatFractions: const [1.0],
      subdivisions: 1,
    );
    metronome.setPattern(defaultPattern);
  }

  void _startStop() {
    final metronome = context.read<MetronomeService>();
    if (metronome.isRunning) {
      metronome.stop();
      _beatSub?.cancel();
    } else {
      _subscribeToBeats();
      metronome.start();
    }
  }

  void _subscribeToBeats() {
    final metronome = context.read<MetronomeService>();
    _beatSub?.cancel();
    _beatSub = metronome.beatStream.listen((event) {
      setState(() => _flashActive = true);
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) setState(() => _flashActive = false);
      });
    });
  }

  @override
  void dispose() {
    _beatSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MetronomeService>(
      builder: (context, metronome, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('节拍练习'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                metronome.stop();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // BPM 显示和调节
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // BPM 大数字
                      AnimatedScale(
                        duration: const Duration(milliseconds: 80),
                        scale: _flashActive ? 1.15 : 1.0,
                        child: Text(
                          '${metronome.bpm}',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: metronome.isRunning
                                ? AppTheme.correctColor
                                : AppTheme.textPrimary,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      const Text(
                        'BPM',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // BPM 滑块
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => metronome.setBpm(metronome.bpm - 5),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppTheme.textSecondary,
                          ),
                          Expanded(
                            child: Slider(
                              value: metronome.bpm.toDouble(),
                              min: 40,
                              max: 240,
                              divisions: 40,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (v) => metronome.setBpm(v.round()),
                            ),
                          ),
                          IconButton(
                            onPressed: () => metronome.setBpm(metronome.bpm + 5),
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 节拍器可视化
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MetronomeWidget(
                    bpm: metronome.bpm,
                    pattern: metronome.currentPattern,
                    currentBeat: metronome.currentBeat,
                    totalBeats: metronome.totalBeats,
                    isRunning: metronome.isRunning,
                    isCountingIn: metronome.isCountingIn,
                    beatInCycle: metronome.beatInCycle,
                  ),
                ),
                const SizedBox(height: 16),
                // 开始/停止按钮
                ElevatedButton.icon(
                  onPressed: _startStop,
                  icon: Icon(
                    metronome.isRunning ? Icons.stop : Icons.play_arrow,
                    size: 28,
                  ),
                  label: Text(metronome.isRunning ? '停止' : '开始'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 48),
                    backgroundColor:
                        metronome.isRunning ? AppTheme.errorColor : null,
                  ),
                ),
                const SizedBox(height: 16),
                // 节奏型选择
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '节奏型',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: AppConstants.rhythmPatterns.length,
                          itemBuilder: (context, index) {
                            final def = AppConstants.rhythmPatterns[index];
                            final isSelected = metronome.currentPattern?.name ==
                                def.name;
                            return GestureDetector(
                              onTap: () {
                                final pattern = RhythmPattern(
                                  name: def.name,
                                  beatFractions: def.beats,
                                  subdivisions: def.beats.length,
                                );
                                metronome.setPattern(pattern);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                      : AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppTheme.primaryColor, width: 2)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  def.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
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
