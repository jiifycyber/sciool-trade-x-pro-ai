import 'dart:math';
import 'advanced_models.dart';
import 'market_data/twelve_data_service.dart';
import 'quantum_models.dart';
import 'advanced_indicators.dart';

class QuantumMarketBrain {
  QuantumAssessment assess({
    required String symbol,
    required List<LiveCandle> candles,
    required List<TimeframeAnalysis> timeframeAnalyses,
  }) {
    final closes = candles.map((e) => e.close).toList();
    final ema20 = TwelveDataService.ema(closes, 20);
    final ema50 = TwelveDataService.ema(closes, 50);
    final ema200 = TwelveDataService.ema(closes, 200);
    final atr = AdvancedIndicators.atr(candles);
    final volatility = TwelveDataService.volatility(candles);
    final rsi = AdvancedIndicators.rsi(closes);
    final macd = AdvancedIndicators.macd(closes);
    final supportResistance =
        AdvancedIndicators.supportResistance(candles, lookback: 80);

    final regime = _detectRegime(
      closes: closes,
      ema20: ema20,
      ema50: ema50,
      ema200: ema200,
      atr: atr,
      volatility: volatility,
    );

    final institutional = _institutionalSignals(
      candles,
      supportResistance.$1,
      supportResistance.$2,
    );

    int bullish = 0;
    int bearish = 0;
    final confirmations = <String>[];
    final warnings = <String>[];

    if (ema20 > ema50 && ema50 > ema200) {
      bullish += 24;
      confirmations.add('20/50/200 EMA stack is bullish');
    } else if (ema20 < ema50 && ema50 < ema200) {
      bearish += 24;
      confirmations.add('20/50/200 EMA stack is bearish');
    } else {
      warnings.add('Moving-average structure is mixed');
    }

    if (rsi >= 52 && rsi <= 68) {
      bullish += 12;
      confirmations.add('RSI supports bullish momentum');
    } else if (rsi <= 48 && rsi >= 32) {
      bearish += 12;
      confirmations.add('RSI supports bearish momentum');
    } else if (rsi > 72 || rsi < 28) {
      warnings.add('RSI is overextended');
    }

    if (macd.$1 > macd.$2) {
      bullish += 12;
      confirmations.add('MACD is above its signal line');
    } else {
      bearish += 12;
      confirmations.add('MACD is below its signal line');
    }

    final calls = timeframeAnalyses.where((a) => a.direction == 'CALL').length;
    final puts = timeframeAnalyses.where((a) => a.direction == 'PUT').length;
    if (calls >= 2) {
      bullish += 22;
      confirmations.add('$calls timeframes confirm CALL');
    } else if (puts >= 2) {
      bearish += 22;
      confirmations.add('$puts timeframes confirm PUT');
    } else {
      warnings.add('Timeframes are not aligned');
    }

    for (final s in institutional) {
      if (s.direction == 'CALL') bullish += (s.strength * 12).round();
      if (s.direction == 'PUT') bearish += (s.strength * 12).round();
      if (s.direction != 'WAIT') confirmations.add(s.explanation);
    }

    if (regime == MarketRegime.range) {
      warnings.add('Range regime reduces trend-following confidence');
      bullish = max(0, bullish - 10);
      bearish = max(0, bearish - 10);
    }
    if (regime == MarketRegime.highVolatility) {
      warnings.add('High volatility requires smaller risk');
      bullish = max(0, bullish - 5);
      bearish = max(0, bearish - 5);
    }

    final direction = bullish > bearish
        ? 'CALL'
        : bearish > bullish
            ? 'PUT'
            : 'WAIT';
    final confidence =
        direction == 'WAIT' ? 0 : max(bullish, bearish).clamp(0, 100);
    final grade = confidence >= 92
        ? 'A+'
        : confidence >= 85
            ? 'A'
            : confidence >= 78
                ? 'B+'
                : confidence >= 70
                    ? 'B'
                    : confidence >= 60
                        ? 'C'
                        : 'F';

    return QuantumAssessment(
      symbol: symbol,
      regime: regime,
      direction: confidence < 60 ? 'WAIT' : direction,
      confidence: confidence,
      grade: grade,
      confirmations: confirmations,
      warnings: warnings,
      institutionalSignals: institutional,
    );
  }

  MarketRegime _detectRegime({
    required List<double> closes,
    required double ema20,
    required double ema50,
    required double ema200,
    required double atr,
    required double volatility,
  }) {
    final price = closes.last.abs();
    final normalizedAtr = price == 0 ? 0 : atr / price;
    final stackStrength =
        ((ema20 - ema50).abs() + (ema50 - ema200).abs()) / max(price, 1e-9);

    if (volatility > .78 || normalizedAtr > .0025) {
      return MarketRegime.highVolatility;
    }
    if (volatility < .18 || normalizedAtr < .00025) {
      return MarketRegime.lowVolatility;
    }
    if (stackStrength > .0016) {
      return MarketRegime.strongTrend;
    }
    if (stackStrength > .0007) {
      return MarketRegime.weakTrend;
    }
    final recent = closes.sublist(max(0, closes.length - 40));
    final hi = recent.reduce(max);
    final lo = recent.reduce(min);
    final range = price == 0 ? 0 : (hi - lo) / price;
    if (range < .003) return MarketRegime.range;
    return MarketRegime.transition;
  }

  List<InstitutionalSignal> _institutionalSignals(
    List<LiveCandle> candles,
    double support,
    double resistance,
  ) {
    final out = <InstitutionalSignal>[];
    if (candles.length < 6) return out;

    final last = candles.last;
    final previous = candles[candles.length - 2];
    final twoBack = candles[candles.length - 3];

    final sweptLow =
        last.low < support && last.close > support;
    final sweptHigh =
        last.high > resistance && last.close < resistance;

    if (sweptLow) {
      out.add(const InstitutionalSignal(
        name: 'Liquidity Sweep',
        direction: 'CALL',
        strength: .85,
        explanation: 'Sell-side liquidity was swept and reclaimed',
      ));
    }
    if (sweptHigh) {
      out.add(const InstitutionalSignal(
        name: 'Liquidity Sweep',
        direction: 'PUT',
        strength: .85,
        explanation: 'Buy-side liquidity was swept and rejected',
      ));
    }

    final bullishGap = last.low > twoBack.high;
    final bearishGap = last.high < twoBack.low;
    if (bullishGap) {
      out.add(const InstitutionalSignal(
        name: 'Fair Value Gap',
        direction: 'CALL',
        strength: .65,
        explanation: 'Bullish fair-value gap detected',
      ));
    }
    if (bearishGap) {
      out.add(const InstitutionalSignal(
        name: 'Fair Value Gap',
        direction: 'PUT',
        strength: .65,
        explanation: 'Bearish fair-value gap detected',
      ));
    }

    final bullishBos =
        last.close > previous.high && previous.high > twoBack.high;
    final bearishBos =
        last.close < previous.low && previous.low < twoBack.low;
    if (bullishBos) {
      out.add(const InstitutionalSignal(
        name: 'Break of Structure',
        direction: 'CALL',
        strength: .8,
        explanation: 'Bullish break of structure confirmed',
      ));
    }
    if (bearishBos) {
      out.add(const InstitutionalSignal(
        name: 'Break of Structure',
        direction: 'PUT',
        strength: .8,
        explanation: 'Bearish break of structure confirmed',
      ));
    }

    if (out.isEmpty) {
      out.add(const InstitutionalSignal(
        name: 'Institutional Structure',
        direction: 'WAIT',
        strength: 0,
        explanation: 'No high-quality institutional pattern detected',
      ));
    }
    return out;
  }
}
