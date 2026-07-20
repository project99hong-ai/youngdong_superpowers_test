# Ttokttok Allowance Hybrid Web Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first `똑똑용돈` MVP as a Flutter cross-platform app that runs in Chrome for the first demo and shows the vertical flow: role selection, parent mission catalog multi-select, senior mission completion, point increase, family dashboard, and AI/fallback report.

**Architecture:** Create a Flutter app under `app/` and keep UI, repository, storage, and AI services separated. The first MVP stores demo state in browser/app-local storage, but models and repository methods are shaped so a later Firestore repository can replace the local implementation. A built-in mission catalog is multi-selected without a count limit, converted into assigned missions for the senior, and tracked with per-mission completions. AI report generation uses an `AiReportService` boundary with fallback behavior when the proxy call is unavailable or fails.

**Tech Stack:** Flutter, Dart, Flutter Web/Chrome, `shared_preferences`, `http`, `flutter_test`, local storage through repository/service boundaries, direct AI API key injection through `--dart-define`.

## 최신 제품 결정: 미션 카탈로그와 제한 없는 다중 선택

이 결정은 이 계획에 남아 있는 기존 단일 미션 입력 폼 예시보다 우선합니다. 자녀는 새로운 미션을 직접 만들거나 제목·설명을 입력하지 않습니다. 앱에 기본 등록된 미션 카탈로그에서 부모님에게 보여줄 미션을 원하는 만큼 선택하고, `부모님에게 적용하기`로 저장합니다.

구현에서는 다음 개념을 사용합니다.

- `MissionTemplate`: 제목, 유형, 설명, 예상 소요 시간을 가진 기본 미션 정의
- `AssignedMission`: 특정 부모님에게 노출하기로 선택된 미션과 미션별 보상 포인트
- `MissionCompletion`: `assignedMissionId`를 기준으로 한 개별 수행 기록
- `RewardPolicy`: 선택된 미션 묶음의 주간 목표 포인트와 용돈 보상 조건
- `DemoState.missionCatalog`, `DemoState.assignedMissions`, `DemoState.completions`는 단일 값이 아닌 컬렉션
- `saveMission()`은 `applySelectedMissions()`로 교체하고, 이후 화면 작업 전에 단일 미션 모델·테스트·UI 예시를 다중 선택 구조로 재작성

The task snippets below were written for the earlier single-mission draft. They are not executable until Tasks 2, 3, and 6 are rewritten around the collection model above; do not copy the old single-mission fields or input form into production code.

## Global Constraints

- Use Flutter cross-platform app structure first; Chrome / Flutter Web is only the first demo surface.
- Put the Flutter project under `app/`.
- Do not use LazyCodex/OmO skills, harnesses, or project structures in this folder.
- Use superpowers workflow for planning and execution.
- `.env`, `.env.local` must not be read, modified, printed, or summarized.
- Do not hardcode API keys.
- Do not store API keys in Git, local storage, client config, or generated source files.
- Direct AI calls in Flutter Web are local-demo only because browser exposure risk remains.
- Add fallback AI report behavior for missing key, API failure, network failure, and timeout.
- Do not implement real payments, real remittance, medical data processing, diagnosis, dementia certainty, risk certainty, or prescription-like language.
- AI input must use activity summary data, not direct identifiers such as names or phone numbers.
- Keep models and repository boundaries easy to move to Firestore later.

---

## Planned File Structure

### Create

- `app/pubspec.yaml`: Flutter dependencies and app metadata.
- `app/lib/main.dart`: app bootstrap.
- `app/lib/app.dart`: Material app, theme, repository/service construction.
- `app/lib/models/demo_state.dart`: immutable demo state and nested value models.
- `app/lib/models/ai_report.dart`: AI report model and source enum.
- `app/lib/services/demo_storage_service.dart`: JSON persistence over `SharedPreferences`.
- `app/lib/services/ai_report_service.dart`: AI service interface, direct service, fallback service, secure config.
- `app/lib/repositories/demo_repository.dart`: repository interface and local implementation.
- `app/lib/screens/role_select_screen.dart`: role entry screen.
- `app/lib/screens/child_setup_screen.dart`: child mission setup screen.
- `app/lib/screens/senior_home_screen.dart`: senior overview screen.
- `app/lib/screens/mission_screen.dart`: mission completion screen.
- `app/lib/screens/family_dashboard_screen.dart`: family dashboard and report screen.
- `app/lib/widgets/app_shell.dart`: shared page scaffold.
- `app/lib/widgets/stat_card.dart`: compact metric card.
- `app/test/models/demo_state_test.dart`: model serialization/default tests.
- `app/test/services/fallback_ai_report_service_test.dart`: fallback report behavior.
- `app/test/repositories/local_demo_repository_test.dart`: repository state transitions.
- `app/test/widget_flow_test.dart`: core screen flow smoke test.

### Modify

- `HANDOFF.md`: append the chosen implementation plan path and execution status after implementation begins.

### Do Not Create

- `.env`
- `.env.local`
- any file containing a real API key

---

### Task 1: Scaffold Flutter App And Dependencies

**Files:**
- Create: `app/`
- Create: `app/pubspec.yaml`
- Create: generated Flutter platform files from `flutter create`
- Modify: `app/pubspec.yaml`

