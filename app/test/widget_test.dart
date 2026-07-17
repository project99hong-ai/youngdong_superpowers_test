import 'package:flutter_test/flutter_test.dart';
import 'package:ttokttok_allowance_mvp/app.dart';

void main() {
  testWidgets('shows MVP title', (WidgetTester tester) async {
    await tester.pumpWidget(const TtokttokAllowanceApp());

    expect(find.text('똑똑용돈 MVP'), findsOneWidget);
  });
}
