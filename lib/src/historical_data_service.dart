import 'dart:math';
import 'package:csv/csv.dart';
import 'stage6_models.dart';

class HistoricalDataService {
  final Random _random = Random(42);

  List<Candle> generateDemoCandles({
    required String symbol,
    int count = 1500,
    Duration interval = const Duration(minutes: 1),
  }) {
    double price = switch (symbol) {
      'GBP/USD' => 1.2850,
      'USD/JPY' => 147.30,
      'AUD/USD' => 0.6580,
      'EUR/GBP' => 0.8560,
      _ => 1.0920,
    };

    final candles = <Candle>[];
    DateTime time = DateTime.now().toUtc().subtract(interval * count);
    double trend = 0;

    for (int i = 0; i < count; i++) {
      if (i % 180 == 0) {
        trend = (_random.nextDouble() - 0.5) * 0.00018;
      }
      final noise = (_random.nextDouble() - 0.5) * 0.0005;
      final open = price;
      final close = open + trend + noise;
      final high = max(open, close) + _random.nextDouble() * 0.00025;
      final low = min(open, close) - _random.nextDouble() * 0.00025;
      final volume = 600 + _random.nextDouble() * 1400;

      candles.add(Candle(
        time: time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      price = close;
      time = time.add(interval);
    }
    return candles;
  }

  List<Candle> parseCsv(String source) {
    final rows = const CsvToListConverter(eol: '\n').convert(source);
    if (rows.length < 2) return [];

    final candles = <Candle>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;
      try {
        candles.add(Candle(
          time: DateTime.parse(row[0].toString()).toUtc(),
          open: double.parse(row[1].toString()),
          high: double.parse(row[2].toString()),
          low: double.parse(row[3].toString()),
          close: double.parse(row[4].toString()),
          volume: double.parse(row[5].toString()),
        ));
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return candles;
  }
}
