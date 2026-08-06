import 'stage6_models.dart';
import 'technical_indicators.dart';

class BacktestEngine {
  BacktestReport run({
    required String symbol,
    required List<Candle> candles,
    required StrategyPreset preset,
    required int payout,
    required int expirationMinutes,
  }) {
    final closes = candles.map((c) => c.close).toList();
    final fast = TechnicalIndicators.ema(closes, preset.fastEma);
    final slow = TechnicalIndicators.ema(closes, preset.slowEma);
    final trades = <BacktestTrade>[];

    final start = preset.slowEma + 25;
    for (int i = start; i < candles.length - expirationMinutes; i++) {
      final fastNow = fast[i];
      final slowNow = slow[i];
      if (fastNow == null || slowNow == null) continue;

      final momentum = TechnicalIndicators.normalizedMomentum(closes, i);
      final volume = TechnicalIndicators.volumeStrength(candles, i);
      final volatility =
          TechnicalIndicators.normalizedVolatility(candles, i, 20);
      final session = TechnicalIndicators.sessionFor(candles[i].time);

      if (!preset.sessions.contains(session)) continue;
      if (payout < preset.minimumPayout) continue;
      if (momentum.abs() < preset.minimumMomentum) continue;
      if (volume < preset.minimumVolumeStrength) continue;
      if (volatility < preset.minimumVolatility ||
          volatility > preset.maximumVolatility) {
        continue;
      }

      final trendUp = fastNow > slowNow;
      final trendDown = fastNow < slowNow;
      final aligned =
          (trendUp && momentum > 0) || (trendDown && momentum < 0);
      if (!aligned) continue;

      int confidence = 45;
      confidence += ((momentum.abs() - preset.minimumMomentum) * 30)
          .clamp(0, 18)
          .round();
      confidence += ((volume - preset.minimumVolumeStrength) * 30)
          .clamp(0, 15)
          .round();
      confidence += 12;
      if (session == MarketSession.overlap) confidence += 8;
      confidence = confidence.clamp(0, 100);

      if (confidence < preset.confidenceThreshold) continue;

      final direction = trendUp ? 'CALL' : 'PUT';
      final entry = candles[i].close;
      final exit = candles[i + expirationMinutes].close;
      final won = direction == 'CALL' ? exit > entry : exit < entry;

      trades.add(BacktestTrade(
        symbol: symbol,
        openedAt: candles[i].time,
        direction: direction,
        entry: entry,
        exit: exit,
        won: won,
        payout: payout,
        confidence: confidence,
        expirationMinutes: expirationMinutes,
        session: session,
      ));

      // Prevent overlapping trades in the backtest.
      i += expirationMinutes;
    }

    return BacktestReport(
      symbol: symbol,
      strategyName: preset.name,
      candleCount: candles.length,
      trades: trades,
      generatedAt: DateTime.now(),
    );
  }
}
