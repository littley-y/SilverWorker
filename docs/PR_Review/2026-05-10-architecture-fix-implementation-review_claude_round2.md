# Architecture Fix Implementation Review — Claude Round 2

> Date: 2026-05-10
> Reviewer: Claude (Opus 4.7)
> Target: working tree on `master` (uncommitted)
> Basis: `docs/PR_Review/2026-05-10-architecture-fix-implementation-request-round2.md`
> Verdict: **Approve** ✅

---

## Round 1 Major 검증

### M-1: AuthException 통합 — ✅ 해소

**검증 명령**:
```bash
$ grep -n "mapFirebaseAuthException\|_exceptionToMessage\|_mapAuthError" lib/providers/auth_provider.dart
123:            errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
141:          errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
181:        errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
207:String _exceptionToMessage(AuthException e) {
```

- `_mapAuthError(FirebaseAuthException)` 완전 제거 ✓
- `mapFirebaseAuthException()` 호출 3건 (Round 1: 0건) ✓
- `_exceptionToMessage`의 switch는 `AuthException` 6개 서브타입(`InvalidPhone/InvalidCode/SessionExpired/TooManyRequests/NetworkRequestFailed/Unknown`)을 모두 커버 — sealed class에 대한 exhaustive switch이므로 향후 새 서브타입 추가 시 컴파일러가 강제 분기를 요구. 견고함.
- Firebase 의존(`FirebaseAuthException`)은 `auth_repository.dart`의 mapper 경계에서 차단되고, provider 이상 레이어는 도메인 예외만 본다 — 본래 의도대로 작동.

### M-2: MainShell guard redirect 삭제 — ✅ 해소

`lib/screens/main/main_shell.dart:46-50`:
```dart
if (user == null) {
  // Router redirect handles this; safe fallback.
  return const Scaffold(
      body: Center(child: CircularProgressIndicator()));
}
```

- `WidgetsBinding.addPostFrameCallback` + `context.go(phone)` 블록 제거 ✓
- Spinner fallback만 유지 — 라우터 redirect가 race를 처리하고, 짧은 transient 동안 빈 Scaffold 대신 Spinner 보여주는 것은 UX적으로 자연스러움.

---

## 검증 결과

```
flutter analyze   → 0 errors / 0 warnings
flutter test      → 97/97 PASS
verify_local.sh   → 6/6 PASS
```

(로컬 재실행으로 확인됨)

---

## Deferred 항목 인정

| 항목 | 코멘트 |
|---|---|
| m-1 applicationId 중복 | 동의. 기능 영향 없음, 데이터 모델 정리는 별도 PR이 깔끔. |
| m-2 sentinel 패턴 | 동의. freezed 도입은 도메인 차원 결정 — 본 아키텍처 픽스 범위 밖. |

---

## 결론

**Approve. Merge: ALLOWED.**

Round 1의 Major 2건이 정확히 코드에 반영되었고 검증도 통과. Round 2 변경분은 spec_*.md 위반 없음, 회귀 없음. 머지 진행해도 좋습니다.

후속 작업으로 `m-1`(applicationId 중복) / `m-2`(sentinel) 처리를 백로그에 남겨 두시면 됩니다.
