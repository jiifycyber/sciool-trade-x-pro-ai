import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../historical_replay_controller.dart';
import '../market_data/twelve_data_service.dart';
import '../theme.dart';
import '../widgets/egypt_widgets.dart';

class HistoricalReplayScreen extends StatefulWidget {
  const HistoricalReplayScreen({super.key});

  @override
  State<HistoricalReplayScreen> createState() => _HistoricalReplayScreenState();
}

class _HistoricalReplayScreenState extends State<HistoricalReplayScreen> {
  final data = TwelveDataService();
  bool loading = false;
  String? error;

  Future<void> load(BuildContext context) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result =
          await data.fetchOneMinuteCandles('EUR/USD', outputSize: 700);
      if (context.mounted) {
        context.read<HistoricalReplayController>().load(result.candles);
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final replay = context.watch<HistoricalReplayController>();
    final current = replay.current;
    return Scaffold(
      appBar: AppBar(title: const Text('HISTORICAL MARKET REPLAY')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const EgyptianBanner(),
          const SizedBox(height: 14),
          EgyptPanel(
            title: 'Replay Controls',
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: loading ? null : () => load(context),
                  icon: const Icon(Icons.download),
                  label: Text(loading ? 'LOADING...' : 'LOAD EUR/USD HISTORY'),
                ),
                if (error != null) Text(error!),
                const SizedBox(height: 16),
                if (current != null) ...[
                  Text(
                    current.signal,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: current.signal == 'CALL'
                          ? TitanEgyptColors.emerald
                          : current.signal == 'PUT'
                              ? TitanEgyptColors.red
                              : TitanEgyptColors.amber,
                    ),
                  ),
                  Text('Price: ${current.price.toStringAsFixed(5)}'),
                  Text('Confidence: ${current.confidence}%'),
                  Text('${replay.index + 1}/${replay.points.length}'),
                  Slider(
                    value: replay.index.toDouble(),
                    min: 0,
                    max: replay.points.isEmpty
                        ? 1
                        : (replay.points.length - 1).toDouble(),
                    onChanged: replay.points.isEmpty
                        ? null
                        : (v) {
                            while (replay.index < v.round()) {
                              replay.next();
                            }
                            while (replay.index > v.round()) {
                              replay.previous();
                            }
                          },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: replay.previous,
                        icon: const Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        onPressed: replay.reset,
                        icon: const Icon(Icons.replay),
                      ),
                      IconButton(
                        onPressed: replay.next,
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
