import 'dart:async';
import 'package:flutter/material.dart';
import '../models/rhythm_pattern.dart';
import 'audio_generator.dart';

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

  final AudioGenerator _audioGen;

  final StreamController<List<int>> _beatController =
      StreamController<List<int>>.broadcast();

  MetronomeService({AudioGenerator? audioGen})
      : _audioGen = audioGen ?? AudioGenerator();

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

  /// 启动节拍器（先预加载音频，确保首次点击能响）
  Future<void> start() async {
    if (_currentPattern == null) return;
    await _audioGen.preloadClicks();
    _isCountingIn = true;
    _countInRemaining = 4;
    _currentBeat = -4;
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
    _timer = _scheduleNextBeat();
  }

  Timer? _scheduleNextBeat() {
    int interval;
    if (_isCountingIn) {
      interval = (60000 / _bpm).round();
    } else {
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
      _beatController.add([_currentBeat, 4 + _totalBeatCount, _countInRemaining == 3 ? 1 : 0]);
      if (_countInRemaining == 3) {
        _audioGen.playAccent();
      } else {
        _audioGen.playClick();
      }
      if (_countInRemaining <= 0) {
        _isCountingIn = false;
        _currentBeat = 0;
        _beatInCycle = 0;
      }
    } else {
      final isAccent = _beatInCycle == 0;
      _beatController.add([_currentBeat, _totalBeats, isAccent ? 1 : 0]);
      if (isAccent) {
        _audioGen.playAccent();
      } else {
        _audioGen.playClick();
      }
      _beatInCycle++;
      _currentBeat++;
      _totalBeatCount++;
      if (_beatInCycle >= _currentPattern!.subdivisions) {
        _beatInCycle = 0;
        _currentBeat = 0;
      }
    }

    notifyListeners();
    _timer = _scheduleNextBeat();
  }

  @override
  void dispose() {
    stop();
    _beatController.close();
    _audioGen.dispose();
    super.dispose();
  }
}
