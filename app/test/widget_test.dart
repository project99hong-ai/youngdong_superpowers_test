import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttokttok_allowance_mvp/app.dart';
import 'package:ttokttok_allowance_mvp/repositories/demo_repository.dart';
import 'package:ttokttok_allowance_mvp/services/demo_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows role selection for an empty repository', (
    WidgetTester tester,
  ) async {
    final repository = LocalDemoRepository(DemoStorageService());
    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('자녀로 시작'), findsOneWidget);
    expect(find.text('시니어로 시작'), findsOneWidget);
  });
}
