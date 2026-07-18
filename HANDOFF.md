# HANDOFF.md

## 0. 최신 구현 인수인계 (2026-07-17)

이 섹션이 아래의 초기 문서 단계 설명보다 우선한다.

### Git 및 작업 위치

- GitHub: `https://github.com/project99hong-ai/youngdong_superpowers_test.git`
- 현재 브랜치: `codex/ttokttok-mvp-ascii`
- 구현 worktree: `C:\tmp\ttokttok-mvp`
- Flutter SDK: `C:\tmp\flutter\bin\flutter.bat` (Flutter 3.44.6, Dart 3.12.2)
- OneDrive의 한글 경로에서는 Flutter 생성/테스트가 멈추는 문제가 있어 ASCII worktree를 사용한다.
- `.env`, `.env.local`은 읽거나 수정하거나 출력하지 않는다.
- 이 폴더에서는 LazyCodex/OmO 스킬, 플러그인, 하네스를 사용하지 않고 Superpowers SDD 방식으로 진행한다.

### 완료된 Task

| Task | 결과 | 커밋 |
| --- | --- | --- |
| 1 | Flutter Web/Android/iOS 스캐폴드와 앱 셸 | `2ca4200`, `c98529a` |
| 2 | `DemoState`, 미션, 완료, 보상, AI report 모델과 JSON 직렬화 | `1bec7b9` |
| 3 | SharedPreferences 저장 서비스와 `DemoRepository`/`LocalDemoRepository` | `f011110` |
| 4 | repository 기반 역할 선택, 역할 영속화, 임시 홈, 역할 초기화 | `d043189` |

Task 4는 원래 구현 계획의 AI 서비스 Task 4보다 사용자의 최신 요청을 우선해 역할 선택 흐름으로 변경됐다. AI API 및 fallback 서비스는 아직 구현하지 않았다.

### 현재 동작

1. 앱 시작 시 `LocalDemoRepository`에서 `DemoState`를 불러온다.
2. role이 없으면 `자녀로 시작`, `시니어로 시작` 화면을 표시한다.
3. 선택한 role을 SharedPreferences에 저장하고 역할별 임시 홈을 표시한다.
4. 브라우저 새로고침 또는 새 repository 인스턴스에서도 role이 유지된다.
5. `역할 다시 선택`으로 데모 상태를 초기화하고 역할 선택으로 돌아간다.
6. 미션 및 AI report 모델은 저장 가능한 상태지만 관련 UI와 AI 호출은 아직 없다.

### 최신 검증

- 관련 역할 흐름 테스트: 12/12 통과
- 전체 `flutter test`: 12/12 통과
- `flutter analyze`: `No issues found`
- 이전의 독립 Task 4 리뷰 승인/무결함 주장은 후속 리뷰에서 발견된 문서 및 RED 프로세스 증거 문제로 대체됐다. 문서 정정과 사후 RED/restore 검증을 반영했으며 Task 4 재리뷰가 대기 중이다.
- Flutter Web 수동 검증: 역할 선택 -> 자녀 홈 -> 새로고침 후 role 유지 -> 역할 초기화 확인
- 로컬 데모 URL: `http://127.0.0.1:7357/` (서버 실행 중일 때만 접근 가능)

### 실행 명령

```powershell
cd C:\tmp\ttokttok-mvp\app
& C:\tmp\flutter\bin\flutter.bat test
& C:\tmp\flutter\bin\flutter.bat analyze
& C:\tmp\flutter\bin\flutter.bat run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```

### 다음 작업 시작점

- 구현 진행 원장: `C:\tmp\ttokttok-mvp\.superpowers\sdd\progress.md`
- 다음 에이전트는 먼저 `AGENTS.md`, 이 섹션, 진행 원장을 읽고 현재 Git 상태를 확인한다.
- 다음 기능도 fresh implementer -> TDD RED -> GREEN -> 전체 검증 -> 독립 리뷰 -> 커밋 순서로 진행한다.
- 다음 우선 후보는 자녀 미션 설정 화면과 repository 연결이다. AI 서비스 Task는 역할/미션 흐름 이후 별도로 재배치해야 한다.

## 1. 현재 상태

