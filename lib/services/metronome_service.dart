import 'dart:async';
import 'package:flutter/material.dart';
import '../models/rhythm_pattern.dart';

/// 节拍器服务 — 管理节拍器状态和节奏型练习
class MetronomeService extends ChangeNotifier {
  int _bpm = 80;
  RhythmPattern? _currentPattern;
  int _currentBeat = 0;
  int _totalBeats = 0;
  bool _isRunning = false;
  bool _isCountingIn = false;
  Timer? _timer;
  int _beatInCycle = 0;
  int _totalBeatCount = 0;
  List<double>? _currentDurations;
  int _countInRemaining = 0;

  // Stream broadcast: [beatIndex, totalBeats, isAccent(0|1)]
  final StreamController<List<int>> _beatController =
      StreamController<List<int>>.broadcast();

  int get bpm => _bpm;
  RhythmPattern? get currentPattern => _currentPattern;
  int get currentBeat => _currentBeat;
  int get totalBeats => _totalBeats;
  bool get isRunning => _isRunning;
  bool get isCountingIn => _isCountingIn;
  Stream<List<int>> get beatStream => _beatController.stream;
  int get beatInCycle => _beatInCycle;

  void setBpm(int bpm) {
    _bpm = bpm.clamp(40, 240);
    if (_isRunning) {
      stop();
      start();
    }
    notifyListeners();
  }

  void setPattern(RhythmPattern pattern) {
    _currentPattern = pattern;
    _totalBeats = pattern.subdivisions;
    notifyListeners();
  }

  /// 启动节拍器，含 4 拍预备拍
  void start() {
    if (_currentPattern == null) return;
    _isCountingIn = true;
    _countInRemaining = 4;
    _currentBeat = -4; // 负数为预备拍
    _beatInCycle = 0;
    _totalBeatCount = 0;
    _currentDurations = _currentPattern!.durationsMs(_bpm).map((d) => d.toDouble()).toList();
    _isRunning = true;
    _startTimer();
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isCountingIn = false;
    _countInRemaining = 0;
    _currentBeat = 0;
    _beatInCycle = 0;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    // 预备拍间隔 = 一个整拍
    final countInInterval = (60000 / _bpm).round();
    _timer = Timer.periodic(Duration(milliseconds: countInInterval ~/ 4), (timer) {
      // 使用更小的 tick 来更精确地控制
    });
    _timer?.cancel();
    _timer = _scheduleNextBeat();
  }

  Timer? _scheduleNextBeat() {
    int interval;
    if (_isCountingIn) {
      interval = (60000 / _bpm).round(); // 预备拍 = 一个四分音符
    } else {
      // 正式节奏：按节奏型中的下一个音
      final idx = _beatInCycle % _currentPattern!.subdivisions;
      interval = _currentDurations![idx].round();
    }
    return Timer(Duration(milliseconds: interval), _onBeat);
  }

  void _onBeat() {
    if (!_isRunning) return;

    if (_isCountingIn) {
      _countInRemaining--;
      _currentBeat++;
      // 预备拍视为四分音符
      _beatController.add([_currentBeat, 4 + _totalBeatCount, _countInRemaining == 3 ? 1 : 0]);
      if (_countInRemaining <= 0) {
        _isCountingIn = false;
        _currentBeat = 0;
        _beatInCycle = 0;
      }
    } else {
      _beatController.add([_currentBeat, _totalBeats, _beatInCycle == 0 ? 1 : 0]);
      _beatInCycle++;
      _currentBeat++;
      _totalBeatCount++;
      if (_beatInCycle >= _currentPattern!.subdivisions) {
        _beatInCycle = 0;
        _currentBeat = 0; // 重置到当前循环的起点
      }
    }

    notifyListeners();
    _timer = _scheduleNextBeat();
  }

  @override
  void dispose() {
    stop();
    _beatController.close();
    super.dispose();
  }
}
