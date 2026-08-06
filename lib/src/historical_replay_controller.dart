import 'package:flutter/foundation.dart';
import 'market_data/twelve_data_service.dart';
import 'quantum_models.dart';

class HistoricalReplayController extends ChangeNotifier {
  List<ReplayPoint> points = [];
  int index = 0;
  bool playing = false;

  ReplayPoint? get current =>
      points.isEmpty || index >= points.length ? null : points[index];

  void load(List<LiveCandle> candles) {
    points = [];
    for (int i = 205; i < candles.length; i++) {
      final closes = candles.sublist(0, i + 1).map((e) => e.close).toList();
      final ema20 = TwelveDataService.ema(closes, 20);
      final ema200 = TwelveDataService.ema(closes, 200);
      final momentum = TwelveDataService.momentum(closes);
      final direction = ema20 > ema200 && momentum > .4
          ? 'CALL'
          : ema20 < ema200 && momentum < -.4
              ? 'PUT'
              : 'WAIT';
      points.add(
        ReplayPoint(
          time: candles[i].time,
          price: candles[i].close,
          signal: direction,
          confidence: direction == 'WAIT' ? 0 : 72 + (momentum.abs() * 20).round(),
        ),
      );
    }
    index = 0;
    notifyListeners();
  }

  void next() {
    if (index < points.length - 1) {
      index++;
      notifyListeners();
    }
  }

  void previous() {
    if (index > 0) {
      index--;
      notifyListeners();
    }
  }

  void reset() {
    index = 0;
    notifyListeners();
  }
}
