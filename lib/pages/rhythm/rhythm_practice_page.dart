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
    metronome.setPattern(RhythmPattern(
      name: '四分音符',
      beatFractions: const [1.0],
      subdivisions: 1,
    ));
  }

  void _startStop() {
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
      metronome.start();
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
              onPressed: () {
                metronome.stop();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 80),
                        scale: _flashActive ? 1.15 : 1.0,
                        child: Text(
                          '${metronome.bpm}',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: metronome.isRunning ? AppTheme.correctColor : colors.textPrimary,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      Text('BPM', style: TextStyle(color: colors.textSecondary, fontSize: 14, letterSpacing: 4)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => metronome.setBpm(metronome.bpm - 5),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: colors.textSecondary,
                          ),
                          Expanded(
                            child: Slider(
                              value: metronome.bpm.toDouble(),
                              min: 40,
                              max: 240,
                              divisions: 40,
                              activeColor: AppTheme.primaryColor,
                              inactiveColor: colors.textSecondary.withValues(alpha: 0.2),
                              onChanged: (v) => metronome.setBpm(v.round()),
                            ),
                          ),
                          IconButton(
                            onPressed: () => metronome.setBpm(metronome.bpm + 5),
                            icon: const Icon(Icons.add_circle_outline),
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startStop,
                  icon: Icon(metronome.isRunning ? Icons.stop : Icons.play_arrow, size: 28),
                  label: Text(metronome.isRunning ? '停止' : '开始'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 48),
                    backgroundColor: metronome.isRunning ? AppTheme.errorColor : null,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('节奏型', style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 2.5,
                            crossAxisSpacing: 8, mainAxisSpacing: 8,
                          ),
                          itemCount: AppConstants.rhythmPatterns.length,
                          itemBuilder: (context, index) {
                            final def = AppConstants.rhythmPatterns[index];
                            final isSelected = metronome.currentPattern?.name == def.name;
                            return GestureDetector(
                              onTap: () {
                                metronome.setPattern(RhythmPattern(
                                  name: def.name,
                                  beatFractions: def.beats,
                                  subdivisions: def.beats.length,
                                ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                      : colors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                                      : Border.all(color: colors.textSecondary.withValues(alpha: 0.15)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  def.name,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primaryColor : colors.textPrimary,
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
