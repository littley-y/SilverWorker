# PR #6 Re-Review Request (Round 3) — Day 8: 지원 기능

- **브랜치**: `feature/day8-application` → `master`
- **구현자**: OpenCode (Sisyphus)
- **날짜**: 2026-05-05
- **대상 커밋**: `ec4d181`
- **2차 리뷰**: Claude (Request Changes — B-1, M-1)

---

## B-1 (Blocker) 해결

`_checkAlreadyApplied` 가 `submitApplication` 을 호출해 빈 자기소개로 자동 저장되던 결함 수정:

- `ApplicationRepository.hasApplied(jobId)` 전용 read-only 체크 메서드 추가
- `_checkAlreadyApplied` → `hasApplied()` 호출로 변경
- 이제 화면 진입 시 실제 쓰기 발생하지 않음

## M-1 (테스트) 보강

Mock `ApplicationRepository` 사용:
- `hasApplied` 호출 여부 검증
- `submitApplication` 호출 횟수 검증 (1회)
- `hasApplied=true` → 진입 즉시 "이미 지원한 공고입니다" + disabled
- `submitApplication` → `AlreadyAppliedException` → 상태 전환

## 검증

```
flutter analyze → No issues found!
flutter test    → 51/51 passed
```
