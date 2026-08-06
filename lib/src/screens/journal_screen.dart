import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../learning_controller.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Trade Journal')),
      body: app.trades.isEmpty
          ? const Center(child: Text('No approved demo trades yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: app.trades.length,
              itemBuilder: (context, index) {
                final t = app.trades[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      '${t.symbol} • ${t.direction == SignalDirection.call ? "CALL" : "PUT"}',
                    ),
                    subtitle: Text(
                      '\$${t.amount.toStringAsFixed(2)} • ${t.payout}% payout\n'
                      '${t.won == null ? "Awaiting result" : t.won! ? "WIN" : "LOSS"}',
                    ),
                    trailing: t.won == null
                        ? Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: 'Mark win',
                                onPressed: () {
                                  app.settleTrade(index, true);
                                  context.read<LearningController>().record(
                                    symbol: t.symbol,
                                    direction: t.direction == SignalDirection.call
                                        ? 'CALL'
                                        : 'PUT',
                                    expirationMinutes: 3,
                                    confidence: 80,
                                    won: true,
                                    profit: t.amount * t.payout / 100,
                                  );
                                },
                                icon: const Icon(Icons.check_circle),
                              ),
                              IconButton(
                                tooltip: 'Mark loss',
                                onPressed: () {
                                  app.settleTrade(index, false);
                                  context.read<LearningController>().record(
                                    symbol: t.symbol,
                                    direction: t.direction == SignalDirection.call
                                        ? 'CALL'
                                        : 'PUT',
                                    expirationMinutes: 3,
                                    confidence: 80,
                                    won: false,
                                    profit: -t.amount,
                                  );
                                },
                                icon: const Icon(Icons.cancel),
                              ),
                            ],
                          )
                        : Text(
                            '${t.profit >= 0 ? "+" : ""}\$${t.profit.toStringAsFixed(2)}',
                          ),
                  ),
                );
              },
            ),
    );
  }
}
