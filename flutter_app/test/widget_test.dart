import 'package:flutter_test/flutter_test.dart';
import 'package:srm_simulator/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SrmApp());
    expect(find.text('Propelente y grano'), findsOneWidget);
  });
}
