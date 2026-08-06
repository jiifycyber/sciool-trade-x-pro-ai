enum MarketSession { asian, london, newYork, overlap, offHours }

class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

class StrategyPreset {
  final String id;
  final String name;
  final int fastEma;
  final int slowEma;
  final double minimumMomentum;
  final double minimumVolumeStrength;
  final double minimumVolatility;
  final double maximumVolatility;
  final int minimumPayout;
  final int confidenceThreshold;
  final List<MarketSession> sessions;

  const StrategyPreset({
    required this.id,
    required this.name,
    required this.fastEma,
    required this.slowEma,
    required this.minimumMomentum,
    required this.minimumVolumeStrength,
    required this.minimumVolatility,
    required this.maximumVolatility,
    required this.minimumPayout,
    required this.confidenceThreshold,
    required this.sessions,
  });
}

class BacktestTrade {
  final String symbol;
  final DateTime openedAt;
  final String direction;
  final double entry;
  final double exit;
  final bool won;
  final int payout;
  final int confidence;
  final int expirationMinutes;
  final MarketSession session;

  const BacktestTrade({
    required this.symbol,
    required this.openedAt,
    required this.direction,
    required this.entry,
    required this.exit,
    required this.won,
    required this.payout,
    required this.confidence,
    required this.expirationMinutes,
    required this.session,
  });

  double profitFor(double stake) => won ? stake * payout / 100 : -stake;
}

class BacktestReport {
  final String symbol;
  final String strategyName;
  final int candleCount;
  final List<BacktestTrade> trades;
  final DateTime generatedAt;

  const BacktestReport({
    required this.symbol,
    required this.strategyName,
    required this.candleCount,
    required this.trades,
    required this.generatedAt,
  });

  int get totalTrades => trades.length;
  int get wins => trades.where((t) => t.won).length;
  int get losses => trades.where((t) => !t.won).length;
  double get winRate => totalTrades == 0 ? 0 : wins / totalTrades * 100;

  int get longestLosingStreak {
    int best = 0;
    int current = 0;
    for (final trade in trades) {
      if (!trade.won) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  Map<MarketSession, double> get winRateBySession {
    final result = <MarketSession, double>{};
    for (final session in MarketSession.values) {
      final filtered = trades.where((t) => t.session == session).toList();
      if (filtered.isNotEmpty) {
        result[session] =
            filtered.where((t) => t.won).length / filtered.length * 100;
      }
    }
    return result;
  }
}

class PairAnalytics {
  final String symbol;
  final int trades;
  final double winRate;
  final double netProfit;
  final int longestLosingStreak;
  final int bestExpirationMinutes;

  const PairAnalytics({
    required this.symbol,
    required this.trades,
    required this.winRate,
    required this.netProfit,
    required this.longestLosingStreak,
    required this.bestExpirationMinutes,
  });
}
