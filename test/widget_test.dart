import 'package:flutter_test/flutter_test.dart';
import 'package:m_practice/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MPracticeApp());
    expect(find.text('M-Practice'), findsOneWidget);
  });
}