**Interfaces:**
- Produces: a Flutter project that can run `flutter test`, `flutter analyze`, and `flutter run -d chrome`.
- Produces dependencies: `shared_preferences: ^2.3.0`, `http: ^1.2.0`.

- [ ] **Step 1: Verify Flutter is available**

Run:

```bash
flutter --version
```

Expected: prints a Flutter version and exits 0. If the command is missing, stop and install Flutter before continuing.

- [ ] **Step 2: Scaffold the Flutter app**

Run from repository root:

```bash
flutter create --project-name ttokttok_allowance_mvp --platforms=web,android,ios app
```

Expected: creates `app/` with Flutter source and platform folders.

- [ ] **Step 3: Add dependencies**

Run:

```bash
cd app
flutter pub add shared_preferences http
```

Expected: `pubspec.yaml` and `pubspec.lock` include `shared_preferences` and `http`. The generated project already includes Flutter test support through the Flutter SDK.

- [ ] **Step 4: Replace the generated counter app**

Replace `app/lib/main.dart` with:

```dart
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TtokttokAllowanceApp());
}
```

Create `app/lib/app.dart` with a temporary shell that compiles:

```dart
import 'package:flutter/material.dart';

class TtokttokAllowanceApp extends StatelessWidget {
  const TtokttokAllowanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '똑똑용돈',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F73)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('똑똑용돈 MVP')),
      ),
    );
  }
}
```

- [ ] **Step 5: Run checks**

Run:

```bash
cd app
flutter analyze
flutter test
```

Expected: both commands exit 0.

- [ ] **Step 6: Commit**

Run:

```bash
git add app
git commit -m "feat: scaffold Flutter web MVP app"
```

Expected: commit succeeds.

---

### Task 2: Add Demo Models And Serialization

**Files:**
- Create: `app/lib/models/ai_report.dart`
- Create: `app/lib/models/demo_state.dart`
- Create: `app/test/models/demo_state_test.dart`

**Interfaces:**
- Produces: `enum UserRole { child, senior }`
- Produces: `enum AllowanceStatus { pending, ready, sentDemo }`
- Produces: `enum AiReportSource { direct, fallback }`
- Produces: `class DemoState` with `DemoState.initial()`, `copyWith`, `toJson()`, and `DemoState.fromJson(Map<String, dynamic>)`.
- Produces: `class Mission`, `class MissionCompletion`, `class RewardStatus`, `class AiReport`.

- [ ] **Step 1: Write model tests**

Create `app/test/models/demo_state_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd app
flutter test test/models/demo_state_test.dart
```

Expected: FAIL because model files do not exist.

- [ ] **Step 3: Implement `AiReport`**

Create `app/lib/models/ai_report.dart`:

```dart
enum AiReportSource { direct, fallback }

class AiReport {
  const AiReport({
    required this.id,
    required this.summary,
    required this.changePoints,
    required this.recommendations,
    required this.generatedAt,
    required this.source,
  });

  final String id;
  final String summary;
  final List<String> changePoints;
  final List<String> recommendations;
  final DateTime generatedAt;
  final AiReportSource source;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'changePoints': changePoints,
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
      'source': source.name,
    };
  }

  factory AiReport.fromJson(Map<String, dynamic> json) {
    return AiReport(
      id: json['id'] as String,
      summary: json['summary'] as String,
      changePoints: List<String>.from(json['changePoints'] as List<dynamic>),
      recommendations: List<String>.from(json['recommendations'] as List<dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      source: AiReportSource.values.byName(json['source'] as String),
    );
  }
}
```

- [ ] **Step 4: Implement `DemoState`**

Create `app/lib/models/demo_state.dart` with focused value objects. Use no generated code.

