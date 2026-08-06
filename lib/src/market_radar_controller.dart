import 'package:flutter/foundation.dart';
import 'advanced_models.dart';
import 'market_data/twelve_data_service.dart';
import 'multi_timeframe_engine.dart';

class MarketRadarController extends ChangeNotifier {
  final TwelveDataService data = TwelveDataService();
  final MultiTimeframeEngine engine = MultiTimeframeEngine();

  final List<String> symbols = const [
    'EUR/USD',
    'GBP/USD',
    'USD/JPY',
    'AUD/USD',
    'EUR/GBP',
  ];

  bool scanning = false;
  String? error;
  DateTime? lastScan;
  List<RadarOpportunity> opportunities = [];

  Future<void> scanAll() async {
    scanning = true;
    error = null;
    notifyListeners();

    final found = <RadarOpportunity>[];
    try {
      for (final symbol in symbols) {
        final result =
            await data.fetchOneMinuteCandles(symbol, outputSize: 620);
        found.add(engine.evaluateSymbol(symbol, result.candles));
      }
      found.sort((a, b) => b.confidence.compareTo(a.confidence));
      opportunities = found;
      lastScan = DateTime.now();
    } catch (e) {
      error = e.toString().replaceFirst('Bad state: ', '');
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  RadarOpportunity? get bestOpportunity =>
      opportunities.isEmpty ? null : opportunities.first;
}
