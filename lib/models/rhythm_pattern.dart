/// 节奏型数据模型
class RhythmPattern {
  final String name;
  final List<double> beatFractions; // 相对于一拍的时长比例
  final int subdivisions;           // 子拍数量

  const RhythmPattern({
    required this.name,
    required this.beatFractions,
    required this.subdivisions,
  });

  /// 在某 BPM 下的各音持续时间（毫秒）
  List<int> durationsMs(int bpm) {
    final beatMs = (60000 / bpm).round();
    return beatFractions.map((f) => (f * beatMs).round()).toList();
  }

  /// 该节奏型中所有 "击打" 的时刻点（毫秒，从0开始累计）
  List<int> hitPointsMs(int bpm) {
    final durs = durationsMs(bpm);
    final hits = <int>[0];
    for (int i = 0; i < durs.length - 1; i++) {
      hits.add(hits.last + durs[i]);
    }
    return hits;
  }

  @override
  String toString() => 'RhythmPattern($name)';
}
