import 'package:flutter_test/flutter_test.dart';
import 'package:ttokttok_allowance_mvp/models/ai_report.dart';
import 'package:ttokttok_allowance_mvp/models/demo_state.dart';

void main() {
  test('initial state contains default demo mission and zero points', () {
    final state = DemoState.initial();

    expect(state.selectedRole, UserRole.child);
    expect(state.mission.title, '기억 퀴즈 미션');
    expect(state.mission.rewardPoints, 100);
    expect(state.reward.currentPoints, 0);
    expect(state.completion.isCompleted, isFalse);
    expect(state.aiReport, isNull);
  });

  test('state round trips through json', () {
    final report = AiReport(
      id: 'report-1',
      summary: '이번 주는 미션을 1회 완료했습니다.',
      changePoints: const ['포인트가 100점 증가했습니다.'],
      recommendations: const ['짧은 체크인 미션을 추천합니다.'],
      generatedAt: DateTime.utc(2026, 7, 17),
      source: AiReportSource.fallback,
    );
    final state = DemoState.initial().copyWith(aiReport: report);

    final restored = DemoState.fromJson(state.toJson());

    expect(restored.aiReport?.summary, report.summary);
    expect(restored.aiReport?.source, AiReportSource.fallback);
    expect(restored.mission.targetPoints, 300);
  });
}
