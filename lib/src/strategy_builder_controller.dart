import 'package:flutter/foundation.dart';
import 'quantum_models.dart';

class StrategyBuilderController extends ChangeNotifier {
  final List<String> fields = const [
    'EMA 20',
    'EMA 50',
    'EMA 200',
    'RSI',
    'MACD',
    'ATR',
    'Bollinger Position',
    'Trend Strength',
    'Timeframe Alignment',
    'News Risk',
    'Payout',
    'Confidence',
  ];

  final List<String> operators = const ['>', '<', '>=', '<=', '=='];

  final List<StrategyDefinition> strategies = [
    const StrategyDefinition(
      name: 'Titan Quantum Sniper',
      conditions: [
        StrategyCondition(left: 'EMA 20', operatorSymbol: '>', right: 'EMA 200'),
        StrategyCondition(left: 'RSI', operatorSymbol: '>=', right: '55'),
        StrategyCondition(left: 'MACD', operatorSymbol: '>', right: 'Signal'),
        StrategyCondition(
          left: 'Timeframe Alignment',
          operatorSymbol: '==',
          right: 'CALL',
        ),
        StrategyCondition(left: 'Confidence', operatorSymbol: '>=', right: '82'),
      ],
      action: 'CALL',
      minimumConfidence: 82,
    ),
  ];

  void addStrategy(StrategyDefinition strategy) {
    strategies.add(strategy);
    notifyListeners();
  }

  void removeStrategy(int index) {
    if (index < 0 || index >= strategies.length) return;
    strategies.removeAt(index);
    notifyListeners();
  }
}
