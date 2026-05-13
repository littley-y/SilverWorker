# Spec 12. 홈 화면 UI 개선 (Home UI Refinement)

> 대상: Day 14 (MVP 후반 UI 개선)
> 참조: `spec_04_job_list_ui.md`, `spec_09_ui_system.md`, `ui_mockup_home_comparison.html`
> 목표: 시니어 사용자의 가독성과 공고 카드 정보 밀도 향상, 마스코트 감성 요소 추가

---

## 1. 변경 요약

이 스펙은 MVP 이후 홈 화면(JobListScreen) 및 공고 카드(JobCard)의 UI/UX를 개선한다.
기획서 확정분을 반영하며, AI 기능 도입 전 목업 단계의 시각적 완성도를 높인다.

### 1.1 주요 변경사항

| # | 변경 영역 | 내용 | 우선순위 |
|---|---|---|---|
| 1 | 마스코트 배너 | AppBar 우측 → 화면 최상단 배너 이동. 스크롤 시 함께 날라감. 터치 시 랜덤 응원 메시지 출력. | P1 |
| 2 | 마스코트 캐릭터 | 토끼 → 강아지 에셋 교체 | P1 |
| 3 | 공고 카드 크기 | 한 화면에 2개만 보이도록 카드 및 폰트 확대 | P1 |
| 4 | 제목 문구 | "~모집" → "~" (끝의 "모집" 제거) | P1 |
| 5 | 거리 표시 | 현재 위치 기준 "도보 00분" 추가 | P1 |
| 6 | 업무 강도 표현 | 단어(가벼움/보통/무거움) → 문장("앉아서 일해요" 등). 테두리 pill 스타일. 색상: 초록(하)/주황(중)/빨강(상) | P1 |
| 7 | 카드 낮부 메타 | 구직형태·도보거리·D-day를 연회색 배경 토큰(chip)으로 한 줄 통일 배치 | P1 |
| 8 | 카드 상단 레이아웃 | 최상단 좌측: 업무 강도 token / 우측: 급여 | P1 |
| 9 | 제목 폰트 | 20pt bold → 24pt extra-bold (w800) | P1 |
| 10 | 회사명 폰트 | 16pt w600 → 17pt w400 (얇게, letter-spacing +0.2px) | P1 |

---

## 2. 마스코트 배너 (MascotBanner)

### 2.1 위치 및 동작

- `JobListScreen`의 `AppBar` 아래, `FilterBar` 위에 배치
- `Column` 내에서 스크롤 대상이므로, 스크롤 시 함께 날라감 (고정 아님)
- 배경: `AppColors.primaryLight` → `#ffffff` 그라데이션
- 패딩: 수평 16dp, 수직 20dp

### 2.2 마스코트 위젯

```dart
class MascotBanner extends StatefulWidget {
  const MascotBanner({super.key});

  @override
  State<MascotBanner> createState() => _MascotBannerState();
}
```

- 왼쪽: 마스코트 이미지 (72dp × 72dp, borderRadius 20dp)
  - 터치 시 랜덤 메시지 변경 + `HapticFeedback.lightImpact()`
  - 진입 시 `TweenAnimationBuilder` scale 0→1 (easeOutBack, 400ms)
- 오른쪽: 말풍선 (Speech Bubble)
  - 배경: 흰색, 테두리: `AppColors.primary` 1.5px
  - borderRadius: 16dp (좌하단 4dp로 꼬리 효과)
  - 그림자: `0 2px 8px rgba(21,101,192,0.08)`
  - 폰트: `AppTextStyles.body` (18pt)

### 2.3 랜덤 메시지 풀

```dart
const List<String> _greetings = [
  '좋은 하루 되세요! 오늘도 힘내세요 🐾',
  '안녕하세요! 새로운 일자리를 찾아볼까요?',
  '오늘도 멋진 하루 되세요!',
  '힘내세요! 좋은 일이 생길 거예요 💪',
  '반가워요! 무엇을 도와드릴까요?',
  '헤헤, 오늘 날씨가 참 좋네요!',
  '새로운 시작을 응원해요! 🌟',
];
```

- 초기 메시지: `_greetings[Random().nextInt(_greetings.length)]`
- 터치 시: 동일 풀에서 무작위 선택 (현재와 중복 가능)

### 2.4 에셋

- `assets/mascot/silver_dog.png` (토끼 에셋 교체)
- 에셋 미존재 시 fallback: `Icons.pets` + 연회색 배경 (기존 `MascotWidget`과 동일 패턴)

---

## 3. 공고 카드 (JobCard) 개선

### 3.1 레이아웃 재설계 (상→하)

