import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/note.dart';
import '../../services/pitch_detector_service.dart';
import '../../widgets/pitch_meter.dart';

/// 音准练习页面 — 给标准音，用户跟唱，检测音高
class PitchPracticePage extends StatefulWidget {
  const PitchPracticePage({super.key});

  @override
  State<PitchPracticePage> createState() => _PitchPracticePageState();
}

class _PitchPracticePageState extends State<PitchPracticePage> {
  MusicNote? _selectedNote;
  bool _isSimulating = false;

  void _playReferenceNote(MusicNote note) {
    final detector = context.read<PitchDetectorService>();
    detector.setTarget(note.frequency);
    setState(() => _selectedNote = note);
    // TODO: 实际播放音频
  }

  void _toggleSimulation() {
    if (_isSimulating) {
      context.read<PitchDetectorService>().clear();
      setState(() => _isSimulating = false);
    } else {
      if (_selectedNote == null) {
        _playReferenceNote(MusicNote.standardRange[5]); // 默认 A4
      }
      _startSimulation();
    }
  }

  void _startSimulation() {
    setState(() => _isSimulating = true);
    final detector = context.read<PitchDetectorService>();
    final target = detector.targetFrequency ?? 440.0;

    // 模拟音高随时间微调，模拟真实演唱
    Future.doWhile(() async {
      if (!_isSimulating) return false;
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isSimulating) return false;
      // 在目标音高附近 ±20 音分随机浮动
      final centsOffset = 20.0 * (_randomDrift());
      final freq = target * _centsToRatio(centsOffset);
      detector.simulateFrequency(freq);
      return _isSimulating;
    });
  }

  double _randomDrift() {
    // 用时间做一个简单的伪随机
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    return (t * 3).remainder(2) - 1; // -1 ~ 1 之间波动
  }

  double _centsToRatio(double cents) {
    return pow(2, cents / 1200).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PitchDetectorService>(
      builder: (context, detector, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('音准练习'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                detector.clear();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 音准仪表盘
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PitchMeter(
                    currentCents: detector.currentCents,
                    targetFrequency: detector.targetFrequency,
                    currentFrequency: detector.currentFrequency,
                  ),
                ),
                // 评价文字
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        detector.evaluation,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _evaluationColor(detector),
                        ),
                      ),
                      if (detector.currentFrequency != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${detector.currentFrequency!.toStringAsFixed(1)} Hz',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 目标音高指示
                if (_selectedNote != null)
                  Text(
                    '目标音：${_selectedNote!.name}  (${_selectedNote!.frequency.toStringAsFixed(1)} Hz)',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                const Spacer(),
                // 标准音选择
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '选择标准音',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: MusicNote.standardRange.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final note = MusicNote.standardRange[index];
                      final isSelected = _selectedNote?.midiNumber == note.midiNumber;
                      return GestureDetector(
                        onTap: () => _playReferenceNote(note),
                        child: Container(
                          width: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: AppTheme.primaryColor, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            note.name.split(' ')[0],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // 播放标准音 & 开始模拟
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton.icon(
                    onPressed: _toggleSimulation,
                    icon: Icon(_isSimulating ? Icons.stop : Icons.play_arrow),
                    label: Text(_isSimulating ? '停止' : '开始练习'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _evaluationColor(PitchDetectorService detector) {
    if (detector.currentCents == null) return AppTheme.textSecondary;
    final c = detector.currentCents!.abs();
    if (c <= 5) return AppTheme.correctColor;
    if (c <= 15) return AppTheme.secondaryColor;
    if (c <= 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
