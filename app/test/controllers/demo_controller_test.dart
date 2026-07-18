import 'package:flutter_test/flutter_test.dart';
import 'package:ttokttok_allowance_mvp/controllers/demo_controller.dart';
import 'package:ttokttok_allowance_mvp/models/ai_report.dart';
import 'package:ttokttok_allowance_mvp/models/demo_state.dart';
import 'package:ttokttok_allowance_mvp/repositories/demo_repository.dart';

void main() {
  test('load exposes the restored role as ready state', () async {
    final controller = DemoController(
      repository: _FakeDemoRepository(
        loadStateHandler: () async =>
            DemoState.initial().copyWith(selectedRole: UserRole.senior),
      ),
    );

    await controller.load();

    expect(controller.status, DemoStatus.ready);
    expect(controller.selectedRole, UserRole.senior);
    expect(controller.error, isNull);
  });

  test('selectRole persists the chosen role through the repository', () async {
    UserRole? selectedRole;
    final controller = DemoController(
      repository: _FakeDemoRepository(
        loadStateHandler: () async => DemoState.initial(),
        selectRoleHandler: (role) async {
          selectedRole = role;
          return DemoState.initial().copyWith(selectedRole: role);
        },
      ),
    );

    await controller.load();
    await controller.selectRole(UserRole.child);

    expect(selectedRole, UserRole.child);
    expect(controller.status, DemoStatus.ready);
    expect(controller.selectedRole, UserRole.child);
  });

  test('resetRole returns the controller to role selection state', () async {
    final controller = DemoController(
      repository: _FakeDemoRepository(
        loadStateHandler: () async =>
            DemoState.initial().copyWith(selectedRole: UserRole.child),
        resetDemoHandler: () async => DemoState.initial(),
      ),
    );

    await controller.load();
    await controller.resetRole();

    expect(controller.status, DemoStatus.ready);
    expect(controller.selectedRole, isNull);
  });

  test('load exposes error state when the repository throws', () async {
    final controller = DemoController(
      repository: _FakeDemoRepository(
        loadStateHandler: () async => throw StateError('load failed'),
      ),
    );

    await controller.load();

    expect(controller.status, DemoStatus.error);
    expect(controller.error, isA<StateError>());
    expect(controller.selectedRole, isNull);
  });
}

class _FakeDemoRepository implements DemoRepository {
  _FakeDemoRepository({
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
