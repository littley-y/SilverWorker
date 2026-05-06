# PR #6 Review Round 3 (Claude) — Day 8: 지원 기능

- **PR**: [#6](https://github.com/littley-y/SilverWorker/pull/6) `feature/day8-application` → `master`
- **대상 커밋**: `ec4d181` (fix(review): B-1 — add hasApplied())
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🟢 **Approve** — Blocker 해결, M-1 회귀 핵심 커버, 머지 가능

---

## 2차 지적 사항 해결 검증

### 🔴 B-1 (자동 빈 지원서 저장) — ✅ 해결

**`lib/repositories/application_repository.dart:32-41`**

```dart
Future<bool> hasApplied(String jobId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final snap = await _firestore
      .collection('users').doc(uid)
      .collection('applications').doc(jobId)
      .get();
  return snap.exists;
}
```

- 결정적 ID(`applications/{jobId}`) 단일 read-only `get()` — 쓰기 발생 없음. ✅
- `submitApplication` 의 transaction 과 동일 경로(`/users/{uid}/applications/{jobId}`)를 조회하므로 m-2 원래 의도(사전 중복 체크) 정확히 충족. ✅

**`lib/screens/application/application_form_screen.dart:31-37`**

```dart
Future<void> _checkAlreadyApplied() async {
  try {
    final applied = await ref.read(applicationRepositoryProvider).hasApplied(widget.jobId);
    if (mounted && applied) setState(() => _alreadyApplied = true);
  } on Exception {
    // Ignore errors during pre-check
  }
}
```

- `submitApplication` 호출 제거. 화면 진입 시 더 이상 write 발생하지 않음. ✅
- 사전 체크 실패 시 form 진입은 허용되고 실제 제출 시 `AlreadyAppliedException` 으로 fallback — 안전한 degradation. ✅

### 🟠 M-1 (테스트 보강) — ✅ 핵심 회귀 커버

**`test/widgets/application_form_screen_test.dart`** — `_MockRepository` 추가 후 4건 신규/보강:

| 테스트 | 검증 항목 | 평가 |
|---|---|---|
| `submit calls repository once` | 진입 시 `hasAppliedCallCount == 1` & `submitCallCount == 0`, 탭 후 `submitCallCount == 1` | ✅ B-1 회귀 정확히 잠금. "진입 시 submit 호출 0회" 불변식이 미래 회귀를 자동으로 차단. |
| `hasApplied=true shows disabled button on entry` | mock 이 true 반환 → "이미 지원한 공고입니다" 노출 | ✅ m-2 사전 체크 동작 검증 |
| `submit error shows already-applied state` | mock 이 `AlreadyAppliedException` 던질 때 → 상태 전환 | ✅ 폴백 경로 검증 |
| (기존 2건) renders + maxLength | 위젯 트리 sanity | ✅ |

**`_MockRepository`** 가 `Fake implements ApplicationRepository` 패턴으로 깨끗하게 작성됨. `submitCallCount` / `hasAppliedCallCount` / `throwAlreadyApplied` / `throwClosed` 플래그로 분기 시나리오를 모두 커버.

`flutter test` 51/51 (44 + 신규 7) 통과.

---

## 잔존 갭 — 머지 비차단

이번 PR 에서 정리되지는 않았지만 후속 PR 또는 spec_10 (테스트 기준 정리) 시점에 보강 권고:

### r-1 (Recommendation). Repository 단위 테스트 부재

`ApplicationRepository.submitApplication` 의 transaction 로직 — `tx.set` 호출, sealed exception 분기 (already_applied/job_not_found/job_closed × 2 케이스), denormalized 필드 저장, `serverTimestamp` 적용 — 은 form 위젯 테스트의 mock 으로 우회되어 있어 직접 검증되지 않습니다. `fake_cloud_firestore` + `firebase_auth_mocks` 도입 시 5건의 단위 테스트로 회귀 잠금 가능. 데모 일정상 본 PR 비차단 인정.

### r-2 (Recommendation). "연속 N회 탭 → 1회 호출" 명시적 회귀 테스트

`submit calls repository once` 가 사실상 같은 불변식을 검증하지만 1회 탭만 수행. APP-01 의 정확한 회귀 시나리오는 다음과 같이 보강 가능:

```dart
testWidgets('rapid consecutive taps invoke submit only once', (tester) async {
  // ... mock setup ...
  final button = find.text('지원하기');
  for (var i = 0; i < 5; i++) {
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(mockRepo.submitCallCount, 1);
});
```

### r-3 (Recommendation). 1차 잔존 nit (n-1 `Colors.grey`, n-3 코드 중복)

후속 PR 보류 인정.

---

## Spec DoD 최종 충족

| DoD | 결과 | 근거 |
|---|---|---|
| 연속 탭 시 1회만 저장 | ✅ | `_isSubmitting` guard + `runTransaction` (deterministic ID) + 1.5s 쿨다운. mock 기반 1회 호출 회귀 테스트 추가. |
| 1.5초 회색 + 스피너 + "지원 중..." | ✅ | round 2 |
| `/users/{uid}/applications/{jobId}` 문서 생성 (실제 자기소개 입력 분만) | ✅ | B-1 해결로 의도된 자기소개만 저장 |
| 재지원 시 "이미 지원한 공고입니다" | ✅ | `hasApplied` 사전 체크 + 제출 시 `AlreadyAppliedException` fallback |

---

## 양호한 부분 (Keep doing)

- B-1 수정안이 round 2 권고와 정확히 일치 — `Future<bool> hasApplied(String jobId)` read-only 메서드 분리.
- `_MockRepository` 가 `Fake implements ApplicationRepository` 패턴으로 작성되어, 실제 인터페이스 변경 시 컴파일 타임에 시그니처 불일치를 잡아냄. (mockito 의 stub 패턴보다 가벼우면서 안전)
- `hasAppliedCallCount == 1 && submitCallCount == 0` 불변식이 테스트로 잠겨 — B-1 결함이 미래에 다시 도입되면 즉시 실패 (회귀 자동 차단).
- 사전 체크 실패 시 silent fallback 으로 form 진입을 허용 — 네트워크 일시 장애 시에도 사용자 경험이 끊기지 않음.

---

## 머지 권고

🟢 **Approve**.

- `flutter analyze` 0 issues, `flutter test` 51/51 passed.
- B-1 (Blocker) 정확히 해결. M-1 의 핵심 회귀(B-1 자동 저장 방지) 자동 잠금.
- 잔존 r-1 ~ r-3 은 머지 비차단. spec_10 (테스트 기준 정리) 또는 별도 follow-up 으로 처리 권고.

PROGRESS.md 의 spec_06 상태를 `✅ 완료` 로 갱신하고 머지 진행하시면 됩니다.
