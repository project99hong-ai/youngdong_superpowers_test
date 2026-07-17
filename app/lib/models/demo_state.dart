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

  factory MissionCompletion.fromJson(Map<String, dynamic> json) =>
      MissionCompletion(
        id: json['id'] as String,
        missionId: json['missionId'] as String,
        isCompleted: json['isCompleted'] as bool,
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
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
        allowanceStatus:
            AllowanceStatus.values.byName(json['allowanceStatus'] as String),
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
        selectedRole:
            UserRole.values.byName(json['selectedRole'] as String),
        mission: Mission.fromJson(json['mission'] as Map<String, dynamic>),
        completion: MissionCompletion.fromJson(
          json['completion'] as Map<String, dynamic>,
        ),
        reward: RewardStatus.fromJson(json['reward'] as Map<String, dynamic>),
        aiReport: json['aiReport'] == null
            ? null
            : AiReport.fromJson(json['aiReport'] as Map<String, dynamic>),
      );
}
