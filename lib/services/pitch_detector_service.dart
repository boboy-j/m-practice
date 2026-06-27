import 'dart:math';
import 'package:flutter/material.dart';

/// 音高检测服务（POC 阶段使用模拟数据）
///
/// 第二阶段将接入 YIN 算法进行真实麦克风音高检测
class PitchDetectorService extends ChangeNotifier {
  double? _currentFrequency;
  double? _targetFrequency;
  double? _currentCents; // 偏离音分
  bool _isListening = false;

  double? get currentFrequency => _currentFrequency;
  double? get targetFrequency => _targetFrequency;
  double? get currentCents => _currentCents;
  bool get isListening => _isListening;

  /// 音分差 → 文字评价
  String get evaluation {
    if (_currentCents == null) return '等待输入...';
    final c = _currentCents!.abs();
    if (c <= 5) return '完美！';
    if (c <= 15) return '很好';
    if (c <= 30) return '偏低/偏高';
    if (c <= 50) return '偏离较大';
    return '请重新校准';
  }

  /// 设置目标音高
  void setTarget(double frequency) {
    _targetFrequency = frequency;
    notifyListeners();
  }

  /// 模拟实时音高输入
  void simulateFrequency(double frequency) {
    _currentFrequency = frequency;
    if (_targetFrequency != null && _targetFrequency! > 0) {
      _currentCents = 1200 * (_log2(frequency / _targetFrequency!));
    }
    notifyListeners();
  }

  void clear() {
    _currentFrequency = null;
    _currentCents = null;
    notifyListeners();
  }

  double _log2(double x) {
    if (x <= 0) return 0;
    return log(x) / log(2);
  }
}
