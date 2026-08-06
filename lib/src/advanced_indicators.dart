import 'dart:math';
import 'market_data/twelve_data_service.dart';

class AdvancedIndicators {
  static List<double> sma(List<double> values, int period) {
    final out = <double>[];
    for (int i = 0; i < values.length; i++) {
      if (i + 1 < period) {
        out.add(values[i]);
      } else {
        final window = values.sublist(i + 1 - period, i + 1);
        out.add(window.reduce((a, b) => a + b) / period);
      }
    }
    return out;
  }

  static List<double> emaSeries(List<double> values, int period) {
    if (values.isEmpty) return [];
    final out = List<double>.filled(values.length, values.first);
    final k = 2 / (period + 1);
    double current = values.take(min(period, values.length))
            .reduce((a, b) => a + b) /
        min(period, values.length);
    for (int i = 0; i < values.length; i++) {
      if (i < period - 1) {
        out[i] = values[i];
      } else if (i == period - 1) {
        out[i] = current;
      } else {
        current = values[i] * k + current * (1 - k);
        out[i] = current;
      }
    }
    return out;
  }

  static double rsi(List<double> closes, {int period = 14}) {
    if (closes.length <= period) return 50;
    double gains = 0;
    double losses = 0;
    for (int i = closes.length - period; i < closes.length; i++) {
      final diff = closes[i] - closes[i - 1];
      if (diff >= 0) {
        gains += diff;
      } else {
        losses += diff.abs();
      }
    }
    if (losses == 0) return 100;
    final rs = (gains / period) / (losses / period);
    return 100 - (100 / (1 + rs));
  }

  static (double, double) macd(List<double> closes) {
    final ema12 = emaSeries(closes, 12);
    final ema26 = emaSeries(closes, 26);
    final macdSeries = <double>[];
    for (int i = 0; i < closes.length; i++) {
      macdSeries.add(ema12[i] - ema26[i]);
    }
    final signal = emaSeries(macdSeries, 9);
    return (macdSeries.last, signal.last);
  }

  static (double, double, double) bollinger(
    List<double> closes, {
    int period = 20,
    double deviations = 2,
  }) {
    final window = closes.sublist(max(0, closes.length - period));
    final mean = window.reduce((a, b) => a + b) / window.length;
    final variance =
        window.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
            window.length;
    final std = sqrt(variance);
    return (mean + deviations * std, mean, mean - deviations * std);
  }

  static double atr(List<LiveCandle> candles, {int period = 14}) {
    if (candles.length < 2) return 0;
    final start = max(1, candles.length - period);
    final tr = <double>[];
    for (int i = start; i < candles.length; i++) {
      final highLow = candles[i].high - candles[i].low;
      final highClose = (candles[i].high - candles[i - 1].close).abs();
      final lowClose = (candles[i].low - candles[i - 1].close).abs();
      tr.add(max(highLow, max(highClose, lowClose)));
    }
    return tr.isEmpty ? 0 : tr.reduce((a, b) => a + b) / tr.length;
  }

  static (double, double) supportResistance(
    List<LiveCandle> candles, {
    int lookback = 50,
  }) {
    final recent = candles.sublist(max(0, candles.length - lookback));
    final support = recent.map((c) => c.low).reduce(min);
    final resistance = recent.map((c) => c.high).reduce(max);
    return (support, resistance);
  }

  static String candlePattern(List<LiveCandle> candles) {
    if (candles.length < 2) return 'None';
    final previous = candles[candles.length - 2];
    final current = candles.last;
    final prevBull = previous.close > previous.open;
    final currBull = current.close > current.open;

    if (!prevBull &&
        currBull &&
        current.open <= previous.close &&
        current.close >= previous.open) {
      return 'Bullish Engulfing';
    }
    if (prevBull &&
        !currBull &&
        current.open >= previous.close &&
        current.close <= previous.open) {
      return 'Bearish Engulfing';
    }

    final body = (current.close - current.open).abs();
    final range = max(current.high - current.low, 0.0000001);
    if (body / range < 0.15) return 'Doji';

    final lowerWick = min(current.open, current.close) - current.low;
    final upperWick = current.high - max(current.open, current.close);
    if (lowerWick > body * 2 && upperWick < body) return 'Hammer';
    if (upperWick > body * 2 && lowerWick < body) return 'Shooting Star';
    return currBull ? 'Bullish Candle' : 'Bearish Candle';
  }
}
