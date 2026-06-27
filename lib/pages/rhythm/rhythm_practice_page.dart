import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/rhythm_pattern.dart';
import '../../services/metronome_service.dart';
import '../../widgets/metronome_widget.dart';

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
    final metronome = context.read<MetronomeService>();
    metronome.setPattern(RhythmPattern(name: '四分音符', beatFractions: const [1.0], subdivisions: 1));
  }

  Future<void> _startStop() async {
    final metronome = context.read<MetronomeService>();
    if (metronome.isRunning) {
      metronome.stop();
      _beatSub?.cancel();
    } else {
      _beatSub = metronome.beatStream.listen((_) {
        setState(() => _flashActive = true);
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) setState(() => _flashActive = false);
        });
      });
      await metronome.start();
    }
  }

  @override
  void dispose() {
    _beatSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark);

    return Consumer<MetronomeService>(
      builder: (context, metronome, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('节拍练习'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () { metronome.stop(); Navigator.pop(context); },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // BPM 大数字 + 滑块
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 80),
                        scale: _flashActive ? 1.12 : 1.0,
                        child: Text('${metronome.bpm}',
                            style: TextStyle(fontSize: 64, fontWeight: FontWeight.w200,
                                color: metronome.isRunning ? AppTheme.correctColor : colors.textPrimary)),
                      ),
                      Text('BPM', style: TextStyle(color: colors.textSecondary, fontSize: 12, letterSpacing: 3)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => metronome.setBpm(metronome.bpm - 5),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.card),
                              child: const Icon(Icons.remove, size: 20),
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: metronome.bpm.toDouble(), min: 40, max: 240, divisions: 40,
                              activeColor: AppTheme.primaryColor,
                              inactiveColor: colors.textSecondary.withValues(alpha: 0.2),
                              onChanged: (v) => metronome.setBpm(v.round()),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => metronome.setBpm(metronome.bpm + 5),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.card),
                              child: const Icon(Icons.add, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 节拍指示器
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MetronomeWidget(
                    bpm: metronome.bpm, pattern: metronome.currentPattern,
                    currentBeat: metronome.currentBeat, totalBeats: metronome.totalBeats,
                    isRunning: metronome.isRunning, isCountingIn: metronome.isCountingIn,
                    beatInCycle: metronome.beatInCycle, isDark: isDark,
                  ),
                ),
                // 开始/停止
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: _startStop,
                    icon: Icon(metronome.isRunning ? Icons.stop : Icons.play_arrow, size: 24),
                    label: Text(metronome.isRunning ? '停止' : '开始'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 44),
                      backgroundColor: metronome.isRunning ? AppTheme.errorColor : null,
                    ),
                  ),
                ),
                // 节奏型标签
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('选择节奏型', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                  ),
                ),
                // 节奏型横向滚动列表（大卡片）
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: AppConstants.rhythmPatterns.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final def = AppConstants.rhythmPatterns[index];
                      final selected = metronome.currentPattern?.name == def.name;
                      return GestureDetector(
                        onTap: () {
                          metronome.setPattern(RhythmPattern(
                            name: def.name, beatFractions: def.beats, subdivisions: def.beats.length,
                          ));
                        },
                        child: Container(
                          width: 130,
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primaryColor.withValues(alpha: 0.2) : colors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? AppTheme.primaryColor : colors.textSecondary.withValues(alpha: 0.15),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(def.name,
                                  style: TextStyle(color: selected ? AppTheme.primaryColor : colors.textPrimary,
                                      fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              // 节奏型简图
                              _RhythmVisual(def.beats, selected, colors),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 节奏型可视化简图
class _RhythmVisual extends StatelessWidget {
  final List<double> beats;
  final bool selected;
  final ThemeColors colors;

  const _RhythmVisual(this.beats, this.selected, this.colors);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: beats.map((b) {
        final h = b >= 0.75 ? 20.0 : b >= 0.5 ? 14.0 : 10.0;
        final w = b >= 0.75 ? 8.0 : 6.0;
        return Container(
          width: w, height: h,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : colors.textPrimary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}
