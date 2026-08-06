import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../strategy_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double balance;
  late double risk;
  late double lossLimit;
  late double maxTrades;
  late StrategyProfile strategy;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final app = context.read<TradeXAppState>();
    balance = app.accountBalance;
    risk = app.riskPercent;
    lossLimit = app.dailyLossLimitPercent;
    maxTrades = app.maxTradesPerDay.toDouble();
    strategy = app.strategy;
    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('AI Strategy & Risk Controls')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Strategy',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(strategy.name),
                  const SizedBox(height: 4),
                  const Text(
                    'These settings control every CALL, PUT, and WAIT decision.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _section('Strategy Settings'),
          _numberRow(
            'Expiration time (minutes)',
            strategy.timeframeMinutes,
            1,
            5,
            (v) => strategy = strategy.copyWith(timeframeMinutes: v),
          ),
          _numberRow('EMA fast', strategy.emaFast, 2, 50,
              (v) => strategy = strategy.copyWith(emaFast: v)),
          _numberRow('EMA slow', strategy.emaSlow, 3, 100,
              (v) => strategy = strategy.copyWith(emaSlow: v)),
          _numberRow('MACD fast', strategy.macdFast, 2, 30,
              (v) => strategy = strategy.copyWith(macdFast: v)),
          _numberRow('MACD slow', strategy.macdSlow, 3, 60,
              (v) => strategy = strategy.copyWith(macdSlow: v)),
          _numberRow('MACD signal', strategy.macdSignal, 2, 20,
              (v) => strategy = strategy.copyWith(macdSignal: v)),
          _numberRow('RSI period', strategy.rsiPeriod, 2, 30,
              (v) => strategy = strategy.copyWith(rsiPeriod: v)),
          _numberRow('Volume/activity period', strategy.volumePeriod, 2, 50,
              (v) => strategy = strategy.copyWith(volumePeriod: v)),
          _numberRow('ZigZag depth', strategy.zigZagDepth, 2, 30,
              (v) => strategy = strategy.copyWith(zigZagDepth: v)),
          _numberRow('ZigZag deviation', strategy.zigZagDeviation, 1, 20,
              (v) => strategy = strategy.copyWith(zigZagDeviation: v)),
          _numberRow('ZigZag backstep', strategy.zigZagBackstep, 1, 20,
              (v) => strategy = strategy.copyWith(zigZagBackstep: v)),
          _numberRow('Bollinger period', strategy.bollingerPeriod, 5, 50,
              (v) => strategy = strategy.copyWith(bollingerPeriod: v)),
          _doubleRow('Bollinger deviation', strategy.bollingerDeviation, 1, 4,
              (v) => strategy = strategy.copyWith(bollingerDeviation: v)),
          _numberRow('Minimum AI confidence', strategy.minimumConfidence, 50,
              98, (v) => strategy = strategy.copyWith(minimumConfidence: v)),
          const SizedBox(height: 12),
          _section('Risk Controls'),
          _slider('Account balance', balance, 100, 100000,
              (v) => setState(() => balance = v),
              valueText: '\$${balance.toStringAsFixed(0)}'),
          _slider(
              'Risk per trade', risk, .25, 3, (v) => setState(() => risk = v),
              valueText: '${risk.toStringAsFixed(2)}%'),
          _slider('Daily loss limit', lossLimit, 1, 10,
              (v) => setState(() => lossLimit = v),
              valueText: '${lossLimit.toStringAsFixed(1)}%'),
          _slider('Maximum trades per day', maxTrades, 1, 20,
              (v) => setState(() => maxTrades = v),
              valueText: maxTrades.toStringAsFixed(0)),
          SwitchListTile(
            value: app.demoMode,
            onChanged: (v) => app.updateSettings(demo: v),
            title: const Text('Demo mode'),
            subtitle: const Text('Trade execution remains approval-only.'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              if (strategy.emaFast >= strategy.emaSlow ||
                  strategy.macdFast >= strategy.macdSlow) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Fast periods must be lower than slow periods.'),
                  ),
                );
                return;
              }
              app.updateSettings(
                balance: balance,
                risk: risk,
                dailyLoss: lossLimit,
                maxTrades: maxTrades.round(),
              );
              await app.updateStrategy(strategy);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Strategy & Risk Settings'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () =>
                setState(() => strategy = StrategyProfile.oneMinute),
            child: const Text('Restore Jontarius 1-Minute Defaults'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );

  Widget _numberRow(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> changed,
  ) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Slider(
          value:
              value.toDouble().clamp(min.toDouble(), max.toDouble()).toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: '$value',
          onChanged: (v) => setState(() => changed(v.round())),
        ),
        trailing:
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _doubleRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> changed,
  ) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: ((max - min) * 10).round(),
          label: value.toStringAsFixed(1),
          onChanged: (v) => setState(() => changed(v)),
        ),
        trailing: Text(value.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    required String valueText,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: $valueText'),
            Slider(value: value, min: min, max: max, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