```
JobCard (padding 16dp, margin h16/v10, radius 14dp, elevation 2)
├── Row (상단)
│   ├── IntensityPill (좌측)          // "앉아서 일해요", 테두리 pill
│   └── Salary (우측)                 // 20pt Bold, primary 색
├── SizedBox(height: 8)
├── Title                             // 24pt, FontWeight.w800
├── SizedBox(height: 4)
├── CompanyName                       // 17pt, FontWeight.w400, textSecondary
├── SizedBox(height: 10)
├── Row (하단 메타)
│   ├── GrayChip: employmentType      // "파트타임"
│   ├── GrayChip: distance            // "🚶 도보 8분"
│   └── GrayChip: deadline            // "D-3"
└── // (전체 카드가 InkWell, onTap → detail)
```

### 3.2 컴포넌트 상세

#### Title

- `AppTextStyles.title` → **24pt, `FontWeight.w800`**
- 끝의 "모집" 문자열 제거: `job.title.replaceAll(RegExp(r'모집$'), '').trim()`
- maxLines: 2, overflow: ellipsis

#### CompanyName

- `TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.2)`
- maxLines: 1, overflow: ellipsis
- **기존 `AppTextStyles.sectionTitle` 미사용** — 별도 스타일 적용

#### IntensityPill (새 위젯)

```dart
class IntensityPill extends StatelessWidget {
  final String physicalIntensity; // 'light' | 'moderate' | 'heavy'
}
```

- 표현 문장 매핑:

| `physicalIntensity` | 표현 문장 | 색상 | 배경 |
|---|---|---|---|
| `light` | `앉아서 일해요` | `#4CAF50` | `rgba(76,175,80,0.08)` |
| `moderate` | `서서 근무해요` | `#FF9800` | `rgba(255,152,0,0.08)` |
| `heavy` | `무거운 짐 있어요` | `#F44336` | `rgba(244,67,54,0.08)` |

- 스타일: `padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7)`
- borderRadius: 10dp
- border: 1.5px solid `currentColor`
- font: 14pt, `FontWeight.w700`

#### Salary

- `AppTextStyles.bodyBold` 기반, **20pt**로 확대
- color: `AppColors.primary`

#### GrayChip (새 위젯, 하단 메타 공통)

```dart
class GrayChip extends StatelessWidget {
  final String label;
  final String? icon; // optional emoji/icon prefix
}
```

- background: `AppColors.background` (`#F5F5F5`)
- border: 1px solid `AppColors.divider`
- borderRadius: 8dp
- padding: `EdgeInsets.symmetric(horizontal: 10, vertical: 6)`
- font: 13pt, `FontWeight.w500`, color: `AppColors.textSecondary`

#### Distance (목업용)

- 실제 거리 계산은 추후 GPS + 공고 주소 기반으로 구현
- 목업 단계: `JobModel`에 `int? walkingMinutes` 필드 추가
- 표시: `🚶 도보 ${walkingMinutes}분`
- `walkingMinutes == null` 시 distance chip 미표시

---

## 4. FilterBar 개선

### 4.1 슬라이드 형태

- 기존 드롭다운/선택 모달 대신 **가로 스크롤 칩 리스트**로 표현
- 양쪽 끝 `filter-pad` (16dp) 추가하여 첫/마지막 칩이 화면 중앙에 보이도록 여백 확보
- `ListView.builder` + `scrollDirection: Axis.horizontal`
- 칩 높이: 36dp, 수평 패딩 14dp, borderRadius 20dp (pill 형태)
- 선택 상태: `AppColors.primary` 배경 + 흰색 텍스트
- 미선택 상태: `AppColors.background` 배경 + `AppColors.textPrimary` 텍스트 + `AppColors.divider` 테두리
- scrollSnap: `scrollSnapType: x mandatory` (Flutter: `PageScrollPhysics` 또는 `ScrollSnapList` 고려)

### 4.2 데이터

- 지역 목록: `['전체 지역', '서울 강남구', '서울 송파구', '서울 종로구', '서울 중구', ...]`
- 직종 목록: `['전체 직종', '사무직', '판매직', '경비/관리', '청소/미화', '단순노무', '서비스']`
- 기존 `JobFilter` 모델과 호환 유지 (`locationCode`, `jobCategory`)

---

## 5. JobListScreen 레이아웃 변경

### 5.1 구조

```dart
Scaffold
├── AppBar
│   └── title: "은빛일자리" (기존과 동일)
│   └── actions: [] // 마스코트 제거
├── body: Column
│   ├── MascotBanner()              // NEW
│   ├── FilterBar(...)              // 개선
│   ├── Divider
│   └── Expanded
│       └── jobsAsync.when(...)
│           ├── data + empty → _EmptyState
│           ├── data + has items → _JobListView
│           ├── loading → _LoadingState
│           └── error → _ErrorState
```