```dart
import 'ai_report.dart';

enum UserRole { child, senior }

enum AllowanceStatus { pending, ready, sentDemo }

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoints,
    required this.targetPoints,
  });

  final String id;
  final String title;
  final String description;
  final int rewardPoints;
  final int targetPoints;

  Mission copyWith({
    String? title,
    String? description,
    int? rewardPoints,
    int? targetPoints,
  }) {
    return Mission(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      targetPoints: targetPoints ?? this.targetPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'rewardPoints': rewardPoints,
        'targetPoints': targetPoints,
      };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        rewardPoints: json['rewardPoints'] as int,
        targetPoints: json['targetPoints'] as int,
      );
}

class MissionCompletion {
  const MissionCompletion({
    required this.id,
    required this.missionId,
    required this.isCompleted,
    required this.completedAt,
    required this.responseSummary,
  });

  final String id;
  final String missionId;
  final bool isCompleted;
  final DateTime? completedAt;
  final String responseSummary;

  MissionCompletion copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    String? responseSummary,
  }) {
    return MissionCompletion(
      id: id,
      missionId: missionId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      responseSummary: responseSummary ?? this.responseSummary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'missionId': missionId,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'responseSummary': responseSummary,
      };

  factory MissionCompletion.fromJson(Map<String, dynamic> json) => MissionCompletion(
        id: json['id'] as String,
        missionId: json['missionId'] as String,
        isCompleted: json['isCompleted'] as bool,
        completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
        responseSummary: json['responseSummary'] as String,
      );
}

class RewardStatus {
  const RewardStatus({
    required this.currentPoints,
    required this.targetPoints,
    required this.allowanceStatus,
  });

  final int currentPoints;
  final int targetPoints;
  final AllowanceStatus allowanceStatus;

  RewardStatus copyWith({
    int? currentPoints,
    int? targetPoints,
    AllowanceStatus? allowanceStatus,
  }) {
    return RewardStatus(
      currentPoints: currentPoints ?? this.currentPoints,
      targetPoints: targetPoints ?? this.targetPoints,
      allowanceStatus: allowanceStatus ?? this.allowanceStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentPoints': currentPoints,
        'targetPoints': targetPoints,
        'allowanceStatus': allowanceStatus.name,
      };

  factory RewardStatus.fromJson(Map<String, dynamic> json) => RewardStatus(
        currentPoints: json['currentPoints'] as int,
        targetPoints: json['targetPoints'] as int,
        allowanceStatus: AllowanceStatus.values.byName(json['allowanceStatus'] as String),
      );
}

class DemoState {
  const DemoState({
    required this.selectedRole,
    required this.mission,
    required this.completion,
    required this.reward,
    required this.aiReport,
  });

  final UserRole selectedRole;
  final Mission mission;
  final MissionCompletion completion;
  final RewardStatus reward;
  final AiReport? aiReport;

  factory DemoState.initial() {
    const mission = Mission(
      id: 'mission-memory-quiz',
      title: '기억 퀴즈 미션',
      description: '오늘 기억나는 아침 메뉴를 떠올리고 간단한 퀴즈를 완료해요.',
      rewardPoints: 100,
      targetPoints: 300,
    );
    return DemoState(
      selectedRole: UserRole.child,
      mission: mission,
      completion: const MissionCompletion(
        id: 'completion-memory-quiz',
        missionId: 'mission-memory-quiz',
        isCompleted: false,
        completedAt: null,
        responseSummary: '',
      ),
      reward: const RewardStatus(
        currentPoints: 0,
        targetPoints: 300,
        allowanceStatus: AllowanceStatus.pending,
      ),
      aiReport: null,
    );
  }

  DemoState copyWith({
    UserRole? selectedRole,
    Mission? mission,
    MissionCompletion? completion,
    RewardStatus? reward,
    AiReport? aiReport,
    bool clearAiReport = false,
  }) {
    return DemoState(
      selectedRole: selectedRole ?? this.selectedRole,
      mission: mission ?? this.mission,
      completion: completion ?? this.completion,
      reward: reward ?? this.reward,
      aiReport: clearAiReport ? null : aiReport ?? this.aiReport,
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedRole': selectedRole.name,
        'mission': mission.toJson(),
        'completion': completion.toJson(),
        'reward': reward.toJson(),
        'aiReport': aiReport?.toJson(),
      };

  factory DemoState.fromJson(Map<String, dynamic> json) => DemoState(
        selectedRole: UserRole.values.byName(json['selectedRole'] as String),
        mission: Mission.fromJson(json['mission'] as Map<String, dynamic>),
        completion: MissionCompletion.fromJson(json['completion'] as Map<String, dynamic>),
        reward: RewardStatus.fromJson(json['reward'] as Map<String, dynamic>),
        aiReport: json['aiReport'] == null ? null : AiReport.fromJson(json['aiReport'] as Map<String, dynamic>),
      );
}
```

- [ ] **Step 5: Run tests**

Run:

```bash
cd app
flutter test test/models/demo_state_test.dart
flutter analyze
```

Expected: both commands exit 0.

- [ ] **Step 6: Commit**

Run:

```bash
git add app/lib/models app/test/models
git commit -m "feat: add demo state models"
```

Expected: commit succeeds.

---

### Task 3: Add Local Storage And Repository State Transitions

**Files:**
- Create: `app/lib/services/demo_storage_service.dart`
- Create: `app/lib/repositories/demo_repository.dart`
- Create: `app/test/repositories/local_demo_repository_test.dart`

**Interfaces:**
- Consumes: `DemoState`, `Mission`, `RewardStatus`, `AiReport`.
- Produces: `abstract class DemoRepository`.
- Produces: `class LocalDemoRepository implements DemoRepository`.
- Produces methods: `Future<DemoState> loadState()`, `Future<DemoState> selectRole(UserRole role)`, `Future<DemoState> saveMission({required String title, required String description, required int rewardPoints, required int targetPoints})`, `Future<DemoState> completeMission({required String responseSummary})`, `Future<DemoState> saveReport(AiReport report)`, `Future<DemoState> resetDemo()`.

- [ ] **Step 1: Write repository tests**

