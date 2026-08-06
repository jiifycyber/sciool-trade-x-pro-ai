import 'package:flutter/foundation.dart';
import 'indicators/titan_indicator_pack_250.dart';

class IndicatorResult {
  final TitanIndicator indicator;
  final double value;
  final String bias;

  const IndicatorResult({
    required this.indicator,
    required this.value,
    required this.bias,
  });
}

class IndicatorConsensusController extends ChangeNotifier {
  final List<TitanIndicator> indicators = TitanIndicatorPack250.build();
  final Set<String> enabledIds = {};
  List<IndicatorResult> latest = [];

  IndicatorConsensusController() {
    enabledIds.addAll(indicators.map((e) => e.id));
  }

  void toggle(String id, bool enabled) {
    if (enabled) {
      enabledIds.add(id);
    } else {
      enabledIds.remove(id);
    }
    notifyListeners();
  }

  void enableCategory(IndicatorCategory category, bool enabled) {
    for (final i in indicators.where((e) => e.category == category)) {
      if (enabled) {
        enabledIds.add(i.id);
      } else {
        enabledIds.remove(i.id);
      }
    }
    notifyListeners();
  }

  void evaluate(List<IndicatorCandle> candles) {
    latest = indicators
        .where((i) => enabledIds.contains(i.id))
        .map((i) {
          final value = i.calculate(candles);
          final bias = _bias(i, value, candles.last.close);
          return IndicatorResult(indicator: i, value: value, bias: bias);
        })
        .toList();
    notifyListeners();
  }

  String _bias(TitanIndicator indicator, double value, double price) {
    switch (indicator.category) {
      case IndicatorCategory.trend:
        return price > value ? 'BULLISH' : price < value ? 'BEARISH' : 'NEUTRAL';
      case IndicatorCategory.momentum:
        if (indicator.name.startsWith('RSI') ||
            indicator.name.startsWith('Stochastic') ||
            indicator.name.startsWith('Ultimate') ||
            indicator.name.startsWith('Money Flow')) {
          if (value > 55) return 'BULLISH';
          if (value < 45) return 'BEARISH';
          return 'NEUTRAL';
        }
        if (indicator.name.startsWith('Williams')) {
          if (value > -45) return 'BULLISH';
          if (value < -55) return 'BEARISH';
          return 'NEUTRAL';
        }
        return value > 0 ? 'BULLISH' : value < 0 ? 'BEARISH' : 'NEUTRAL';
      case IndicatorCategory.volatility:
        return 'NEUTRAL';
      case IndicatorCategory.volume:
        return value > 0 ? 'BULLISH' : value < 0 ? 'BEARISH' : 'NEUTRAL';
      case IndicatorCategory.structure:
        if (indicator.name.contains('Support') ||
            indicator.name.contains('Resistance') ||
            indicator.name.contains('Pivot')) {
          return price > value ? 'BULLISH' : price < value ? 'BEARISH' : 'NEUTRAL';
        }
        return value > 0 ? 'BULLISH' : value < 0 ? 'BEARISH' : 'NEUTRAL';
    }
  }

  int get bullish => latest.where((e) => e.bias == 'BULLISH').length;
  int get bearish => latest.where((e) => e.bias == 'BEARISH').length;
  int get neutral => latest.where((e) => e.bias == 'NEUTRAL').length;

  int get consensusPercent {
    final directional = bullish + bearish;
    if (directional == 0) return 0;
    return ((bullish > bearish ? bullish : bearish) / directional * 100).round();
  }

  String get consensusDirection =>
      bullish > bearish ? 'BULLISH' : bearish > bullish ? 'BEARISH' : 'NEUTRAL';
}
