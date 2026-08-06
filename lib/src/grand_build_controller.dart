import 'package:flutter/foundation.dart';
import 'backtest_engine.dart';
import 'historical_data_service.dart';
import 'stage6_models.dart';

class GrandBuildController extends ChangeNotifier {
  final HistoricalDataService dataService = HistoricalDataService();
  final BacktestEngine backtestEngine = BacktestEngine();

  String selectedSymbol = 'EUR/USD';
  int payout = 88;
  int expirationMinutes = 3;
  bool isRunning = false;
  BacktestReport? report;

  final List<StrategyPreset> presets = const [
    StrategyPreset(
      id: 'balanced',
      name: 'Titan Balanced',
      fastEma: 20,
      slowEma: 200,
      minimumMomentum: 0.45,
      minimumVolumeStrength: 0.55,
      minimumVolatility: 0.20,
      maximumVolatility: 0.78,
      minimumPayout: 80,
      confidenceThreshold: 70,
      sessions: [
        MarketSession.london,
        MarketSession.overlap,
        MarketSession.newYork,
      ],
    ),
    StrategyPreset(
      id: 'sniper',
      name: 'Titan Sniper',
      fastEma: 20,
      slowEma: 200,
      minimumMomentum: 0.62,
      minimumVolumeStrength: 0.68,
      minimumVolatility: 0.28,
      maximumVolatility: 0.68,
      minimumPayout: 85,
      confidenceThreshold: 82,
      sessions: [MarketSession.overlap, MarketSession.newYork],
    ),
    StrategyPreset(
      id: 'session',
      name: 'London/New York Flow',
      fastEma: 12,
      slowEma: 50,
      minimumMomentum: 0.52,
      minimumVolumeStrength: 0.60,
      minimumVolatility: 0.24,
      maximumVolatility: 0.80,
      minimumPayout: 80,
      confidenceThreshold: 75,
      sessions: [
        MarketSession.london,
        MarketSession.overlap,
        MarketSession.newYork,
      ],
    ),
  ];

  late StrategyPreset selectedPreset = presets.first;

  Future<void> runDemoBacktest({int candleCount = 2500}) async {
    isRunning = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final candles = dataService.generateDemoCandles(
      symbol: selectedSymbol,
      count: candleCount,
    );

    report = backtestEngine.run(
      symbol: selectedSymbol,
      candles: candles,
      preset: selectedPreset,
      payout: payout,
      expirationMinutes: expirationMinutes,
    );

    isRunning = false;
    notifyListeners();
  }

  void setSymbol(String value) {
    selectedSymbol = value;
    notifyListeners();
  }

  void setPreset(StrategyPreset value) {
    selectedPreset = value;
    notifyListeners();
  }

  void setPayout(int value) {
    payout = value;
    notifyListeners();
  }

  void setExpiration(int value) {
    expirationMinutes = value;
    notifyListeners();
  }
}