### 5.2 빈 상태 / 로딩 상태

- 기존과 동일 (`_EmptyState`, `_LoadingState`)
- 빈 상태 마스코트: 기존 `MascotWidget(size: 100)` 유지 (토끼 에셋 → 강아지 에셋으로 교체 시 같이 변경)

---

## 6. 데이터 모델 변경

### 6.1 JobModel 확장

```dart
class JobModel {
  // ... 기존 필드들 ...

  /// 목업용: 현재 위치로부터 도보 예상 시간(분)
  /// 추후 GPS 거리 계산으로 대체
  final int? walkingMinutes;

  // 생성자, copyWith, fromJson, toJson 모두 walkingMinutes 포함
}
```

- `walkingMinutes`는 nullable — 기존 데이터와 하위 호환 유지
- `JobCard`에서 `null`이면 distance chip 미표시

---

## 7. 완료 기준 (DoD)

- [ ] 마스코트 배너가 화면 최상단에 표시되고, 스크롤 시 함께 날라감
- [ ] 마스코트 터치 시 랜덤 메시지가 변경됨
- [ ] 공고 카드가 한 화면에 2개만 보임 (카드 높이/폰트 확대 확인)
- [ ] 공고 제목에서 "모집" 문구가 제거됨
- [ ] 카드 상단에 업무 강도 pill이 표시됨 (문장 형태, 테두리 스타일)
- [ ] 카드 하단에 구직형태·도보거리·D-day가 연회색 chip으로 한 줄 배치됨
- [ ] 제목 폰트가 24pt 이상, 회사명은 얇은 폰트(400)로 표시됨
- [ ] 필터바가 가로 슬라이드 칩 형태로 동작함
- [ ] `flutter analyze` 0경고, `flutter test` 기존 테스트 전부 통과
- [ ] 신규/변경 위젯에 대한 단위 테스트 추가

---

## 8. 변경 파일 목록

| 파일 | 변경 유형 | 내용 |
|---|---|---|
| `lib/widgets/job_card.dart` | 수정 | 전체 레이아웃 재설계, IntensityPill/GrayChip 추가, 제목 "모집" 제거 |
| `lib/widgets/mascot_banner.dart` | 신규 | 최상단 배너, 강아지 에셋, 랜덤 메시지, 터치 반응 |
| `lib/widgets/filter_bar.dart` | 수정 | 슬라이드 칩 형태로 UI 변경, 선택 상태 스타일 변경 |
| `lib/screens/job/job_list_screen.dart` | 수정 | MascotBanner 추가, AppBar actions에서 마스코트 제거 |
| `lib/models/job_model.dart` | 수정 | `walkingMinutes` 필드 추가, fromJson/toJson/copyWith 업데이트 |
| `lib/models/job_model.g.dart` | 자동생성 | `build_runner` 재실행 시 생성 (freezed/json_serializable 사용 시) |
| `test/widgets/job_card_test.dart` | 수정 | 변경된 레이아웃/스타일에 맞게 테스트 업데이트 |
| `test/widgets/mascot_banner_test.dart` | 신규 | 메시지 변경, 터치, 애니메이션 테스트 |
| `test/models/job_model_test.dart` | 수정 | `walkingMinutes` 직렬화/역직렬화 테스트 추가 |
| `assets/mascot/silver_dog.png` | 에셋 추가 | 강아지 마스코트 이미지 (에셋 미제공 시 fallback 유지) |

---

## 9. 리스크 및 대응

| 리스크 | 영향 | 대응 |
|---|---|---|
| 강아지 에셋 미제공 | 마스코트 fallback 아이콘 사용 | `Icons.pets` fallback 유지, 에셋 추가 시 자동 적용 |
| 24pt 제목이 2줄 이상 차지 | 카드 높이 불균형 | maxLines: 2 유지, ellipsis 처리. Galaxy S10+ 기준 테스트 |
| walkingMinutes 목업 데이터 불일치 | 거리 chip 미표시 | `seed_jobs.py`에 `walkingMinutes` 추가 또는 `null` 허용 |
| FilterBar 슬라이드 UX 불편 | 사용자 필터 선택 어려움 | `ScrollPhysics` 튜닝, 칩 크기 36dp 이상 보장 |
| 한 화면 2개 카드 → 빈 공간 과다 | 시각적 낭비 | 카드 minHeight 140dp 이상 설정, 간격 10dp로 조정 |
