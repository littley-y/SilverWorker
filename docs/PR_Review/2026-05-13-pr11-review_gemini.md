# PR Review — spec_12: 홈 화면 UI 개선 (Gemini)

> Date: 2026-05-13
> Reviewer: Gemini
> PR: #11
> Target Branch: `master`
> Source Branch: `feature/spec-12-home-ui-refinement`

---

## 1. 아키텍처 (Architecture)

*   **`JobModel`에 `walkingMinutes` 추가 하위 호환성**
    *   **평가**: ✅ **Pass**
    *   **의견**: 완벽하게 호환됩니다. `final int? walkingMinutes;` 로 Nullable 타입으로 정의되었고, `fromJson`에서도 `as int?`로 캐스팅하므로, 필드가 존재하지 않는 기존 Firestore 문서는 정상적으로 `null`로 파싱되어 장애를 일으키지 않습니다.
*   **`MascotBanner`의 `StatefulWidget` 설계**
    *   **평가**: ✅ **Pass**
    *   **의견**: 매우 적절합니다. `_message` 텍스트 변경은 전역적인 상태 관리가 필요 없는, 위젯 내부의 일회성 프레젠테이션(Presentation) 상태입니다. 불필요하게 Riverpod 등의 전역 상태로 올리지 않고 `StatefulWidget`의 `setState`로 가볍게 처리한 것은 훌륭한 선택입니다.
*   **`IntensityPill`의 색상/문장 매핑 확장성**
    *   **평가**: ⚠️ **Minor**
    *   **의견**: 현재 요구사항에는 문제없으나, 장기적인 확장성은 다소 아쉽습니다. `switch(physicalIntensity)`를 통해 String 하드코딩으로 매핑하고 있습니다. 향후 강도 단계가 추가되거나 변경될 경우, 뷰 레벨(`IntensityPill`)을 직접 수정해야 합니다. String 대신 **Enum (예: `PhysicalIntensity`)** 을 정의하고 Enum 내부에 `color`, `label` 프로퍼티(또는 Extension)를 갖도록 도메인 로직으로 분리하는 것이 더 안전하고 확장하기 좋습니다.

## 2. UI / UX

*   **2줄 제목 시 카드 높이 불균형 문제**
    *   **평가**: ✅ **Pass** (with note)
    *   **의견**: `JobListScreen`이 `ListView.builder` (세로 리스트)로 구성되어 있으므로 높이가 달라져도 레이아웃이 깨지거나 잘리지 않고 자연스럽게 스크롤됩니다. 다만 리스트 항목들의 높낮이가 계속 바뀌는 것이 시각적으로 거슬린다면, 향후 `Container(constraints: BoxConstraints(minHeight: ...))` 등으로 최소 높이를 고정해주는 것을 고려해볼 수 있습니다.
*   **한 화면 2개 노출 여부**
    *   **평가**: ✅ **Pass**
    *   **의견**: 타이틀(24pt), 금액(20pt), 다양한 칩과 여백(16dp)을 고려하면 하나의 카드가 약 170~190dp 정도의 높이를 차지할 것으로 예상됩니다. 기기 높이를 고려하면 리스트에서 동시에 2~3개가 큼직하게 잘 보일 것입니다.
*   **필터바 슬라이드 UX 및 칩 터치 영역 (40dp 이상?)**
    *   **평가**: ⚠️ **Minor**
    *   **의견**: 터치 영역이 다소 작을 수 있습니다. PR 명세에 의하면 FilterBar 칩의 높이가 **36dp**로 지정되어 있습니다. 구글 Material Design 가이드라인 및 시니어 사용자 접근성 가이드에서는 최소 터치 영역을 **48dp(권장)**, 최소 **40dp**를 요구합니다. 칩 내부 패딩이나 높이를 더 키우는 것을 권장합니다.
*   **마스코트 말풍선 감성 요소**
    *   **평가**: ✅ **Pass**
    *   **의견**: 따뜻한 인삿말 배열과 탭할 때마다 `HapticFeedback`과 함께 바뀌는 텍스트는 앱을 더 친근하고 '살아있는' 느낌이 들도록 돕습니다.

## 3. 코드 품질 (Code Quality)

*   **`RegExp(r'모집$')` 정규식의 정확성**
    *   **평가**: ⚠️ **Minor** (Potential Bug)
    *   **의견**: `job.title.replaceAll(RegExp(r'모집$'), '').trim();`의 경우, 원본 타이틀에 공백이 포함되어 **"아파트 경비원 모집 "** 처럼 끝나는 경우 매칭에 실패합니다(`$`는 문자열의 맨 끝을 의미하므로 뒤에 공백이 있으면 안 됨). 정규식을 보완하여 `job.title.trim().replaceAll(RegExp(r'모집$'), '').trim()` 형태로 변경하는 것을 권장합니다.
*   **`GrayChip`의 재사용성**
    *   **평가**: ✅ **Pass**
    *   **의견**: 텍스트와 함께 `icon`을 옵셔널로 받아 어느 메타 정보에든 유연하게 적용할 수 있도록 잘 추상화되었습니다.
*   **테스트 커버리지**
    *   **평가**: ✅ **Pass**
    *   **의견**: `test/widgets/job_card_test.dart`에서 월급/시급/일급 등 다양한 조건 포맷팅, '마감' 렌더링, 칩 렌더링까지 화면에 노출되는 시각적 요구사항을 디테일하게 잘 검증하고 있습니다.

---

## 최종 리뷰 의견 (Summary)

**승인 여부: Approved (권장 수정 사항 반영 시)**

코드는 전반적으로 매우 우수하며, 시니어 사용자를 위한 세심한 UI/UX 개선이 돋보입니다. 앱 안정성에 위배되는 블로커는 없으므로 머지가 가능한 상태입니다. 아래 권장 수정 사항을 시간 여유 시 반영해 주시면 더 견고한 앱이 될 것입니다.

**[권장 수정 사항]**
1. **[Nit]** 정규식 보완: `job.title.trim().replaceAll(RegExp(r'모집$'), '').trim()` 적용
2. **[Minor]** 시니어 터치 영역 고려: FilterBar 칩 높이/패딩 약간 확장 (36dp -> 40dp 이상)
3. **[Minor]** Enum 전환: `IntensityPill` 강도 String 하드코딩 부분 도메인 모델 내 Enum 활용으로 리팩토링 고려