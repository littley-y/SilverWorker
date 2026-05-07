# 2026-05-07 — 전체 리펙토링 및 코드 품질 개선

## 개요

Day 1~9 구현물에 대해 코드 중복, 데드코드, 하드코딩, 일관성 문제를 대폭 정리했습니다.
3개의 explore 에이전트를 병렬로 실행하여 `lib/` 전체를 감사한 후, 11건의 리펙토링을 수행했습니다.

---

## 발견된 주요 문제

### 에이전트 감사 결과 (3개 병렬 실행)

1. **구조 분석 에이전트**: `lib/` 35개 파일, 3,500라인 분석
   - `badge_widget.dart`, `loading_overlay.dart` 사용되지 않음 (데드코드)
   - `JobRepository`만 생성자 주입 패턴 미적용
   - `auth_provider.dart`에 비즈니스 로직 과다 (151라인)

2. **중복 코드 에이전트**: 7개 카테고리, 30+ 중복 패턴 발견
   - `PrimaryButton` 패턴 8곳 중복
   - `SnackBar` 패턴 9곳 중복
   - 고용형태 레이블 2곳 중복
   - 그림자 색상 3곳 중복
   - 경로 문자열 5곳 하드코딩

3. **품질 에이전트**: 14개 카테고리, 50+ 이슈 발견
   - 빈 catch 블록 5곳
   - `setState` 19개 (Riverpod 프로젝트에서 StatefulWidget 잔여)
   - `Colors.grey.shade300/400` 16+곳 하드코딩
   - `job_filter.dart` `as` 캐스트 안전성 이슈

---

## 수행한 변경

### 삭제 (2건)

| 파일 | 사유 |
|---|---|
| `lib/widgets/badge_widget.dart` | 사용되지 않음 (0 import) |
| `lib/widgets/loading_overlay.dart` | 사용되지 않음 (0 import) |

### 신규 (2건)

| 파일 | 용도 |
|---|---|
| `lib/widgets/primary_button.dart` | `PrimaryButton` 공통 위젯 |
| `lib/utils/snack_utils.dart` | `showErrorSnack`, `showSuccessSnack` 유틸 |

### 수정 (14건)

| 파일 | 주요 변경 |
|---|---|
| `lib/models/job_model.dart` | `employmentTypeLabel`, `physicalIntensityLabel`, `physicalIntensityColor` getter 추가 |
| `lib/constants/app_colors.dart` | `border`, `hintText`, `disabled`, `cardShadow` 상수 추가 |
| `lib/router/app_router.dart` | 파라미터화된 경로 빌더 헬퍼 추가 |
| `lib/repositories/job_repository.dart` | 생성자 주입(DI) 적용 |
| `lib/providers/auth_provider.dart` | Logger 추가, 빈 catch → 로깅 |
| `lib/screens/job/job_detail_screen.dart` | 고용형태 중복 제거, 경로 상수화 |
| `lib/widgets/job_card.dart` | 고용형태/강도 중복 제거, `'힘듦'`→`'무거움'` |
| `lib/screens/mypage/my_page_screen.dart` | 그림자 색상 상수화 |
| `lib/screens/mypage/application_list_screen.dart` | 그림자 색상 상수화 |
| `lib/screens/job/job_list_screen.dart` | 경로 상수화 |
| `lib/screens/application/application_form_screen.dart` | 경로 상수화, Logger 추가 |
| `lib/screens/application/application_result_screen.dart` | 경로 상수화 |
| `lib/screens/auth/phone_input_screen.dart` | 경로 상수화 |
| `lib/screens/auth/profile_register_screen.dart` | Logger 추가 |

### Round 2 수정 (Claude REQUEST CHANGES 반영)

| 파일 | 주요 변경 |
|---|---|
| `lib/models/job_model.dart` | `physicalIntensityColor` getter 및 `flutter/painting.dart` import **삭제** |
| `lib/widgets/job_card.dart` | `_IntensityBadge._color`가 `AppColors.intensity*` 직접 참조하도록 복원 |
| `lib/widgets/primary_button.dart` | `disabled` 파라미터 추가. 임시 변수 제거 |
| `lib/screens/application/application_form_screen.dart` | `PrimaryButton` + `showErrorSnack` 적용. `appLogger` 사용 |
| `lib/screens/application/application_result_screen.dart` | `PrimaryButton` 적용 |
| `lib/providers/auth_provider.dart` | `appLogger` 공유 인스턴스 사용 |
| `lib/utils/app_logger.dart` | 🆕 **신규** — 단일 `Logger` 인스턴스 |
| `lib/utils/snack_utils.dart` | 기본 배경색 `AppColors.primary`로 수정 |

### Round 3 수정 (Claude Blocker B-1 반영)

| 파일 | 주요 변경 |
|---|---|
| `lib/screens/application/application_form_screen.dart` | 외곽 `SizedBox` + `ElevatedButton` 제거. `PrimaryButton`만 남김 |
| `lib/widgets/primary_button.dart` | `disabledBackgroundColor`: `AppColors.border` → `AppColors.disabled` |

### 인프라 개선

| 파일 | 주요 변경 |
|---|---|
| `.git/hooks/pre-commit` | 리뷰 파일 차단 패턴 수정: `review_claude\|review_gemini` → `review_claude.*\.md$\|review_gemini.*\.md$` |
| `tools/scripts/generate_review_request.py` | 🆕 **신규** — PR 리뷰 요청 문서 자동 생성 스크립트 |
| `tools/scripts/pre_pr_checklist.sh` | 리뷰 요청 문서 누락 시 자동 생성 시도 |

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

## PR

- **브랜치**: `feature/refactoring-cleanup`
- **PR**: #8
- **리뷰 요청**: `docs/PR_Review/2026-05-07-pr8-request.md`
- **리뷰 피드백**: `docs/PR_Review/2026-05-07-pr8-review_claude.md` (Round 1), `docs/PR_Review/2026-05-07-pr8-review_claude_round2.md` (Round 2)
- **커밋**: `954a42a` (Round 1) → `4b2d067` (Round 2) → `f464d9f` (Round 3) → `54e3c48` (인프라) → `747f8dd` (문서)

---

## 남은 기술부채 (향후 처리 예정)

| 우선순위 | 항목 | 사유 |
|---|---|---|
| Low | `PhoneInputScreen._hasError` → `StateProvider<bool>` | `setState` → Riverpod 마이그레이션 |
| Low | `Container+BoxDecoration` → `Card` 위젯 | 시맨틱 개선 (3곳) |
| Low | `PrimaryButton` / `SnackBar` 기존 화면 적용 | 유틸은 생성했으나 기존 화면 교체는 별도 PR로 분리 |
| Low | `freezed` 도입 | `copyWith` 보일러플레이트 150라인 제거 가능 |

---

*세션 종료: Sisyphus (OpenCode)*
