# PR #4 Review (Claude) — Day 4: 공고 목록 UI

- **PR**: [#4](https://github.com/littley-y/SilverWorker/pull/4) `feature/day4-job-list-ui` → `master`
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🔴 **Request Changes** — Blocker 1건, Major 2건, Minor 3건, Nit 2건
- **참조 Spec**: `spec_04_job_list_ui.md`, `spec_09_ui_system.md`

---

## 종합 평가

기능 구현 범위는 spec_04 §1~5 를 충실히 커버합니다. JobCard / FilterBar / 로딩·에러·빈 상태 / 라우팅 버그 수정까지 단일 PR 안에서 일관되게 처리했고, 위젯 테스트 15건이 추가되어 회귀 방지 측면도 양호합니다. 다만 **실제 시드 데이터(mock 30건)에 포함된 시급 표기 시 금액 손실**이 발생하는 표시 버그가 있어 머지 전에 반드시 고쳐야 합니다. 그 외 spec_09 폰트 하한 위반 1건과 `JobFilter.copyWith` 결함은 별도 처리가 필요합니다.

---

## 🔴 Blocker

### B-1. `JobCard._formatSalary` — 시급/일급에서 금액 손실 (실제 데이터 영향)

**위치**: `lib/widgets/job_card.dart:89-98`

```dart
static String _formatSalary(JobModel job) {
  final amount = (job.salaryAmount / 10000).toStringAsFixed(0);
  ...
  return '$prefix ${amount}만원';
}
```

`salaryAmount`를 항상 10,000으로 나눈 뒤 정수 반올림하여 "만원" 단위로 표시합니다. 월급(2,000,000원 → "월 200만원")에는 적합하지만, **시급/일급에서는 의미 있는 금액이 사라집니다**.

`tools/scripts/seed_jobs.json` 의 실제 mock 데이터:

| salaryType | salaryAmount | 현재 표시 | 문제 |
|---|---|---|---|
| hourly | 12000 | "시 1만원" | 시급 1만원처럼 오인 (실제 12,000원) |
| hourly | 14000 | "시 1만원" | 반올림 손실 |
| hourly | 15000 | "시 2만원" | 반올림 오류 (실제 15,000원, 표시는 2만원) |

이는 단순 UI 문제가 아니라 **유저(60대 이상)가 잘못된 임금 정보로 지원 결정을 할 수 있는 정보 무결성 이슈**입니다.

**수정 권고**:

```dart
static String _formatSalary(JobModel job) {
  final formatter = NumberFormat('#,###'); // intl 패키지
  switch (job.salaryType) {
    case 'hourly':
      return '시급 ${formatter.format(job.salaryAmount)}원';
    case 'daily':
      return '일급 ${formatter.format(job.salaryAmount)}원';
    case 'monthly':
      // 월급은 만원 단위가 관습적으로 자연스러움
      final manwon = job.salaryAmount ~/ 10000;
      return '월 $manwon만원';
    default:
      return '${formatter.format(job.salaryAmount)}원';
  }
}
```

회귀 테스트: `JobCard renders hourly salary as "시급 12,000원"` 추가 필요.

---

## 🟠 Major

### M-1. spec_09 §1 폰트 하한(14pt) 위반 — JobCard 내부 칩/배지 12pt

**위치**: `lib/widgets/job_card.dart:135`, `:175`

```dart
// _EmploymentTypeChip
style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),

// _IntensityBadge
Text(_label, style: TextStyle(fontSize: 12, color: _color)),
```

`spec_09 §1` 은 **"최소 폰트: 14pt. 이 이하 크기는 사용 금지"** 라고 명시합니다. 또한 `spec_04` DoD "18pt 이상 폰트 전체 적용 확인" 항목이 리뷰 요청서에서 ✅ 로 체크되어 있으나 실제로는 12pt 텍스트가 두 곳 존재합니다.

`spec_04 §2` 표에는 "근무 형태 칩 12pt" 라는 기재가 있지만, `spec_04 §4` 에서는 같은 화면이 `AppTextStyles` 를 따르도록 지시하고 있고, `AppTextStyles` 의 최소값은 caption 14pt 입니다. 두 spec 이 충돌할 때는 시니어 UX 의 핵심 원칙(가독성)을 보장하는 `spec_09` 의 명시적 금지 규정이 우선되어야 합니다.

**수정 권고**: 두 12pt 모두 `AppTextStyles.caption` (14pt) 로 통일. 칩 컨테이너 패딩을 `EdgeInsets.symmetric(horizontal: 10, vertical: 4)` → `(horizontal: 10, vertical: 6)` 정도로 보정해 카드 높이 변동 흡수.

### M-2. `JobFilter.copyWith` 가 nullable 필드를 null 로 재설정 불가

**위치**: `lib/models/job_filter.dart:21-35`

```dart
JobFilter copyWith({String? locationCode, ...}) {
  return JobFilter(
    locationCode: locationCode ?? this.locationCode,  // null 전달해도 기존값 유지
    ...
  );
}
```

리뷰 요청서에서도 인지된 이슈로 명시되어 있고, 실제로 `FilterBar` 가 `copyWith` 대신 `JobFilter(...)` 를 직접 생성하는 우회로 회피하고 있습니다(`filter_bar.dart:49-57, 66-74`). 또한 `test/widgets/job_card_test.dart:140-162` 의 "상시" 테스트에서도 동일 우회로 인해 모든 필드를 수동 복사하는 코드가 들어가 있습니다.

이 상태로 두면 향후 다른 화면(상세, 검색)에서 누군가 `copyWith(locationCode: null)` 을 호출했을 때 **소리 없이 무시되는 잠복 버그**가 됩니다.

**수정 권고** (sentinel 패턴 또는 명시적 clear):

```dart
static const Object _unset = Object();

JobFilter copyWith({
  Object? locationCode = _unset,
  Object? jobCategory = _unset,
  ...
}) {
  return JobFilter(
    locationCode: locationCode == _unset
        ? this.locationCode
        : locationCode as String?,
    ...
  );
}
```

또는 더 단순하게 `JobFilter.clear({bool location = false, bool category = false})` 헬퍼 추가. 어떤 방향이든 `FilterBar` 의 직접 생성 코드는 `copyWith` 호출로 정리되어야 합니다.

---

## 🟡 Minor

### m-1. AppBar 에 `AppTextStyles.headline` (24pt + height 1.4) 사용 시 잠재적 클리핑

`lib/screens/job/job_list_screen.dart:26`

`AppBar.title` 의 기본 toolbar 높이는 56dp 입니다. `headline` (24pt × 1.4 line height ≈ 34dp 높이) 자체는 들어가지만, 시스템 텍스트 스케일이 1.3배 이상으로 설정된 노인 사용자의 단말에서는 ascender/descender 가 잘릴 가능성이 있습니다. `AppBar(toolbarHeight: 64)` 추가 또는 `title` (20pt) 사용을 권고합니다.

### m-2. 스켈레톤 로더 색상이 너무 옅어 인지하기 어려움

`lib/screens/job/job_list_screen.dart:122, 132, 144, 152`

스켈레톤 블록이 모두 `AppColors.divider` (#E0E0E0) 인데, 카드 배경(흰색) 위에서는 보이지만 스캐폴드 배경(#F5F5F5) 과 묶여 시각적으로 흐려집니다. `Color(0xFFCCCCCC)` 정도로 한 단계 진하게 권고.

### m-3. `app_text_styles.dart` fontFamily = 'Roboto' — 한글 렌더링 시스템 폴백 의존

`lib/constants/app_text_styles.dart:9-10`

Roboto 는 한글 글리프가 없어 시스템 폴백(Android: 본고딕, iOS: 애플산돌고딕)이 일어납니다. 기기마다 폰트 두께/자간이 달라져 시니어 UX 일관성이 깨집니다. spec_09 마무리 단계(Day 11)에 NotoSansKR 등 명시 적용 권고. 본 PR 의 블로커는 아니나 추적 항목으로 기록 권합니다.

---

## 🟢 Nit

### n-1. `JobCard._formatSalary` / `_formatDeadline` 모델 측 노출 권고

위젯 내부 `static` 으로 두면 단위 테스트가 위젯 트리를 띄워야 합니다. `JobModel.formattedSalary`, `JobModel.deadlineLabel` getter 로 옮기면 순수 단위 테스트가 가능합니다(현재 회귀 시 `flutter test` 의 widget 부팅 비용을 절감).

### n-2. JobListScreen 자체 위젯 테스트 부재

`_LoadingState` / `_ErrorState` / `_EmptyState` 분기는 위젯 테스트가 없습니다. `ProviderScope.overrides` 로 `jobListProvider` 를 각각 `AsyncLoading/AsyncError/AsyncData([])` 로 오버라이드하는 3건 정도 추가하면 spec_04 §5 DoD 의 회귀 방어가 명확해집니다.

---

## Spec DoD 재검증

| DoD | 리뷰 요청서 | 실제 |
|---|---|---|
| 카드 형태 표시 | ✅ | ✅ |
| 필터 칩 탭 시 목록 변경 | ✅ | ✅ (jobFilterProvider → jobListProvider 연동 확인) |
| **18pt 이상 폰트 전체 적용** | ✅ | ❌ (M-1 — 칩/배지 12pt 잔존) |
| 에뮬레이터 스크롤 | ⚠️ 실기기 미확인 | ⚠️ 동일 — 본 리뷰 범위 외 |

---

## 양호한 부분 (Keep doing)

- `main.dart` 의 `MaterialApp.router()` + `routerProvider` 연결 누락 버그 발견·수정. 본 PR 범위 외였으나 발견 즉시 처리한 판단 적절.
- `app_colors.dart` / `app_text_styles.dart` 를 `abstract final class` 로 정의해 인스턴스화 차단 — Dart 3 best practice.
- FilterBar 의 단일 선택 + 재탭 해제 동작에 대한 위젯 테스트가 정확히 작성됨 (`filter_bar_test.dart:83-106`).
- Firestore 쿼리 (`job_repository.dart:23-36`) 는 spec_03 의 기존 인덱스 정의 범위 내에서 동작 — 추가 인덱스 요구 없음.
- `JobCard` 의 `InkWell` + `Card.borderRadius` 동기화로 ripple 영역 정확히 제한됨.

---

## 머지 권고

🔴 **Request Changes**.

- **B-1** 수정 후 회귀 테스트(시급/일급 표시) 추가 필수.
- **M-1** 폰트 하한 위반 수정 필수 — 본 PR 의 핵심 가치(시니어 UX)와 직결.
- **M-2** copyWith 결함은 본 PR 에서 정리하거나, 별도 follow-up 이슈로 분리하더라도 본 PR 본문에 명시.
- m-1 ~ m-3, n-1 ~ n-2 는 후속 PR 또는 본 PR 추가 커밋으로 처리 가능.
