import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../advanced_models.dart';
import '../learning_controller.dart';

class LearningCenterScreen extends StatelessWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Titan Learning Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.psychology),
              title: Text('Performance Learning'),
              subtitle: Text(
                'TITAN groups completed trades by pair, direction, expiration, and confidence band. It does not retrain a foundation model.',
              ),
            ),
          ),
          _section('Performance by Pair', learning.byPair),
          _section('Performance by Direction', learning.byDirection),
          _section('Performance by Expiration', learning.byExpiration),
          _section('Performance by Confidence', learning.byConfidenceBand),
        ],
      ),
    );
  }

  Widget _section(String title, Map<String, LearningStat> stats) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title),
        children: stats.isEmpty
            ? const [
                ListTile(title: Text('No completed trade data yet.')),
              ]
            : stats.values
                .map(
                  (s) => ListTile(
                    title: Text(s.key),
                    subtitle: Text(
                      '${s.wins}/${s.trades} wins • '
                      '${s.winRate.toStringAsFixed(1)}%',
                    ),
                    trailing: Text(
                      '${s.netProfit >= 0 ? "+" : ""}\$${s.netProfit.toStringAsFixed(2)}',
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
