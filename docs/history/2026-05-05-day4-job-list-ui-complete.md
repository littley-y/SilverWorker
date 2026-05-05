# Session History — 2026-05-05 Day 4: 공고 목록 UI (완료)

## 개요
- **구현자**: OpenCode (Sisyphus)
- **리뷰어**: Claude, Gemini
- **작업 범위**: spec_04 (공고 목록 UI) + spec_09 (시니어 UI 시스템 기반)
- **브랜치**: `feature/day4-job-list-ui`
- **PR**: [#4](https://github.com/littley-y/SilverWorker/pull/4)
- **최종 CI**: `flutter analyze` 0 issues, `flutter test` 33/33 passed

---

## 타임라인

| 시간 | 이벤트 |
|---|---|
| 15:00 | 브랜치 생성, 작업 시작 |
| 15:15 | 초기 구현 완료, PR #4 생성 |
| 15:30 | Claude 1차 리뷰 (Request Changes) |
| 15:30 | Gemini 1차 리뷰 (Approved) |
| 16:00 | Claude Blocker/Major 수정 (fc59d48) |
| 16:15 | Claude 2차 리뷰 (Approve) |
| 16:15 | Gemini 2차 리뷰 (Final Approved) |
| 16:20 | PR #4 master 머지 완료 |

---

## 구현 내용

### 1. UI 시스템 정렬 (spec_09 기반)
- `AppTextStyles`: caption 14pt, button 20pt, sectionTitle 16pt, headline 24pt
- `AppColors`: WCAG AA 대비율 충족 컬러 팔레트 (primary, textPrimary/Secondary, background/cardBackground, divider, skeleton, intensity/status)
- `AppColors.surface` → `AppColors.background` 마이그레이션 (auth screen 3개)

### 2. FilterBar (`lib/widgets/filter_bar.dart`)
- 지역 칩 4종 (전체, 종로구, 중구, 용산구)
- 직종 칩 6종 (전체, 경비/관리, 청소/미화, 단순노무, 서비스, 사무/문서)
- 수평 스크롤, 단일 선택, 재탭 해제
- `jobFilterProvider` 연동 → `jobListProvider` 자동 재조회

### 3. JobCard (`lib/widgets/job_card.dart`)
- 제목(20pt bold), 회사명(16pt), 급여(18pt bold primary) — 시급/일급 정확 표시
- 고용형태 칩 (파트타임/일용직/단기/정규직), D-n 마감일, 강도 배지 (가벼움/보통/힘듦)
- 16dp 패딩, 12dp 라운드, elevation 2, 최소 88dp 높이
- 전체 카드 InkWell, 탭 → `/job/:jobId`

### 4. JobListScreen (`lib/screens/job/job_list_screen.dart`)
- AppBar "은빛일자리" (toolbarHeight 64dp)
- FilterBar + Divider
- ListView.builder (JobCard)
- 로딩: 스켈레톤 카드 3개 (#CCCCCC, shimmer 없음)
- 에러: 아이콘 + "공고를 불러올 수 없습니다" + 재시도 버튼
- 빈 상태: 아이콘 + "해당 조건의 공고가 없습니다" + 필터 초기화 버튼

### 5. 라우팅 버그 수정
- `main.dart`: `MaterialApp(home:)` → `MaterialApp.router(routerConfig:)` (GoRouter 연결 누락 수정)
- `app_router.dart`: `/job/:jobId` 라우트 추가
- `JobDetailScreen`: jobId 파라미터 수용 (Day 5 placeholder)

### 6. JobFilter.copyWith 개선
- sentinel 패턴 (`_unset`) 도입으로 nullable 필드 명시적 null 설정 가능
- FilterBar에서 직접 생성자 우회 제거 → `copyWith` 호출로 정리

---

## 리뷰 피드백 및 수정

### Claude 1차 (Request Changes)

| ID | 등급 | 내용 | 수정 |
|---|---|---|---|
| B-1 | 🔴 Blocker | 시급/일급 금액 손실 (12,000원 → "시 1만원") | `NumberFormat` 도입, 시급/일급/월급 분기 처리 |
| M-1 | 🟠 Major | 칩/배지 12pt → spec_09 14pt 하한 위반 | `AppTextStyles.caption` (14pt) 통일, 패딩 보정 |
| M-2 | 🟠 Major | `JobFilter.copyWith` null 설정 불가 | sentinel 패턴 도입 |
| m-1 | 🟡 Minor | AppBar headline 클리핑 | `toolbarHeight: 64` |
| m-2 | 🟡 Minor | 스켈레톤 색상 옅음 | `AppColors.skeleton` (#CCCCCC) |
| n-2 | 🟢 Nit | JobListScreen 상태 테스트 부재 | 5건 추가 (empty/error/data/appbar/filterbar) |

### Gemini 1차 (Approved)
- M-1 (copyWith 개선 권장) → M-2 수정으로 해결
- N-1 (skeleton shimmer) → 후속 고려

### 공통 승인 (2차)
- Claude: 🟢 Approve — "1차 리뷰 모든 Blocker/Major 해결, 머지 가능"
- Gemini: ✅ Final Approved — "모든 결함 수정, 완성도 매우 높음"

---

## 테스트 커버리지

| 파일 | 건수 | 내용 |
|---|---|---|
| `test/models/job_model_test.dart` | 3 | JobModel.fromJson (기존) |
| `test/models/user_model_test.dart` | 3 | UserModel (기존) |
| `test/constants/address_data_test.dart` | 5 | AddressData (기존) |
| `test/widgets/job_card_test.dart` | 10 | JobCard 렌더링, 급여(월/시/일), 고용칩, D-n, 상시/마감, 탭 |
| `test/widgets/filter_bar_test.dart` | 7 | FilterBar 렌더링, 선택/해제, 색상 |
| `test/widgets/job_list_screen_test.dart` | 5 | JobListScreen empty/error/data/appbar/filterbar |
| **합계** | **33** | 전부 통과 |

---

## 발견 및 해결된 이슈
1. `main.dart` GoRouter 미연결 — `MaterialApp.router()`로 수정
2. `JobFilter.copyWith` nullable null 설정 불가 — sentinel 패턴
3. 시급/일급 `_formatSalary` 금액 손실 — `NumberFormat` 분기
4. spec_04 표(12pt) vs spec_09 하한(14pt) 충돌 — spec_09 우선 적용

---

## 다음 작업
- **Day 5**: spec_05 (공고 상세 + 세이프티 배지)
- **Day 11**: spec_09 마무리 (NotoSansKR 폰트, 햅틱 피드백, 공통 위젯)
