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
  bool _useSimulation = true;
  late PageController _pageController;
  int _currentOctaveIdx = 1; // 默认 C4（八度4）

  // 按八度分组
  late final List<int> _octaveKeys;
  late final Map<int, List<MusicNote>> _octaves;

  @override
  void initState() {
    super.initState();
    _octaves = {};
    for (final note in MusicNote.fullRange) {
      _octaves.putIfAbsent(note.octave, () => []);
      _octaves[note.octave]!.add(note);
    }
    _octaveKeys = _octaves.keys.toList()..sort();
    _pageController = PageController(initialPage: _currentOctaveIdx);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      _playReferenceNote(MusicNote.fullRange[11]);
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
      detector.simulateFrequency(target * pow(2, 18.0 * drift / 1200));
      return _isActive && _useSimulation;
    });
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark);

    return Consumer<PitchDetectorService>(
      builder: (context, detector, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('音准练习'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () { _stop(); Navigator.pop(context); },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 仪表盘（紧凑）
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: PitchMeter(currentCents: detector.currentCents, isDark: isDark),
                ),
                // 评价 + 目标音
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(detector.evaluation,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _evalColor(detector))),
                      if (_selectedNote != null)
                        Text('目标：${_selectedNote!.name} (${_selectedNote!.solfege})  ${_selectedNote!.frequency.toStringAsFixed(1)} Hz',
                            style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                // 模式切换
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _chip('模拟', Icons.smart_toy, _useSimulation, colors, _isActive ? null : () => setState(() => _useSimulation = true)),
                    const SizedBox(width: 8),
                    _chip('麦克风', Icons.mic, !_useSimulation, colors, _isActive ? null : () => setState(() => _useSimulation = false)),
                  ],
                ),
                // 八度指示器
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        onPressed: _currentOctaveIdx > 0
                            ? () => _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut)
                            : null,
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36),
                      ),
                      Text('八度 ${_octaveKeys[_currentOctaveIdx]} · ${_octaveLabel(_octaveKeys[_currentOctaveIdx])}',
                          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 28),
                        onPressed: _currentOctaveIdx < _octaveKeys.length - 1
                            ? () => _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut)
                            : null,
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36),
                      ),
                    ],
                  ),
                ),
                // PageView 钢琴键盘
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentOctaveIdx = i),
                    itemCount: _octaveKeys.length,
                    itemBuilder: (context, index) {
                      final octave = _octaveKeys[index];
                      final notes = _octaves[octave]!;
                      return _OctavePage(
                        notes: notes,
                        selectedNote: _selectedNote,
                        onNoteTap: _playReferenceNote,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
                // 底部按钮
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 4, 32, 12),
                  child: ElevatedButton.icon(
                    onPressed: _togglePractice,
                    icon: Icon(_isActive ? Icons.stop : Icons.play_arrow),
                    label: Text(_isActive ? '停止' : '开始练习'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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

  Color _evalColor(PitchDetectorService d) {
    if (d.currentCents == null) return Colors.grey;
    final c = d.currentCents!.abs();
    if (c <= 5) return AppTheme.correctColor;
    if (c <= 15) return AppTheme.secondaryColor;
    if (c <= 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Widget _chip(String label, IconData icon, bool selected, ThemeColors colors, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withValues(alpha: 0.2) : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppTheme.primaryColor : colors.textSecondary.withValues(alpha: 0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: selected ? AppTheme.primaryColor : colors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: selected ? AppTheme.primaryColor : colors.textSecondary, fontSize: 12)),
        ]),
      ),
    );
  }
}

/// 单个八度的钢琴键盘（大按键，适合手指点击）
class _OctavePage extends StatelessWidget {
  final List<MusicNote> notes;
  final MusicNote? selectedNote;
  final Function(MusicNote) onNoteTap;
  final bool isDark;

  const _OctavePage({required this.notes, this.selectedNote, required this.onNoteTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyWidth = (screenWidth - 20) / 7;
    final whiteBg = isDark ? const Color(0xFFE8E8E8) : Colors.white;
    final whiteBorder = isDark ? const Color(0xFF999999) : const Color(0xFFCCCCCC);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          const Spacer(),
          // 键名标签
          Row(
            children: notes.map((n) => SizedBox(
              width: keyWidth,
              child: Center(child: Text(n.solfege,
                  style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontSize: 16, fontWeight: FontWeight.w700))),
            )).toList(),
          ),
          const SizedBox(height: 6),
          // 琴键
          SizedBox(
            height: 100,
            child: Row(
              children: List.generate(7, (i) {
                final note = notes[i];
                final isSel = selectedNote?.midiNumber == note.midiNumber;
                return GestureDetector(
                  onTap: () => onNoteTap(note),
                  child: Container(
                    width: keyWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primaryColor : whiteBg,
                      border: Border.all(color: whiteBorder, width: 0.5),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(0, 2), blurRadius: 3)],
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      note.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSel ? Colors.white : const Color(0xFF333333)),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
