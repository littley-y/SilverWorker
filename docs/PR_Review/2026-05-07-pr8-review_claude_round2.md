# PR #8 Review — Claude (Round 2)

**날짜**: 2026-05-07
**리뷰어**: Claude Code
**대상 PR**: #8 — `refactor: remove dead code, deduplicate patterns, fix hardcoding`
**브랜치**: `feature/refactoring-cleanup` (HEAD: `4b2d067`)
**판정**: 🔴 **REQUEST CHANGES** (**Blocker 1** / Major 0 / Minor 2 / Nit 0)

---

## TL;DR

Round 1의 **M-1·M-2·M-3 및 모든 Minor/Nit 항목은 정확히 반영**되었습니다. 다만 **M-3을 적용하면서 `application_form_screen.dart`의 기존 `ElevatedButton`을 제거하지 않고 `PrimaryButton`을 그 child로 끼워 넣은 회귀**가 발생했습니다. 화면이 실질적으로 망가지므로 머지 전 반드시 수정이 필요합니다.

---

## 🔴 Blocker

### B-1. `PrimaryButton`이 기존 `ElevatedButton`의 자식으로 들어가 버튼이 중첩됨

**위치**: `lib/screens/application/application_form_screen.dart:150-174`

```dart
bottomNavigationBar: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: SizedBox(                          // ← 외곽 래퍼 (제거되어야 함)
      height: 56,
      child: ElevatedButton(                  // ← 외곽 ElevatedButton (제거되어야 함)
        onPressed: _alreadyApplied || _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey,   // ← 하드코딩 회귀
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: PrimaryButton(                 // ← child로 PrimaryButton (잘못됨)
          label: _alreadyApplied ? '이미 지원한 공고입니다' : '지원하기',
          onPressed: _submit,
          isLoading: _isSubmitting,
          disabled: _alreadyApplied,
        ),
      ),
    ),
  ),
),
```

**문제**:
1. **버튼이 ElevatedButton 안의 ElevatedButton으로 이중 중첩**됩니다 (`PrimaryButton` 내부도 `SizedBox(56) → ElevatedButton`). Material 가이드 위반이고 ripple/포커스가 두 겹으로 잡혀 시각적으로도 깨집니다.
2. **외곽 `ElevatedButton.onPressed`가 실제 탭 핸들러**가 됩니다 (자식 버튼은 자체 탭 영역을 가지지만 외곽 버튼이 우선 ink 처리). 즉 `PrimaryButton`이 받은 `_submit`, `disabled`, `isLoading` 모두 사실상 작동하지 않을 가능성이 높습니다 — 동작이 외곽 버튼의 `onPressed: _alreadyApplied || _isSubmitting ? null : _submit`에 좌우됨.
3. **`disabledBackgroundColor: Colors.grey`** — 본 PR이 제거 대상으로 선언한 `Colors.grey` 하드코딩이 다시 들어왔습니다. 실제 비활성 시 회색은 **외곽** 버튼의 색이 적용되며, `PrimaryButton.disabledBackgroundColor` 설정은 무시됩니다.
4. 결과적으로 **M-3에서 의도한 "PrimaryButton으로의 통합"이 표면적으로만 이루어진 셈**입니다.

**수정안**: 외곽 `SizedBox` + `ElevatedButton` + `style`을 모두 제거하고 `PrimaryButton`만 남깁니다.

```dart
bottomNavigationBar: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: PrimaryButton(
      label: _alreadyApplied ? '이미 지원한 공고입니다' : '지원하기',
      onPressed: _submit,
      isLoading: _isSubmitting,
      disabled: _alreadyApplied,
    ),
  ),
),
```

`PrimaryButton`은 이미 내부적으로 `SizedBox(height: 56)`, `width: double.infinity`, primary 배경, rounded shape, disabled 처리, loading spinner를 모두 처리하므로 외곽 래퍼는 불필요합니다 (`application_result_screen.dart`에서는 깔끔하게 그렇게 적용됨 — 같은 패턴을 form 화면에도 적용해 주세요).

검증 후 `flutter analyze` / `flutter test` 재확인 필요.

---

## 🟢 Minor

