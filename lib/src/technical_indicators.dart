import 'dart:math';
import 'stage6_models.dart';

class TechnicalIndicators {
  static List<double?> ema(List<double> values, int period) {
    if (values.isEmpty || period <= 0) return List.filled(values.length, null);
    final result = List<double?>.filled(values.length, null);
    if (values.length < period) return result;

    double seed = 0;
    for (int i = 0; i < period; i++) {
      seed += values[i];
    }
    seed /= period;
    result[period - 1] = seed;

    final multiplier = 2 / (period + 1);
    double previous = seed;
    for (int i = period; i < values.length; i++) {
      final next = (values[i] - previous) * multiplier + previous;
      result[i] = next;
      previous = next;
    }
    return result;
  }

  static double normalizedMomentum(List<double> closes, int index,
      {int lookback = 5}) {
    if (index < lookback) return 0;
    final start = closes[index - lookback];
    if (start == 0) return 0;
    final raw = (closes[index] - start) / start;
    return (raw * 300).clamp(-1.0, 1.0);
  }

  static double normalizedVolatility(
      List<Candle> candles, int index, int lookback) {
    if (index < lookback) return 0;
    final returns = <double>[];
    for (int i = index - lookback + 1; i <= index; i++) {
      final previous = candles[i - 1].close;
      if (previous != 0) {
        returns.add((candles[i].close - previous) / previous);
      }
    }
    if (returns.isEmpty) return 0;
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns
            .map((r) => pow(r - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        returns.length;
    return (sqrt(variance) * 800).clamp(0.0, 1.0);
  }

  static double volumeStrength(List<Candle> candles, int index,
      {int lookback = 20}) {
    if (index < lookback) return 0.5;
    double avg = 0;
    for (int i = index - lookback; i < index; i++) {
      avg += candles[i].volume;
    }
    avg /= lookback;
    if (avg <= 0) return 0.5;
    return (candles[index].volume / avg / 2).clamp(0.0, 1.0);
  }

  static MarketSession sessionFor(DateTime utc) {
    final hour = utc.toUtc().hour;
    if (hour >= 0 && hour < 7) return MarketSession.asian;
    if (hour >= 7 && hour < 12) return MarketSession.london;
    if (hour >= 12 && hour < 16) return MarketSession.overlap;
    if (hour >= 16 && hour < 21) return MarketSession.newYork;
    return MarketSession.offHours;
  }
}
