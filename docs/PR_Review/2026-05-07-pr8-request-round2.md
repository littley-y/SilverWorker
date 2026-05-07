# PR #8 Review Request — Round 2

**날짜**: 2026-05-07
**브랜치**: `feature/refactoring-cleanup`
**대상 PR**: #8 — `refactor: remove dead code, deduplicate patterns, fix hardcoding`
**구현자**: Sisyphus (OpenCode)
**이전 리뷰**: [Claude Round 1](2026-05-07-pr8-review_claude.md) / [Gemini Round 1](2026-05-07-pr8-review_gemini.md)

---

## Round 1 피드백 반영 요약

Claude (REQUEST CHANGES)와 Gemini (APPROVED)의 Round 1 리뷰를 모두 반영했습니다.

### Major 수정 (3건)

| ID | 항목 | 반영 내용 |
|---|---|---|
| **M-1** | `JobModel.physicalIntensityColor`가 `AppColors`를 복제 | `physicalIntensityColor` getter **삭제**. `job_card.dart`가 `AppColors.intensityLight/Moderate/Heavy`를 직접 참조하도록 복원 |
| **M-2** | 도메인 모델에 Flutter UI 의존성 (`package:flutter/painting.dart`) | `JobModel`에서 `Color` import 및 getter **완전 제거**. `Color` 매핑은 위젯 계층(`job_card.dart`)에서만 처리 |
| **M-3** | 사용처 없는 신규 자산 (`PrimaryButton`, `snack_utils.dart`) | `PrimaryButton`을 `application_form_screen.dart`, `application_result_screen.dart`에 즉시 적용. `showErrorSnack`을 `application_form_screen.dart`의 3개 SnackBar에 적용 |

### Minor 수정 (3건)

| ID | 항목 | 반영 내용 |
|---|---|---|
| **m-1** | Import 순서 위반 | `application_form_screen.dart`에서 `package:logger/logger.dart`를 `package:` 그룹 앞으로 이동 |
| **m-2** | 파일별 top-level `final _log = Logger()` 중복 | `lib/utils/app_logger.dart` 신규 생성. `appLogger` 단일 인스턴스를 3개 파일(`auth_provider`, `application_form_screen`, `profile_register_screen`)에서 공유 |
| **m-3** | `showSnack` 기본 배경색이 `AppColors.textSecondary` | 기본값을 `AppColors.primary`로 변경 (시맨틱 정렬) |

### Nit 수정 (2건)

| ID | 항목 | 반영 내용 |
|---|---|---|
| **n-1** | `PrimaryButton.build`의 불필요한 임시 변수 | `final button = SizedBox(...); return button;` → `return SizedBox(...)` 직접 반환 |
| **n-2** | `physicalIntensityLabel` fallback 비대칭 | `_ => physicalIntensity` (raw 노출) → `_ => '알 수 없음'` (sentinel)로 대칭화 |

---

## 추가 변경 (Round 1 미포함, Round 2에서 반영)

### `PrimaryButton.disabled` 파라미터 추가

`application_form_screen.dart`의 `_alreadyApplied` 상태에서 버튼을 비활성화해야 하는데, `isLoading`만으로는 커버되지 않아 `disabled` 파라미터를 추가했습니다.

```dart
PrimaryButton(
  label: _alreadyApplied ? '이미 지원한 공고입니다' : '지원하기',
  onPressed: _submit,
  isLoading: _isSubmitting,
  disabled: _alreadyApplied,
)
```

---

## 검증

```bash
$ bash tools/verify_local.sh
[1/6] Installing dependencies (flutter pub get)...
✅ Dependencies resolved.
[2/6] Checking code formatting (dart format)...
✅ Formatting is clean.
[3/6] Running static analysis (flutter analyze)...
✅ Zero warnings.
[4/6] Running unit tests (flutter test)...
✅ All tests passed. (62/62)
[5/6] Simulating GitHub Pages build (pages.yml)...
✅ Pages build simulation passed.
[6/6] Checking for uncommitted graphify changes...
✅ Graphify check done.

🚀 LOCAL CI PASSED (6/6 steps, 9s)
```

---

## 변경 파일 (Round 2)

| 파일 | 변경 |
|---|---|
| `lib/models/job_model.dart` | `physicalIntensityColor` getter 및 `flutter/painting.dart` import 삭제. `physicalIntensityLabel` fallback 대칭화 |
| `lib/widgets/job_card.dart` | `_IntensityBadge._color`가 `AppColors.intensity*` 상수를 직접 참조하도록 복원 |
| `lib/widgets/primary_button.dart` | `disabled` 파라미터 추가. 임시 변수 제거. `disabledBackgroundColor`를 `AppColors.border`로 설정 |
| `lib/screens/application/application_form_screen.dart` | `PrimaryButton` + `showErrorSnack` 적용. `appLogger` 사용. import 순서 수정 |
| `lib/screens/application/application_result_screen.dart` | `PrimaryButton` 적용. `AppColors` import 복원 |
| `lib/screens/auth/profile_register_screen.dart` | `appLogger` 사용. `Logger` import 제거 |
| `lib/providers/auth_provider.dart` | `appLogger` 사용. `Logger` import 제거 |
| `lib/utils/app_logger.dart` | 🆕 **신규** — 단일 `Logger` 인스턴스 |
| `lib/utils/snack_utils.dart` | 기본 배경색 `AppColors.primary`로 수정 |

---

## 리뷰 포인트 (Round 2)

1. **M-1/M-2 검증**: `JobModel`에서 `Color` 의존성이 완전히 제거되었는지
2. **M-3 검증**: `PrimaryButton`과 `showErrorSnack`이 실제 화면에 적용되었는지
3. **m-2 검증**: `appLogger`가 3개 파일에서 일관되게 사용되는지
4. **PrimaryButton.disabled**: 새로 추가된 `disabled` 파라미터가 `_alreadyApplied` 상태를 올바르게 처리하는지

---

## 리뷰어

- [ ] Claude Code
- [x] Gemini CLI

---

*Round 1 리뷰 후 수정 사항을 본 브랜치에 추가 커밋(`4b2d067`)으로 반영했습니다.*
