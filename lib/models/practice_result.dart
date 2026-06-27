/// 练习结果模型
class PracticeResult {
  final DateTime dateTime;
  final String mode;          // 'pitch' | 'rhythm' | 'score'
  final double accuracy;      // 0.0 ~ 1.0
  final int totalNotes;
  final int correctNotes;
  final Duration duration;

  const PracticeResult({
    required this.dateTime,
    required this.mode,
    required this.accuracy,
    required this.totalNotes,
    required this.correctNotes,
    required this.duration,
  });

  String get accuracyPercent => '${(accuracy * 100).toStringAsFixed(1)}%';

  @override
  String toString() =>
      'PracticeResult($mode, $accuracyPercent, $correctNotes/$totalNotes)';
}
