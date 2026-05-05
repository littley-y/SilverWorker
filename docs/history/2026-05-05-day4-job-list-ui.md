# Session History — 2026-05-05 Day 4: 공고 목록 UI 구현

## 개요
- **구현자**: OpenCode (Sisyphus)
- **작업 범위**: spec_04 (공고 목록 UI) + spec_09 (시니어 UI 시스템 기반)
- **브랜치**: `feature/day4-job-list-ui`
- **CI 결과**: `verify_local.sh` 6/6 통과, `flutter test` 26/26 통과

## 작업 내용

### 1. UI 시스템 정렬 (spec_09)
- `AppTextStyles`: caption 16→14pt, button 18→20pt, sectionTitle 16pt 신규
- `AppColors`: textSecondary 616161→757575, background FFFFFF→F5F5F5, divider/cardBackground/intensity/status 색상 신규
- `AppColors.surface` → `AppColors.background` 마이그레이션 (auth screen 3개)

### 2. FilterBar 위젯 신규
- 지역 칩 4종 (전체, 종로구, 중구, 용산구)
- 직종 칩 6종 (전체, 경비/관리, 청소/미화, 단순노무, 서비스, 사무/문서)
- 단일 선택, 재탭 해제, 수평 스크롤
- `jobFilterProvider` 연동 → `jobListProvider` 자동 재조회

### 3. JobCard 위젯 구현
- 제목(20pt bold), 회사명(16pt gray), 급여(18pt bold primary)
- 고용형태 칩(파트타임/일용직/단기/정규직), D-n 마감일, 강도 배지(가벼움/보통/힘듦)
- 16dp 패딩, 12dp 라운드, elevation 2, 최소 88dp 높이
- 전체 카드 InkWell, 탭 → `/job/:jobId`

### 4. JobListScreen 구현
- AppBar "은빛일자리"
- FilterBar + Divider
- ListView.builder (JobCard)
- 로딩: 스켈레톤 카드 3개 (회색 블록, shimmer 없음)
- 에러: 아이콘 + "공고를 불러올 수 없습니다" + 재시도 버튼
- 빈 상태: 아이콘 + "해당 조건의 공고가 없습니다" + 필터 초기화 버튼

### 5. 라우팅 버그 수정
- `main.dart`: `MaterialApp(home:)` → `MaterialApp.router(routerConfig:)`로 수정
- `app_router.dart`: `/job/:jobId` 라우트 추가
- `JobDetailScreen`: jobId 파라미터 수용 (Day 5용 placeholder)

### 6. 테스트
- `test/widgets/job_card_test.dart`: 8종 (렌더링, 급여포맷, 고용칩, D-n, 상시/마감, 탭)
- `test/widgets/filter_bar_test.dart`: 7종 (렌더링, 선택/해제, 색상)

## 발견된 이슈
- `JobFilter.copyWith`: nullable 필드를 null로 설정 불가 (`??` 연산자 한계). FilterBar에서 직접 JobFilter 생성으로 우회. copyWith 자체는 다른 곳에서 정상 동작하므로 수정 보류.
- `JobModel.copyWith`: 동일한 nullable 필드 null 설정 불가 이슈 있음. 테스트에서 직접 생성자 사용으로 우회.

## 다음 작업
- PR #4 리뷰 후 Day 5 (spec_05: 공고 상세 + 세이프티 배지)
