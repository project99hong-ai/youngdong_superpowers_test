# 똑똑용돈 Hybrid Web Demo MVP Design

## 1. 목적

이 설계 문서는 `똑똑용돈`의 첫 MVP를 만들기 위한 기준이다. 목표는 완성형 서비스가 아니라 발표에서 핵심 플라이휠이 끊김 없이 보이는 세로 데모를 완성하는 것이다.

```text
역할 선택 -> 자녀 미션 설정 -> 시니어 미션 완료 -> 포인트 증가 -> 가족 대시보드 -> AI 리포트
```

구현은 Flutter cross-platform 앱을 우선한다. 첫 검증과 발표는 Chrome에서 Flutter Web으로 진행하지만, 구조는 Galaxy/Android와 iPhone/iOS 빌드로 확장할 수 있게 둔다.

## 2. 확정된 방향

- 접근 방식: 하이브리드 Web 데모
- 앱 구조: Flutter cross-platform 앱 우선
- 첫 시연 표면: Chrome / Flutter Web
- 첫 저장소: 브라우저/앱 내부 local persistence
- 이후 확장: Firestore로 옮기기 쉬운 모델과 repository 경계
- AI 방식: 첫 MVP에서는 실행 시점에 주입한 API key로 직접 호출 가능하게 구성
- 보안 원칙: API key는 코드, Git, local storage, client config에 저장하지 않는다
- 안정성: AI 호출 실패 또는 key 없음 상태에서는 fallback 리포트로 발표 흐름을 유지한다
- 작업 방식: 이 폴더에서는 superpowers 플러그인 중심으로 작업하며 LazyCodex/OmO 구조는 기본 작업 방식으로 쓰지 않는다

## 3. 범위

### 포함

- Flutter Web으로 실행 가능한 앱 구조
- 역할 선택 화면
- 자녀 미션/용돈 조건 설정 화면
- 시니어 홈 화면
- 미션 수행/완료 화면
- 포인트 증가와 보상 상태 업데이트
- 브라우저/앱 내부 저장소 기반 상태 유지
- 가족 대시보드
- 실제 AI 직접 호출을 위한 service 경계
- API 실패, key 없음, 네트워크 실패에 대비한 fallback AI 리포트
- 나중에 Firestore와 Cloud Functions proxy로 전환 가능한 인터페이스

### 제외

- 실제 금융결제
- 실제 송금 API
- 의료기관 진료 데이터 처리
- 질병 진단, 치매 확정, 위험 단정, 처방형 표현
- 실제 Firebase Auth/Firestore 완전 연동
- Cloud Functions 배포 완료
- 만보기 연동
- SNS 공유 카드
- 커머스/포인트 사용처
- B2B/B2G 기능

## 4. 아키텍처

Flutter 앱은 `app/` 하위에 둔다. 문서와 구현을 분리하고, 나중에 모바일 빌드와 Firebase 연결을 진행하기 쉽게 하기 위함이다.

```text
app/
  lib/
    main.dart
    app.dart
    models/
    services/
      demo_storage_service.dart
      ai_report_service.dart
    repositories/
      demo_repository.dart
    screens/
      role_select_screen.dart
      child_setup_screen.dart
      senior_home_screen.dart
      mission_screen.dart
      family_dashboard_screen.dart
    widgets/
```

화면은 repository만 사용한다. 화면이 local storage나 AI 호출 세부 구현을 직접 알지 않게 한다. 이렇게 하면 첫 MVP는 local persistence로 완성하고, 이후 Firestore/Cloud Functions로 바꿀 때 화면 코드를 크게 흔들지 않아도 된다.

## 5. 화면 흐름

첫 MVP는 발표자가 한 번에 보여줄 수 있는 단일 세로 흐름으로 만든다.

```text
역할 선택
  -> 자녀: 미션/용돈 조건 설정
  -> 시니어: 오늘의 미션 확인
  -> 미션 수행/완료
  -> 포인트 증가 및 보상 상태 업데이트
  -> 자녀 가족 대시보드
  -> AI 리포트 확인
```

### 역할 선택 화면

- `자녀로 시작`
- `시니어로 시작`
- 발표 중 빠른 전환을 위한 역할 변경 진입

### 자녀 미션 설정 화면

- 이번 주 미션 제목
- 미션 설명
- 완료 시 보상 포인트
- 목표 포인트
- 기본값 제공: 기억 퀴즈 1회 완료 시 100포인트

### 시니어 홈 화면

- 오늘의 미션 카드
- 현재 포인트
- 이번 주 진행률
- 큰 글자와 명확한 CTA
- `미션 시작` 버튼

### 미션 화면

- 간단한 체크인 또는 쉬운 기억 퀴즈 1개
- 완료 버튼
- 완료 후 포인트 증가
- 완료 상태 저장

### 가족 대시보드 화면

