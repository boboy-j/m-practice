import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/note.dart';
import '../../services/audio_generator.dart';
import '../../services/pitch_detector_service.dart';
import '../../widgets/pitch_meter.dart';

class PitchPracticePage extends StatefulWidget {
  const PitchPracticePage({super.key});

  @override
  State<PitchPracticePage> createState() => _PitchPracticePageState();
}

class _PitchPracticePageState extends State<PitchPracticePage> {
  MusicNote? _selectedNote;
  bool _isActive = false;
  bool _useSimulation = true; // Web 默认模拟，移动端可切换真实录音

  void _playReferenceNote(MusicNote note) {
    final detector = context.read<PitchDetectorService>();
    detector.setTarget(note.frequency);
    setState(() => _selectedNote = note);
    context.read<AudioGenerator>().playTone(note.frequency);
  }

  void _togglePractice() {
    if (_isActive) {
      _stop();
    } else {
      _start();
    }
  }

  Future<void> _start() async {
    if (_selectedNote == null) {
      _playReferenceNote(MusicNote.fullRange[11]); // C4
    }
    setState(() => _isActive = true);

    if (_useSimulation) {
      _startSimulation();
    } else {
      await context.read<PitchDetectorService>().startListening();
    }
  }

  void _stop() {
    final detector = context.read<PitchDetectorService>();
    if (_useSimulation) {
      detector.clear();
    } else {
      detector.stopListening();
    }
    setState(() => _isActive = false);
  }

  void _startSimulation() {
    final detector = context.read<PitchDetectorService>();
    final target = detector.targetFrequency ?? 440.0;

    Future.doWhile(() async {
      if (!_isActive || !_useSimulation) return false;
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isActive || !_useSimulation) return false;
      final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final drift = ((t * 3.7).remainder(2) - 1);
      final centsOffset = 18.0 * drift;
      detector.simulateFrequency(target * pow(2, centsOffset / 1200));
      return _isActive && _useSimulation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark);

    final octaves = <int, List<MusicNote>>{};
    for (final note in MusicNote.fullRange) {
      octaves.putIfAbsent(note.octave, () => []);
      octaves[note.octave]!.add(note);
    }

    return Consumer<PitchDetectorService>(
      builder: (context, detector, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('音准练习'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _stop();
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
                    isDark: isDark,
                  ),
                ),
                // 评价文字
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        detector.evaluation,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _evaluationColor(detector),
                        ),
                      ),
                      if (detector.currentFrequency != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${detector.currentFrequency!.toStringAsFixed(1)} Hz',
                          style: TextStyle(color: colors.textSecondary, fontSize: 12),
                        ),
                      ],
                      if (_selectedNote != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '目标音：${_selectedNote!.name} (${_selectedNote!.solfege}) · ${_selectedNote!.frequency.toStringAsFixed(1)} Hz',
                          style: TextStyle(color: colors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 模式切换
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeChip(
                      label: '模拟',
                      icon: Icons.smart_toy,
                      selected: _useSimulation,
                      colors: colors,
                      onTap: _isActive ? null : () => setState(() => _useSimulation = true),
                    ),
                    const SizedBox(width: 8),
                    _ModeChip(
                      label: '麦克风',
                      icon: Icons.mic,
                      selected: !_useSimulation,
                      colors: colors,
                      onTap: _isActive ? null : () => setState(() => _useSimulation = false),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 钢琴键盘
                Expanded(
                  child: _PianoKeyboard(
                    octaves: octaves,
                    selectedNote: _selectedNote,
                    onNoteTap: _playReferenceNote,
                    isDark: isDark,
                  ),
                ),
                // 底部操作
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                  child: ElevatedButton.icon(
                    onPressed: _togglePractice,
                    icon: Icon(_isActive ? Icons.stop : (_useSimulation ? Icons.play_arrow : Icons.mic)),
                    label: Text(_isActive ? '停止' : '开始练习'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: _isActive ? AppTheme.errorColor : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _evaluationColor(PitchDetectorService detector) {
    if (detector.currentCents == null) return Colors.grey;
    final c = detector.currentCents!.abs();
    if (c <= 5) return AppTheme.correctColor;
    if (c <= 15) return AppTheme.secondaryColor;
    if (c <= 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}

/// 模式切换芯片
class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ThemeColors colors;
  final VoidCallback? onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primaryColor
                : colors.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? AppTheme.primaryColor : colors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? AppTheme.primaryColor : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PianoKeyboard extends StatelessWidget {
  final Map<int, List<MusicNote>> octaves;
  final MusicNote? selectedNote;
  final Function(MusicNote) onNoteTap;
  final bool isDark;

  const _PianoKeyboard({
    required this.octaves,
    this.selectedNote,
    required this.onNoteTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: octaves.length,
      itemBuilder: (context, octaveIndex) {
        final octave = octaves.keys.toList()[octaveIndex];
        final notes = octaves[octave]!;
        return _OctaveRow(
          octave: octave,
          notes: notes,
          selectedNote: selectedNote,
          onNoteTap: onNoteTap,
          isDark: isDark,
        );
      },
    );
  }
}

class _OctaveRow extends StatelessWidget {
  final int octave;
  final List<MusicNote> notes;
  final MusicNote? selectedNote;
  final Function(MusicNote) onNoteTap;
  final bool isDark;

  const _OctaveRow({
    required this.octave,
    required this.notes,
    this.selectedNote,
    required this.onNoteTap,
    required this.isDark,
  });

  String _octaveLabel(int o) {
    switch (o) {
      case 3: return '低音';
      case 4: return '中音';
      case 5: return '高音';
      case 6: return '倍高音';
      case 7: return '超高音';
      default: return '八度 $o';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyWidth = (screenWidth - 16) / 7;
    final colors = ThemeColors(isDark);

    final whiteKeyColor = isDark ? const Color(0xFFE8E8E8) : const Color(0xFFFFFFFF);
    final whiteKeyBorder = isDark ? const Color(0xFF999999) : const Color(0xFFBBBBBB);
    final whiteKeyTextColor = const Color(0xFF333333);
    final whiteKeySubColor = const Color(0xFF777777);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Text(
              '八度 $octave · ${_octaveLabel(octave)}',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: Row(
              children: List.generate(7, (i) {
                final note = notes[i];
                final isSelected = selectedNote?.midiNumber == note.midiNumber;
                return GestureDetector(
                  onTap: () => onNoteTap(note),
                  child: Container(
                    width: keyWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : whiteKeyColor,
                      border: Border.all(color: whiteKeyBorder, width: 0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(note.solfege, style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : whiteKeyTextColor,
                        )),
                        Text(note.name, style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white70 : whiteKeySubColor,
                        )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
