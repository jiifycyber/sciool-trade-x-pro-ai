import 'dart:math';
import 'advanced_indicators.dart';
import 'advanced_models.dart';
import 'market_data/twelve_data_service.dart';

class MultiTimeframeEngine {
  List<LiveCandle> aggregate(
    List<LiveCandle> oneMinute,
    int minutes,
  ) {
    if (minutes <= 1) return oneMinute;
    final result = <LiveCandle>[];
    for (int i = 0; i + minutes <= oneMinute.length; i += minutes) {
      final group = oneMinute.sublist(i, i + minutes);
      result.add(
        LiveCandle(
          time: group.first.time,
          open: group.first.open,
          high: group.map((c) => c.high).reduce(max),
          low: group.map((c) => c.low).reduce(min),
          close: group.last.close,
        ),
      );
    }
    return result;
  }

  TimeframeAnalysis analyze(
    List<LiveCandle> candles,
    Timeframe timeframe,
  ) {
    final closes = candles.map((c) => c.close).toList();
    final ema20 = TwelveDataService.ema(closes, min(20, closes.length));
    final ema200 =
        TwelveDataService.ema(closes, min(200, closes.length));
    final rsi = AdvancedIndicators.rsi(closes);
    final macdValues = AdvancedIndicators.macd(closes);
    final bands = AdvancedIndicators.bollinger(closes);
    final atr = AdvancedIndicators.atr(candles);
    final sr = AdvancedIndicators.supportResistance(candles);
    final pattern = AdvancedIndicators.candlePattern(candles);
    final momentum = TwelveDataService.momentum(closes);
    final volatility = TwelveDataService.volatility(candles);

    int bullish = 0;
    int bearish = 0;
    final reasons = <String>[];

    if (ema20 > ema200) {
      bullish += 22;
      reasons.add('EMA trend is bullish');
    } else {
      bearish += 22;
      reasons.add('EMA trend is bearish');
    }

    if (rsi >= 52 && rsi <= 70) {
      bullish += 14;
      reasons.add('RSI supports upward momentum');
    } else if (rsi <= 48 && rsi >= 30) {
      bearish += 14;
      reasons.add('RSI supports downward momentum');
    } else if (rsi > 70 || rsi < 30) {
      reasons.add('RSI is overextended');
    }

    if (macdValues.$1 > macdValues.$2) {
      bullish += 14;
      reasons.add('MACD is above signal');
    } else {
      bearish += 14;
      reasons.add('MACD is below signal');
    }

    final latest = closes.last;
    if (latest < bands.$3) {
      bullish += 10;
      reasons.add('Price is below lower Bollinger Band');
    } else if (latest > bands.$1) {
      bearish += 10;
      reasons.add('Price is above upper Bollinger Band');
    }

    if (pattern.contains('Bullish') || pattern == 'Hammer') {
      bullish += 12;
      reasons.add(pattern);
    } else if (pattern.contains('Bearish') ||
        pattern == 'Shooting Star') {
      bearish += 12;
      reasons.add(pattern);
    } else if (pattern == 'Doji') {
      reasons.add('Doji signals uncertainty');
    }

    if (momentum > 0.45) {
      bullish += 14;
      reasons.add('Positive momentum confirmed');
    } else if (momentum < -0.45) {
      bearish += 14;
      reasons.add('Negative momentum confirmed');
    }

    if (volatility >= 0.20 && volatility <= 0.80) {
      bullish += 4;
      bearish += 4;
      reasons.add('Volatility is tradable');
    }

    final direction = bullish > bearish
        ? 'CALL'
        : bearish > bullish
            ? 'PUT'
            : 'WAIT';
    final score = max(bullish, bearish).clamp(0, 100);

    return TimeframeAnalysis(
      timeframe: timeframe,
      direction: score < 55 ? 'WAIT' : direction,
      score: score,
      indicators: IndicatorSnapshot(
        ema20: ema20,
        ema200: ema200,
        rsi: rsi,
        macd: macdValues.$1,
        macdSignal: macdValues.$2,
        bollingerUpper: bands.$1,
        bollingerMiddle: bands.$2,
        bollingerLower: bands.$3,
        atr: atr,
        support: sr.$1,
        resistance: sr.$2,
        candlePattern: pattern,
        momentum: momentum,
        volatility: volatility,
      ),
      reasons: reasons,
    );
  }

  RadarOpportunity evaluateSymbol(
    String symbol,
    List<LiveCandle> oneMinute,
  ) {
    final analyses = <TimeframeAnalysis>[];
    for (final tf in Timeframe.values) {
      final candles = aggregate(oneMinute, tf.minutes);
      analyses.add(analyze(candles, tf));
    }

    final calls = analyses.where((a) => a.direction == 'CALL').length;
    final puts = analyses.where((a) => a.direction == 'PUT').length;
    final direction = calls >= 2
        ? 'CALL'
        : puts >= 2
            ? 'PUT'
            : 'WAIT';

    int confidence = 0;
    if (direction != 'WAIT') {
      final aligned = analyses.where((a) => a.direction == direction).toList();
      confidence =
          (aligned.map((a) => a.score).reduce((a, b) => a + b) /
                  aligned.length)
              .round();
      if (aligned.length == 3) confidence = min(100, confidence + 8);
    }

    final reasons = <String>[
      if (direction == 'WAIT') 'Timeframes are not aligned',
      if (direction != 'WAIT') '$calls CALL / $puts PUT timeframe votes',
      ...analyses.expand(
        (a) => a.reasons.take(2).map((r) => '${a.timeframe.label}: $r'),
      ),
    ];

    return RadarOpportunity(
      symbol: symbol,
      direction: direction,
      confidence: confidence,
      generatedAt: DateTime.now(),
      expirationMinutes: direction == 'WAIT' ? 0 : 3,
      analyses: analyses,
      reasons: reasons,
    );
  }
}
