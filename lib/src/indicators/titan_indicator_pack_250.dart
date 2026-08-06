import 'dart:math';

class IndicatorCandle {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const IndicatorCandle({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

enum IndicatorCategory {
  trend,
  momentum,
  volatility,
  volume,
  structure,
}

abstract class TitanIndicator {
  String get id;
  String get name;
  IndicatorCategory get category;
  String get description;
  double calculate(List<IndicatorCandle> candles);
}

class IndicatorMath {
  static List<double> closes(List<IndicatorCandle> c) =>
      c.map((e) => e.close).toList();

  static double sma(List<double> values, int period) {
    if (values.isEmpty) return 0;
    final p = min(period, values.length);
    return values.sublist(values.length - p).reduce((a, b) => a + b) / p;
  }

  static List<double> emaSeries(List<double> values, int period) {
    if (values.isEmpty) return [];
    final out = <double>[];
    final p = max(1, min(period, values.length));
    double current = values.take(p).reduce((a, b) => a + b) / p;
    final k = 2 / (p + 1);
    for (int i = 0; i < values.length; i++) {
      if (i < p - 1) {
        out.add(values[i]);
      } else if (i == p - 1) {
        out.add(current);
      } else {
        current = values[i] * k + current * (1 - k);
        out.add(current);
      }
    }
    return out;
  }

  static double ema(List<double> values, int period) =>
      emaSeries(values, period).last;

  static double wma(List<double> values, int period) {
    if (values.isEmpty) return 0;
    final p = min(period, values.length);
    final window = values.sublist(values.length - p);
    double weighted = 0;
    double denom = 0;
    for (int i = 0; i < window.length; i++) {
      final weight = i + 1;
      weighted += window[i] * weight;
      denom += weight;
    }
    return denom == 0 ? 0 : weighted / denom;
  }

  static double hma(List<double> values, int period) {
    if (values.isEmpty) return 0;
    final p = max(2, min(period, values.length));
    final half = max(1, p ~/ 2);
    final sqrtP = max(1, sqrt(p).round());
    final synthetic = <double>[];
    for (int i = 0; i < values.length; i++) {
      final sub = values.sublist(0, i + 1);
      synthetic.add(2 * wma(sub, half) - wma(sub, p));
    }
    return wma(synthetic, sqrtP);
  }

  static double dema(List<double> values, int period) {
    final e1 = emaSeries(values, period);
    final e2 = emaSeries(e1, period);
    return 2 * e1.last - e2.last;
  }

  static double tema(List<double> values, int period) {
    final e1 = emaSeries(values, period);
    final e2 = emaSeries(e1, period);
    final e3 = emaSeries(e2, period);
    return 3 * e1.last - 3 * e2.last + e3.last;
  }

  static double zlema(List<double> values, int period) {
    if (values.isEmpty) return 0;
    final lag = max(1, (period - 1) ~/ 2);
    final adjusted = <double>[];
    for (int i = 0; i < values.length; i++) {
      final lagged = i - lag >= 0 ? values[i - lag] : values[i];
      adjusted.add(values[i] + (values[i] - lagged));
    }
    return ema(adjusted, period);
  }

  static double kama(List<double> values, int period) {
    if (values.isEmpty) return 0;
    final p = min(period, values.length - 1);
    if (p <= 0) return values.last;
    double change = (values.last - values[values.length - 1 - p]).abs();
    double volatility = 0;
    for (int i = values.length - p; i < values.length; i++) {
      volatility += (values[i] - values[i - 1]).abs();
    }
    final er = volatility == 0 ? 0.0 : change / volatility;
    final fast = 2 / (2 + 1);
    final slow = 2 / (30 + 1);
    final sc = pow(er * (fast - slow) + slow, 2).toDouble();
    double current = values[values.length - 1 - p];
    for (int i = values.length - p; i < values.length; i++) {
      current += sc * (values[i] - current);
    }
    return current;
  }

  static double rsi(List<double> values, int period) {
    if (values.length < 2) return 50;
    final p = min(period, values.length - 1);
    double gains = 0;
    double losses = 0;
    for (int i = values.length - p; i < values.length; i++) {
      final d = values[i] - values[i - 1];
      if (d >= 0) {
        gains += d;
      } else {
        losses += d.abs();
      }
    }
    if (losses == 0) return 100;
    final rs = gains / max(losses, 1e-12);
    return 100 - (100 / (1 + rs));
  }

  static double stochastic(List<IndicatorCandle> candles, int period) {
    if (candles.isEmpty) return 50;
    final p = min(period, candles.length);
    final recent = candles.sublist(candles.length - p);
    final hi = recent.map((e) => e.high).reduce(max);
    final lo = recent.map((e) => e.low).reduce(min);
    if (hi == lo) return 50;
    return (candles.last.close - lo) / (hi - lo) * 100;
  }

  static double stochasticRsi(List<double> values, int period) {
    if (values.length < period + 2) return 50;
    final rsis = <double>[];
    for (int i = period + 1; i <= values.length; i++) {
      rsis.add(rsi(values.sublist(0, i), period));
    }
    final p = min(period, rsis.length);
    final recent = rsis.sublist(rsis.length - p);
    final hi = recent.reduce(max);
    final lo = recent.reduce(min);
    if (hi == lo) return 50;
    return (rsis.last - lo) / (hi - lo) * 100;
  }

  static double roc(List<double> values, int period) {
    if (values.length <= period) return 0;
    final prev = values[values.length - 1 - period];
    return prev == 0 ? 0 : (values.last - prev) / prev * 100;
  }

  static double momentum(List<double> values, int period) {
    if (values.length <= period) return 0;
    return values.last - values[values.length - 1 - period];
  }

  static double williamsR(List<IndicatorCandle> candles, int period) {
    if (candles.isEmpty) return -50;
    final p = min(period, candles.length);
    final recent = candles.sublist(candles.length - p);
    final hi = recent.map((e) => e.high).reduce(max);
    final lo = recent.map((e) => e.low).reduce(min);
    if (hi == lo) return -50;
    return (hi - candles.last.close) / (hi - lo) * -100;
  }

  static double cci(List<IndicatorCandle> candles, int period) {
    if (candles.isEmpty) return 0;
    final p = min(period, candles.length);
    final tps = candles
        .sublist(candles.length - p)
        .map((e) => (e.high + e.low + e.close) / 3)
        .toList();
    final avg = tps.reduce((a, b) => a + b) / tps.length;
    final md =
        tps.map((v) => (v - avg).abs()).reduce((a, b) => a + b) / tps.length;
    if (md == 0) return 0;
    return (tps.last - avg) / (0.015 * md);
  }

  static double macd(List<double> values, int fast, int slow, int signal) {
    final fastSeries = emaSeries(values, fast);
    final slowSeries = emaSeries(values, slow);
    final diff = <double>[];
    for (int i = 0; i < values.length; i++) {
      diff.add(fastSeries[i] - slowSeries[i]);
    }
    final signalSeries = emaSeries(diff, signal);
    return diff.last - signalSeries.last;
  }

  static double trix(List<double> values, int period) {
    final e1 = emaSeries(values, period);
    final e2 = emaSeries(e1, period);
    final e3 = emaSeries(e2, period);
    if (e3.length < 2 || e3[e3.length - 2] == 0) return 0;
    return (e3.last - e3[e3.length - 2]) / e3[e3.length - 2] * 100;
  }

  static double cmo(List<double> values, int period) {
    if (values.length < 2) return 0;
    final p = min(period, values.length - 1);
    double up = 0;
    double down = 0;
    for (int i = values.length - p; i < values.length; i++) {
      final d = values[i] - values[i - 1];
      if (d >= 0) {
        up += d;
      } else {
        down += d.abs();
      }
    }
    final denom = up + down;
    return denom == 0 ? 0 : (up - down) / denom * 100;
  }

  static double ultimate(List<IndicatorCandle> candles, int s, int m, int l) {
    if (candles.length < 2) return 50;
    double avg(int period) {
      final p = min(period, candles.length - 1);
      double bp = 0;
      double tr = 0;
      for (int i = candles.length - p; i < candles.length; i++) {
        final minLowClose = min(candles[i].low, candles[i - 1].close);
        final maxHighClose = max(candles[i].high, candles[i - 1].close);
        bp += candles[i].close - minLowClose;
        tr += maxHighClose - minLowClose;
      }
      return tr == 0 ? 0.5 : bp / tr;
    }
    return 100 * (4 * avg(s) + 2 * avg(m) + avg(l)) / 7;
  }

  static double awesome(List<IndicatorCandle> candles, int fast, int slow) {
    final med = candles.map((e) => (e.high + e.low) / 2).toList();
    return sma(med, fast) - sma(med, slow);
  }

  static double fisher(List<IndicatorCandle> candles, int period) {
    final stoch = stochastic(candles, period) / 100;
    final x = (2 * stoch - 1).clamp(-0.999, 0.999);
    return 0.5 * log((1 + x) / (1 - x));
  }

  static double trueRange(List<IndicatorCandle> c, int i) {
    if (i == 0) return c[i].high - c[i].low;
    return max(
      c[i].high - c[i].low,
      max(
        (c[i].high - c[i - 1].close).abs(),
        (c[i].low - c[i - 1].close).abs(),
      ),
    );
  }

  static double atr(List<IndicatorCandle> candles, int period) {
    if (candles.isEmpty) return 0;
    final p = min(period, candles.length);
    double total = 0;
    for (int i = candles.length - p; i < candles.length; i++) {
      total += trueRange(candles, i);
    }
    return total / p;
  }

  static double stdDev(List<double> values, int period) {
    final p = min(period, values.length);
    final w = values.sublist(values.length - p);
    final mean = w.reduce((a, b) => a + b) / p;
    final variance =
        w.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / p;
    return sqrt(variance);
  }

  static double bollingerZ(List<double> values, int period, double deviations) {
    final mean = sma(values, period);
    final sd = stdDev(values, period);
    if (sd == 0) return 0;
    return (values.last - mean) / (sd * deviations);
  }

  static double keltnerPosition(
    List<IndicatorCandle> candles,
    int period,
    double multiplier,
  ) {
    final values = closes(candles);
    final mid = ema(values, period);
    final a = atr(candles, period);
    if (a == 0) return 0;
    return (values.last - mid) / (a * multiplier);
  }

  static double donchianPosition(List<IndicatorCandle> candles, int period) {
    final p = min(period, candles.length);
    final recent = candles.sublist(candles.length - p);
    final hi = recent.map((e) => e.high).reduce(max);
    final lo = recent.map((e) => e.low).reduce(min);
    if (hi == lo) return 0.5;
    return (candles.last.close - lo) / (hi - lo);
  }

  static double historicalVolatility(List<double> values, int period) {
    if (values.length < 2) return 0;
    final p = min(period, values.length - 1);
    final returns = <double>[];
    for (int i = values.length - p; i < values.length; i++) {
      if (values[i - 1] != 0) {
        returns.add(log(values[i] / values[i - 1]));
      }
    }
    if (returns.isEmpty) return 0;
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns
            .map((r) => pow(r - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        returns.length;
    return sqrt(variance) * sqrt(252) * 100;
  }

  static double chaikinVolatility(List<IndicatorCandle> candles, int period) {
    final ranges = candles.map((e) => e.high - e.low).toList();
    if (ranges.length <= period) return 0;
    final e = emaSeries(ranges, period);
    final prev = e[e.length - 1 - period];
    return prev == 0 ? 0 : (e.last - prev) / prev * 100;
  }

  static double massIndex(List<IndicatorCandle> candles, int period) {
    final ranges = candles.map((e) => e.high - e.low).toList();
    final e1 = emaSeries(ranges, 9);
    final e2 = emaSeries(e1, 9);
    final ratios = <double>[];
    for (int i = 0; i < ranges.length; i++) {
      ratios.add(e2[i] == 0 ? 0 : e1[i] / e2[i]);
    }
    final p = min(period, ratios.length);
    return ratios.sublist(ratios.length - p).fold(0.0, (a, b) => a + b);
  }

  static double ulcerIndex(List<double> values, int period) {
    final p = min(period, values.length);
    final w = values.sublist(values.length - p);
    double peak = w.first;
    double sumSq = 0;
    for (final v in w) {
      peak = max(peak, v);
      final draw = peak == 0 ? 0 : (v - peak) / peak * 100;
      sumSq += draw * draw;
    }
    return sqrt(sumSq / p);
  }

  static double squeezeScore(
    List<IndicatorCandle> candles,
    int period,
    double bbDev,
    double kcMult,
  ) {
    final values = closes(candles);
    final bbWidth = stdDev(values, period) * bbDev * 2;
    final kcWidth = atr(candles, period) * kcMult * 2;
    if (kcWidth == 0) return 0;
    return bbWidth / kcWidth;
  }

  static double obv(List<IndicatorCandle> candles) {
    double value = 0;
    for (int i = 1; i < candles.length; i++) {
      if (candles[i].close > candles[i - 1].close) {
        value += candles[i].volume;
      } else if (candles[i].close < candles[i - 1].close) {
        value -= candles[i].volume;
      }
    }
    return value;
  }

  static double mfi(List<IndicatorCandle> candles, int period) {
    if (candles.length < 2) return 50;
    final p = min(period, candles.length - 1);
    double positive = 0;
    double negative = 0;
    for (int i = candles.length - p; i < candles.length; i++) {
      final tp = (candles[i].high + candles[i].low + candles[i].close) / 3;
      final prevTp =
          (candles[i - 1].high + candles[i - 1].low + candles[i - 1].close) /
              3;
      final flow = tp * candles[i].volume;
      if (tp >= prevTp) {
        positive += flow;
      } else {
        negative += flow;
      }
    }
    if (negative == 0) return 100;
    final ratio = positive / negative;
    return 100 - 100 / (1 + ratio);
  }

  static double cmf(List<IndicatorCandle> candles, int period) {
    final p = min(period, candles.length);
    double mfv = 0;
    double vol = 0;
    for (final c in candles.sublist(candles.length - p)) {
      final range = c.high - c.low;
      final multiplier =
          range == 0 ? 0 : ((c.close - c.low) - (c.high - c.close)) / range;
      mfv += multiplier * c.volume;
      vol += c.volume;
    }
    return vol == 0 ? 0 : mfv / vol;
  }

  static double adl(List<IndicatorCandle> candles) {
    double result = 0;
    for (final c in candles) {
      final range = c.high - c.low;
      final mfm =
          range == 0 ? 0 : ((c.close - c.low) - (c.high - c.close)) / range;
      result += mfm * c.volume;
    }
    return result;
  }

  static double forceIndex(List<IndicatorCandle> candles, int period) {
    if (candles.length < 2) return 0;
    final raw = <double>[];
    raw.add(0);
    for (int i = 1; i < candles.length; i++) {
      raw.add((candles[i].close - candles[i - 1].close) * candles[i].volume);
    }
    return ema(raw, period);
  }

  static double easeOfMovement(List<IndicatorCandle> candles, int period) {
    if (candles.length < 2) return 0;
    final vals = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final distance =
          ((candles[i].high + candles[i].low) / 2) -
              ((candles[i - 1].high + candles[i - 1].low) / 2);
      final range = candles[i].high - candles[i].low;
      final boxRatio = range == 0 ? 0 : candles[i].volume / range;
      vals.add(boxRatio == 0 ? 0 : distance / boxRatio);
    }
    return sma(vals, period);
  }

  static double vpt(List<IndicatorCandle> candles) {
    double value = 0;
    for (int i = 1; i < candles.length; i++) {
      final prev = candles[i - 1].close;
      if (prev != 0) {
        value += candles[i].volume * (candles[i].close - prev) / prev;
      }
    }
    return value;
  }

  static double vwap(List<IndicatorCandle> candles, int period) {
    final p = min(period, candles.length);
    double pv = 0;
    double vol = 0;
    for (final c in candles.sublist(candles.length - p)) {
      final typical = (c.high + c.low + c.close) / 3;
      pv += typical * c.volume;
      vol += c.volume;
    }
    return vol == 0 ? candles.last.close : pv / vol;
  }

  static double support(List<IndicatorCandle> candles, int period) {
    final p = min(period, candles.length);
    return candles
        .sublist(candles.length - p)
        .map((e) => e.low)
        .reduce(min);
  }

  static double resistance(List<IndicatorCandle> candles, int period) {
    final p = min(period, candles.length);
    return candles
        .sublist(candles.length - p)
        .map((e) => e.high)
        .reduce(max);
  }

  static double pivot(List<IndicatorCandle> candles) {
    final c = candles.last;
    return (c.high + c.low + c.close) / 3;
  }

  static double trendStrength(List<double> values, int period) {
    if (values.length <= period) return 0;
    final start = values[values.length - 1 - period];
    final end = values.last;
    final sd = stdDev(values, period);
    if (sd == 0) return 0;
    return (end - start) / sd;
  }

  static double breakoutScore(List<IndicatorCandle> candles, int period) {
    if (candles.length <= period) return 0;
    final prior = candles.sublist(candles.length - period - 1, candles.length - 1);
    final hi = prior.map((e) => e.high).reduce(max);
    final lo = prior.map((e) => e.low).reduce(min);
    if (candles.last.close > hi) return 1;
    if (candles.last.close < lo) return -1;
    return 0;
  }
}

class ConfiguredIndicator implements TitanIndicator {
  @override
  final String id;
  @override
  final String name;
  @override
  final IndicatorCategory category;
  @override
  final String description;
  final double Function(List<IndicatorCandle>) calculator;

  const ConfiguredIndicator({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.calculator,
  });

  @override
  double calculate(List<IndicatorCandle> candles) => calculator(candles);
}

class TitanIndicatorPack250 {
  static List<TitanIndicator> build() {
    final list = <TitanIndicator>[];
    final closes = IndicatorMath.closes;

    void add(
      String id,
      String name,
      IndicatorCategory category,
      String description,
      double Function(List<IndicatorCandle>) calculator,
    ) {
      list.add(
        ConfiguredIndicator(
          id: id,
          name: name,
          category: category,
          description: description,
          calculator: calculator,
        ),
      );
    }

    // 1-15 SMA
    for (final p in [5, 9, 10, 14, 20, 21, 25, 30, 34, 50, 55, 75, 100, 144, 200]) {
      add('sma_$p', 'SMA $p', IndicatorCategory.trend,
          'Simple moving average, period $p.',
          (c) => IndicatorMath.sma(closes(c), p));
    }
    // 16-30 EMA
    for (final p in [5, 9, 10, 14, 20, 21, 25, 30, 34, 50, 55, 75, 100, 144, 200]) {
      add('ema_$p', 'EMA $p', IndicatorCategory.trend,
          'Exponential moving average, period $p.',
          (c) => IndicatorMath.ema(closes(c), p));
    }
    // 31-40 WMA
    for (final p in [5, 9, 10, 14, 20, 30, 50, 75, 100, 200]) {
      add('wma_$p', 'WMA $p', IndicatorCategory.trend,
          'Weighted moving average, period $p.',
          (c) => IndicatorMath.wma(closes(c), p));
    }
    // 41-50 HMA
    for (final p in [9, 14, 20, 21, 34, 50, 55, 75, 100, 200]) {
      add('hma_$p', 'HMA $p', IndicatorCategory.trend,
          'Hull moving average, period $p.',
          (c) => IndicatorMath.hma(closes(c), p));
    }
    // 51-60 DEMA
    for (final p in [5, 9, 10, 14, 20, 30, 50, 75, 100, 200]) {
      add('dema_$p', 'DEMA $p', IndicatorCategory.trend,
          'Double exponential moving average, period $p.',
          (c) => IndicatorMath.dema(closes(c), p));
    }
    // 61-70 TEMA
    for (final p in [5, 9, 10, 14, 20, 30, 50, 75, 100, 200]) {
      add('tema_$p', 'TEMA $p', IndicatorCategory.trend,
          'Triple exponential moving average, period $p.',
          (c) => IndicatorMath.tema(closes(c), p));
    }
    // 71-80 ZLEMA
    for (final p in [5, 9, 10, 14, 20, 30, 50, 75, 100, 200]) {
      add('zlema_$p', 'ZLEMA $p', IndicatorCategory.trend,
          'Zero-lag EMA approximation, period $p.',
          (c) => IndicatorMath.zlema(closes(c), p));
    }
    // 81-86 KAMA
    for (final p in [5, 10, 14, 20, 30, 50]) {
      add('kama_$p', 'KAMA $p', IndicatorCategory.trend,
          'Kaufman adaptive moving average, period $p.',
          (c) => IndicatorMath.kama(closes(c), p));
    }

    // 87-96 RSI
    for (final p in [5, 7, 9, 10, 12, 14, 20, 21, 30, 50]) {
      add('rsi_$p', 'RSI $p', IndicatorCategory.momentum,
          'Relative Strength Index, period $p.',
          (c) => IndicatorMath.rsi(closes(c), p));
    }
    // 97-104 Stochastic
    for (final p in [5, 7, 9, 10, 14, 20, 21, 30]) {
      add('stoch_$p', 'Stochastic $p', IndicatorCategory.momentum,
          'Stochastic oscillator %K, period $p.',
          (c) => IndicatorMath.stochastic(c, p));
    }
    // 105-112 Stochastic RSI
    for (final p in [5, 7, 9, 10, 14, 20, 21, 30]) {
      add('stochrsi_$p', 'Stochastic RSI $p', IndicatorCategory.momentum,
          'Stochastic RSI, period $p.',
          (c) => IndicatorMath.stochasticRsi(closes(c), p));
    }
    // 113-122 ROC
    for (final p in [1, 3, 5, 7, 9, 10, 12, 14, 20, 30]) {
      add('roc_$p', 'ROC $p', IndicatorCategory.momentum,
          'Rate of change, period $p.',
          (c) => IndicatorMath.roc(closes(c), p));
    }
    // 123-132 Momentum
    for (final p in [1, 3, 5, 7, 9, 10, 12, 14, 20, 30]) {
      add('mom_$p', 'Momentum $p', IndicatorCategory.momentum,
          'Price momentum, period $p.',
          (c) => IndicatorMath.momentum(closes(c), p));
    }
    // 133-140 Williams %R
    for (final p in [5, 7, 9, 10, 14, 20, 21, 30]) {
      add('willr_$p', 'Williams %R $p', IndicatorCategory.momentum,
          'Williams percent R, period $p.',
          (c) => IndicatorMath.williamsR(c, p));
    }
    // 141-148 CCI
    for (final p in [5, 7, 9, 10, 14, 20, 21, 30]) {
      add('cci_$p', 'CCI $p', IndicatorCategory.momentum,
          'Commodity Channel Index, period $p.',
          (c) => IndicatorMath.cci(c, p));
    }
    // 149-158 MACD variants
    final macds = [
      [5, 13, 4], [6, 19, 4], [8, 17, 9], [8, 21, 5], [10, 20, 7],
      [12, 26, 9], [15, 30, 9], [19, 39, 9], [24, 52, 18], [3, 10, 16],
    ];
    for (final m in macds) {
      add('macd_${m[0]}_${m[1]}_${m[2]}',
          'MACD ${m[0]}/${m[1]}/${m[2]}',
          IndicatorCategory.momentum,
          'MACD histogram variant.',
          (c) => IndicatorMath.macd(closes(c), m[0], m[1], m[2]));
    }
    // 159-164 TRIX
    for (final p in [5, 9, 10, 14, 20, 30]) {
      add('trix_$p', 'TRIX $p', IndicatorCategory.momentum,
          'Triple-smoothed rate of change, period $p.',
          (c) => IndicatorMath.trix(closes(c), p));
    }
    // 165-170 CMO
    for (final p in [5, 9, 10, 14, 20, 30]) {
      add('cmo_$p', 'CMO $p', IndicatorCategory.momentum,
          'Chande Momentum Oscillator, period $p.',
          (c) => IndicatorMath.cmo(closes(c), p));
    }
    // 171-174 Ultimate Oscillator
    for (final v in [[4,8,16], [7,14,28], [5,10,20], [10,20,40]]) {
      add('ultimate_${v[0]}_${v[1]}_${v[2]}',
          'Ultimate ${v[0]}/${v[1]}/${v[2]}',
          IndicatorCategory.momentum,
          'Ultimate Oscillator variant.',
          (c) => IndicatorMath.ultimate(c, v[0], v[1], v[2]));
    }
    // 175-178 Awesome Oscillator
    for (final v in [[5,34], [3,21], [8,55], [10,50]]) {
      add('awesome_${v[0]}_${v[1]}', 'Awesome ${v[0]}/${v[1]}',
          IndicatorCategory.momentum, 'Awesome Oscillator variant.',
          (c) => IndicatorMath.awesome(c, v[0], v[1]));
    }
    // 179-182 Fisher
    for (final p in [9, 10, 14, 20]) {
      add('fisher_$p', 'Fisher Transform $p',
          IndicatorCategory.momentum, 'Fisher transform, period $p.',
          (c) => IndicatorMath.fisher(c, p));
    }

    // 183-192 ATR
    for (final p in [5, 7, 9, 10, 12, 14, 20, 21, 30, 50]) {
      add('atr_$p', 'ATR $p', IndicatorCategory.volatility,
          'Average True Range, period $p.',
          (c) => IndicatorMath.atr(c, p));
    }
    // 193-202 Bollinger Z variants
    final bbs = [
      [10, 1.5], [10, 2.0], [14, 1.5], [14, 2.0], [20, 1.5],
      [20, 2.0], [20, 2.5], [30, 2.0], [50, 2.0], [100, 2.0],
    ];
    for (final b in bbs) {
      add('bb_${b[0]}_${b[1]}', 'Bollinger ${b[0]} x${b[1]}',
          IndicatorCategory.volatility, 'Normalized Bollinger position.',
          (c) => IndicatorMath.bollingerZ(
              closes(c), (b[0] as num).toInt(), (b[1] as num).toDouble()));
    }
    // 203-210 Keltner
    final kcs = [
      [10, 1.5], [10, 2.0], [14, 1.5], [14, 2.0],
      [20, 1.5], [20, 2.0], [30, 2.0], [50, 2.0],
    ];
    for (final k in kcs) {
      add('kc_${k[0]}_${k[1]}', 'Keltner ${k[0]} x${k[1]}',
          IndicatorCategory.volatility, 'Normalized Keltner position.',
          (c) => IndicatorMath.keltnerPosition(
              c, (k[0] as num).toInt(), (k[1] as num).toDouble()));
    }
    // 211-218 Donchian
    for (final p in [5, 10, 14, 20, 30, 50, 100, 200]) {
      add('donchian_$p', 'Donchian Position $p',
          IndicatorCategory.volatility, 'Position inside Donchian channel.',
          (c) => IndicatorMath.donchianPosition(c, p));
    }
    // 219-226 StdDev
    for (final p in [5, 10, 14, 20, 30, 50, 100, 200]) {
      add('stddev_$p', 'Standard Deviation $p',
          IndicatorCategory.volatility, 'Price standard deviation.',
          (c) => IndicatorMath.stdDev(closes(c), p));
    }
    // 227-234 Historical Volatility
    for (final p in [5, 10, 14, 20, 30, 50, 100, 200]) {
      add('hv_$p', 'Historical Volatility $p',
          IndicatorCategory.volatility, 'Annualized historical volatility.',
          (c) => IndicatorMath.historicalVolatility(closes(c), p));
    }
    // 235-238 Chaikin Volatility
    for (final p in [5, 10, 14, 20]) {
      add('chaikin_vol_$p', 'Chaikin Volatility $p',
          IndicatorCategory.volatility, 'Chaikin range volatility.',
          (c) => IndicatorMath.chaikinVolatility(c, p));
    }
    // 239-242 Mass Index
    for (final p in [9, 14, 25, 30]) {
      add('mass_$p', 'Mass Index $p', IndicatorCategory.volatility,
          'Mass Index, period $p.',
          (c) => IndicatorMath.massIndex(c, p));
    }
    // 243-246 Ulcer Index
    for (final p in [5, 10, 14, 20]) {
      add('ulcer_$p', 'Ulcer Index $p', IndicatorCategory.volatility,
          'Ulcer Index, period $p.',
          (c) => IndicatorMath.ulcerIndex(closes(c), p));
    }
    // 247-250 Structure modules
    add('support_50', 'Support Level 50', IndicatorCategory.structure,
        'Lowest low over 50 candles.',
        (c) => IndicatorMath.support(c, 50));
    add('resistance_50', 'Resistance Level 50', IndicatorCategory.structure,
        'Highest high over 50 candles.',
        (c) => IndicatorMath.resistance(c, 50));
    add('pivot_classic', 'Classic Pivot', IndicatorCategory.structure,
        'Classic pivot price.',
        (c) => IndicatorMath.pivot(c));
    add('breakout_20', 'Breakout Detector 20', IndicatorCategory.structure,
        'Returns 1 for upside breakout, -1 for downside, 0 otherwise.',
        (c) => IndicatorMath.breakoutScore(c, 20));

    assert(list.length == 250, 'Indicator pack must contain exactly 250.');
    return List.unmodifiable(list);
  }
}
