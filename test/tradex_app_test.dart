import 'package:flutter_test/flutter_test.dart';
import 'package:sciool_trade_x_pro/main.dart';

void main() {
  testWidgets('SCIOOL Trade X Pro starts', (tester) async {
    await tester.pumpWidget(const TradeXApp());
    expect(find.text('SCIOOL TRADE X PRO'), findsOneWidget);
  });
}