- 이 폴더는 `똑똑용돈` MVP를 만들기 위한 문서 중심 작업 공간이다.
- 아직 Flutter/ Firebase/ Cloud Functions 구현 코드는 없다.
- 현재 기준 문서는 `MVP_작업지시서.md`이며, 다음 작업자는 이 문서를 기준으로 실제 MVP 앱 구현을 시작하면 된다.
- `코드게이트_똑똑용돈 통합 기획안.md`는 제출/설명용 기획안이고, 서비스 배경과 표현을 확인할 때 참고한다.
- `AGENTS.md`는 작업 규칙, 보안 경계, 검증 규칙을 담고 있으므로 모든 작업 전 먼저 읽는다.

## 2. 프로젝트 한 줄 정의

`똑똑용돈`은 부모님께 드리는 용돈을 시니어의 미션 참여, 활동 데이터, AI 개인화 리포트, 가족 대시보드로 연결하는 가족 케어 MVP다.

핵심 플라이휠:

```text
용돈(트리거) -> 시니어 참여 -> 활동 데이터 -> AI 분석 -> 개인화 -> 재참여
```

## 3. 반드시 먼저 읽을 파일

1. `AGENTS.md`
2. `HANDOFF.md`
3. `MVP_작업지시서.md`
4. `코드게이트_똑똑용돈 통합 기획안.md`

## 4. 중요한 결정 사항

- 이 폴더에서는 `superpowers` 플러그인 중심으로 작업한다.
- LazyCodex/OmO 계열의 스킬, 하네스, 작업 구조는 프로젝트 기본 방식으로 사용하지 않는다.
- 구현 앱 형태는 `Flutter` cross-platform 앱을 우선한다.
- `코드게이트_똑똑용돈 통합 기획안.md`에는 iOS/SwiftUI 언급이 있지만, `MVP_작업지시서.md`의 인터뷰 기반 결정이 더 최신 기준이다.
- MVP에서는 실제 계정/결제 완성보다 발표용 end-to-end 데모 완성이 우선이다.
- 시작 화면에서 `시니어` / `자녀` 역할을 선택한다.
- MVP 역할 전환은 실제 계정 전환이 아니라 앱 내부 role state로 처리한다.
- 미션 완료 상태와 포인트 상태는 앱을 껐다 켜도 남아야 하므로 local persistence가 필요하다.
- AI 리포트는 실제 Open API 호출 흐름을 포함하되, 앱에 API key를 넣지 않는다.
- Open API 호출은 `Cloud Functions` 같은 backend proxy를 통해서만 한다.
- API 실패, 네트워크 오류, proxy 오류에 대비해 fallback mock/rule-based report를 반드시 둔다.

## 5. MVP 데모 흐름

다음 흐름이 끊기지 않고 보여야 한다.

1. 자녀가 시작 화면에서 `자녀` 역할을 선택한다.
2. 자녀가 부모님에게 이번 주 미션과 용돈 보상 조건을 설정한다.
3. 시니어가 시작 화면에서 `시니어` 역할을 선택한다.
4. 시니어가 오늘의 미션을 확인한다.
5. 시니어가 체크인 또는 인지 활동 미션을 완료한다.
6. 포인트 또는 용돈 보상 상태가 증가한다.
7. 앱을 재실행해도 미션 완료와 포인트 상태가 유지된다.
8. 자녀가 가족 대시보드에서 참여 현황, 활동 변화, 포인트 증가, 관리 포인트를 확인한다.
9. 가족 대시보드에서 AI 요약 리포트를 생성한다.
10. 실제 API 호출 실패 시 fallback 리포트가 표시되어 발표 흐름이 유지된다.

## 6. 1순위 구현 범위

- Flutter 프로젝트 구조 생성
- 시작 화면: `시니어` / `자녀` 역할 선택
- 자녀 화면: 미션/용돈 조건 설정
- 시니어 화면: 오늘의 미션, 참여 현황, 포인트/보상 상태
- 미션 완료 흐름: 체크인 또는 간단한 인지 활동 1개 이상
- local persistence: 역할, 미션 완료, 포인트, 보상 상태 저장
- 가족 대시보드: 참여 현황, 미션 완료율, 활동 변화 요약, 관리 포인트
- AI 리포트 카드: 활동 요약, 변화 포인트, 추천 미션, fallback 여부
- Cloud Functions backend proxy 기반 Open API 호출 구조
- API 실패 시 fallback 리포트

## 7. 2순위 구현 범위