Create `app/test/repositories/local_demo_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttokttok_allowance_mvp/models/demo_state.dart';
import 'package:ttokttok_allowance_mvp/repositories/demo_repository.dart';
import 'package:ttokttok_allowance_mvp/services/demo_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveMission updates mission and reward target', () async {
    final repository = LocalDemoRepository(DemoStorageService());

    final state = await repository.saveMission(
      title: '산책 체크인',
      description: '집 앞을 10분 걷고 기분을 체크해요.',
      rewardPoints: 80,
      targetPoints: 240,
    );

    expect(state.mission.title, '산책 체크인');
    expect(state.mission.rewardPoints, 80);
    expect(state.reward.targetPoints, 240);
    expect(state.reward.currentPoints, 0);
    expect(state.completion.isCompleted, isFalse);
  });

  test('completeMission adds points once and marks reward ready at target', () async {
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
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd app
flutter test test/repositories/local_demo_repository_test.dart
```

Expected: FAIL because repository and storage files do not exist.

- [ ] **Step 3: Implement storage service**

Create `app/lib/services/demo_storage_service.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/demo_state.dart';

class DemoStorageService {
  static const String _stateKey = 'ttokttok_demo_state_v1';

  Future<DemoState> loadState() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_stateKey);
    if (raw == null || raw.isEmpty) {
      return DemoState.initial();
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return DemoState.fromJson(decoded);
  }

  Future<void> saveState(DemoState state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_stateKey, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_stateKey);
  }
}
```

- [ ] **Step 4: Implement repository**

Create `app/lib/repositories/demo_repository.dart`:

```dart
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
    final status = nextPoints >= current.reward.targetPoints ? AllowanceStatus.ready : AllowanceStatus.pending;
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
```

- [ ] **Step 5: Run tests**

Run:

```bash
cd app
flutter test test/repositories/local_demo_repository_test.dart
flutter test
flutter analyze
```

Expected: all commands exit 0.

- [ ] **Step 6: Commit**

Run:

```bash
git add app/lib/services/demo_storage_service.dart app/lib/repositories/demo_repository.dart app/test/repositories/local_demo_repository_test.dart
git commit -m "feat: add local demo repository"
```

Expected: commit succeeds.

---

### Task 4: Add AI Direct And Fallback Report Services

**Files:**
- Create/Modify: `app/lib/services/ai_report_service.dart`
- Create: `app/test/services/fallback_ai_report_service_test.dart`

**Interfaces:**
- Consumes: `DemoState`, `AiReport`.
- Produces: `abstract class AiReportService`.
- Produces: `class FallbackAiReportService implements AiReportService`.
- Produces: `class DirectAiReportService implements AiReportService`.
- Produces: `class ResilientAiReportService implements AiReportService`.
- Produces: `class AiRuntimeConfig` with `fromEnvironment()`.

- [ ] **Step 1: Write fallback service tests**

Create `app/test/services/fallback_ai_report_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ttokttok_allowance_mvp/models/ai_report.dart';
import 'package:ttokttok_allowance_mvp/models/demo_state.dart';
import 'package:ttokttok_allowance_mvp/services/ai_report_service.dart';

void main() {
  test('fallback report summarizes completed mission without medical claims', () async {
    final service = FallbackAiReportService();
    final completedState = DemoState.initial().copyWith(
      completion: DemoState.initial().completion.copyWith(
            isCompleted: true,
            completedAt: DateTime.utc(2026, 7, 17),
            responseSummary: '기억 퀴즈를 완료했습니다.',
          ),
      reward: DemoState.initial().reward.copyWith(currentPoints: 100),
    );

    final report = await service.generateReport(completedState);

    expect(report.source, AiReportSource.fallback);
    expect(report.summary, contains('100포인트'));
    expect(report.summary.contains('진단'), isFalse);
    expect(report.summary.contains('치매 확정'), isFalse);
    expect(report.changePoints, isNotEmpty);
    expect(report.recommendations, isNotEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
cd app
flutter test test/services/fallback_ai_report_service_test.dart
```

Expected: FAIL because `ai_report_service.dart` is not implemented.

- [ ] **Step 3: Implement AI services**

Create `app/lib/services/ai_report_service.dart`:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_report.dart';
import '../models/demo_state.dart';

abstract class AiReportService {
  Future<AiReport> generateReport(DemoState state);
}

class AiRuntimeConfig {
  const AiRuntimeConfig({
    required this.apiKey,
    required this.model,
    required this.endpoint,
  });

  final String apiKey;
  final String model;
  final Uri endpoint;

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  factory AiRuntimeConfig.fromEnvironment() {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    const model = String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
    const endpoint = String.fromEnvironment('OPENAI_CHAT_ENDPOINT', defaultValue: 'https://api.openai.com/v1/chat/completions');
    return AiRuntimeConfig(
      apiKey: apiKey,
      model: model,
      endpoint: Uri.parse(endpoint),
    );
  }
}

class FallbackAiReportService implements AiReportService {
  @override
  Future<AiReport> generateReport(DemoState state) async {
    final completedText = state.completion.isCompleted ? '미션을 완료했고 ${state.reward.currentPoints}포인트를 획득했습니다.' : '아직 오늘의 미션을 완료하지 않았습니다.';
    return AiReport(
      id: 'fallback-${DateTime.now().toUtc().millisecondsSinceEpoch}',
      summary: '이번 주는 $completedText 활동 패턴을 더 잘 이어가기 위해 짧고 부담 없는 미션을 추천합니다.',
      changePoints: [
        state.completion.isCompleted ? '오늘 참여 데이터가 새로 기록되었습니다.' : '오늘 참여 데이터는 아직 없습니다.',
        '현재 포인트는 ${state.reward.currentPoints}/${state.reward.targetPoints}점입니다.',
      ],
      recommendations: const [
        '다음 미션은 1분 체크인처럼 짧게 시작하는 흐름을 추천합니다.',
        '가족이 이번 주 한 번 안부를 확인하면 좋겠습니다.',
      ],
      generatedAt: DateTime.now().toUtc(),
      source: AiReportSource.fallback,
    );
  }
}

