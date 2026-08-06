import 'models.dart';
import 'quantum_models.dart';

class PerformanceAnalytics {
  AdvancedPerformanceReport build(List<TradeRecord> trades) {
    final settled = trades.where((e) => e.won != null).toList();
    int wins = 0;
    int losses = 0;
    double grossWins = 0;
    double grossLosses = 0;
    double equity = 0;
    double peak = 0;
    double maxDrawdown = 0;
    int currentWin = 0;
    int currentLoss = 0;
    int longestWin = 0;
    int longestLoss = 0;

    for (final trade in settled.reversed) {
      final p = trade.profit;
      equity += p;
      if (equity > peak) peak = equity;
      final drawdown = peak - equity;
      if (drawdown > maxDrawdown) maxDrawdown = drawdown;

      if (trade.won == true) {
        wins++;
        grossWins += p;
        currentWin++;
        currentLoss = 0;
        if (currentWin > longestWin) longestWin = currentWin;
      } else {
        losses++;
        grossLosses += p.abs();
        currentLoss++;
        currentWin = 0;
        if (currentLoss > longestLoss) longestLoss = currentLoss;
      }
    }

    return AdvancedPerformanceReport(
      trades: settled.length,
      wins: wins,
      losses: losses,
      netProfit: grossWins - grossLosses,
      maxDrawdown: maxDrawdown,
      profitFactor: grossLosses == 0 ? grossWins : grossWins / grossLosses,
      longestWinStreak: longestWin,
      longestLossStreak: longestLoss,
    );
  }
}