- 교육형 콘텐츠 화면
- 미션 유형별 상세 화면
- 추천 미션 로직 고도화
- Firebase Auth/Firestore 실제 연결 준비
- 설정 화면의 역할 변경 구조

## 8. 지금은 범위 밖

- 실제 금융결제
- 실제 송금 API
- 의료기관 진료 데이터 처리
- 과도한 의료/진단 데이터 처리
- 만보기 연동
- SNS 공유 카드
- 커머스/포인트 사용처
- B2B/B2G 확장 기능

## 9. 보안 및 표현 경계

- `.env`, `.env.local`은 읽거나 수정하거나 출력하지 않는다.
- 앱 코드, client config, local storage에 Open API key를 넣지 않는다.
- MVP에서는 실제 금융결제 데이터를 처리하지 않는다.
- MVP에서는 의료기관 진료 데이터나 과도한 의료 데이터를 처리하지 않는다.
- AI 리포트 입력에는 이름, 연락처 등 직접 식별 정보를 넣지 않는다.
- AI 리포트는 활동 데이터 기반 요약과 추천으로만 작성한다.
- 질병 진단, 치매 확정, 위험 단정, 처방처럼 보이는 표현은 금지한다.
- 권장 표현은 `참여가 줄었습니다`, `활동 패턴 변화가 보입니다`, `가벼운 체크인 미션을 추천합니다` 같은 형태다.

## 10. 추천 데이터 모델

MVP에서는 mock/local persistence로 시작해도 된다.

- `User`: id, role, displayName, familyId
- `FamilyLink`: id, seniorUserId, childUserId, relationship, permissionLevel
- `Mission`: id, title, type, description, rewardPoints, estimatedMinutes
- `MissionCompletion`: id, missionId, seniorUserId, completedAt, score/responseSummary, earnedPoints
- `RewardStatus`: id, seniorUserId, period, targetPoints, currentPoints, allowanceStatus
- `AIReport`: id, seniorUserId, period, summary, changePoints, recommendations, generatedAt

## 11. 다음 에이전트의 첫 작업 제안

1. `AGENTS.md`, `MVP_작업지시서.md`, 이 파일을 다시 읽는다.
2. Flutter 프로젝트가 없으므로 현재 폴더에 Flutter 앱 구조를 생성할지, 별도 하위 폴더를 만들지 확인한다. 특별한 요청이 없으면 `app/` 하위에 생성하는 편이 문서와 구현을 분리하기 좋다.
3. `superpowers` 플러그인을 사용해 작업하고, 작업 시작 시 관련 skill을 먼저 읽는다.
4. 첫 구현 목표는 `시작 화면 -> 자녀 설정 -> 시니어 미션 완료 -> 포인트 증가 -> 가족 대시보드 -> AI/fallback 리포트` 단일 세로 흐름이다.
5. 실제 Firebase 연결 전에 local persistence와 mock/proxy 인터페이스를 먼저 만들어 발표 흐름을 고정한다.
6. Cloud Functions proxy는 API key가 앱에 들어가지 않는 구조로 분리한다.
7. UI는 시니어가 읽기 쉬운 큰 글자, 적은 선택지, 명확한 CTA를 우선한다.

## 12. 완료 전 검증 체크리스트

- 시니어 참여 홈에서 오늘의 미션과 보상 상태가 보이는가?
- 자녀가 미션/용돈 조건을 설정할 수 있는가?
- 미션 완료 후 참여 데이터와 포인트 상태가 바뀌는가?
- 앱 재실행 후 미션 완료와 포인트 상태가 유지되는가?
- 가족 대시보드에서 참여 현황과 변화 요약이 보이는가?
- AI 리포트가 backend proxy 호출 성공/실패 상태를 구분하는가?
- Open API 호출 실패 시 fallback 리포트가 표시되는가?
- 실제 결제/의료 데이터 없이도 데모가 설득되는가?
- 앱 코드에 Open API key가 포함되지 않았는가?
- 문서 변경만 한 경우 UTF-8 읽기 검증을 실행했는가?

## 13. 이번 인수인계 작성 근거

- `AGENTS.md`: 작업 규칙, 보안 경계, MVP 핵심 범위
- `MVP_작업지시서.md`: 구현 순서, 데모 흐름, 데이터 모델, 완료 기준
- `코드게이트_똑똑용돈 통합 기획안.md`: 서비스 정의, 문제의식, 플라이휠, 제출용 표현
