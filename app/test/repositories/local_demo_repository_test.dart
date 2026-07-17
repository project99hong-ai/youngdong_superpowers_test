import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttokttok_allowance_mvp/models/ai_report.dart';
import 'package:ttokttok_allowance_mvp/models/demo_state.dart';
import 'package:ttokttok_allowance_mvp/repositories/demo_repository.dart';
import 'package:ttokttok_allowance_mvp/services/demo_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('빈 저장소는 기본 데모 상태를 반환한다', () async {
    final repository = LocalDemoRepository(DemoStorageService());

    final state = await repository.loadState();

    expect(state.selectedRole, UserRole.child);
    expect(state.mission.title, '기억 퀴즈 미션');
    expect(state.reward.currentPoints, 0);
    expect(state.reward.allowanceStatus, AllowanceStatus.pending);
    expect(state.completion.isCompleted, isFalse);
    expect(state.aiReport, isNull);
  });

  test('저장한 상태는 새 저장소 인스턴스에서도 불러온다', () async {
    final firstRepository = LocalDemoRepository(DemoStorageService());
    await firstRepository.selectRole(UserRole.senior);

    final secondRepository = LocalDemoRepository(DemoStorageService());
    final restored = await secondRepository.loadState();

    expect(restored.selectedRole, UserRole.senior);
  });

  test('미션 저장은 상태를 영속하고 보상 진행을 초기화한다', () async {
    final repository = LocalDemoRepository(DemoStorageService());
    await repository.completeMission(responseSummary: '기억 퀴즈를 완료했습니다.');

    final saved = await repository.saveMission(
      title: '산책 체크인',
      description: '집 앞을 10분 걷고 기분을 체크해요.',
      rewardPoints: 80,
      targetPoints: 240,
    );
    final restored = await LocalDemoRepository(DemoStorageService()).loadState();

    expect(saved.mission.title, '산책 체크인');
    expect(saved.mission.rewardPoints, 80);
    expect(saved.reward.targetPoints, 240);
    expect(saved.reward.currentPoints, 0);
    expect(saved.reward.allowanceStatus, AllowanceStatus.pending);
    expect(saved.completion.isCompleted, isFalse);
    expect(restored.mission.title, '산책 체크인');
    expect(restored.reward.currentPoints, 0);
  });

  test('미션 완료는 포인트를 한 번만 더하고 목표 달성 상태를 갱신한다', () async {
    final repository = LocalDemoRepository(DemoStorageService());
    await repository.saveMission(
      title: '기억 퀴즈',
      description: '오늘의 기억 퀴즈를 풀어요.',
      rewardPoints: 300,
      targetPoints: 300,
    );

    final first = await repository.completeMission(responseSummary: '기억 퀴즈를 완료했습니다.');
    final second = await repository.completeMission(responseSummary: '다시 완료 버튼을 눌렀습니다.');

    expect(first.reward.currentPoints, 300);
    expect(first.reward.allowanceStatus, AllowanceStatus.ready);
    expect(first.completion.isCompleted, isTrue);
    expect(second.reward.currentPoints, 300);
    expect(second.reward.allowanceStatus, AllowanceStatus.ready);
  });

  test('리포트 저장은 생성 없이 전달받은 리포트를 영속한다', () async {
    final repository = LocalDemoRepository(DemoStorageService());
    final report = AiReport(
      id: 'report-walk-1',
      summary: '이번 주 산책 체크인에 참여했습니다.',
      changePoints: const ['미션 참여가 1회 늘었습니다.'],
      recommendations: const ['내일도 짧은 산책 체크인을 추천합니다.'],
      generatedAt: DateTime.utc(2026, 7, 17),
      source: AiReportSource.fallback,
    );

    final saved = await repository.saveReport(report);
    final restored = await LocalDemoRepository(DemoStorageService()).loadState();

    expect(saved.aiReport?.id, report.id);
    expect(saved.aiReport?.summary, report.summary);
    expect(restored.aiReport?.id, report.id);
    expect(restored.aiReport?.source, AiReportSource.fallback);
  });
}
