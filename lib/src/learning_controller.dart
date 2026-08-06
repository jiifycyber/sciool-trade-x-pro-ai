import 'package:flutter/foundation.dart';
import 'advanced_models.dart';

class LearningController extends ChangeNotifier {
  final Map<String, LearningStat> byPair = {};
  final Map<String, LearningStat> byDirection = {};
  final Map<String, LearningStat> byExpiration = {};
  final Map<String, LearningStat> byConfidenceBand = {};

  void record({
    required String symbol,
    required String direction,
    required int expirationMinutes,
    required int confidence,
    required bool won,
    required double profit,
  }) {
    _update(byPair, symbol, won, profit);
    _update(byDirection, direction, won, profit);
    _update(byExpiration, '${expirationMinutes}m', won, profit);
    final band = confidence >= 90
        ? '90–100'
        : confidence >= 80
            ? '80–89'
            : confidence >= 70
                ? '70–79'
                : 'Below 70';
    _update(byConfidenceBand, band, won, profit);
    notifyListeners();
  }

  void _update(
    Map<String, LearningStat> map,
    String key,
    bool won,
    double profit,
  ) {
    final stat = map.putIfAbsent(key, () => LearningStat(key: key));
    stat.trades++;
    if (won) stat.wins++;
    stat.netProfit += profit;
  }

  LearningStat? best(Map<String, LearningStat> map) {
    if (map.isEmpty) return null;
    final values = map.values.where((s) => s.trades >= 3).toList();
    if (values.isEmpty) return null;
    values.sort((a, b) => b.winRate.compareTo(a.winRate));
    return values.first;
  }
}
