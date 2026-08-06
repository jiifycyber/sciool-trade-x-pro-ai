import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'signal_engine.dart';
import 'strategy_profile.dart';
import 'market_data/twelve_data_service.dart';

class TradeXAppState extends ChangeNotifier {
  final _engine = TitanSignalEngine();
  final _liveData = TwelveDataService();
  Timer? _clockTimer;

  double accountBalance = 1000;
  double riskPercent = 1;
  double dailyLossLimitPercent = 5;
  int maxTradesPerDay = 8;
  bool demoMode = true;
  bool cooldownActive = false;
  int consecutiveLosses = 0;
  String selectedSymbol = 'EUR/USD';
  int payout = 88;
  StrategyProfile strategy = StrategyProfile.oneMinute;

  MarketSnapshot? market;
  TitanSignal? signal;
  final List<TradeRecord> trades = [];

  bool isLoading = false;
  String? marketError;
  String dataSource = 'Not connected';
  DateTime? lastMarketUpdateUtc;
  DateTime now = DateTime.now();
  DateTime? entryTime;
  DateTime? entryWindowEnd;
  DateTime? expirationTime;

  List<String> symbols = const [
    'EUR/USD',
    'GBP/USD',
    'USD/JPY',
    'AUD/USD',
    'EUR/GBP',
  ];

  bool get liveDataConfigured => _liveData.isConfigured;
  int get minimumConfidence => strategy.minimumConfidence;

