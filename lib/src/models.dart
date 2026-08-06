enum SignalDirection { call, put, wait }

class MarketSnapshot {
  final String symbol;
  final double price;
  final double emaFast;
  final double emaSlow;
  final double macd;
  final double macdSignal;
  final double rsi;
  final double bollingerUpper;
  final double bollingerMiddle;
  final double bollingerLower;
  final int zigZagDirection;
  final double momentum;
  final double volumeStrength;
  final double volatility;
  final int payout;
  final DateTime time;

  const MarketSnapshot({
    required this.symbol,
    required this.price,
    required this.emaFast,
    required this.emaSlow,
    required this.macd,
    required this.macdSignal,
    required this.rsi,
    required this.bollingerUpper,
    required this.bollingerMiddle,
    required this.bollingerLower,
    required this.zigZagDirection,
    required this.momentum,
    required this.volumeStrength,
    required this.volatility,
    required this.payout,
    required this.time,
  });
}

class TitanSignal {
  final String symbol;
  final SignalDirection direction;
  final int confidence;
  final int expirationMinutes;
  final double suggestedAmount;
  final List<String> reasons;
  final List<String> warnings;
  final DateTime generatedAt;

  const TitanSignal({
    required this.symbol,
    required this.direction,
    required this.confidence,
    required this.expirationMinutes,
    required this.suggestedAmount,
    required this.reasons,
    required this.warnings,
    required this.generatedAt,
  });
}

class TradeRecord {
  final String symbol;
  final SignalDirection direction;
  final double amount;
  final int payout;
  final bool? won;
  final DateTime openedAt;

  const TradeRecord({
    required this.symbol,
    required this.direction,
    required this.amount,
    required this.payout,
    required this.won,
    required this.openedAt,
  });

  double get profit {
    if (won == null) return 0;
    return won! ? amount * payout / 100 : -amount;
  }

  TradeRecord copyWith({bool? won}) => TradeRecord(
        symbol: symbol,
        direction: direction,
        amount: amount,
        payout: payout,
        won: won,
        openedAt: openedAt,
      );
}