class DirectAiReportService implements AiReportService {
  DirectAiReportService({
    required AiRuntimeConfig config,
    http.Client? client,
  })  : _config = config,
        _client = client ?? http.Client();

  final AiRuntimeConfig _config;
  final http.Client _client;

  @override
  Future<AiReport> generateReport(DemoState state) async {
    if (!_config.hasApiKey) {
      throw StateError('Missing OPENAI_API_KEY runtime configuration.');
    }
    final response = await _client
        .post(
          _config.endpoint,
          headers: {
            'Authorization': 'Bearer ${_config.apiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(_requestBody(state)),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('AI request failed with status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>;
    final message = choices.first as Map<String, dynamic>;
    final content = ((message['message'] as Map<String, dynamic>)['content'] as String).trim();
    final reportJson = jsonDecode(content) as Map<String, dynamic>;

    return AiReport(
      id: 'direct-${DateTime.now().toUtc().millisecondsSinceEpoch}',
      summary: reportJson['summary'] as String,
      changePoints: List<String>.from(reportJson['changePoints'] as List<dynamic>),
      recommendations: List<String>.from(reportJson['recommendations'] as List<dynamic>),
      generatedAt: DateTime.now().toUtc(),
      source: AiReportSource.direct,
    );
  }

  Map<String, dynamic> _requestBody(DemoState state) {
    return {
      'model': _config.model,
      'messages': [
        {
          'role': 'system',
          'content': 'You write Korean family care activity summaries. Do not diagnose disease, claim dementia risk certainty, or provide prescription-like medical advice. Return only JSON.',
        },
        {
          'role': 'user',
          'content': jsonEncode({
            'missionTitle': state.mission.title,
            'missionCompleted': state.completion.isCompleted,
            'responseSummary': state.completion.responseSummary,
            'currentPoints': state.reward.currentPoints,
            'targetPoints': state.reward.targetPoints,
          }),
        },
      ],
      'response_format': {
        'type': 'json_schema',
        'json_schema': {
          'name': 'family_activity_report',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'properties': {
              'summary': {'type': 'string'},
              'changePoints': {
                'type': 'array',
                'items': {'type': 'string'},
              },
              'recommendations': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
            'required': ['summary', 'changePoints', 'recommendations'],
          },
        },
      },
    };
  }
}

class ResilientAiReportService implements AiReportService {
  const ResilientAiReportService({
    required this.direct,
    required this.fallback,
  });

  final AiReportService direct;
  final AiReportService fallback;

  @override
  Future<AiReport> generateReport(DemoState state) async {
    try {
      return await direct.generateReport(state);
    } on Object {
      return fallback.generateReport(state);
    }
  }
}
```

- [ ] **Step 4: Run tests and analyze**

Run:

```bash
cd app
flutter test test/services/fallback_ai_report_service_test.dart
flutter test
flutter analyze
```

Expected: all commands exit 0.

- [ ] **Step 5: Manually confirm no key is stored**

Run:

```bash
git grep -n "sk-" -- app || true
git grep -n "OPENAI_API_KEY=" -- app || true
```

Expected: no output.

- [ ] **Step 6: Commit**

Run:

```bash
git add app/lib/services/ai_report_service.dart app/test/services/fallback_ai_report_service_test.dart
git commit -m "feat: add AI report services"
```

Expected: commit succeeds.

---

### Task 5: Build Shared UI Shell And Role Flow

**Files:**
- Modify: `app/lib/app.dart`
- Create: `app/lib/widgets/app_shell.dart`
- Create: `app/lib/widgets/stat_card.dart`
- Create: `app/lib/screens/role_select_screen.dart`

**Interfaces:**
- Consumes: `DemoRepository`, `LocalDemoRepository`, `DemoStorageService`, `AiReportService`.
- Produces: `class AppShell extends StatelessWidget`.
- Produces: `class StatCard extends StatelessWidget`.
- Produces: `class RoleSelectScreen extends StatefulWidget`.

- [ ] **Step 1: Implement shared widgets**

Create `app/lib/widgets/app_shell.dart`:

```dart
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [child],
        ),
      ),
    );
  }
}
```

Create `app/lib/widgets/stat_card.dart`:

```dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Implement role select screen**

Create `app/lib/screens/role_select_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/demo_state.dart';
import '../repositories/demo_repository.dart';
import 'child_setup_screen.dart';
import 'senior_home_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key, required this.repository});

  final DemoRepository repository;

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  bool _loading = false;

  Future<void> _start(UserRole role) async {
    setState(() => _loading = true);
    await widget.repository.selectRole(role);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    final screen = role == UserRole.child
        ? ChildSetupScreen(repository: widget.repository)
        : SeniorHomeScreen(repository: widget.repository);
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('똑똑용돈', style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('용돈이 미션이 되고, 가족 리포트로 이어지는 데모입니다.', textAlign: TextAlign.center),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: _loading ? null : () => _start(UserRole.child),
                child: const Text('자녀로 시작'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loading ? null : () => _start(UserRole.senior),
                child: const Text('시니어로 시작'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Wire app dependencies**

Modify `app/lib/app.dart`:

```dart
import 'package:flutter/material.dart';