  Future<void> initialize() async {
    strategy = await StrategyProfile.load();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
      notifyListeners();
    });
    await refreshMarket();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshMarket() async {
    isLoading = true;
    marketError = null;
    notifyListeners();

    try {
      final requiredCandles = [
        strategy.emaSlow,
        strategy.bollingerPeriod,
        strategy.macdSlow + strategy.macdSignal,
        60,
      ].reduce((a, b) => a > b ? a : b);
      final result = await _liveData.fetchOneMinuteCandles(
        selectedSymbol,
        outputSize: requiredCandles + 40,
      );
      final closes = result.candles.map((c) => c.close).toList();
      final macd = TwelveDataService.macd(
        closes,
        strategy.macdFast,
        strategy.macdSlow,
        strategy.macdSignal,
      );
      final bands = TwelveDataService.bollinger(
        closes,
        strategy.bollingerPeriod,
        strategy.bollingerDeviation,
      );

      market = MarketSnapshot(
        symbol: selectedSymbol,
        price: closes.last,
        emaFast: TwelveDataService.ema(closes, strategy.emaFast),
        emaSlow: TwelveDataService.ema(closes, strategy.emaSlow),
        macd: macd.line,
        macdSignal: macd.signal,
        rsi: TwelveDataService.rsi(closes, strategy.rsiPeriod),
        bollingerUpper: bands.upper,
        bollingerMiddle: bands.middle,
        bollingerLower: bands.lower,
        zigZagDirection: TwelveDataService.zigZagDirection(
          result.candles,
          strategy.zigZagDepth,
        ),
        momentum: TwelveDataService.momentum(closes),
        volumeStrength: TwelveDataService.activityStrength(
          result.candles,
          lookback: strategy.volumePeriod * 4,
        ),
        volatility: TwelveDataService.volatility(result.candles),
        payout: payout,
        time: result.candles.last.time.toLocal(),
      );

      dataSource = result.source;
      lastMarketUpdateUtc = result.fetchedAt;
      generateSignal();
      _calculateTradeTimes();
    } catch (error) {
      market = null;
      signal = null;
      entryTime = null;
      entryWindowEnd = null;
      expirationTime = null;
      marketError = error.toString().replaceFirst('Bad state: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void generateSignal() {
    if (market == null) return;
    signal = _engine.evaluate(
      market: market!,
      strategy: strategy,
      accountBalance: accountBalance,
      riskPercent: riskPercent,
    );
  }

  Future<void> updateStrategy(StrategyProfile value) async {
    strategy = value;
    await strategy.save();
    await refreshMarket();
  }

  Future<void> resetOneMinuteStrategy() async {
    await updateStrategy(StrategyProfile.oneMinute);
  }

  void _calculateTradeTimes() {
    final currentSignal = signal;
    if (currentSignal == null || currentSignal.direction == SignalDirection.wait) {
      entryTime = null;
      entryWindowEnd = null;
      expirationTime = null;
      return;
    }

    final localNow = DateTime.now();
    entryTime = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      localNow.hour,
      localNow.minute + 1,
    );
    entryWindowEnd = entryTime!.add(const Duration(seconds: 5));
    expirationTime = entryTime!.add(
      Duration(minutes: currentSignal.expirationMinutes),
    );
  }

  Duration? get timeUntilEntry => entryTime == null ? null : entryTime!.difference(now);

  bool get entryWindowOpen {
    if (entryTime == null || entryWindowEnd == null) return false;
    return !now.isBefore(entryTime!) && !now.isAfter(entryWindowEnd!);
  }

  bool get entryMissed => entryWindowEnd != null && now.isAfter(entryWindowEnd!);

  String get entryStatus {
    if (signal == null || signal!.direction == SignalDirection.wait) {
      return 'WAIT — CONDITIONS ARE NOT FULLY ALIGNED';
    }
    if (entryWindowOpen) return 'ENTER NOW';
    if (entryMissed) return 'ENTRY MISSED — DO NOT CHASE';
    final remaining = timeUntilEntry;
    if (remaining == null) return 'NO ENTRY';
    final seconds = remaining.inSeconds.clamp(0, 3599);
    return 'ENTRY IN ${seconds}s';
  }

  void setSymbol(String value) {
    selectedSymbol = value;
    refreshMarket();
  }

  void approveSignal() {
    if (signal == null || signal!.direction == SignalDirection.wait) return;
    if (!canTrade || entryMissed) return;
    trades.insert(
      0,
      TradeRecord(
        symbol: signal!.symbol,
        direction: signal!.direction,
        amount: signal!.suggestedAmount,
        payout: market!.payout,
        won: null,
        openedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  bool get canTrade {
    if (cooldownActive) return false;
    if (tradesToday >= maxTradesPerDay) return false;
    if (dailyProfit <= -(accountBalance * dailyLossLimitPercent / 100)) return false;
    return true;
  }

  void settleTrade(int index, bool won) {
    if (index < 0 || index >= trades.length) return;
    trades[index] = trades[index].copyWith(won: won);
    if (won) {
      consecutiveLosses = 0;
    } else {
      consecutiveLosses++;
      if (consecutiveLosses >= 3) cooldownActive = true;
    }
    notifyListeners();
  }

  void resetCooldown() {
    cooldownActive = false;
    consecutiveLosses = 0;
    notifyListeners();
  }

  int get tradesToday => trades.where((t) =>
      t.openedAt.year == DateTime.now().year &&
      t.openedAt.month == DateTime.now().month &&
      t.openedAt.day == DateTime.now().day).length;

  double get dailyProfit => trades.where((t) => t.openedAt.day == DateTime.now().day)
      .fold(0, (sum, t) => sum + t.profit);

  int get settledTrades => trades.where((t) => t.won != null).length;
  int get wins => trades.where((t) => t.won == true).length;
  double get winRate => settledTrades == 0 ? 0 : wins / settledTrades * 100;

  void updateSettings({
    double? balance,
    double? risk,
    double? dailyLoss,
    int? maxTrades,
    bool? demo,
  }) {
    if (balance != null) accountBalance = balance;
    if (risk != null) riskPercent = risk;
    if (dailyLoss != null) dailyLossLimitPercent = dailyLoss;
    if (maxTrades != null) maxTradesPerDay = maxTrades;
    if (demo != null) demoMode = demo;
    generateSignal();
    _calculateTradeTimes();
    notifyListeners();
  }
}
