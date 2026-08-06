import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../performance_analytics.dart';
import '../theme.dart';
import '../widgets/egypt_widgets.dart';

class AdvancedReportsScreen extends StatelessWidget {
  const AdvancedReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final report = PerformanceAnalytics().build(app.trades);

    return Scaffold(
      appBar: AppBar(title: const Text('ADVANCED PERFORMANCE REPORTS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const EgyptianBanner(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              EgyptMetric(label: 'Trades', value: '${report.trades}'),
              EgyptMetric(
                label: 'Win Rate',
                value: '${report.winRate.toStringAsFixed(1)}%',
              ),
              EgyptMetric(
                label: 'Net Profit',
                value: '\$${report.netProfit.toStringAsFixed(2)}',
                valueColor: report.netProfit >= 0
                    ? TitanEgyptColors.emerald
                    : TitanEgyptColors.red,
              ),
              EgyptMetric(
                label: 'Profit Factor',
                value: report.profitFactor.toStringAsFixed(2),
              ),
              EgyptMetric(
                label: 'Max Drawdown',
                value: '\$${report.maxDrawdown.toStringAsFixed(2)}',
                valueColor: TitanEgyptColors.red,
              ),
              EgyptMetric(
                label: 'Longest Win Streak',
                value: '${report.longestWinStreak}',
              ),
              EgyptMetric(
                label: 'Longest Loss Streak',
                value: '${report.longestLossStreak}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const EgyptPanel(
            title: 'Report Guidance',
            child: Text(
              'Use win rate together with profit factor, drawdown, trade count, and losing streaks. A high win rate by itself does not prove a strategy is safe or profitable.',
            ),
          ),
        ],
      ),
    );
  }
}
