import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../market_radar_controller.dart';
import '../theme.dart';
import '../widgets/egypt_widgets.dart';

class QuantumAiScreen extends StatelessWidget {
  const QuantumAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radar = context.watch<MarketRadarController>();
    final best = radar.bestOpportunity;

    return Scaffold(
      appBar: AppBar(title: const Text('TradeX Intelligence')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const EgyptianBanner(),
          const SizedBox(height: 14),
          EgyptPanel(
            title: 'Quantum Market Brain',
            trailing: FilledButton.icon(
              onPressed: radar.scanning ? null : radar.scanAll,
              icon: const Icon(Icons.radar),
              label: Text(radar.scanning ? 'SCANNING' : 'RUN QUANTUM SCAN'),
            ),
            child: best == null
                ? const ListTile(
                    title: Text('No assessment available'),
                    subtitle: Text('Run the live market radar first.'),
                  )
                : Column(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        size: 90,
                        color: TitanEgyptColors.cyan,
                      ),
                      Text(
                        '${best.symbol} • ${best.direction}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        '${best.confidence}% • ${best.confidence >= 92 ? "A+" : best.confidence >= 85 ? "A" : best.confidence >= 78 ? "B+" : "C"}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: TitanEgyptColors.emerald,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...best.analyses.map(
                        (a) => ListTile(
                          title: Text(
                            '${a.timeframe.name.toUpperCase()}: ${a.direction} (${a.score}%)',
                          ),
                          subtitle: Text(
                            'RSI ${a.indicators.rsi.toStringAsFixed(1)} • '
                            'MACD ${a.indicators.macd.toStringAsFixed(5)} • '
                            '${a.indicators.candlePattern}',
                          ),
                        ),
                      ),
                      const Divider(),
                      ...best.reasons.take(10).map((e) => Text('✓ $e')),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