import 'repositories/demo_repository.dart';
import 'screens/role_select_screen.dart';
import 'services/demo_storage_service.dart';

class TtokttokAllowanceApp extends StatelessWidget {
  const TtokttokAllowanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = LocalDemoRepository(DemoStorageService());
    return MaterialApp(
      title: '똑똑용돈',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F73)),
        useMaterial3: true,
      ),
      home: RoleSelectScreen(repository: repository),
    );
  }
}
```

- [ ] **Step 4: Run checks**

Run:

```bash
cd app
flutter analyze
flutter test
```

Expected: the analyzer may fail because referenced screens from later tasks do not exist. If it fails only for `child_setup_screen.dart` and `senior_home_screen.dart`, continue to Task 6 before committing this task. If it fails for other reasons, fix this task before continuing.

- [ ] **Step 5: Commit after Task 6 screens exist**

Commit this task together with Task 6 if analyzer cannot pass until all referenced screens exist.

---

### Task 6: Implement Child Setup, Senior Home, And Mission Completion

**Files:**
- Create: `app/lib/screens/child_setup_screen.dart`
- Create: `app/lib/screens/senior_home_screen.dart`
- Create: `app/lib/screens/mission_screen.dart`

**Interfaces:**
- Consumes: `DemoRepository`.
- Produces: screens that complete the flow from child setup to senior mission completion.

- [ ] **Step 1: Implement child setup screen**

Create `app/lib/screens/child_setup_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../repositories/demo_repository.dart';
import '../widgets/app_shell.dart';
import 'family_dashboard_screen.dart';
import 'senior_home_screen.dart';

class ChildSetupScreen extends StatefulWidget {
  const ChildSetupScreen({super.key, required this.repository});

  final DemoRepository repository;

  @override
  State<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends State<ChildSetupScreen> {
  final _title = TextEditingController(text: '기억 퀴즈 미션');
  final _description = TextEditingController(text: '오늘 기억나는 아침 메뉴를 떠올리고 간단한 퀴즈를 완료해요.');
  final _rewardPoints = TextEditingController(text: '100');
  final _targetPoints = TextEditingController(text: '300');
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _rewardPoints.dispose();
    _targetPoints.dispose();
    super.dispose();
  }

