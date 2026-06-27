/// 应用常量
class AppConstants {
  AppConstants._();

  // 节奏型定义
  static const List<RhythmPatternDef> rhythmPatterns = [
    RhythmPatternDef(name: '四分音符', beats: [1.0]),
    RhythmPatternDef(name: '八分音符', beats: [0.5, 0.5]),
    RhythmPatternDef(name: '十六分音符', beats: [0.25, 0.25, 0.25, 0.25]),
    RhythmPatternDef(name: '前八后十六', beats: [0.5, 0.25, 0.25]),
    RhythmPatternDef(name: '前十六后八', beats: [0.25, 0.25, 0.5]),
    RhythmPatternDef(name: '附点节奏', beats: [0.75, 0.25]),
    RhythmPatternDef(name: '切分节奏', beats: [0.5, 1.0, 0.5]),
    RhythmPatternDef(name: '三连音', beats: [1/3, 1/3, 1/3]),
  ];

  // 节拍检测容差（秒）
  static const double rhythmTolerance = 0.08;

  // 音准检测容差（音分）
  static const double pitchToleranceCents = 10.0;

  // 默认 BPM
  static const int defaultBpm = 80;
}

/// 节奏型定义
class RhythmPatternDef {
  final String name;
  final List<double> beats; // 相对于一拍的时长比例

  const RhythmPatternDef({required this.name, required this.beats});

  /// 获取该节奏型在指定 BPM 下的各音符时长（秒）
  List<double> durationsAtBpm(int bpm) {
    final beatDuration = 60.0 / bpm;
    return beats.map((b) => b * beatDuration).toList();
  }
}
