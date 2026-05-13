# Spec 05. 공고 상세 및 세이프티 큐레이션

> 대상 Day: Day 5
> 참조: `overview/03_mvp_specs.md` JOB-05, SAFE-01~02

---

## 1. 화면 구성

```
JobDetailScreen
├── AppBar: 뒤로가기 버튼 + "공고 상세"
├── ScrollView
│   ├── 헤더 영역: 공고 제목(모집 제거), 회사명, 급여
│   ├── 정보 카드 그리드 (2x2)
│   │   ├── 근무시간 카드
│   │   ├── 근무기간 카드
│   │   ├── 근무요일 카드
│   │   └── 고용형태 카드
│   ├── 업무 세부 내용 카드 (가로)
│   ├── 자격 요건 카드 (가로)
│   └── 업무 강도 상세 카드 (가로)
│       ├── 서있는 시간
│       ├── 무거운 짐
│       └── 실내 / 외
└── BottomBar: "지원하기" or "지원 취소" 버튼 (고정)
```

---

## 2. 헤더 영역

- **공고 제목**: `job.displayTitle` 사용 (끝의 "모집" 자동 제거)
- **회사명**: `companyName` (가상의 실제 회사명, underscore 없음)
- **급여**: `formattedSalary` (월/시급/일급 자동 변환)

---

## 3. 정보 카드 그리드 (2x2)

4개의 소형 카드를 2열 그리드로 배치:

| 위치 | 라벨 | 값 |
|---|---|---|
| 좌상 | 근무시간 | `workHoursPerDay`시간 (또는 `workHours`) |
| 우상 | 근무기간 | `workPeriod` |
| 좌하 | 근무요일 | `workDays` |
| 우하 | 고용형태 | `employmentTypeLabel` |

카드 스펙:
- 배경: `AppColors.cardBackground`
- 둥근 모서리: 12dp
- 그림자: `AppColors.cardShadow`
- 아이콘 + 라벨 (caption) + 값 (bodyBold)

---

## 4. 업무 세부 내용 카드

- 가로로 긴 카드 (전체 폭)
- 아이콘: `Icons.description_outlined`
- 제목: "업무 세부 내용"
- 내용: `description` (빈 값 시 "정보 없음")

---

## 5. 자격 요건 카드

- 가로로 긴 카드 (전체 폭)
- 아이콘: `Icons.verified_outlined`
- 제목: "자격 요건"
- 내용: `requirements` (빈 값 시 "정보 없음")

---

## 6. 업무 강도 상세 카드

physicalBadges를 기반으로 3가지 항목을 문장으로 표현:

| 항목 | 아이콘 | 값 규칙 |
|---|---|---|
| 서있는 시간 | `accessibility_new` | `standing` → "계속 서있기", `sitting` → "좌식 업무", else → "보통" |
| 무거운 짐 | `inventory_2` | `heavy_lifting` → "있음", else → "없음" |
| 실내 / 외 | `home` | `outdoor` → "야외 근무", else → "실내 위주" |

복리후생 섹션은 제거됨.

---

## 7. 하단 고정 버튼

### 지원하기 (미지원 상태)
- 높이: 56dp
- 배경: `AppColors.primary` (파랑)
- 텍스트: "지원하기" 20pt Bold 흰색
- 탭 → ApplicationFormScreen으로 이동 (spec_06)

### 지원 취소 (이미 지원한 상태)
- 높이: 56dp
- 배경: `AppColors.error` (빨강)
- 텍스트: "지원 취소" 20pt Bold 흰색
- 탭 → 확인 다이얼로그 → `cancelApplication()` 호출 → 상태 'cancelled'로 업데이트

`SafeArea` 로 감싸서 하단 노치/홈바 영역 침범 방지.

---

## 8. 완료 기준 (Day 5 DoD)

- [ ] 공고 목록에서 카드 탭 → 상세 화면 진입 확인
- [ ] 제목에서 "모집"이 제거되어 표시됨
- [ ] 2x2 정보 카드 그리드가 정상 표시됨
- [ ] 업무 세부 내용 / 자격 요건 카드가 가로로 표시됨
- [ ] 업무 강도 상세 카드에 서있는시간/무거운짐/실내외 표시됨
- [ ] 하단 버튼이 스크롤필도 고정되어 있음
- [ ] 뒤로가기 버튼으로 목록 복귀 확인
