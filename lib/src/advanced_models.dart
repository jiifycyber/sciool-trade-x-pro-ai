enum Timeframe { oneMinute, fiveMinutes, fifteenMinutes }

extension TimeframeLabel on Timeframe {
  String get label => switch (this) {
        Timeframe.oneMinute => '1m',
        Timeframe.fiveMinutes => '5m',
        Timeframe.fifteenMinutes => '15m',
      };

  int get minutes => switch (this) {
        Timeframe.oneMinute => 1,
        Timeframe.fiveMinutes => 5,
        Timeframe.fifteenMinutes => 15,
      };
}

class IndicatorSnapshot {
  final double ema20;
  final double ema200;
  final double rsi;
  final double macd;
  final double macdSignal;
  final double bollingerUpper;
  final double bollingerMiddle;
  final double bollingerLower;
  final double atr;
  final double support;
  final double resistance;
  final String candlePattern;
  final double momentum;
  final double volatility;

  const IndicatorSnapshot({
    required this.ema20,
    required this.ema200,
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.bollingerUpper,
    required this.bollingerMiddle,
    required this.bollingerLower,
    required this.atr,
    required this.support,
    required this.resistance,
    required this.candlePattern,
    required this.momentum,
    required this.volatility,
  });
}

class TimeframeAnalysis {
  final Timeframe timeframe;
  final String direction;
  final int score;
  final IndicatorSnapshot indicators;
  final List<String> reasons;

  const TimeframeAnalysis({
    required this.timeframe,
    required this.direction,
    required this.score,
    required this.indicators,
    required this.reasons,
  });
}

class RadarOpportunity {
  final String symbol;
  final String direction;
  final int confidence;
  final DateTime generatedAt;
  final int expirationMinutes;
  final List<TimeframeAnalysis> analyses;
  final List<String> reasons;

  const RadarOpportunity({
    required this.symbol,
    required this.direction,
    required this.confidence,
    required this.generatedAt,
    required this.expirationMinutes,
    required this.analyses,
    required this.reasons,
  });
}

class LearningStat {
  final String key;
  int trades;
  int wins;
  double netProfit;

  LearningStat({
    required this.key,
    this.trades = 0,
    this.wins = 0,
    this.netProfit = 0,
  });

  double get winRate => trades == 0 ? 0 : wins / trades * 100;
}