### m-1. `PrimaryButton.disabledBackgroundColor`가 `AppColors.border`로 변경됨 (Round 2에서 새로 도입)

**위치**: `lib/widgets/primary_button.dart:36`

```dart
disabledBackgroundColor: AppColors.border,   // 0xFFE0E0E0
```

Round 1 시점에는 `AppColors.disabled` (0xFF9E9E9E)였습니다. `border`(0xFFE0E0E0)는 1px 라인용 옅은 그레이라 **버튼 면적 전체의 비활성 색**으로는 너무 옅어 텍스트(흰색) 가독성이 떨어질 수 있습니다.

**권장**: `disabled` (0xFF9E9E9E) 유지 또는 더 어두운 surface 색을 별도 정의. 시각적으로 직접 확인 후 결정해 주세요.

### m-2. `application_result_screen.dart`의 `error` 분기는 여전히 `'지원이 완료되었습니다'`를 표시

**위치**: `lib/screens/application/application_result_screen.dart:57-74`

이 PR의 직접 스코프는 아니지만 PrimaryButton 적용 작업 중 눈에 띄어 기록만 남깁니다. `loading.error` 분기(공고 정보 조회 실패) 에서도 "지원 완료" 메시지가 출력됩니다 — 별도 PR에서 정리 대상.

---

## ⚪️ Nit

없음.

---

## ✅ Round 1 피드백 반영 검증

| ID | 내용 | 검증 |
|---|---|---|
| **M-1** | `JobModel.physicalIntensityColor` 삭제 + `job_card.dart`가 `AppColors.intensity*` 직접 참조 | ✅ 정확히 반영. `lib/models/job_model.dart`에서 `Color` getter 완전 제거됨 |
| **M-2** | `JobModel`에서 `package:flutter/painting.dart` import 제거 | ✅ 정확히 반영. 모델 레이어가 다시 순수해짐 |
| **M-3 (1/2)** | `PrimaryButton`을 `application_result_screen.dart`에 적용 | ✅ 정확히 반영. SizedBox+ElevatedButton 블록 두 곳을 깨끗하게 `PrimaryButton`으로 교체 |
| **M-3 (2/2)** | `PrimaryButton`을 `application_form_screen.dart`에 적용 | ❌ **회귀** — B-1 참조 |
| **M-3 (3/3)** | `showErrorSnack`를 `application_form_screen.dart`의 3개 SnackBar에 적용 | ✅ 정확히 반영. `'이미 지원한 공고입니다'`, `'마감된 공고입니다'`, `'지원에 실패했습니다...'` 3건 모두 교체됨 |
| **m-1** | Import 순서 (`package:logger/logger.dart` 위치) | ✅ → `package:logger/logger.dart` 자체가 제거되고 `app_logger.dart`로 일원화. 더 나은 해법 |
| **m-2** | 단일 `appLogger` 인스턴스 | ✅ `lib/utils/app_logger.dart` 신설, 3개 파일이 import. `PrettyPrinter` 설정도 일관됨 |
| **m-3** | `showSnack` 기본 배경색 → `AppColors.primary` | ✅ 반영. textSecondary보다는 적절한 선택 |
| **n-1** | `PrimaryButton.build`의 임시 변수 제거 | ✅ `final button = ...; return button;` → `return SizedBox(...)`로 정리 |
| **n-2** | `physicalIntensityLabel` fallback 대칭화 | ✅ `_ => '알 수 없음'` sentinel 적용 |

---

## 머지 가이드

| 항목 | 상태 |
|---|---|
| Spec 일치 | ✅ |
| 0경고 / 테스트 통과 | ✅ (구현자 검증) |
| Round 1 항목 8/9건 정확 반영 | ✅ |
| **Blocker** | ❌ B-1 (form 화면 버튼 중첩) |
| Minor | m-1 (디자인 토론), m-2 (별도 PR) |

→ **B-1 수정 후 round 3 리뷰 요청 필요.**
B-1만 정리되면 머지 가능 수준입니다. 외곽 `SizedBox`+`ElevatedButton` 제거가 5줄 변경이라 round 3는 짧게 끝날 것으로 보입니다.

---

*Reviewed by Claude Code · 2026-05-07 · Round 2*
