/// 音符模型 — 支持多八度
class MusicNote {
  final String name;       // 音名 如 "C4"
  final String solfege;    // 唱名 如 "do"
  final double frequency;  // 频率 Hz
  final int midiNumber;    // MIDI 编号
  final int octave;        // 八度编号

  const MusicNote({
    required this.name,
    required this.solfege,
    required this.frequency,
    required this.midiNumber,
    required this.octave,
  });

  /// 5 个八度的音域 C3 ~ B7（35个音）
  static const List<MusicNote> fullRange = [
    // 八度 3 (低音)
    MusicNote(name: 'C3', solfege: 'do', frequency: 130.81, midiNumber: 48, octave: 3),
    MusicNote(name: 'D3', solfege: 're', frequency: 146.83, midiNumber: 50, octave: 3),
    MusicNote(name: 'E3', solfege: 'mi', frequency: 164.81, midiNumber: 52, octave: 3),
    MusicNote(name: 'F3', solfege: 'fa', frequency: 174.61, midiNumber: 53, octave: 3),
    MusicNote(name: 'G3', solfege: 'sol', frequency: 196.00, midiNumber: 55, octave: 3),
    MusicNote(name: 'A3', solfege: 'la', frequency: 220.00, midiNumber: 57, octave: 3),
    MusicNote(name: 'B3', solfege: 'si', frequency: 246.94, midiNumber: 59, octave: 3),
    // 八度 4 (中音 / 标准音)
    MusicNote(name: 'C4', solfege: 'do', frequency: 261.63, midiNumber: 60, octave: 4),
    MusicNote(name: 'D4', solfege: 're', frequency: 293.66, midiNumber: 62, octave: 4),
    MusicNote(name: 'E4', solfege: 'mi', frequency: 329.63, midiNumber: 64, octave: 4),
    MusicNote(name: 'F4', solfege: 'fa', frequency: 349.23, midiNumber: 65, octave: 4),
    MusicNote(name: 'G4', solfege: 'sol', frequency: 392.00, midiNumber: 67, octave: 4),
    MusicNote(name: 'A4', solfege: 'la', frequency: 440.00, midiNumber: 69, octave: 4),
    MusicNote(name: 'B4', solfege: 'si', frequency: 493.88, midiNumber: 71, octave: 4),
    // 八度 5 (高音)
    MusicNote(name: 'C5', solfege: 'do', frequency: 523.25, midiNumber: 72, octave: 5),
    MusicNote(name: 'D5', solfege: 're', frequency: 587.33, midiNumber: 74, octave: 5),
    MusicNote(name: 'E5', solfege: 'mi', frequency: 659.25, midiNumber: 76, octave: 5),
    MusicNote(name: 'F5', solfege: 'fa', frequency: 698.46, midiNumber: 77, octave: 5),
    MusicNote(name: 'G5', solfege: 'sol', frequency: 783.99, midiNumber: 79, octave: 5),
    MusicNote(name: 'A5', solfege: 'la', frequency: 880.00, midiNumber: 81, octave: 5),
    MusicNote(name: 'B5', solfege: 'si', frequency: 987.77, midiNumber: 83, octave: 5),
    // 八度 6 (倍高音)
    MusicNote(name: 'C6', solfege: 'do', frequency: 1046.50, midiNumber: 84, octave: 6),
    MusicNote(name: 'D6', solfege: 're', frequency: 1174.66, midiNumber: 86, octave: 6),
    MusicNote(name: 'E6', solfege: 'mi', frequency: 1318.51, midiNumber: 88, octave: 6),
    MusicNote(name: 'F6', solfege: 'fa', frequency: 1396.91, midiNumber: 89, octave: 6),
    MusicNote(name: 'G6', solfege: 'sol', frequency: 1567.98, midiNumber: 91, octave: 6),
    MusicNote(name: 'A6', solfege: 'la', frequency: 1760.00, midiNumber: 93, octave: 6),
    MusicNote(name: 'B6', solfege: 'si', frequency: 1975.53, midiNumber: 95, octave: 6),
    // 八度 7 (超高音)
    MusicNote(name: 'C7', solfege: 'do', frequency: 2093.00, midiNumber: 96, octave: 7),
    MusicNote(name: 'D7', solfege: 're', frequency: 2349.32, midiNumber: 98, octave: 7),
    MusicNote(name: 'E7', solfege: 'mi', frequency: 2637.02, midiNumber: 100, octave: 7),
    MusicNote(name: 'F7', solfege: 'fa', frequency: 2793.83, midiNumber: 101, octave: 7),
    MusicNote(name: 'G7', solfege: 'sol', frequency: 3135.96, midiNumber: 103, octave: 7),
    MusicNote(name: 'A7', solfege: 'la', frequency: 3520.00, midiNumber: 105, octave: 7),
    MusicNote(name: 'B7', solfege: 'si', frequency: 3951.07, midiNumber: 107, octave: 7),
  ];

  /// 标准音域 C4 ~ B4（向后兼容）
  static const List<MusicNote> standardRange = [
    MusicNote(name: 'C4', solfege: 'do', frequency: 261.63, midiNumber: 60, octave: 4),
    MusicNote(name: 'D4', solfege: 're', frequency: 293.66, midiNumber: 62, octave: 4),
    MusicNote(name: 'E4', solfege: 'mi', frequency: 329.63, midiNumber: 64, octave: 4),
    MusicNote(name: 'F4', solfege: 'fa', frequency: 349.23, midiNumber: 65, octave: 4),
    MusicNote(name: 'G4', solfege: 'sol', frequency: 392.00, midiNumber: 67, octave: 4),
    MusicNote(name: 'A4', solfege: 'la', frequency: 440.00, midiNumber: 69, octave: 4),
    MusicNote(name: 'B4', solfege: 'si', frequency: 493.88, midiNumber: 71, octave: 4),
  ];

  @override
  String toString() => 'MusicNote($name, ${frequency.toStringAsFixed(2)}Hz)';
}
