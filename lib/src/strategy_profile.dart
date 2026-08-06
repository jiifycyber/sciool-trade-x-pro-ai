import 'package:shared_preferences/shared_preferences.dart';

class StrategyProfile {
  final String name;
  final int timeframeMinutes;
  final int emaFast;
  final int emaSlow;
  final int macdFast;
  final int macdSlow;
  final int macdSignal;
  final int rsiPeriod;
  final int volumePeriod;
  final int zigZagDepth;
  final int zigZagDeviation;
  final int zigZagBackstep;
  final int bollingerPeriod;
  final double bollingerDeviation;
  final int minimumConfidence;

  const StrategyProfile({
    required this.name,
    required this.timeframeMinutes,
    required this.emaFast,
    required this.emaSlow,
    required this.macdFast,
    required this.macdSlow,
    required this.macdSignal,
    required this.rsiPeriod,
    required this.volumePeriod,
    required this.zigZagDepth,
    required this.zigZagDeviation,
    required this.zigZagBackstep,
    required this.bollingerPeriod,
    required this.bollingerDeviation,
    required this.minimumConfidence,
  });

  static const oneMinute = StrategyProfile(
    name: 'Jontarius 1-Minute',
    timeframeMinutes: 1,
    emaFast: 9,
    emaSlow: 21,
    macdFast: 5,
    macdSlow: 13,
    macdSignal: 5,
    rsiPeriod: 14,
    volumePeriod: 10,
    zigZagDepth: 5,
    zigZagDeviation: 4,
    zigZagBackstep: 3,
    bollingerPeriod: 20,
    bollingerDeviation: 2,
    minimumConfidence: 85,
  );

  StrategyProfile copyWith({
    String? name,
    int? timeframeMinutes,
    int? emaFast,
    int? emaSlow,
    int? macdFast,
    int? macdSlow,
    int? macdSignal,
    int? rsiPeriod,
    int? volumePeriod,
    int? zigZagDepth,
    int? zigZagDeviation,
    int? zigZagBackstep,
    int? bollingerPeriod,
    double? bollingerDeviation,
    int? minimumConfidence,
  }) {
    return StrategyProfile(
      name: name ?? this.name,
      timeframeMinutes: timeframeMinutes ?? this.timeframeMinutes,
      emaFast: emaFast ?? this.emaFast,
      emaSlow: emaSlow ?? this.emaSlow,
      macdFast: macdFast ?? this.macdFast,
      macdSlow: macdSlow ?? this.macdSlow,
      macdSignal: macdSignal ?? this.macdSignal,
      rsiPeriod: rsiPeriod ?? this.rsiPeriod,
      volumePeriod: volumePeriod ?? this.volumePeriod,
      zigZagDepth: zigZagDepth ?? this.zigZagDepth,
      zigZagDeviation: zigZagDeviation ?? this.zigZagDeviation,
      zigZagBackstep: zigZagBackstep ?? this.zigZagBackstep,
      bollingerPeriod: bollingerPeriod ?? this.bollingerPeriod,
      bollingerDeviation: bollingerDeviation ?? this.bollingerDeviation,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
    );
  }

  static Future<StrategyProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final d = oneMinute;
    return StrategyProfile(
      name: prefs.getString('strategy_name') ?? d.name,
      timeframeMinutes: prefs.getInt('strategy_timeframe') ?? d.timeframeMinutes,
      emaFast: prefs.getInt('strategy_ema_fast') ?? d.emaFast,
      emaSlow: prefs.getInt('strategy_ema_slow') ?? d.emaSlow,
      macdFast: prefs.getInt('strategy_macd_fast') ?? d.macdFast,
      macdSlow: prefs.getInt('strategy_macd_slow') ?? d.macdSlow,
      macdSignal: prefs.getInt('strategy_macd_signal') ?? d.macdSignal,
      rsiPeriod: prefs.getInt('strategy_rsi') ?? d.rsiPeriod,
      volumePeriod: prefs.getInt('strategy_volume') ?? d.volumePeriod,
      zigZagDepth: prefs.getInt('strategy_zigzag_depth') ?? d.zigZagDepth,
      zigZagDeviation: prefs.getInt('strategy_zigzag_deviation') ?? d.zigZagDeviation,
      zigZagBackstep: prefs.getInt('strategy_zigzag_backstep') ?? d.zigZagBackstep,
      bollingerPeriod: prefs.getInt('strategy_bollinger_period') ?? d.bollingerPeriod,
      bollingerDeviation: prefs.getDouble('strategy_bollinger_deviation') ?? d.bollingerDeviation,
      minimumConfidence: prefs.getInt('strategy_min_confidence') ?? d.minimumConfidence,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('strategy_name', name);
    await prefs.setInt('strategy_timeframe', timeframeMinutes);
    await prefs.setInt('strategy_ema_fast', emaFast);
    await prefs.setInt('strategy_ema_slow', emaSlow);
    await prefs.setInt('strategy_macd_fast', macdFast);
    await prefs.setInt('strategy_macd_slow', macdSlow);
    await prefs.setInt('strategy_macd_signal', macdSignal);
    await prefs.setInt('strategy_rsi', rsiPeriod);
    await prefs.setInt('strategy_volume', volumePeriod);
    await prefs.setInt('strategy_zigzag_depth', zigZagDepth);
    await prefs.setInt('strategy_zigzag_deviation', zigZagDeviation);
    await prefs.setInt('strategy_zigzag_backstep', zigZagBackstep);
    await prefs.setInt('strategy_bollinger_period', bollingerPeriod);
    await prefs.setDouble('strategy_bollinger_deviation', bollingerDeviation);
    await prefs.setInt('strategy_min_confidence', minimumConfidence);
  }
}
