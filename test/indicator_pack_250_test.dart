import 'package:flutter_test/flutter_test.dart';
import 'package:sciool_trade_x_pro/src/indicators/titan_indicator_pack_250.dart';

void main() {
  final candles = List<IndicatorCandle>.generate(
    300,
    (i) {
      final close = 1.0 + i * 0.001 + (i % 7) * 0.0001;
      return IndicatorCandle(
        open: close - 0.0002,
        high: close + 0.0005,
        low: close - 0.0005,
        close: close,
        volume: 1000 + i.toDouble(),
      );
    },
  );

  test('pack contains exactly 250 indicators', () {
    expect(TitanIndicatorPack250.build().length, 250);
  });

  test('all 250 indicators return finite values', () {
    final pack = TitanIndicatorPack250.build();
    for (final indicator in pack) {
      final value = indicator.calculate(candles);
      expect(
        value.isFinite,
        isTrue,
        reason: '${indicator.name} returned $value',
      );
    }
  });

  test('all indicator ids are unique', () {
    final pack = TitanIndicatorPack250.build();
    expect(pack.map((e) => e.id).toSet().length, 250);
  });
}
