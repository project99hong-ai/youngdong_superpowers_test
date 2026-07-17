import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttokttok_allowance_mvp/app.dart';
import 'package:ttokttok_allowance_mvp/models/demo_state.dart';
import 'package:ttokttok_allowance_mvp/repositories/demo_repository.dart';
import 'package:ttokttok_allowance_mvp/services/demo_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('child role selection persists and shows the child home', (
    WidgetTester tester,
  ) async {
    final repository = LocalDemoRepository(DemoStorageService());
    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('자녀로 시작'));
    await tester.pumpAndSettle();

    expect((await repository.loadState()).selectedRole, UserRole.child);
    expect(find.text('자녀 홈'), findsOneWidget);
  });

  testWidgets('senior role selection persists and shows the senior home', (
    WidgetTester tester,
  ) async {
    final repository = LocalDemoRepository(DemoStorageService());
    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('시니어로 시작'));
    await tester.pumpAndSettle();

    expect((await repository.loadState()).selectedRole, UserRole.senior);
    expect(find.text('시니어 홈'), findsOneWidget);
  });

  testWidgets('a new repository and app instance load the persisted role', (
    WidgetTester tester,
  ) async {
    final firstRepository = LocalDemoRepository(DemoStorageService());
    await firstRepository.selectRole(UserRole.senior);
    final secondRepository = LocalDemoRepository(DemoStorageService());

    await tester.pumpWidget(TtokttokAllowanceApp(repository: secondRepository));
    await tester.pumpAndSettle();

    expect(find.text('시니어 홈'), findsOneWidget);
    expect(find.text('자녀로 시작'), findsNothing);
    expect(find.text('시니어로 시작'), findsNothing);
  });

  testWidgets('reset clears the role and returns to role selection', (
    WidgetTester tester,
  ) async {
    final repository = LocalDemoRepository(DemoStorageService());
    await repository.selectRole(UserRole.child);
    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('역할 다시 선택'));
    await tester.pumpAndSettle();

    expect((await repository.loadState()).selectedRole, isNull);
    expect(find.text('자녀로 시작'), findsOneWidget);
    expect(find.text('시니어로 시작'), findsOneWidget);
  });
}
