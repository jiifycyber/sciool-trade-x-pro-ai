enum MarketRegime {
  strongTrend,
  weakTrend,
  range,
  highVolatility,
  lowVolatility,
  transition,
}

extension MarketRegimeLabel on MarketRegime {
  String get label => switch (this) {
        MarketRegime.strongTrend => 'Strong Trend',
        MarketRegime.weakTrend => 'Weak Trend',
        MarketRegime.range => 'Range',
        MarketRegime.highVolatility => 'High Volatility',
        MarketRegime.lowVolatility => 'Low Volatility',
        MarketRegime.transition => 'Transition',
      };
}

class InstitutionalSignal {
  final String name;
  final String direction;
  final double strength;
  final String explanation;

  const InstitutionalSignal({
    required this.name,
    required this.direction,
    required this.strength,
    required this.explanation,
  });
}

class QuantumAssessment {
  final String symbol;
  final MarketRegime regime;
  final String direction;
  final int confidence;
  final String grade;
  final List<String> confirmations;
  final List<String> warnings;
  final List<InstitutionalSignal> institutionalSignals;

  const QuantumAssessment({
    required this.symbol,
    required this.regime,
    required this.direction,
    required this.confidence,
    required this.grade,
    required this.confirmations,
    required this.warnings,
    required this.institutionalSignals,
  });
}

class StrategyCondition {
  final String left;
  final String operatorSymbol;
  final String right;

  const StrategyCondition({
    required this.left,
    required this.operatorSymbol,
    required this.right,
  });

  String get display => '$left $operatorSymbol $right';
}

class StrategyDefinition {
  final String name;
  final List<StrategyCondition> conditions;
  final String action;
  final int minimumConfidence;

  const StrategyDefinition({
    required this.name,
    required this.conditions,
    required this.action,
    required this.minimumConfidence,
  });
}

class ReplayPoint {
  final DateTime time;
  final double price;
  final String signal;
  final int confidence;

  const ReplayPoint({
    required this.time,
    required this.price,
    required this.signal,
    required this.confidence,
  });
}

class AdvancedPerformanceReport {
  final int trades;
  final int wins;
  final int losses;
  final double netProfit;
  final double maxDrawdown;
  final double profitFactor;
  final int longestWinStreak;
  final int longestLossStreak;

  const AdvancedPerformanceReport({
    required this.trades,
    required this.wins,
    required this.losses,
    required this.netProfit,
    required this.maxDrawdown,
    required this.profitFactor,
    required this.longestWinStreak,
    required this.longestLossStreak,
  });

  double get winRate => trades == 0 ? 0 : wins / trades * 100;
}