- 오늘/이번 주 참여 현황
- 미션 완료율
- 포인트 증가
- 활동 변화 요약
- 관리 포인트
- AI 리포트 카드
- 실제 AI 응답인지 fallback 응답인지 표시

## 6. 데이터 모델과 저장

첫 MVP는 브라우저/앱 내부 저장소를 사용한다. 단, 모델은 Firestore로 옮기기 쉬운 문서 단위로 설계한다.

```text
DemoState
  selectedRole
  mission
    id
    title
    description
    rewardPoints
    targetPoints
  completion
    id
    missionId
    isCompleted
    completedAt
    responseSummary
  reward
    currentPoints
    targetPoints
    allowanceStatus
  aiReport
    id
    summary
    changePoints
    recommendations
    generatedAt
    source: direct | fallback
```

Firestore 전환 시 예상 문서 구조:

```text
users/{userId}
families/{familyId}
missions/{missionId}
missionCompletions/{completionId}
rewardStatuses/{seniorUserId_period}
aiReports/{reportId}
```

저장 방식은 repository 뒤에 숨긴다.

```text
DemoRepository
  loadState()
  saveMission()
  completeMission()
  generateReport()
  resetDemo()

LocalDemoRepository
  첫 MVP에서 사용
  DemoStorageService를 통해 local persistence 저장

FirebaseDemoRepository
  이후 확장용
  Firebase Auth / Firestore 연결 시 추가
```

## 7. AI 리포트 설계

첫 MVP는 실제 AI가 작동하는 데모를 목표로 한다. 다만 보안이 최우선이므로 API key는 코드에 넣지 않는다.

```text
AiReportService
  generateReport(DemoState state)

DirectAiReportService
  첫 MVP에서 사용
  실행 시점에 주입된 API key로 직접 호출
  성공하면 source = direct

ProxyAiReportService
  이후 Cloud Functions/backend proxy 전환용

FallbackAiReportService
  key 없음, API 실패, 네트워크 실패, timeout 시 사용
  성공하면 source = fallback
```

첫 구현 우선순위:

1. API key가 주입된 경우 실제 AI 리포트 생성
2. API key가 없거나 호출 실패한 경우 fallback 리포트 생성
3. 같은 `AiReportService` 경계 아래에서 나중에 proxy 호출로 교체 가능하게 유지

프롬프트 상세 내용은 이후 별도 조정한다. 첫 MVP에서는 활동 데이터 기반 요약, 변화 포인트, 추천 미션, 가족 관리 포인트가 포함되면 충분하다.

## 8. 보안 기준

- `.env`, `.env.local`은 읽거나 수정하거나 출력하지 않는다.
- API key는 코드에 하드코딩하지 않는다.
- API key는 Git에 올라갈 수 있는 파일에 저장하지 않는다.
- API key는 local storage에 저장하지 않는다.
- Flutter Web 직접 호출은 브라우저 노출 위험이 있으므로 첫 MVP의 로컬 발표용으로만 취급한다.
- 공개 배포 전에는 Cloud Functions/backend proxy로 전환한다.
- AI 입력에는 이름, 전화번호 등 직접 식별 정보를 넣지 않는다.
- AI 리포트는 의료 판단이 아니라 활동 요약과 가족 관리 제안으로 제한한다.
- key 없음, 호출 실패, timeout은 앱 오류가 아니라 fallback 리포트 흐름으로 처리한다.

## 9. 검증 기준

### 정적 검증

- `flutter analyze`
- 가능하면 `flutter test`
- key, secret, `.env`류 파일이 코드에 포함되지 않았는지 확인

### 실행 검증

- `flutter run -d chrome`
- 역할 선택 화면 진입 확인
- 자녀 미션 설정 저장 확인
- 시니어 미션 완료 후 포인트 증가 확인
- 새로고침 후 상태 유지 확인
- 가족 대시보드에서 리포트 카드 표시 확인

### AI 검증

- API key가 없는 상태에서 fallback 리포트 표시 확인
- API key가 주입된 상태에서 실제 AI 리포트 생성 확인
- 실패 또는 timeout이 발표 흐름을 깨지 않는지 확인

## 10. 완료 기준

첫 MVP는 다음 조건을 만족하면 완료로 본다.

- Chrome에서 Flutter Web 앱이 실행된다.
- 역할 선택에서 자녀와 시니어 흐름으로 이동할 수 있다.
- 자녀가 미션과 보상 조건을 설정할 수 있다.
- 시니어가 미션을 완료하면 포인트가 증가한다.
- 새로고침 후에도 미션/포인트 상태가 유지된다.
- 가족 대시보드에 참여 현황, 포인트, 변화 요약이 보인다.
- API key가 주입되면 실제 AI 리포트를 생성할 수 있다.
- API key가 없거나 호출 실패 시 fallback 리포트가 보인다.
- API key가 코드, Git, local storage에 남지 않는다.
- 나중에 Firestore와 backend proxy로 옮길 수 있는 repository/service 경계가 유지된다.

