class IndicatorDefinition {
  final String category;
  final String name;
  bool enabled;

  IndicatorDefinition({
    required this.category,
    required this.name,
    this.enabled = true,
  });
}

class IndicatorLibrary {
  final List<IndicatorDefinition> indicators = [
    for (final name in const [
      'EMA 20',
      'EMA 50',
      'EMA 200',
      'SMA',
      'WMA',
      'HMA',
      'VWMA',
      'KAMA',
      'DEMA',
      'TEMA',
      'ZLEMA',
      'Supertrend',
      'Ichimoku Cloud',
      'Parabolic SAR',
      'Donchian Channels',
      'Keltner Channels',
      'Aroon',
      'Vortex',
      'Zig Zag',
      'Linear Regression Trend',
    ])
      IndicatorDefinition(category: 'Trend', name: name),
    for (final name in const [
      'RSI',
      'Stochastic RSI',
      'Stochastic Oscillator',
      'MACD',
      'CCI',
      'ROC',
      'Momentum',
      'Williams %R',
      'Awesome Oscillator',
      'TRIX',
      'Ultimate Oscillator',
      'Relative Vigor Index',
      'Fisher Transform',
      'Chande Momentum Oscillator',
    ])
      IndicatorDefinition(category: 'Momentum', name: name),
    for (final name in const [
      'ATR',
      'Bollinger Bands',
      'Historical Volatility',
      'Standard Deviation',
      'Chaikin Volatility',
      'Mass Index',
      'Ulcer Index',
      'Squeeze Detector',
    ])
      IndicatorDefinition(category: 'Volatility', name: name),
    for (final name in const [
      'OBV',
      'Money Flow Index',
      'Chaikin Money Flow',
      'Accumulation/Distribution',
      'Force Index',
      'Ease of Movement',
      'Volume Price Trend',
      'VWAP',
      'Anchored VWAP',
    ])
      IndicatorDefinition(category: 'Volume / Activity', name: name),
    for (final name in const [
      'Support / Resistance',
      'Supply / Demand Zones',
      'Pivot Points',
      'Fibonacci Retracement',
      'Fibonacci Extension',
      'Breakout / Retest',
      'Fair Value Gaps',
      'Liquidity Sweeps',
      'Order Blocks',
      'Market Structure Shift',
      'Higher High / Lower Low',
      'Consolidation Detector',
    ])
      IndicatorDefinition(category: 'Structure', name: name),
    for (final name in const [
      'Doji',
      'Hammer',
      'Shooting Star',
      'Bullish Engulfing',
      'Bearish Engulfing',
      'Harami',
      'Morning Star',
      'Evening Star',
      'Three White Soldiers',
      'Three Black Crows',
      'Head and Shoulders',
      'Double Top / Bottom',
      'Triangles',
      'Wedges',
      'Flags / Pennants',
      'Cup and Handle',
    ])
      IndicatorDefinition(category: 'Patterns', name: name),
  ];

  List<String> get categories =>
      indicators.map((e) => e.category).toSet().toList();

  List<IndicatorDefinition> inCategory(String category) =>
      indicators.where((e) => e.category == category).toList();
}
