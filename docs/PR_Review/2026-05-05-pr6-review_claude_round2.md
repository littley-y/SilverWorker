# PR #6 Review Round 2 (Claude) — Day 8: 지원 기능

- **PR**: [#6](https://github.com/littley-y/SilverWorker/pull/6) `feature/day8-application` → `master`
- **대상 커밋**: `2b425b1` (fix(review): add M-1 tests) on top of `4f8bc5d` (M-2 + minor)
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🔴 **Request Changes** — Blocker 1, Major 1, 기존 m/n 처리 양호

---

## 종합 평가

M-2 (race) 는 deterministic doc ID + transaction 으로 정확히 해결되었고, m-1~m-5, n-2 는 모두 정상 처리되었습니다. 다만 **m-2(사전 중복 체크) 의 구현 방식이 핵심 기능을 망가뜨리는 신규 결함을 도입**했고, M-1(테스트) 의 추가분이 1차 리뷰에서 명시적으로 요청한 회귀 항목들을 커버하지 못합니다.

---

## 🔴 Blocker (신규)

### B-1. `_checkAlreadyApplied` 가 화면 진입 시마다 빈 지원 문서를 자동 생성

**위치**: `lib/screens/application/application_form_screen.dart:31-44`

```dart
Future<void> _checkAlreadyApplied() async {
  try {
    await ref.read(applicationRepositoryProvider).submitApplication(
          jobId: widget.jobId,
          selfIntroduction: '',
        );
  } on AlreadyAppliedException {
    if (mounted) setState(() => _alreadyApplied = true);
  } on Exception {
    // Ignore other exceptions during pre-check
  }
}
```

m-2 (사전 중복 체크 부재) 를 해결하기 위해 도입된 코드인데, **`submitApplication` 은 검사 함수가 아니라 실제 쓰기 함수**입니다. 다음 시나리오가 발생합니다:

1. 사용자가 처음 ApplicationFormScreen 진입 (아직 미지원)
2. `initState` → `_checkAlreadyApplied()` → `submitApplication(jobId, selfIntroduction: '')`
3. transaction 내부: `snap.exists == false` (미지원), isActive/deadline OK → `tx.set(...)` 실행
4. **빈 자기소개로 지원이 자동 저장됨** (`selfIntroduction: ''`, `status: 'submitted'`)
5. 함수 정상 종료 — `AlreadyAppliedException` 미발생, catch 블록 미실행
6. 사용자가 폼에 자기소개 정성껏 작성 후 "지원하기" 탭
7. 두 번째 `submitApplication` 호출 → `snap.exists == true` → `AlreadyAppliedException`
8. 사용자에게 **"이미 지원한 공고입니다"** 메시지가 노출. 작성한 자기소개는 저장되지 않음.

**결과**: Day 8 의 핵심 기능 ApplicationFormScreen 이 사실상 작동 불가. 모든 사용자가 실제 지원서를 제출하지 못하고, 빈 자기소개로 지원된 문서가 Firestore 에 누적됨. **데이터 정합성 + 핵심 기능 모두 파괴**.

**이 결함이 자동 회귀 테스트에 잡히지 않은 이유**: `application_form_screen_test.dart` 가 `applicationRepositoryProvider` 를 오버라이드하지 않아, 테스트 환경의 `FirebaseAuth.instance.currentUser!.uid` 호출이 즉시 예외를 던지고 `on Exception` 에서 조용히 삼켜집니다. 테스트는 `pumpAndSettle` 후 위젯 트리만 확인하므로 통과합니다 — 즉 본 PR 의 테스트는 사전 체크 경로를 **단 한 줄도 실행하지 않음**.

**수정 권고**:

(a) Repository 에 전용 체크 메서드 추가:

```dart
// lib/repositories/application_repository.dart
Future<bool> hasApplied(String jobId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final snap = await _firestore
      .collection('users').doc(uid)
      .collection('applications').doc(jobId)
      .get();
  return snap.exists;
}
```

(b) Form 의 `_checkAlreadyApplied`:

```dart
Future<void> _checkAlreadyApplied() async {
  final applied = await ref.read(applicationRepositoryProvider).hasApplied(widget.jobId);
  if (mounted && applied) setState(() => _alreadyApplied = true);
}
```

(c) **회귀 테스트 필수**: `application_form_screen_test.dart` 에서 `applicationRepositoryProvider` 를 모의 객체로 오버라이드하여 다음을 검증:
- 화면 진입 시 `hasApplied` 가 1회 호출되고 `submitApplication` 은 호출되지 않음
- `hasApplied` 가 `true` 반환 시 버튼이 "이미 지원한 공고입니다" + disabled 로 전환

---

## 🟠 Major (잔존)

### M-1 (round 1 의 연장). 추가된 테스트가 1차 리뷰의 명시 요청 사항을 커버하지 못함

**현재 상태**: 신규 테스트 4건 추가 (44 → 48). 그러나 1차 리뷰 본문에서 명시한 최소 요구를 비교하면:

| 1차 요청 | 추가 여부 | 비고 |
|---|---|---|
| `application_repository_test.dart` 5건 (정상/already_applied/job_closed×2/job_not_found) | ❌ | 0건. **본 PR 의 가장 복잡하고 가장 회귀에 취약한 레이어가 미테스트** |
| `application_form_screen_test.dart` 3건: 1회 탭 → submitApplication 1회 / 연속 탭 → 1회만 / `already_applied` → 텍스트 전환·disabled | ❌ → ⚠️ | 2건 추가되었으나 모두 "위젯 렌더링" 검증. APP-01 / APP-04 의 핵심 회귀 항목(연속 탭 1회만 저장, _isSubmitting 상태 머신, _alreadyApplied 전환) 미커버 |
| `application_result_screen_test.dart` 1건 | ✅ | 2건 추가, 충분 |

특히 가장 큰 문제는 **B-1 결함이 추가된 form 테스트로도 잡히지 않는다는 사실** 입니다. 테스트는 실제 동작이 아닌 "위젯이 그려지는지" 만 확인합니다.

**수정 권고** (B-1 해결과 함께):

1. `test/repositories/application_repository_test.dart` 신규:
   ```dart
   // pubspec.yaml dev_dependencies: fake_cloud_firestore, firebase_auth_mocks
   ```
   - `submitApplication` 정상 케이스: 문서 1건 생성, 6개 필드 검증 (`applications/{jobId}` 결정적 ID 검증 포함)
   - 같은 jobId 두 번째 호출 → `AlreadyAppliedException` 발생, 문서 추가 생성되지 않음
   - `isActive: false` → `JobClosedException`
   - `deadline` 과거 → `JobClosedException`
   - 존재하지 않는 jobId → `JobNotFoundException`
   - `hasApplied` (B-1 수정 후) 정상/없음 케이스

2. `test/widgets/application_form_screen_test.dart` 보강:
   - `applicationRepositoryProvider` 를 mock 으로 오버라이드
   - "지원하기" 탭 1회 → `submitApplication` 1회 호출 (검증 핵심: 호출 횟수)
   - 1초 안에 5회 연속 탭 → 여전히 1회만 호출 (APP-01 / APP-04 명시 회귀)
   - mock 이 `AlreadyAppliedException` 던질 때 → 버튼 텍스트 "이미 지원한 공고입니다" + disabled
   - mock `hasApplied → true` 일 때 → 진입 시 즉시 disabled

`fake_cloud_firestore` / `firebase_auth_mocks` 도입이 부담된다면 최소한 **위젯 테스트 4건** (호출 횟수 검증) 만이라도 mock 으로 처리해야 본 PR 의 핵심 DoD(APP-01) 가 회귀 보호됩니다.

---

## 1차 지적 사항 해결 검증 (정상 처리분)

| ID | 처리 |
|---|---|
| **M-2** race condition | ✅ `applications/{jobId}` 결정적 ID + `runTransaction`. 트랜잭션 내부에서 `tx.get(jobs/...)` 까지 함께 실행되어 jobs 조회 결과까지 동일 트랜잭션에 묶임. 정확. |
| **m-1** "지원 중..." 텍스트 | ✅ `Row` + 스피너 + 텍스트 |
| **m-3** Result 폰트 | ✅ companyName 18pt(`body`), 안내문 16pt(`sectionTitle`) |
| **m-4** 예외 식별 | ✅ `sealed class ApplicationException` + 3종 서브타입. `on AlreadyAppliedException` 패턴 매칭으로 분기. 깔끔. |
| **m-5** raw Text → AppTextStyles | ✅ |
| **n-2** 22pt 하드코딩 | ✅ `AppTextStyles.headline` 사용 |
| **n-1** `Colors.grey` / **n-3** 코드 중복 | ⏸ 후속 PR 보류 — 인정 |

---

## Spec DoD 재검증

| DoD | 결과 |
|---|---|
| 연속 탭 시 1회만 저장 | ⚠️ 코드 상으로는 가드 + 트랜잭션 두 겹으로 보호되지만 회귀 테스트 부재(M-1) |
| 1.5초 회색 + 스피너 + "지원 중..." | ✅ |
| `/users/{uid}/applications/{jobId}` 문서 생성 | ❌ B-1 — 화면 진입 즉시 빈 자기소개로 자동 생성됨. 정상 제출 시에는 두 번째 호출이 차단됨. |
| 재지원 시 "이미 지원한 공고입니다" | ❌ B-1 의 부작용으로 첫 진입 후 바로 발생 (정상 흐름 차단) |

---

## 머지 권고

🔴 **Request Changes** — B-1 으로 인해 핵심 기능이 작동하지 않는 상태이므로 머지 불가.

처리 순서 권고:

1. **B-1**: `hasApplied` 메서드 분리 + `_checkAlreadyApplied` 가 그것을 호출하도록 변경. 작성된 application document 가 빈 자기소개로 자동 저장되지 않음을 확인.
2. **M-1**: 최소 form 테스트 3건(1회 호출 / 연속 탭 1회 / `hasApplied → true` 시 disabled) 을 mock repository 로 작성. 가능하면 repository 테스트 5건도 함께.
3. round 3 검증: `flutter test` 출력에서 application_repository_test / form_screen_test 의 **호출 횟수 검증** 라인이 보이는지 확인.

본 결함이 운영 환경에 도달하면 모든 사용자에게 빈 자기소개가 자동 저장되고, 사용자는 본인이 의도한 지원서를 제출할 수 없게 됩니다. 반드시 round 3 에서 처리되어야 합니다.
