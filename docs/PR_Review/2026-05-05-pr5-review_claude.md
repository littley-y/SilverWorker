# PR #5 Review (Claude) — Day 5: 공고 상세 + 세이프티 큐레이션

- **PR**: [#5](https://github.com/littley-y/SilverWorker/pull/5) `feature/day5-job-detail` → `master`
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🟡 **Approve with Comments** — Blocker 0, Major 1, Minor 4, Nit 3
- **참조 Spec**: `spec_05_job_detail.md`, `spec_09_ui_system.md`

---

## 종합 평가

spec_05 §1~4 의 화면 구성·세이프티 큐레이션·근무 조건 표·하단 고정 버튼이 모두 구현되었고, DoD 5개 항목을 모두 충족합니다. spec_04 round 2 에서 합의한 시급/일급/월급 포맷팅 패턴을 그대로 가져온 점이 일관성 측면에서 좋습니다. 다만 **"지원하기" 버튼이 `onPressed: () {}` 로 무반응 상태**라는 UX 이슈와, **PR #4 의 n-1(`_formatSalary` 모델 측 이전) 후속이 누락된 결과 코드 중복이 두 화면에 걸쳐 존재**하는 점은 본 PR 머지 후 빠르게 정리하는 것이 좋습니다. 본 PR 단독으로는 머지 가능합니다.

---

## 🟠 Major

### M-1. "지원하기" 버튼 — 활성 상태이나 콜백 무반응 (UX 함정)

**위치**: `lib/screens/job/job_detail_screen.dart:89-99`

```dart
ElevatedButton(
  onPressed: () {},   // <-- 빈 콜백
  ...
  child: const Text('지원하기', style: AppTextStyles.button),
)
```

`onPressed`가 비어있는 함수이지만 `null` 이 아니므로 버튼은 **시각적으로 활성** (primary 색상, ripple 효과 발생) 상태입니다. 시니어 사용자가 탭 → 시각적 피드백(ripple) → 화면 전환 없음 → "버그"로 오인할 가능성이 큽니다. 본 앱의 핵심 사용자층(60대 이상)에게는 특히 문제가 됩니다.

spec_06(지원 기능)이 Day 8 까지 미구현이므로 그 사이 기간을 위한 임시 처리 필요.

**수정 권고** (택 1):

```dart
// (a) SnackBar 안내 — 가장 사용자 친화적
onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('지원 기능은 곧 제공될 예정입니다')),
  );
},

// (b) 버튼 비활성화 + 안내 텍스트
onPressed: null,  // 자동으로 disabledBackgroundColor 적용
// 텍스트는 "준비 중" 등으로 변경

// (c) 명시적 TODO + 라우팅 자리표시
onPressed: () {
  // TODO(spec_06): Navigate to ApplicationFormScreen
},
```

(a) 가 현재 시점에서 가장 권장됩니다. (c) 만으로는 위 UX 함정 해결되지 않으므로 비추천.

---

## 🟡 Minor

### m-1. `_formatSalary` 코드 중복 — `JobCard` ↔ `JobDetailScreen`

**위치**: `lib/widgets/job_card.dart:89-104`, `lib/screens/job/job_detail_screen.dart:131-144`

PR #4 round 1 에서 nit (n-1) 로 제기되어 "선택적 후속" 으로 분류된 `_formatSalary` 모델 측 이전이 미반영되었고, 이번 PR 에서 동일 로직이 한 번 더 복사되어 **두 곳에 존재**하게 되었습니다. 이미 `_WorkConditionSection` 이 `_HeaderSection._formatSalary(job)` 를 private static 메서드로 호출하는 우회까지 발생 중입니다(`job_detail_screen.dart:168`).

**수정 권고**: `JobModel` 에 `String get formattedSalary` getter 추가 후 두 화면 모두 호출.

```dart
// lib/models/job_model.dart
String get formattedSalary {
  final formatter = NumberFormat('#,###');
  return switch (salaryType) {
    'hourly' => '시급 ${formatter.format(salaryAmount)}원',
    'daily' => '일급 ${formatter.format(salaryAmount)}원',
    'monthly' => '월 ${salaryAmount ~/ 10000}만원',
    _ => '${formatter.format(salaryAmount)}원',
  };
}
```

이렇게 하면 단위 테스트도 widget tree 부팅 없이 가능. 차후 통화/지역화 변경 시 한 군데만 수정.

### m-2. JobDetailScreen 에러·로딩 상태가 spec_04 의 패턴에서 후퇴

**위치**: `lib/screens/job/job_detail_screen.dart:32-34`

```dart
loading: () => const Center(child: CircularProgressIndicator()),
error: (_, __) => const Center(child: Text('공고를 불러오는 중 오류가 발생했습니다')),
```

PR #4 의 `JobListScreen` 은 에러 시 아이콘 + 메시지 + **다시 시도** 버튼, 빈 상태 시 아이콘 + 메시지 + 액션 버튼을 제공합니다. 본 PR 의 에러 상태는 텍스트만 있고 재시도 수단이 없어 시니어 UX 일관성이 깨집니다.

**수정 권고**: spec_04 §5 의 ErrorView 패턴(`_ErrorState` 위젯)을 공통 위젯으로 추출하여 재사용. 본 PR 에서는 최소한 다음 형태로 보강:

```dart
error: (_, __) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
      const SizedBox(height: 16),
      Text('공고를 불러오는 중 오류가 발생했습니다', style: AppTextStyles.body),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => ref.invalidate(jobDetailProvider(jobId)),
        child: const Text('다시 시도'),
      ),
    ],
  ),
),
```

(이 경우 `error` 콜백을 `Builder` 또는 외부 클래스에서 `ref` 주입 형태로 변경 필요)

### m-3. JobDetailScreen 테스트 — 시급/일급 회귀 누락

**위치**: `test/widgets/job_detail_screen_test.dart`

PR #4 의 `JobCard` 에서 시급/일급 회귀 테스트(B-1 대응)가 추가되었지만, 본 PR 의 JobDetailScreen 은 monthly 케이스만 검증합니다(`월 200만원` only). `_HeaderSection._formatSalary` 가 별도 복사본이므로, JobCard 의 회귀 테스트가 JobDetailScreen 의 회귀를 보장하지 못합니다.

**수정 권고**: `salaryType: 'hourly'` / `'daily'` 케이스 1건씩 추가. m-1 (모델 getter 이전) 을 함께 처리하면 `JobModel.formattedSalary` 단위 테스트로 더 간단히 정리 가능.

### m-4. `_SectionBlock` 의 "정보 없음" — 공백 문자열만 입력 시 처리 누락

**위치**: `lib/screens/job/job_detail_screen.dart:215`

```dart
Text(content.isNotEmpty ? content : '정보 없음', style: AppTextStyles.body)
```

`content == ' '` (공백 문자) 또는 `'\n\n'` 같은 화이트스페이스만 있는 경우 `isNotEmpty == true` 가 되어 빈 영역이 그대로 표시됩니다. mock 데이터가 정상적이라 현재는 문제없지만, 실데이터(고용24 API) 도입 시 발생 가능.

**수정 권고**: `content.trim().isNotEmpty` 로 변경.

---

## 🟢 Nit

### n-1. `_WorkConditionSection` → `_HeaderSection._formatSalary` 의 private static 호출

**위치**: `lib/screens/job/job_detail_screen.dart:168`

같은 파일 내에서 `_HeaderSection._formatSalary(job)` 호출은 Dart 문법상 합법이나, 다른 위젯의 private 정적 메서드를 끌어다 쓰는 것은 응집도 측면에서 좋지 않습니다. m-1(모델 getter 이전) 을 적용하면 자연스럽게 해소됩니다.

### n-2. `ElevatedButton.styleFrom(foregroundColor: Colors.white)` 중복

**위치**: `lib/screens/job/job_detail_screen.dart:91-93`

`AppTextStyles.button` 자체가 이미 `color: Colors.white` 입니다. `foregroundColor: Colors.white` 는 ripple 색상에는 영향 있지만 텍스트에는 중복. 의도한 것이라면 그대로 두어도 무방.

### n-3. SafetyCurationSection 의 `physicalIntensity` 알 수 없는 값 → `moderate` fallback

**위치**: `lib/widgets/safety_curation_section.dart:47, 61`

```dart
_ => AppColors.intensityModerate,
_ => Icons.fitness_center,
```

라벨은 원문 문자열을 그대로 표시(`_ => intensity`)하는 반면, 색·아이콘은 `moderate` 로 폴백합니다. 이 경우 사용자에게 "주황색 + 알 수 없는 영문 라벨" 이 노출되어 의미 충돌. 현 mock 범위에서는 발생하지 않으나, JobModel 검증 단(`fromJson`)에서 enum 화이트리스트 검사를 추가하거나, 폴백 라벨을 `'정보 없음'` 으로 통일하는 것이 안전.

---

## Spec DoD 재검증

| DoD | 결과 | 근거 |
|---|---|---|
| 카드 탭 → 상세 진입 | ✅ | Day 4 의 `context.push('/job/${jobId}')` + `app_router.dart` `/job/:jobId` 경로 |
| physicalIntensity 색·텍스트 | ✅ | `_IntensityGradeBox` 3단계 매핑 + spec §2 표와 일치 |
| physicalBadges 1개+ 표시 | ✅ | `Wrap` + 6종 매핑 |
| 하단 버튼 스크롤 시 고정 | ✅ | `Stack` + `Positioned(bottom:0)` + `SafeArea` + ScrollView bottom padding 96dp |
| 뒤로가기 복귀 | ✅ | `AppBar` 기본 leading |
| 14pt 미만 텍스트 없음 (spec_09) | ✅ | 모든 텍스트가 `AppTextStyles` 토큰 또는 `bodyBold`/`title`/`headline` 사용. 14pt 미만 없음 확인. |

---

## 양호한 부분 (Keep doing)

- spec_04 round 2 에서 합의한 `_formatSalary` 분기(시급/일급/월급) 패턴을 그대로 가져와 일관성 유지. (이상적으로는 모델 getter 로 통합되어야 하지만, 분기 로직 자체는 정확)
- `SafetyCurationSection` 이 `physicalBadges.isEmpty` 시 섹션 제목 자체를 숨김 — spec 에 명시되지 않았으나 시니어 UX 측면에서 적절한 판단.
- `jobDetailProvider = FutureProvider.family<JobModel?, String>` 선택이 깔끔. `family` 로 jobId 별 자동 캐싱.
- `Stack` + `Positioned` + `SafeArea` + ScrollView padding 96dp 조합으로 하단 버튼 고정이 안드로이드 노치/홈바 모두에서 안전.
- AppBar 의 `surfaceTintColor: Colors.transparent` 가 Material 3 기본 색조 오버레이를 제거 — 시니어 UX 시각 일관성에 도움.
- 9건의 위젯 테스트로 핵심 분기(empty badges, intensity all 3, work conditions, fixed button, null job not-found) 커버.

---

## 머지 권고

🟡 **Approve with Comments**.

본 PR 단독 머지는 가능합니다. 다만 머지 직후 또는 본 PR 추가 커밋으로 다음을 처리하는 것을 강력 권고:

1. **M-1 (지원하기 버튼 무반응)** — SnackBar 또는 onPressed: null 처리. 시니어 UX 직결.
2. **m-1 (`_formatSalary` 모델 이전)** — PR #4 의 n-1 잔존이 본 PR 에서 코드 중복으로 확대됨. 더 늦으면 spec_06/07 에서 또 복사될 위험.

m-2~m-4, n-1~n-3 은 후속 PR 가능.
