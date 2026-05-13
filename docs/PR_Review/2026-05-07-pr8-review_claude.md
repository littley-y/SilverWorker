# PR #8 Review — Claude (Round 1)

**날짜**: 2026-05-07
**리뷰어**: Claude Code
**대상 PR**: #8 — `refactor: remove dead code, deduplicate patterns, fix hardcoding`
**브랜치**: `feature/refactoring-cleanup`
**판정**: 🔄 **REQUEST CHANGES** (Blocker 0 / Major 3 / Minor 3 / Nit 2)

---

## TL;DR

리펙토링의 의도와 범위는 적절하고 검증(`flutter analyze` 0경고, 62/62 tests)도 통과했습니다. 다만 **이번 PR이 스스로 표방한 "중복 제거 / 데드코드 삭제" 원칙을 일부 위반**하는 항목이 있어 머지 전에 보정이 필요합니다.

핵심 두 가지:
1. `JobModel.physicalIntensityColor`가 `AppColors.intensity*` 상수를 그대로 hex 리터럴로 복제했습니다 (DRY 위반).
2. `PrimaryButton`, `snack_utils.dart`, `AppColors.border/hintText/disabled` 모두 **이번 PR에서 사용처가 0건**입니다. 도입과 적용을 같은 PR로 묶거나, 적용 PR이 준비될 때까지 보류해야 합니다.

---

## 🔴 Blocker

없음.

---

## 🟡 Major

### M-1. `JobModel.physicalIntensityColor`가 `AppColors`를 복제 — DRY 위반

**위치**: `lib/models/job_model.dart:209-214`

```dart
Color get physicalIntensityColor => switch (physicalIntensity) {
      'light' => const Color(0xFF4CAF50), // intensityLight
      'moderate' => const Color(0xFFFF9800), // intensityModerate
      'heavy' => const Color(0xFFF44336), // intensityHeavy
      _ => const Color(0xFFFF9800),
    };
```

이미 `lib/constants/app_colors.dart:37-39`에 동일한 hex 값으로 `intensityLight/Moderate/Heavy`가 정의되어 있고, 주석(`// intensityLight`)이 그 사실을 인지하고 있음을 보여줍니다. 본 PR의 명시된 목적이 "중복 코드 제거"인 만큼, 모델에서도 `AppColors` 상수를 직접 참조해야 합니다.

**수정안**:
```dart
import '../constants/app_colors.dart';
...
Color get physicalIntensityColor => switch (physicalIntensity) {
      'light' => AppColors.intensityLight,
      'moderate' => AppColors.intensityModerate,
      'heavy' => AppColors.intensityHeavy,
      _ => AppColors.intensityModerate,
    };
```

---

### M-2. 도메인 모델에 Flutter UI 의존성 추가

**위치**: `lib/models/job_model.dart:1` — `import 'package:flutter/painting.dart';`

`JobModel`은 Firestore 매핑을 담당하는 데이터 모델 계층입니다. 여기에 `Color` getter를 추가하면 모델이 Flutter UI 패키지에 종속되어:

- 순수 Dart 환경(서버, CLI, 단위 테스트 setup) 에서 모델을 재사용하기 어려워집니다.
- 향후 `freezed` 마이그레이션(`history` 문서에 명시된 후속 과제)에서 직렬화 코드 생성 시 불필요한 Flutter 의존을 끌고 갑니다.
- 레이어 분리 관점에서 "presentation 정보(색)"가 model에 흘러 들어옵니다.

**권장**: `physicalIntensityColor`만 모델 밖으로 분리. 옵션 두 가지:
1. `lib/utils/job_presentation.dart` 같은 presentation helper를 신설하여 색상 매핑을 두기.
2. 각 위젯(`job_card`, `safety_curation_section`)에 `_intensityColorOf(String)` 헬퍼를 두는 기존 패턴 유지.

`employmentTypeLabel` / `physicalIntensityLabel`은 한글 레이블이라 도메인 영역에서 받아들일 수 있지만, **`Color`만큼은 모델 밖으로 빼는 것**을 권장합니다. (M-1 수정 시 import도 함께 사라집니다.)

---

### M-3. 사용처 없는 신규 자산 — Dead-on-arrival

**위치**:
- `lib/widgets/primary_button.dart` (신규, 56줄) — `lib/`, `test/` 어디서도 import되지 않음
- `lib/utils/snack_utils.dart` (신규, 40줄) — 동일하게 사용처 0건
- `lib/constants/app_colors.dart:28-33` — `border`, `hintText`, `disabled` 추가했으나 호출처 0건

`docs/PR_Review/2026-05-07-pr8-request.md`에서도 명시:
> 기존 코드는 추후 PR에서 교체 예정

이는 본 PR의 "데드코드 제거" 테마와 정면으로 충돌합니다. 사용처가 없는 코드는:
- 인터페이스가 실 사용 전에 굳어져, 첫 적용 시 불일치가 드러납니다.
- 리뷰 시점에 적합성을 검증할 수 없습니다 (`PrimaryButton`이 8곳 중 몇 곳에 정말 들어맞는지 확인 불가).
- 향후 PR이 표류하면 그대로 영구적 사용되지 않은 코드로 남습니다.

