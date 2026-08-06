import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grand_build_controller.dart';
import '../stage6_models.dart';

class StrategyLabScreen extends StatelessWidget {
  const StrategyLabScreen({super.key});

  String sessionName(MarketSession session) => switch (session) {
        MarketSession.asian => 'Asian',
        MarketSession.london => 'London',
        MarketSession.newYork => 'New York',
        MarketSession.overlap => 'London/NY Overlap',
        MarketSession.offHours => 'Off Hours',
      };

  @override
  Widget build(BuildContext context) {
    final grand = context.watch<GrandBuildController>();
    final report = grand.report;

    return Scaffold(
      appBar: AppBar(title: const Text('Titan Strategy Lab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Backtest Configuration'),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: grand.selectedSymbol,
                    items: const [
                      'EUR/USD',
                      'GBP/USD',
                      'USD/JPY',
                      'AUD/USD',
                      'EUR/GBP',
                    ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) grand.setSymbol(v);
                    },
                    decoration: const InputDecoration(labelText: 'Currency pair'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<StrategyPreset>(
                    value: grand.selectedPreset,
                    items: grand.presets
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) grand.setPreset(v);
                    },
                    decoration: const InputDecoration(labelText: 'Strategy'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: grand.expirationMinutes,
                    items: const [1, 2, 3, 5]
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text('$v minute(s)'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) grand.setExpiration(v);
                    },
                    decoration: const InputDecoration(labelText: 'Expiration'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: grand.payout,
                    items: const [70, 75, 80, 85, 88, 90, 92]
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text('$v%'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) grand.setPayout(v);
                    },
                    decoration: const InputDecoration(labelText: 'Payout'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        grand.isRunning ? null : grand.runDemoBacktest,
                    icon: const Icon(Icons.science),
                    label: Text(
                      grand.isRunning
                          ? 'Running Test...'
                          : 'Run 2,500-Candle Backtest',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (report != null) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metric('Trades', '${report.totalTrades}'),
                _metric('Win Rate', '${report.winRate.toStringAsFixed(1)}%'),
                _metric('Wins', '${report.wins}'),
                _metric('Losses', '${report.losses}'),
                _metric('Longest Loss Streak',
                    '${report.longestLosingStreak}'),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${report.strategyName} — ${report.symbol}'),
                    Text('Candles tested: ${report.candleCount}'),
                    const SizedBox(height: 12),
                    const Text('Win Rate by Session'),
                    const SizedBox(height: 8),
                    ...report.winRateBySession.entries.map(
                      (entry) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(sessionName(entry.key)),
                        trailing:
                            Text('${entry.value.toStringAsFixed(1)}%'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ExpansionTile(
                title: const Text('Recent Backtest Trades'),
                children: report.trades.reversed.take(20).map(
                  (trade) {
                    return ListTile(
                      title: Text(
                        '${trade.symbol} • ${trade.direction} • ${trade.confidence}%',
                      ),
                      subtitle: Text(
                        '${sessionName(trade.session)} • '
                        '${trade.expirationMinutes} minute(s)',
                      ),
                      trailing: Text(trade.won ? 'WIN' : 'LOSS'),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Research build'),
              subtitle: Text(
                'Demo-generated candles verify the backtesting workflow, not real-world profitability. Import and authorized live-data adapters are the next data-source step.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 21)),
            ],
          ),
        ),
      ),
    );
  }
}
