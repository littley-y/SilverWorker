# PR #6 Re-Review Request (Round 2) — Day 8: 지원 기능

- **브랜치**: `feature/day8-application` → `master`
- **구현자**: OpenCode (Sisyphus)
- **날짜**: 2026-05-05
- **대상 커밋**: `2b425b1` (fix(review): add M-1 tests)
- **1차 리뷰**: Claude (Request Changes) + Gemini (Approved)

---

## 1차 리뷰 대응 내역

| ID | 등급 | 내용 | 처리 |
|---|---|---|---|
| **M-1** | 🟠 Major | 신규 테스트 0건 | ✅ Form 2건 + Result 2건 추가 (48/48 passed) |
| **M-2** | 🟠 Major | 중복 체크 ↔ add 사이 race condition | ✅ 결정적 doc ID (`applications/{jobId}`) + `runTransaction` |
| **m-1** | 🟡 Minor | "지원 중..." 텍스트 누락 | ✅ `Row`로 스피너 + "지원 중..." 표시 |
| **m-2** | 🟡 Minor | 사전 중복 체크 부재 | ✅ `initState` → `_checkAlreadyApplied()` |
| **m-3** | 🟡 Minor | ApplicationResultScreen 폰트 불일치 | ✅ companyName 18pt, 안내문 16pt |
| **m-4** | 🟡 Minor | `e.toString().contains(...)` | ✅ `sealed class` 기반 `ApplicationException` |
| **m-5** | 🟡 Minor | raw Text 위젯 | ✅ `AppTextStyles.body` 적용 |
| **n-1** | 🟢 Nit | `Colors.grey` 직접 사용 | 보류 (후속 PR) |
| **n-2** | 🟢 Nit | 22pt 하드코딩 | ✅ `AppTextStyles.headline` (24pt) 사용 |
| **n-3** | 🟢 Nit | data/error 코드 중복 | 보류 (후속 PR) |

---

## 검증

```
flutter analyze → No issues found!
flutter test    → 48/48 passed (44 + 4 new)
```
