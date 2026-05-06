# PR #6 Review (Claude) — Day 8: 지원 기능

- **PR**: [#6](https://github.com/littley-y/SilverWorker/pull/6) `feature/day8-application` → `master`
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🔴 **Request Changes** — Blocker 0, Major 2, Minor 5, Nit 3
- **참조 Spec**: `spec_06_application.md`, `spec_09_ui_system.md`, `spec_10_test_criteria.md`

---

## 종합 평가

화면 구성·라우팅·중복 체크·오터치 방어·Firestore 저장은 spec_06 §1~5 를 정확히 따르고 있고 DoD 4개 항목 모두 흐름 자체는 작동합니다. 그러나 **본 PR 은 신규 테스트 0건**으로 PR #4(+22건), PR #5(+9건)에서 확립한 회귀 방어 디스플린에서 후퇴했고, spec_06 의 핵심 DoD("연속 탭 시 1회만 저장", "재지원 차단")가 정확히 회귀에 취약한 상태 머신 로직임을 고려하면 머지 전 보강이 필요합니다. 또한 spec 자체의 한계이지만 중복 체크 → add 사이의 **race condition**과, **사전 중복 체크 부재**로 인한 "폼 작성 후 거부" UX 함정도 정리할 가치가 있습니다.

---

## 🟠 Major

### M-1. 신규 테스트 0건 — spec_10 / 프로젝트 디스플린 회귀

**근거**: PR 본문 "44/44 passed" — PR #5 머지 시점과 동일 카운트. 신규 파일·로직에 대한 테스트가 추가되지 않음.

PR #4 (22건) / PR #5 (9건) 에서 확립한 "DoD 항목당 회귀 테스트" 패턴이 본 PR 에서만 끊겼습니다. 본 PR 의 핵심 로직은 다음과 같이 모두 **상태 머신 + 비동기 + Firestore 호출** 의 조합으로, 향후 손쉽게 회귀할 수 있는 영역입니다:

- `_isSubmitting` 중복 클릭 차단 (APP-04, 명시적 DoD)
- `_alreadyApplied` 의 비활성 텍스트/스타일 전환
- `submitApplication` 의 `already_applied` / `job_closed` / `job_not_found` 분기
- denormalized `jobTitle` / `companyName` 저장
- `serverTimestamp()` 적용

**수정 권고** (최소 셋):

1. `test/repositories/application_repository_test.dart` — `fake_cloud_firestore` + `firebase_auth_mocks` 사용:
   - 정상 제출 시 문서 1건 생성, 필드 6종(jobId/jobTitle/companyName/selfIntroduction/status/submittedAt) 검증
   - 동일 jobId 두 번째 호출 시 `already_applied` 예외
   - `isActive: false` job → `job_closed`
   - `deadline` 과거 → `job_closed`
   - 존재하지 않는 jobId → `job_not_found`

2. `test/widgets/application_form_screen_test.dart` — `ProviderScope.overrides` 로 repository / jobDetailProvider 주입:
   - 버튼 1회 탭 시 `submitApplication` 1회 호출 (regression for APP-01 / APP-04)
   - 연속 5회 탭 시 1회만 호출
   - `already_applied` 발생 시 버튼 텍스트가 "이미 지원한 공고입니다" 로 전환되고 disabled

3. `test/widgets/application_result_screen_test.dart` — 체크 아이콘·확인 버튼 렌더링·`context.go('/')` 호출.

`fake_cloud_firestore` 패키지가 미설치라면 `pubspec.yaml` `dev_dependencies` 추가 필요.

### M-2. 중복 체크 ↔ `add` 사이 race condition — APP-01 "1회만 저장" 보장 미흡

**위치**: `lib/repositories/application_repository.dart:30-70`

```dart
final existing = await _firestore.collection(...).where('jobId', isEqualTo: jobId).limit(1).get();
if (existing.docs.isNotEmpty) throw ...;
// ... <-- (네트워크/UI guard 우회 시 race window)
await _firestore.collection(...).add({...});
```

UI 가드(`_isSubmitting` + 1.5s 쿨다운)는 **단일 디바이스의 단일 세션**에서만 유효합니다. 다음 시나리오에서 중복 문서가 생길 수 있습니다:

- 사용자가 같은 계정으로 두 기기에서 동시 제출
- 네트워크 retry 가 클라이언트 측에서 중복 전송
- (방어막이 무력화된) 디버그 빌드 / 미래 변경

spec_06 §3 의 코드 예시 자체가 이 race 를 그대로 가지고 있어 implementer 가 spec 을 충실히 따른 결과이긴 하나, `APP-01` "1회만 저장" 의 의미를 데이터 정합성 차원에서 충족하려면 **deterministic doc ID** 로 변경하는 것이 옳습니다.

**수정 권고** — `applications/{jobId}` 결정적 ID + `set` 사전조건:

```dart
final ref = _firestore.collection('users').doc(uid)
    .collection('applications').doc(jobId);

await _firestore.runTransaction((tx) async {
  final snap = await tx.get(ref);
  if (snap.exists) throw Exception('already_applied');
  // ... job 검증 ...
  tx.set(ref, {
    'jobId': jobId,
    // ...
  });
});
```

부수 효과로 기존 `where('jobId', isEqualTo: ...)` 인덱스/쿼리 비용이 사라집니다. 다만 이 변경은 spec_06 §3 의 코드 샘플과 충돌하므로 spec 도 함께 갱신 필요. 본 PR 머지 전후 어느 쪽이든 진행 가능하지만, **반드시 본 PR 안에서 처리하거나 즉시 후속 PR 로 분리하여 트래킹**되어야 합니다.

---

## 🟡 Minor

### m-1. spec_06 §2 "지원 중..." 텍스트 누락

**위치**: `lib/screens/application/application_form_screen.dart:147-159`

spec_06 §2 본문: *"버튼 상태: `_isSubmitting == true` 일 때 → 배경 회색, 텍스트 '지원 중...', 로딩 스피너 표시"*

현재 구현은 스피너만 표시하고 텍스트는 비어 있습니다. 시니어 사용자에게는 시각 단서(텍스트)가 추가로 있는 편이 안전합니다.

**수정 권고**: 스피너 + "지원 중..." Row 또는 스피너만 24dp 후 옆 텍스트.

### m-2. 사전 중복 체크 부재 — "폼 다 작성한 후 거부" UX 함정

**위치**: `application_form_screen.dart:18-21`

`_alreadyApplied` 가 `false` 로 초기화되고, 화면 진입 시 사전 검사하지 않습니다. 시나리오:

1. 사용자가 어제 이미 지원한 공고를 오늘 다시 진입
2. 자기소개 200자 정성껏 작성
3. "지원하기" 탭 → SnackBar "이미 지원한 공고입니다" + 버튼 비활성화

작성한 내용이 모두 무의미해지는 UX. 시니어 사용자에게는 특히 좌절 요소.

**수정 권고**: `initState` 에서 `applicationRepositoryProvider.fetchApplications` 호출 또는 `applications.where(jobId).limit(1).get()` 으로 사전 체크. 이미 지원했으면 진입 즉시 "이미 지원한 공고입니다" 상태로 표시 + 폼 disable.

### m-3. ApplicationResultScreen 폰트 크기가 spec 과 불일치

**위치**: `application_result_screen.dart:32-36`

| 요소 | spec_06 §4 | 현재 |
|---|---|---|
| 공고명 | 18pt | `AppTextStyles.body` (18pt) ✅ |
| 회사명 | 18pt | `AppTextStyles.caption` (14pt) ❌ |
| "마이페이지에서 지원 현황을…" | 16pt 회색 | `AppTextStyles.caption` (14pt) ❌ |

**수정 권고**: 회사명 → `AppTextStyles.body.copyWith(color: AppColors.textSecondary)`, 안내 텍스트 → `AppTextStyles.sectionTitle` (16pt) 또는 신규 토큰.

### m-4. 예외 타입 식별이 `e.toString().contains(...)` 기반

**위치**: `application_form_screen.dart:39-58`

```dart
} on Exception catch (e) {
  if (e.toString().contains('already_applied')) { ... }
  else if (e.toString().contains('job_closed')) { ... }
}
```

문자열 매칭은 다음 위험을 가집니다:
- 다른 코드가 같은 문자열을 메시지로 던지면 오탐
- 메시지 변경(국제화 등) 시 분기가 깨짐
- IDE 의 정적 분석이 보호하지 못함

**수정 권고**: `lib/repositories/application_repository.dart` 에 sealed class 또는 enum 기반 예외:

```dart
sealed class ApplicationException implements Exception {}
class AlreadyAppliedException extends ApplicationException {}
class JobClosedException extends ApplicationException {}
class JobNotFoundException extends ApplicationException {}
```

호출 측은 `on AlreadyAppliedException catch (_) { ... }` 패턴.

### m-5. `loading` / `error` / "공고를 찾을 수 없습니다" 의 raw `Text(...)`

**위치**: `application_form_screen.dart:79, 129-130`, `application_result_screen.dart:64-65`

`AppTextStyles` 토큰이 누락된 raw `Text` 위젯이 4곳 존재합니다. PR #5 round 2 의 N-1 에서 해결한 패턴을 본 PR 에서 다시 도입한 셈. 일관성 유지를 위해 모두 `AppTextStyles.body` 적용.

---

## 🟢 Nit

### n-1. `disabledBackgroundColor: Colors.grey` 직접 사용

**위치**: `application_form_screen.dart:141`

`Colors.grey` (#9E9E9E) 가 `AppColors.textSecondary` (#757575) 와 다릅니다. 디자인 시스템 일관성을 위해 `AppColors` 에 `disabled = Color(0xFFBDBDBD)` 등 토큰 추가 후 참조 권고. (PR #5 round 1 에서 짚었던 spec_09 토큰화 흐름의 연속선)

### n-2. ApplicationResultScreen — "지원이 완료되었습니다!" 하드코딩 TextStyle

**위치**: `application_result_screen.dart:29, 65`

```dart
const Text('지원이 완료되었습니다!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
```

22pt 헤딩이 `AppTextStyles` 에 없으므로 일회성 정의가 들어왔습니다. spec_09 §1 표는 `headline 24` / `title 20` 만 정의 — 22pt 가 필요하다면 `AppTextStyles` 에 명시적 토큰을 추가하거나 `headline` (24pt) 으로 통일.

### n-3. ApplicationResultScreen 의 error 분기와 data 분기 코드 중복

**위치**: `application_result_screen.dart:21-83`

`data: (job)` 와 `error: (_, __)` 콜백이 90% 동일한 트리를 반환. job 정보가 없을 때만 정보 텍스트가 빠지는 차이. `Builder` 또는 추출 위젯으로 통합 가능.

---

## Spec DoD 재검증

| DoD | 결과 | 비고 |
|---|---|---|
| 연속 탭 시 1회만 저장 | ⚠️ | UI 가드는 작동하나 race window 존재(M-2). 자동 회귀 테스트 부재(M-1). |
| 1.5초 회색 + 스피너 | ✅ | `disabledBackgroundColor` + `CircularProgressIndicator` + `Future.delayed(1500ms)`. (스피너 옆 "지원 중..." 텍스트 누락 — m-1) |
| `/users/{uid}/applications/` 문서 생성 | ✅ | 필드 6종 + denormalized + serverTimestamp |
| 재지원 시 "이미 지원한 공고입니다" | ✅ | SnackBar + 버튼 비활성화. 단 사전 체크 미실시(m-2). |

---

## 양호한 부분 (Keep doing)

- `app_router.dart` 에 `/apply/:jobId` + `/apply/:jobId/done` 두 경로를 `AppRoutes` 상수로 정리 — go_router 의존성 일관 유지.
- `submitApplication` 의 단계별 검증 순서(중복 → exists → isActive → deadline) 가 시간복잡도/실패 빠른 반환 측면에서 합리적.
- `bottomNavigationBar` 자리에 SafeArea + ElevatedButton 배치 — `Stack/Positioned` 보다 안드로이드 IME(키보드) 와의 호환성이 좋음 (spec_06 의 텍스트 입력 화면 특성에 적합한 선택).
- `disabledBackgroundColor` 명시 — disabled 상태에서 primary 색이 그대로 남는 Material 3 기본 동작을 정확히 우회.
- `firestore.rules` 의 `users/{uid}/{subcollection}/{docId}` 와이일드카드 규칙이 본 PR 의 저장 경로를 이미 커버 — 추가 rules 변경 불필요.

---

## 머지 권고

🔴 **Request Changes**.

- **M-1 (테스트 부재)** — 본 PR 의 가장 중요한 회귀 항목. 최소 repository 5건 + form 3건 + result 1건 추가 필수.
- **M-2 (race condition)** — deterministic doc ID + transaction 권고. spec 갱신과 함께 본 PR 또는 즉시 후속 PR.

m-1~m-5, n-1~n-3 은 본 PR 추가 커밋으로 처리 권장하나 후속 PR 가능.
