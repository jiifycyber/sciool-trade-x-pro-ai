import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../advanced_models.dart';
import '../market_radar_controller.dart';

class MarketRadarScreen extends StatelessWidget {
  const MarketRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radar = context.watch<MarketRadarController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Titan Multi-Pair Market Radar')),
      body: RefreshIndicator(
        onRefresh: radar.scanAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1m + 5m + 15m Opportunity Scanner'),
                    const SizedBox(height: 8),
                    Text(
                      radar.lastScan == null
                          ? 'Not scanned yet'
                          : 'Last scan: ${DateFormat('h:mm:ss a').format(radar.lastScan!)}',
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: radar.scanning ? null : radar.scanAll,
                      icon: radar.scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.radar),
                      label: Text(
                        radar.scanning
                            ? 'Scanning Five Pairs...'
                            : 'Scan All Live Pairs',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (radar.error != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Radar unavailable'),
                  subtitle: Text(radar.error!),
                ),
              ),
            const SizedBox(height: 12),
            ...radar.opportunities.map((o) => _opportunity(context, o)),
            if (radar.opportunities.isEmpty && !radar.scanning)
              const Card(
                child: ListTile(
                  title: Text('Run the live radar to rank the markets.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _opportunity(BuildContext context, RadarOpportunity o) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${o.confidence}')),
        title: Text('${o.symbol} • ${o.direction}'),
        subtitle: Text(
          o.direction == 'WAIT'
              ? 'No aligned entry'
              : '${o.expirationMinutes} minute expiration',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...o.analyses.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${a.timeframe.label}: ${a.direction} (${a.score}%)',
                    ),
                    subtitle: Text(
                      'RSI ${a.indicators.rsi.toStringAsFixed(1)} • '
                      'Pattern ${a.indicators.candlePattern}',
                    ),
                  ),
                ),
                const Divider(),
                ...o.reasons.take(8).map((r) => Text('• $r')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
