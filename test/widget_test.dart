import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/main.dart';

void main() {
  testWidgets('App shows splash screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Powered by ZIP'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