  Future<void> _saveAndOpenSenior() async {
    setState(() => _saving = true);
    await widget.repository.saveMission(
      title: _title.text,
      description: _description.text,
      rewardPoints: int.tryParse(_rewardPoints.text) ?? 100,
      targetPoints: int.tryParse(_targetPoints.text) ?? 300,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SeniorHomeScreen(repository: widget.repository),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '자녀 미션 설정',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => FamilyDashboardScreen(repository: widget.repository),
          )),
          child: const Text('대시보드'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: '미션 제목')),
          const SizedBox(height: 12),
          TextField(controller: _description, decoration: const InputDecoration(labelText: '미션 설명'), maxLines: 3),
          const SizedBox(height: 12),
          TextField(controller: _rewardPoints, decoration: const InputDecoration(labelText: '완료 보상 포인트'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _targetPoints, decoration: const InputDecoration(labelText: '이번 주 목표 포인트'), keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _saveAndOpenSenior,
            child: const Text('저장하고 시니어 화면 보기'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Implement senior home screen**

Create `app/lib/screens/senior_home_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/demo_state.dart';
import '../repositories/demo_repository.dart';
import '../widgets/app_shell.dart';
import '../widgets/stat_card.dart';
import 'family_dashboard_screen.dart';
import 'mission_screen.dart';

class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key, required this.repository});

  final DemoRepository repository;

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  late Future<DemoState> _state;

  @override
  void initState() {
    super.initState();
    _state = widget.repository.loadState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DemoState>(
      future: _state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? DemoState.initial();
        return AppShell(
          title: '시니어 홈',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('오늘의 미션', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.mission.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(state.mission.description),
                    ],
                  ),
                ),
              ),
              StatCard(label: '현재 포인트', value: '${state.reward.currentPoints}점', icon: Icons.stars),
              StatCard(label: '이번 주 목표', value: '${state.reward.targetPoints}점', icon: Icons.flag),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.completion.isCompleted
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => MissionScreen(repository: widget.repository),
                        )),
                child: Text(state.completion.isCompleted ? '오늘 미션 완료' : '미션 시작'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => FamilyDashboardScreen(repository: widget.repository),
                )),
                child: const Text('가족 대시보드 보기'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Implement mission screen**

Create `app/lib/screens/mission_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../repositories/demo_repository.dart';
import '../widgets/app_shell.dart';
import 'family_dashboard_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key, required this.repository});

  final DemoRepository repository;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool _saving = false;

  Future<void> _complete() async {
    setState(() => _saving = true);
    await widget.repository.completeMission(responseSummary: '기억 퀴즈를 완료했습니다.');
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => FamilyDashboardScreen(repository: widget.repository),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '기억 퀴즈',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('오늘 아침에 드신 음식이나 마신 음료를 떠올려보세요.', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('질문: 오늘 아침 식사 후 기분은 어땠나요?'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _complete,
            child: const Text('미션 완료하고 포인트 받기'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run checks**

Run:

```bash
cd app
flutter analyze
flutter test
```

Expected: analyzer may fail only because `family_dashboard_screen.dart` is not created yet. If so, continue to Task 7 before committing. If it fails for other reasons, fix before continuing.

- [ ] **Step 5: Commit after Task 7 screen exists**

Commit Task 5, Task 6, and Task 7 UI files together if analyzer cannot pass until all screens exist.

---

### Task 7: Implement Family Dashboard And AI Report Generation

**Files:**
- Create: `app/lib/screens/family_dashboard_screen.dart`
- Modify: `app/lib/app.dart`
- Create: `app/test/widget_flow_test.dart`

**Interfaces:**
- Consumes: `DemoRepository`, `AiReportService`, `DirectAiReportService`, `FallbackAiReportService`, `ResilientAiReportService`, `AiRuntimeConfig`.
- Produces: dashboard screen that loads state, generates AI report, saves report, and displays source.

- [ ] **Step 1: Modify app dependency wiring for AI service**

Modify `app/lib/app.dart`:

```dart
import 'package:flutter/material.dart';

import 'repositories/demo_repository.dart';
import 'screens/role_select_screen.dart';
import 'services/ai_report_service.dart';
import 'services/demo_storage_service.dart';

class TtokttokAllowanceApp extends StatelessWidget {
  const TtokttokAllowanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = LocalDemoRepository(DemoStorageService());
    final aiService = ResilientAiReportService(
      direct: DirectAiReportService(config: AiRuntimeConfig.fromEnvironment()),
      fallback: FallbackAiReportService(),
    );
    return MaterialApp(
      title: '똑똑용돈',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F73)),
        useMaterial3: true,
      ),
      home: RoleSelectScreen(repository: repository, aiReportService: aiService),
    );
  }
}
```

Update screen constructors that navigate to `FamilyDashboardScreen` so they pass `aiReportService`.

- [ ] **Step 2: Update role select constructor**

Modify `app/lib/screens/role_select_screen.dart` so the class accepts and passes AI service:

```dart
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({
    super.key,
    required this.repository,
    required this.aiReportService,
  });

  final DemoRepository repository;
  final AiReportService aiReportService;
}
```

When creating `ChildSetupScreen`, `SeniorHomeScreen`, and later dashboard screens, pass `aiReportService: widget.aiReportService`.

- [ ] **Step 3: Update existing screen constructors**

Add `required AiReportService aiReportService` to `ChildSetupScreen`, `SeniorHomeScreen`, and `MissionScreen`. Store it in a `final AiReportService aiReportService;` field and pass it along on navigation. Import:

```dart
import '../services/ai_report_service.dart';
```

- [ ] **Step 4: Implement family dashboard screen**

Create `app/lib/screens/family_dashboard_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/ai_report.dart';
import '../models/demo_state.dart';
import '../repositories/demo_repository.dart';
import '../services/ai_report_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/stat_card.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({
    super.key,
    required this.repository,
    required this.aiReportService,
  });

  final DemoRepository repository;
  final AiReportService aiReportService;

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  late Future<DemoState> _state;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _state = widget.repository.loadState();
  }

  Future<void> _generateReport() async {
    setState(() => _generating = true);
    final current = await widget.repository.loadState();
    final report = await widget.aiReportService.generateReport(current);
    final updated = await widget.repository.saveReport(report);
    if (!mounted) {
      return;
    }
    setState(() {
      _state = Future.value(updated);
      _generating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DemoState>(
      future: _state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? DemoState.initial();
        final report = state.aiReport;
        return AppShell(
          title: '가족 대시보드',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('부모님 참여 현황', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              StatCard(label: '미션 상태', value: state.completion.isCompleted ? '완료' : '대기', icon: Icons.check_circle),
              StatCard(label: '포인트', value: '${state.reward.currentPoints}/${state.reward.targetPoints}점', icon: Icons.stars),
              StatCard(label: '보상 상태', value: _statusLabel(state.reward.allowanceStatus.name), icon: Icons.card_giftcard),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _generating ? null : _generateReport,
                child: Text(_generating ? '리포트 생성 중' : 'AI 리포트 생성'),
              ),
              const SizedBox(height: 16),
              if (report != null) _ReportCard(report: report),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'ready' => '용돈 보상 준비',
      'sentDemo' => '데모 송금 완료',
      _ => '진행 중',
    };
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final AiReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('가족용 AI 리포트', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Chip(label: Text(report.source == AiReportSource.direct ? '실제 AI' : '데모 리포트')),
              ],
            ),
            const SizedBox(height: 12),
            Text(report.summary),
            const SizedBox(height: 12),
            Text('변화 포인트', style: Theme.of(context).textTheme.titleMedium),
            for (final item in report.changePoints) Text('- $item'),
            const SizedBox(height: 12),
            Text('추천', style: Theme.of(context).textTheme.titleMedium),
            for (final item in report.recommendations) Text('- $item'),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Write widget flow smoke test**

Create `app/test/widget_flow_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttokttok_allowance_mvp/app.dart';

void main() {
  testWidgets('demo flow reaches dashboard and fallback report', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TtokttokAllowanceApp());
    await tester.tap(find.text('자녀로 시작'));
    await tester.pumpAndSettle();

    expect(find.text('자녀 미션 설정'), findsOneWidget);
    await tester.tap(find.text('저장하고 시니어 화면 보기'));
    await tester.pumpAndSettle();

    expect(find.text('시니어 홈'), findsOneWidget);
    await tester.tap(find.text('미션 시작'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('미션 완료하고 포인트 받기'));
    await tester.pumpAndSettle();

    expect(find.text('가족 대시보드'), findsOneWidget);
    await tester.tap(find.text('AI 리포트 생성'));
    await tester.pumpAndSettle();

    expect(find.text('가족용 AI 리포트'), findsOneWidget);
    expect(find.text('데모 리포트'), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run checks**

Run:

```bash
cd app
flutter test
flutter analyze
```

Expected: both commands exit 0.

- [ ] **Step 7: Commit UI flow**

Run:

```bash
git add app/lib/app.dart app/lib/screens app/lib/widgets app/test/widget_flow_test.dart
git commit -m "feat: add MVP demo flow screens"
```

Expected: commit succeeds.

---

### Task 8: Manual Web Demo Validation And Security Check

**Files:**
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: completed Flutter app.
- Produces: verified Chrome demo and updated handoff notes.

- [ ] **Step 1: Run full automated checks**

Run:

```bash
cd app
flutter test
flutter analyze
```

Expected: both commands exit 0.

- [ ] **Step 2: Check for accidental secrets**

Run:

```bash
git grep -n "sk-" -- . || true
git grep -n "OPENAI_API_KEY=" -- . || true
git status -sb
```

Expected: no secret-looking key output. `git status -sb` shows only intended implementation changes before the final docs commit.

- [ ] **Step 3: Run Chrome demo without API key**

Run:

```bash
cd app
flutter run -d chrome
```

Expected: app opens in Chrome. Complete this manual path:

```text
자녀로 시작 -> 저장하고 시니어 화면 보기 -> 미션 시작 -> 미션 완료하고 포인트 받기 -> AI 리포트 생성
```

Expected visual result:

```text
가족 대시보드 shows mission completed, points increased, and report chip says 데모 리포트.
```

- [ ] **Step 4: Run Chrome demo with runtime API key only when available**

Use a local shell variable or paste the key into the command prompt only for this run. Do not write it to a file.

PowerShell example:

```powershell
cd app
flutter run -d chrome --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY
```

Expected visual result when a valid key is present:

```text
가족 대시보드 shows report chip as 실제 AI.
```

If the browser blocks the direct request or the API returns an error, the app must still show `데모 리포트`.

- [ ] **Step 5: Confirm persistence**

While the app is running:

```text
1. Complete the mission.
2. Generate a report.
3. Refresh Chrome.
4. Navigate back to the dashboard.
```

Expected: mission completion, points, and report remain visible.

- [ ] **Step 6: Update handoff**

Append a short section to `HANDOFF.md`:

```markdown
## 구현 진행 상태

- Flutter app path: `app/`
- First demo surface: Chrome / Flutter Web
- Storage: local persistence through `LocalDemoRepository`
- AI: direct runtime-key service with fallback report
- Validation to rerun:
  - `cd app && flutter test`
  - `cd app && flutter analyze`
  - `cd app && flutter run -d chrome`
```

- [ ] **Step 7: Commit validation notes**

Run:

```bash
git add HANDOFF.md
git commit -m "docs: update MVP implementation handoff"
```

Expected: commit succeeds.

- [ ] **Step 8: Push branch**

Run:

```bash
git push
```

Expected: pushes all implementation commits to `origin/main`.

---

## Implementation Notes

- The planned package name is `ttokttok_allowance_mvp`; keep imports and `app/pubspec.yaml` aligned with that name.
- If direct AI JSON parsing fails because the provider response shape differs, keep the fix inside `DirectAiReportService`; do not let screens parse provider responses.
- Do not add Firebase in this first implementation plan. The Firestore-ready boundary is the repository interface and the model shape.
- Do not add routing packages for the first MVP. `Navigator.push` is enough for this demo flow.
- Do not add state management packages for the first MVP. Repository calls plus local widget state are enough.

## Self-Review Checklist

- Spec coverage: the plan covers Flutter Web app, local persistence, repository boundary, direct AI calling, fallback report, security constraints, manual Chrome validation, and future Firestore/proxy boundaries.
- Placeholder scan: no task contains open-ended marker words or vague failure-handling instructions.
- Type consistency: `DemoRepository`, `AiReportService`, `DemoState`, `AiReport`, and enum names are defined before later tasks consume them.
- Scope check: Firebase, Cloud Functions deployment, payments, medical data, and share cards stay outside this MVP.
