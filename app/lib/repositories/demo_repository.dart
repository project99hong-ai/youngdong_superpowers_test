import '../models/ai_report.dart';
import '../models/demo_state.dart';
import '../services/demo_storage_service.dart';

abstract class DemoRepository {
  Future<DemoState> loadState();

  Future<DemoState> selectRole(UserRole role);

  Future<DemoState> saveMission({
    required String title,
    required String description,
    required int rewardPoints,
    required int targetPoints,
  });

  Future<DemoState> completeMission({required String responseSummary});

  Future<DemoState> saveReport(AiReport report);

  Future<DemoState> resetDemo();
}

class LocalDemoRepository implements DemoRepository {
  LocalDemoRepository(this._storage);

  final DemoStorageService _storage;

  @override
  Future<DemoState> loadState() => _storage.loadState();

  @override
  Future<DemoState> selectRole(UserRole role) async {
    final current = await loadState();
    final updated = current.copyWith(selectedRole: role);
    await _storage.saveState(updated);
    return updated;
  }

  @override
  Future<DemoState> saveMission({
    required String title,
    required String description,
    required int rewardPoints,
    required int targetPoints,
  }) async {
    final current = await loadState();
    final mission = current.mission.copyWith(
      title: title.trim(),
      description: description.trim(),
      rewardPoints: rewardPoints,
      targetPoints: targetPoints,
    );
    final updated = current.copyWith(
      mission: mission,
      completion: MissionCompletion(
        id: current.completion.id,
        missionId: mission.id,
        isCompleted: false,
        completedAt: null,
        responseSummary: '',
      ),
      reward: RewardStatus(
        currentPoints: 0,
        targetPoints: targetPoints,
        allowanceStatus: AllowanceStatus.pending,
      ),
      clearAiReport: true,
    );
    await _storage.saveState(updated);
    return updated;
  }

  @override
  Future<DemoState> completeMission({required String responseSummary}) async {
    final current = await loadState();
    if (current.completion.isCompleted) {
      return current;
    }

    final nextPoints = current.reward.currentPoints + current.mission.rewardPoints;
    final status = nextPoints >= current.reward.targetPoints
        ? AllowanceStatus.ready
        : AllowanceStatus.pending;
    final updated = current.copyWith(
      completion: current.completion.copyWith(
        isCompleted: true,
        completedAt: DateTime.now().toUtc(),
        responseSummary: responseSummary.trim(),
      ),
      reward: current.reward.copyWith(
        currentPoints: nextPoints,
        allowanceStatus: status,
      ),
      clearAiReport: true,
    );
    await _storage.saveState(updated);
    return updated;
  }

  @override
  Future<DemoState> saveReport(AiReport report) async {
    final current = await loadState();
    final updated = current.copyWith(aiReport: report);
    await _storage.saveState(updated);
    return updated;
  }

  @override
  Future<DemoState> resetDemo() async {
    await _storage.clear();
    final initial = DemoState.initial();
    await _storage.saveState(initial);
    return initial;
  }
}
