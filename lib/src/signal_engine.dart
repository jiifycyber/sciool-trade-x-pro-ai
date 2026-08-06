import 'models.dart';
import 'strategy_profile.dart';

class TitanSignalEngine {
  TitanSignal evaluate({
    required MarketSnapshot market,
    required StrategyProfile strategy,
    required double accountBalance,
    required double riskPercent,
  }) {
    int bullish = 0;
    int bearish = 0;
    final reasons = <String>[];
    final warnings = <String>[];

    final emaSpread = (market.emaFast - market.emaSlow) / market.price;
    if (emaSpread > 0.00003) {
      bullish += 25;
      reasons.add('EMA ${strategy.emaFast} is above EMA ${strategy.emaSlow}');
    } else if (emaSpread < -0.00003) {
      bearish += 25;
      reasons.add('EMA ${strategy.emaFast} is below EMA ${strategy.emaSlow}');
    } else {
      warnings.add('EMA trend is not separated enough');
    }

    final macdGap = market.macd - market.macdSignal;
    if (macdGap > 0) {
      bullish += 20;
      reasons.add('MACD ${strategy.macdFast}/${strategy.macdSlow}/${strategy.macdSignal} is bullish');
    } else if (macdGap < 0) {
      bearish += 20;
      reasons.add('MACD ${strategy.macdFast}/${strategy.macdSlow}/${strategy.macdSignal} is bearish');
    }

    if (market.rsi >= 52 && market.rsi <= 70) {
      bullish += 12;
      reasons.add('RSI ${market.rsi.toStringAsFixed(1)} supports upward momentum');
    } else if (market.rsi <= 48 && market.rsi >= 30) {
      bearish += 12;
      reasons.add('RSI ${market.rsi.toStringAsFixed(1)} supports downward momentum');
    } else if (market.rsi > 70 || market.rsi < 30) {
      warnings.add('RSI is stretched; reversal risk is elevated');
    } else {
      warnings.add('RSI is neutral');
    }

    if (market.price <= market.bollingerLower && market.momentum > 0) {
      bullish += 12;
      reasons.add('Price is rebounding from the lower Bollinger Band');
    } else if (market.price >= market.bollingerUpper && market.momentum < 0) {
      bearish += 12;
      reasons.add('Price is rejecting the upper Bollinger Band');
    } else if (market.price > market.bollingerMiddle && market.momentum > 0) {
      bullish += 7;
      reasons.add('Price is holding above the Bollinger midline');
    } else if (market.price < market.bollingerMiddle && market.momentum < 0) {
      bearish += 7;
      reasons.add('Price is holding below the Bollinger midline');
    }

    if (market.zigZagDirection > 0) {
      bullish += 10;
      reasons.add('ZigZag ${strategy.zigZagDepth}/${strategy.zigZagDeviation}/${strategy.zigZagBackstep} confirms a rising swing');
    } else if (market.zigZagDirection < 0) {
      bearish += 10;
      reasons.add('ZigZag ${strategy.zigZagDepth}/${strategy.zigZagDeviation}/${strategy.zigZagBackstep} confirms a falling swing');
    }

    if (market.volumeStrength >= 0.55) {
      if (bullish > bearish) {
        bullish += 10;
      } else if (bearish > bullish) {
        bearish += 10;
      }
      reasons.add('Market activity confirms participation');
    } else {
      warnings.add('Market activity is weak');
    }

    if (market.volatility >= 0.12 && market.volatility <= 0.78) {
      if (bullish > bearish) bullish += 6;
      if (bearish > bullish) bearish += 6;
      reasons.add('Volatility is inside the preferred range');
    } else {
      warnings.add('Volatility is outside the preferred range');
    }

    if (market.payout >= 80) {
      if (bullish > bearish) bullish += 5;
      if (bearish > bullish) bearish += 5;
    } else {
      warnings.add('Payout is below the preferred threshold');
    }

    final strongest = bullish > bearish ? bullish : bearish;
    final disagreement = (bullish - bearish).abs();
    var direction = SignalDirection.wait;

    if (strongest >= strategy.minimumConfidence && disagreement >= 25) {
      direction = bullish > bearish ? SignalDirection.call : SignalDirection.put;
    } else {
      warnings.add('Indicators are not aligned strongly enough for entry');
    }

    final riskAmount = accountBalance * riskPercent / 100;
    return TitanSignal(
      symbol: market.symbol,
      direction: direction,
      confidence: strongest.clamp(0, 100),
      expirationMinutes: strategy.timeframeMinutes,
      suggestedAmount: riskAmount,
      reasons: reasons,
      warnings: warnings,
      generatedAt: DateTime.now(),
    );
  }
}
