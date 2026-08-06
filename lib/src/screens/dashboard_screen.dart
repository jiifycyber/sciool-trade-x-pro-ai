import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'stage5_integration_screen.dart';
import '../integration/integration_controller.dart';
import '../integration/connector_models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String directionName(SignalDirection d) => switch (d) {
        SignalDirection.call => 'CALL',
        SignalDirection.put => 'PUT',
        SignalDirection.wait => 'WAIT',
      };

  String formatTime(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('h:mm:ss a').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final market = app.market;
    final signal = app.signal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCIOOL TRADE X PRO — LIVE SCANNER'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalScreen()),
            ),
            icon: const Icon(Icons.receipt_long),
          ),
          IconButton(
            tooltip: 'Integration',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Stage5IntegrationScreen(),
              ),
            ),
            icon: const Icon(Icons.hub),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: app.refreshMarket,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _stat('Data', app.liveDataConfigured ? 'LIVE READY' : 'KEY NEEDED'),
                _stat('Win Rate', '${app.winRate.toStringAsFixed(1)}%'),
                _stat('Daily P/L', '\$${app.dailyProfit.toStringAsFixed(2)}'),
                _stat('Trades Today', '${app.tradesToday}/${app.maxTradesPerDay}'),
              ],
            ),
            const SizedBox(height: 16),
            if (app.marketError != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Live market data unavailable'),
                  subtitle: Text(app.marketError!),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Real Forex Market Scanner'),
                    const SizedBox(height: 8),
                    Text('Source: ${app.dataSource}'),
                    Text('Last fetch: ${app.lastMarketUpdateUtc == null ? "—" : formatTime(app.lastMarketUpdateUtc!.toLocal())}'),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: app.selectedSymbol,
                      items: app.symbols
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) app.setSymbol(v);
                      },
                    ),
                    const SizedBox(height: 14),
                    if (market != null) ...[
                      Text('Latest candle: ${formatTime(market.time)}'),
                      Text('Price: ${market.price.toStringAsFixed(5)}'),
                      Text('EMA ${app.strategy.emaFast}: ${market.emaFast.toStringAsFixed(5)}'),
                      Text('EMA ${app.strategy.emaSlow}: ${market.emaSlow.toStringAsFixed(5)}'),
                      Text('MACD: ${market.macd.toStringAsFixed(6)} / ${market.macdSignal.toStringAsFixed(6)}'),
                      Text('RSI ${app.strategy.rsiPeriod}: ${market.rsi.toStringAsFixed(1)}'),
                      Text('Bollinger: ${market.bollingerLower.toStringAsFixed(5)} — ${market.bollingerUpper.toStringAsFixed(5)}'),
                      Text('Payout setting: ${market.payout}%'),
                      Text('Momentum: ${market.momentum.toStringAsFixed(2)}'),
                      Text('Market activity: ${market.volumeStrength.toStringAsFixed(2)}'),
                      Text('Volatility: ${market.volatility.toStringAsFixed(2)}'),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: app.isLoading ? null : app.refreshMarket,
                      icon: app.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.radar),
                      label: Text(app.isLoading ? 'Scanning...' : 'Scan Live Market'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (signal != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        directionName(signal.direction),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text('Confidence: ${signal.confidence}%'),
                      Text('Expiration length: ${signal.expirationMinutes} minute(s)'),
                      Text('Suggested amount: \$${signal.suggestedAmount.toStringAsFixed(2)}'),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.entryStatus,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text('Entry time: ${formatTime(app.entryTime)}'),
                            Text('Entry window ends: ${formatTime(app.entryWindowEnd)}'),
                            Text('Expiration time: ${formatTime(app.expirationTime)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...signal.reasons.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('• $r'),
                        ),
                      ),
                      if (signal.warnings.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Why the AI may be waiting:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...signal.warnings.map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('⚠ $w'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: signal.direction == SignalDirection.wait ||
                                !app.canTrade ||
                                app.entryMissed
                            ? null
                            : () {
                                app.approveSignal();
                                context.read<IntegrationController>().enqueue(
                                  ExecutionRequest(
                                    id: DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                    symbol: signal.symbol,
                                    direction: directionName(signal.direction),
                                    amount: signal.suggestedAmount,
                                    expirationMinutes:
                                        signal.expirationMinutes,
                                    confidence: signal.confidence,
                                    approved: false,
                                    createdAt: DateTime.now(),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.verified_user),
                        label: const Text('Send to Approval Queue'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The live scanner provides timing guidance only. It does not place a Pocket Option trade.',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