**권장 (둘 중 하나)**:
- (A) **이번 PR에서 1~2개 화면이라도 적용**: 예) `PrimaryButton`은 `application_result_screen.dart`/`application_form_screen.dart`의 56dp ElevatedButton에 즉시 교체. `showErrorSnack`은 `application_form_screen.dart:65/71/78` 세 곳에 즉시 교체.
- (B) **신규 파일들을 본 PR에서 제거**하고 적용 PR과 함께 도입.

`AppColors.border/hintText/disabled`도 동일 원칙. 적어도 `disabled`는 `PrimaryButton`이 `disabledBackgroundColor`로 사용하므로 `PrimaryButton`을 적용한다면 자동으로 활성화됩니다.

---

## 🟢 Minor

### m-1. Import 순서 위반

**위치**: `lib/screens/application/application_form_screen.dart:1-10`

```dart
import 'package:flutter/material.dart';
...
import '../../repositories/application_repository.dart';
import '../../router/app_router.dart';
import 'package:logger/logger.dart';   // ← package 임포트가 relative 뒤
```

Dart 관례상 `package:` 임포트가 relative 임포트보다 앞에 와야 합니다 (`directives_ordering` lint 규약). 분석기가 활성화돼 있지 않아 통과는 하지만, 같은 파일 안에서도 일관성이 깨졌습니다. `package:logger/logger.dart`를 `package:flutter/material.dart` 그룹으로 이동해 주세요.

`profile_register_screen.dart`는 올바르게 정렬되어 있어 일관성 회복이 필요합니다.

### m-2. 파일별 top-level `final _log = Logger();` 중복

3개 파일(`auth_provider.dart`, `application_form_screen.dart`, `profile_register_screen.dart`)에서 각자 `final _log = Logger();`를 선언합니다. 향후 다른 파일에도 동일 패턴이 퍼지면 출력 포맷, 로그 레벨, 필터를 일괄 조정하기 어려워집니다.

**권장**: `lib/utils/app_logger.dart`에 단일 `Logger` 인스턴스를 두고 import해 재사용. 이번 PR 스코프가 부담스러우면 후속 PR로 빼도 무방합니다.

### m-3. `showSnack` 기본 배경색이 `AppColors.textSecondary`

**위치**: `lib/utils/snack_utils.dart:34`

```dart
backgroundColor: backgroundColor ?? AppColors.textSecondary,
```

"text 보조색"을 surface로 사용하는 것은 시맨틱이 맞지 않습니다. 의도적인 게 아니라면 `null`을 그대로 넘겨 Material 기본값(혹은 명시적인 `AppColors.surfaceXXX`)을 쓰는 편이 안전합니다.

---

## ⚪️ Nit

### n-1. `PrimaryButton.build`의 불필요한 임시 변수
**위치**: `lib/widgets/primary_button.dart:50-54`
```dart
final button = SizedBox(...);
return button;
```
`return SizedBox(...)`로 바로 반환해도 됩니다. (M-3 적용 시 같이 정리)

### n-2. `physicalIntensityLabel` vs `physicalIntensityColor`의 fallback 비대칭
- Label fallback: `_ => physicalIntensity` (raw string 노출)
- Color fallback: `_ => intensityModerate`

데이터가 enum 외 값일 때 한쪽은 raw, 한쪽은 색을 강제 매핑합니다. 가능하다면 두 getter 모두 `'unknown'` 같은 sentinel을 만들거나, 두 곳 다 raw 패스스루로 통일해 호출자가 동일 가정을 할 수 있도록 해주세요.

---

## ✅ 잘된 점

- `'힘듦' → '무거움'` 수정은 `docs/planning/spec_05_job_detail.md:33`의 사양과 일치 — 정확한 버그 수정.
- `JobRepository` 생성자 주입은 향후 unit test (mock Firestore) 도입을 가능케 함. 기존 호출자(`job_provider.dart:8 return JobRepository()`)도 default-arg로 무중단 호환됨.
- `auth_provider.dart`의 빈 catch → Logger 전환은 운영 디버깅성에 명확한 개선.
- `AppRoutes.jobDetailRoute(id)` 등 파라미터 빌더는 go_router 컨벤션과 무관하게 호출 사이트에서 안전성 ↑.
- 데드코드(`badge_widget`, `loading_overlay`) 삭제는 적절히 검증됨 (참조 0건 확인 가능).

---

## 머지 가이드

| 항목 | 상태 |
|---|---|
| Spec 일치 | ✅ (refactoring PR — 신규 spec 영향 없음) |
| 0경고 / 테스트 통과 | ✅ |
| Blocker | 없음 |
| Major | M-1, M-2, M-3 — **수정 필요** |
| Minor / Nit | 가능하면 동반 처리, 별도 PR 가능 |

→ **M-1, M-3는 머지 전 필수 수정. M-2는 토론 가능 (모델에 Color를 둘지 여부에 대한 팀 컨벤션 확인 권장).**

수정 후 round 2 리뷰 요청 부탁드립니다.

---

*Reviewed by Claude Code · 2026-05-07*
