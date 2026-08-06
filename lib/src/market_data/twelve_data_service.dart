import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class LiveCandle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  const LiveCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class LiveMarketResult {
  final String symbol;
  final List<LiveCandle> candles;
  final String source;
  final DateTime fetchedAt;

  const LiveMarketResult({
    required this.symbol,
    required this.candles,
    required this.source,
    required this.fetchedAt,
  });
}

class TwelveDataService {
  static const _apiKey = String.fromEnvironment('TWELVE_DATA_API_KEY');

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<LiveMarketResult> fetchOneMinuteCandles(
    String symbol, {
    int outputSize = 260,
  }) async {
    if (!isConfigured) {
      throw StateError(
        'Twelve Data API key is missing. Launch with '
        '--dart-define=TWELVE_DATA_API_KEY=YOUR_KEY',
      );
    }

    final uri = Uri.https(
      'api.twelvedata.com',
      '/time_series',
      {
        'symbol': symbol,
        'interval': '1min',
        'outputsize': outputSize.toString(),
        'timezone': 'UTC',
        'format': 'JSON',
        'apikey': _apiKey,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw StateError('Market-data request failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected market-data response.');
    }

    if (decoded['status'] == 'error' || decoded['code'] != null) {
      throw StateError(
        (decoded['message'] ?? 'Twelve Data returned an error.').toString(),
      );
    }

    final values = decoded['values'];
    if (values is! List || values.length < 40) {
      throw StateError(
        'Not enough one-minute candles were returned for analysis.',
      );
    }

    final candles = <LiveCandle>[];
    for (final item in values.reversed) {
      if (item is! Map<String, dynamic>) continue;
      try {
        candles.add(
          LiveCandle(
            time: DateTime.parse('${item['datetime']}Z').toUtc(),
            open: double.parse(item['open'].toString()),
            high: double.parse(item['high'].toString()),
            low: double.parse(item['low'].toString()),
            close: double.parse(item['close'].toString()),
          ),
        );
      } catch (_) {
        // Ignore malformed candles.
      }
    }

    if (candles.length < 40) {
      throw StateError('Valid candle count is below the strategy requirement.');
    }

    return LiveMarketResult(
      symbol: symbol,
      candles: candles,
      source: 'Twelve Data',
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  static double ema(List<double> values, int period) {
    if (values.length < period) {
      throw ArgumentError('EMA period exceeds the available candle count.');
    }
    double current =
        values.take(period).reduce((a, b) => a + b) / period;
    final multiplier = 2 / (period + 1);
    for (int i = period; i < values.length; i++) {
      current = (values[i] - current) * multiplier + current;
    }
    return current;
  }

  static double momentum(List<double> closes, {int lookback = 5}) {
    if (closes.length <= lookback) return 0;
    final previous = closes[closes.length - 1 - lookback];
    final current = closes.last;
    if (previous == 0) return 0;
    return (((current - previous) / previous) * 300).clamp(-1.0, 1.0);
  }

  static double volatility(List<LiveCandle> candles, {int lookback = 20}) {
    if (candles.length <= lookback) return 0;
    final recent = candles.sublist(candles.length - lookback);
    final ranges = recent
        .map((c) => (c.high - c.low) / max(c.close.abs(), 0.000001))
        .toList();
    final average = ranges.reduce((a, b) => a + b) / ranges.length;
    return (average * 900).clamp(0.0, 1.0);
  }

  /// Forex feeds commonly do not provide centralized exchange volume.
  /// This measures recent candle-range activity relative to its own baseline.
  static double activityStrength(
    List<LiveCandle> candles, {
    int lookback = 40,
  }) {
    if (candles.length <= lookback) return 0.5;
    final recent = candles.sublist(candles.length - lookback);
    final ranges = recent.map((c) => (c.high - c.low).abs()).toList();
    final baseline =
        ranges.take(ranges.length - 1).reduce((a, b) => a + b) /
            (ranges.length - 1);
    if (baseline <= 0) return 0.5;
    return (ranges.last / baseline / 2).clamp(0.0, 1.0);
  }
  static double rsi(List<double> closes, int period) {
    if (closes.length <= period) return 50;
    double gains = 0;
    double losses = 0;
    final start = closes.length - period;
    for (int i = start; i < closes.length; i++) {
      final change = closes[i] - closes[i - 1];
      if (change >= 0) {
        gains += change;
      } else {
        losses += -change;
      }
    }
    if (losses == 0) return 100;
    final rs = (gains / period) / (losses / period);
    return 100 - (100 / (1 + rs));
  }

  static List<double> emaSeries(List<double> values, int period) {
    if (values.length < period) return const [];
    final output = <double>[];
    double current = values.take(period).reduce((a, b) => a + b) / period;
    for (int i = 0; i < period - 1; i++) {
      output.add(current);
    }
    output.add(current);
    final multiplier = 2 / (period + 1);
    for (int i = period; i < values.length; i++) {
      current = (values[i] - current) * multiplier + current;
      output.add(current);
    }
    return output;
  }

  static ({double line, double signal}) macd(
    List<double> closes,
    int fast,
    int slow,
    int signalPeriod,
  ) {
    final fastSeries = emaSeries(closes, fast);
    final slowSeries = emaSeries(closes, slow);
    if (fastSeries.isEmpty || slowSeries.isEmpty) return (line: 0, signal: 0);
    final length = min(fastSeries.length, slowSeries.length);
    final macdSeries = <double>[];
    for (int i = fastSeries.length - length, j = slowSeries.length - length;
        i < fastSeries.length && j < slowSeries.length;
        i++, j++) {
      macdSeries.add(fastSeries[i] - slowSeries[j]);
    }
    final line = macdSeries.last;
    final signal = macdSeries.length >= signalPeriod
        ? ema(macdSeries, signalPeriod)
        : macdSeries.reduce((a, b) => a + b) / macdSeries.length;
    return (line: line, signal: signal);
  }

  static ({double upper, double middle, double lower}) bollinger(
    List<double> closes,
    int period,
    double deviation,
  ) {
    if (closes.length < period) {
      final value = closes.isEmpty ? 0.0 : closes.last;
      return (upper: value, middle: value, lower: value);
    }
    final recent = closes.sublist(closes.length - period);
    final mean = recent.reduce((a, b) => a + b) / recent.length;
    final variance = recent
            .map((value) => pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        recent.length;
    final sd = sqrt(variance);
    return (
      upper: mean + deviation * sd,
      middle: mean,
      lower: mean - deviation * sd,
    );
  }

  static int zigZagDirection(List<LiveCandle> candles, int depth) {
    if (candles.length < depth + 2) return 0;
    final recent = candles.sublist(candles.length - depth - 1);
    final first = recent.first.close;
    final last = recent.last.close;
    final high = recent.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final low = recent.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final range = max(high - low, 0.000001);
    final move = (last - first) / range;
    if (move > 0.18) return 1;
    if (move < -0.18) return -1;
    return 0;
  }

}
