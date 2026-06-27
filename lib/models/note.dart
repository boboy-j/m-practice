/// 音符模型
class MusicNote {
  final String name;    // 音名，如 "C4", "D4"
  final double frequency; // 频率 Hz
  final int midiNumber;   // MIDI 编号

  const MusicNote({
    required this.name,
    required this.frequency,
    required this.midiNumber,
  });

  /// 标准音域 C4 ~ C5 (一个八度 + 标准音)
  static const List<MusicNote> standardRange = [
    MusicNote(name: 'C4 (do)', frequency: 261.63, midiNumber: 60),
    MusicNote(name: 'D4 (re)', frequency: 293.66, midiNumber: 62),
    MusicNote(name: 'E4 (mi)', frequency: 329.63, midiNumber: 64),
    MusicNote(name: 'F4 (fa)', frequency: 349.23, midiNumber: 65),
    MusicNote(name: 'G4 (sol)', frequency: 392.00, midiNumber: 67),
    MusicNote(name: 'A4 (la)', frequency: 440.00, midiNumber: 69),
    MusicNote(name: 'B4 (si)', frequency: 493.88, midiNumber: 71),
  ];

  @override
  String toString() => 'MusicNote($name, ${frequency.toStringAsFixed(2)}Hz)';
}
