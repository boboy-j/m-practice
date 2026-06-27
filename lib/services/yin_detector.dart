import 'dart:typed_data';

/// YIN 音高检测算法 — 纯 Dart 实现
///
/// 参考文献: De Cheveigné & Kawahara (2002) "YIN, a fundamental frequency estimator"
class YinDetector {
  final int sampleRate;
  final double threshold;
  final int minFreq;
  final int maxFreq;

  /// [sampleRate] 采样率，如 44100
  /// [threshold] 检测阈值，越低越严格（默认 0.15）
  /// [minFreq] 最小检测频率 Hz（默认 60）
  /// [maxFreq] 最大检测频率 Hz（默认 2000）
  YinDetector({
    this.sampleRate = 44100,
    this.threshold = 0.15,
    this.minFreq = 60,
    this.maxFreq = 2000,
  });

  /// 检测一段音频帧的基频（Hz），无有效音高时返回 null
  double? detectPitch(List<double> samples) {
    if (samples.isEmpty) return null;

    final n = samples.length;
    final minPeriod = (sampleRate / maxFreq).round();
    final maxPeriod = (sampleRate / minFreq).round();

    // 1. 计算差分函数 d_t(τ)
    final diff = Float64List(maxPeriod + 1);
    for (int tau = 0; tau <= maxPeriod; tau++) {
      if (tau < minPeriod) {
        diff[tau] = double.infinity;
        continue;
      }
      double sum = 0;
      final limit = n - tau;
      for (int j = 0; j < limit; j++) {
        final delta = samples[j] - samples[j + tau];
        sum += delta * delta;
      }
      diff[tau] = sum;
    }

    // 2. 累积均值归一化差分函数 d'(τ)
    final cmndf = Float64List(maxPeriod + 1);
    cmndf[0] = 1.0;
    double runningSum = 0;
    for (int tau = 1; tau <= maxPeriod; tau++) {
      runningSum += diff[tau];
      cmndf[tau] = tau < minPeriod
          ? 1.0
          : diff[tau] * tau / runningSum;
    }

    // 3. 绝对阈值检测：找到第一个低于阈值的 τ
    int? tauEstimate;
    for (int tau = minPeriod; tau <= maxPeriod; tau++) {
      if (cmndf[tau] < threshold) {
        // 继续寻找更低的值
        while (tau + 1 <= maxPeriod && cmndf[tau + 1] < cmndf[tau]) {
          tau++;
        }
        tauEstimate = tau;
        break;
      }
    }

    if (tauEstimate == null) {
      // 未找到低于阈值的周期，取全局最小值
      double minVal = double.infinity;
      int minTau = minPeriod;
      for (int tau = minPeriod; tau <= maxPeriod; tau++) {
        if (cmndf[tau] < minVal) {
          minVal = cmndf[tau];
          minTau = tau;
        }
      }
      if (minVal >= 0.5) return null; // 没有明显音高
      tauEstimate = minTau;
    }

    // 4. 抛物线插值提高精度
    final betterTau = _parabolicInterpolation(cmndf, tauEstimate);

    return sampleRate / betterTau;
  }

  /// 抛物线插值：用前一点、当前点、后一点拟合抛物线，取极小值位置
  double _parabolicInterpolation(Float64List cmndf, int tau) {
    if (tau < 1 || tau >= cmndf.length - 1) return tau.toDouble();

    final y0 = cmndf[tau - 1];
    final y1 = cmndf[tau];
    final y2 = cmndf[tau + 1];

    // 抛物线插值公式: tau + (y2 - y0) / (2 * (2*y1 - y0 - y2))
    final denominator = 2 * (2 * y1 - y0 - y2);
    if (denominator.abs() < 1e-10) return tau.toDouble();

    return tau + (y2 - y0) / denominator;
  }
}
