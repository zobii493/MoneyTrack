import 'package:flutter_test/flutter_test.dart';
import 'package:money_track/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MoneyTrackApp());
    expect(find.byType(MoneyTrackApp), findsOneWidget);
  });
}
