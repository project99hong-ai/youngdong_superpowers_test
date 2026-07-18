import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttokttok_allowance_mvp/app.dart';
import 'package:ttokttok_allowance_mvp/models/ai_report.dart';
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

    await tester.tap(find.byKey(const Key('role-select-child-button')));
    await tester.pumpAndSettle();

    expect((await repository.loadState()).selectedRole, UserRole.child);
    expect(find.byKey(const Key('role-home-child')), findsOneWidget);
  });

  testWidgets('senior role selection persists and shows the senior home', (
    WidgetTester tester,
  ) async {
    final repository = LocalDemoRepository(DemoStorageService());
    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('role-select-senior-button')));
    await tester.pumpAndSettle();

    expect((await repository.loadState()).selectedRole, UserRole.senior);
    expect(find.byKey(const Key('role-home-senior')), findsOneWidget);
  });

  testWidgets('a new repository and app instance load the persisted role', (
    WidgetTester tester,
  ) async {
    final firstRepository = LocalDemoRepository(DemoStorageService());
    await firstRepository.selectRole(UserRole.senior);
    final secondRepository = LocalDemoRepository(DemoStorageService());

    await tester.pumpWidget(TtokttokAllowanceApp(repository: secondRepository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('role-home-senior')), findsOneWidget);
    expect(find.byKey(const Key('role-select-child-button')), findsNothing);
    expect(find.byKey(const Key('role-select-senior-button')), findsNothing);
  });

  testWidgets('reset clears the role and returns to role selection', (
    WidgetTester tester,
  ) async {
    final repository = LocalDemoRepository(DemoStorageService());
    await repository.selectRole(UserRole.child);
    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('role-home-reset-button')));
    await tester.pumpAndSettle();

    expect((await repository.loadState()).selectedRole, isNull);
    expect(find.byKey(const Key('role-select-child-button')), findsOneWidget);
    expect(find.byKey(const Key('role-select-senior-button')), findsOneWidget);
  });

  testWidgets('shows a loading indicator while startup state is loading', (
    WidgetTester tester,
  ) async {
    final completer = Completer<DemoState>();
    final repository = _FakeWidgetDemoRepository(
      loadStateHandler: () => completer.future,
    );

    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));

    expect(find.byKey(const Key('demo-loading-indicator')), findsOneWidget);

    completer.complete(DemoState.initial());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('role-select-child-button')), findsOneWidget);
  });

  testWidgets('shows an error state and retries loading', (
    WidgetTester tester,
  ) async {
    var attempts = 0;
    final repository = _FakeWidgetDemoRepository(
      loadStateHandler: () async {
        attempts += 1;
        if (attempts == 1) {
          throw StateError('load failed');
        }
        return DemoState.initial();
      },
    );

    await tester.pumpWidget(TtokttokAllowanceApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('demo-error-state')), findsOneWidget);

    await tester.tap(find.byKey(const Key('demo-retry-button')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.byKey(const Key('role-select-child-button')), findsOneWidget);
  });
}

class _FakeWidgetDemoRepository implements DemoRepository {
  _FakeWidgetDemoRepository({
    this.loadStateHandler,
    this.selectRoleHandler,
    this.resetDemoHandler,
  });

  final Future<DemoState> Function()? loadStateHandler;
  final Future<DemoState> Function(UserRole role)? selectRoleHandler;
  final Future<DemoState> Function()? resetDemoHandler;

  @override
  Future<DemoState> loadState() => loadStateHandler != null
      ? loadStateHandler!()
      : Future.value(DemoState.initial());

  @override
  Future<DemoState> selectRole(UserRole role) => selectRoleHandler != null
      ? selectRoleHandler!(role)
      : Future.value(DemoState.initial().copyWith(selectedRole: role));

  @override
  Future<DemoState> resetDemo() => resetDemoHandler != null
      ? resetDemoHandler!()
      : Future.value(DemoState.initial());

  @override
  Future<DemoState> saveMission({
    required String title,
    required String description,
    required int rewardPoints,
    required int targetPoints,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DemoState> completeMission({required String responseSummary}) {
    throw UnimplementedError();
  }

  @override
  Future<DemoState> saveReport(AiReport report) {
    throw UnimplementedError();
  }
}
