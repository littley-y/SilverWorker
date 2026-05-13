---
title: SilverWorkerNow — 전체 아키텍처/코드베이스 리뷰
date: 2026-05-10
reviewer: Claude (Opus 4.7)
scope: lib/ 전체 (35 files, 2,275 LOC) + graphify graph (431 nodes / 22 communities)
basis: graphify-out/GRAPH_REPORT.md + 직접 파일 읽기
---

## 0. 요약

| 항목 | 평가 |
|---|---|
| 레이어 분리 (screens/providers/repositories/models) | ✅ 명확 |
| Riverpod DI 일관성 | ⚠️ 부분 (auth만 watch 패턴 불일치) |
| Firestore 추상화 | ✅ Repository 계층에서 캡슐화 |
| 도메인 enum 정합성 | ⚠️ `physicalBadges` 도메인 드리프트 |
| 테스트 커버리지 | ✅ 모델/리포지토리/위젯 84개 |
| 코드 중복 | ⚠️ intensity 매핑 3곳, 에러 화면 4곳 |
| Dead code | ⚠️ Bookmark 모듈 전체 미연결 |

**Blocker 0 / Major 3 / Minor 5**

---

## 1. 그래프 구조 분석

### 1.1 God Nodes (정상)
1. `package:flutter/material.dart` (28 edges)
2. `package:flutter_riverpod/flutter_riverpod.dart` (22)
3. `../constants/app_colors.dart` (15) — 컬러 시스템 단일화 ✅
4. `../constants/app_text_styles.dart` (15) — 타이포 단일화 ✅
5. `../../router/app_router.dart` (9) — 라우트 진입점 단일화 ✅

→ 인프라/디자인 토큰이 god node로 잡힘. 도메인 모듈(JobRepository, AuthRepository)이 god node에 들어가 있지 않음 = **건강한 의존성 분포**.

### 1.2 Community 분포

| ID | 노드 | 응집도 | 의미 |
|---|---|---|---|
| 0 | 41 | 0.05 | OTP/Auth 화면 + AddressData ⚠️ 응집도 낮음, 분할 후보 |
| 1 | 36 | 0.06 | 디자인 토큰 + snack utils + 칩 위젯 |
| 2 | 30 | 0.07 | 모델 테스트 클러스터 |
| 4 | 22 | 0.08 | **Repositories + Exceptions** (`AuthRepository`, `ApplicationRepository`, `_mapAuthError`, 4 Exception 타입) — 도메인 핵심 ✅ |
| 6 | 27 | 0.07 | Application 화면 + 라우트 빌더 (`applyRoute`, `applyDoneRoute`, `_AuthRefresh`) |
| 8 | 22 | 0.07 | JobRepository + Job 화면 상태 위젯 |
| 11 | 14 | 0.12 | ApplicationList 화면 cluster |
| 12 | 11 | 0.13 | **모델 (JobModel, UserModel, BookmarkModel, copyWith)** |
| 19 | 3 | 0.67 | JobFilter (sentinel pattern 단독) |
| 22 | 1 | 1.0 | MainActivity (Android 단독) |

**해석**: 모델/리포지토리/Exception이 명확히 클러스터로 잡힘 — DDD 친화적 구조. Community 0의 응집도 0.05는 OTP 화면이 dispose/build/initState/_distributeDigits 등 위젯 라이프사이클 노드로 부풀려진 것 — 실제 문제 없음.

### 1.3 Knowledge Gap
- 277 isolated nodes 중 대부분이 `tools/scripts/*.py` 훅 함수 — 코드 자체는 문제 없으나 그래프상 외딴섬.
- `Community 23` (`logger`) — `app_logger.dart`만 사용. 로깅 표준화는 잘 되어 있음.

---

## 2. Major 이슈

### M-1. `MainShell` / `MyPageScreen` / `ApplicationListScreen`이 인증 상태 변화에 안 반응

**위치**:
- `lib/screens/main/main_shell.dart:42` — `ref.watch(authRepositoryProvider).currentUser`
- `lib/screens/mypage/my_page_screen.dart:19` — 동일 패턴
- `lib/screens/mypage/application_list_screen.dart:15` — 동일 패턴

```dart
final user = ref.watch(authRepositoryProvider).currentUser;
```

**문제**: `authRepositoryProvider`는 `Provider<AuthRepository>` (싱글턴) 이므로 watch해도 인스턴스는 영원히 동일. `currentUser`는 `FirebaseAuth.instance.currentUser`의 동기 스냅샷이라 **로그인/로그아웃 시 리빌드가 트리거되지 않음**.

현재 동작하는 이유: GoRouter `redirect`가 `_AuthRefresh`(`router/app_router.dart:42`)로 별도 구독 → 인증 변경 시 `redirect` 재실행 → 라우트 자체가 바뀌어 위젯이 unmount/mount. 즉 **우연히 동작**.

만약 같은 라우트(`/home`)에 머무르는 동안 토큰 만료 등으로 `currentUser`가 null이 되면 화면이 멍하게 남음.

**권장**:
```dart
final authState = ref.watch(authStateProvider); // StreamProvider — 이미 정의됨
final user = authState.value;
```

`auth_provider.dart:21`에 이미 `authStateProvider`가 있는데 `MainShell` 등에서 사용 안 함. 일관성 + 정확성 둘 다 해결.

---

### M-2. `physicalBadges` 도메인 enum 드리프트 (3-way 불일치)

| 소스 | 정의된 값 |
|---|---|
| `safety_curation_section.dart:93-101` (UI 렌더링) | `standing, sitting, heavy_lifting, outdoor, repetitive, stairs` |
| `test/models/physical_badge_test.dart` ("all 6 known") | `standing, outdoor, lifting, bending, walking, sitting` |
| `JobModel.physicalBadges` 주석 (`models/job_model.dart:31`) | `["standing", "outdoor"]` 예시만 |

**문제**: 테스트가 "6 known badge types"라며 검증하는 `lifting / bending / walking`은 UI 스위치에 없음 → 실제 데이터로 들어와도 라벨 매핑 실패해 raw 영문이 그대로 표시되거나 `Icons.info_outline` 폴백.

뒤집어 말하면, UI가 처리하는 `heavy_lifting / repetitive / stairs`는 테스트에서 검증 안 됨.

**권장**:
1. `lib/models/physical_badge.dart`에 enum 또는 `abstract final class PhysicalBadge` 단일 정의를 두고
2. UI / fixture / 테스트가 같은 상수를 참조하도록 통일
3. `safety_curation_section.dart`의 `_label`/`_icon`도 enum 기반 매핑으로

이 항목은 **데모 시연(spec_10 §4 체크리스트)에서 "세이프티 배지 확인"이 raw 영문 표시로 깨질 수 있는 실 위험**.

---

### M-3. Bookmark 모듈 전체가 dead code

- `lib/models/bookmark_model.dart` (51 LOC)
- `lib/repositories/bookmark_repository.dart` (44 LOC)
- `lib/providers/bookmark_provider.dart` (14 LOC)

`my_page_screen.dart:225-228`의 "찜한 공고" 메뉴는 빈 `onTap: () { /* 추후 구현 */ }`. 호출 사이트 0개.

**판단**:
- 후속 spec에서 사용 예정이면 `// TODO(spec_XX)`로 명시 + 로드맵 문서에 기재
- MVP 데모 범위 외라면 **삭제 후 필요 시점에 부활** (CLAUDE.md "no premature abstraction" 원칙)

현재처럼 표면만 노출하면 코드 인덱스/리뷰/번들에 부담만 누적.

---

## 3. Minor 이슈

### m-1. Intensity 매핑이 3곳에 중복
- `JobModel.physicalIntensityLabel` (`job_model.dart:203`)
- `safety_curation_section._IntensityGradeBox` (`safety_curation_section.dart:45-64`)
- `job_card._IntensityBadge` (`job_card.dart:127-139`)

라벨/색/아이콘 3종을 한 헬퍼로 묶을 여지. 예: `IntensityViewModel.from(String)` → `(label, color, icon)`.

### m-2. 에러 상태 화면 4중복
`my_page_screen`, `main_shell`, `job_list_screen._ErrorState`, `job_detail_screen` 모두 "아이콘 + 메시지 + 다시 시도 버튼" 구조를 직접 작성. `widgets/error_retry_view.dart` 추출 권장.

### m-3. `ApplicationFormScreen._submit`의 `finally` 내 `Future.delayed(1500ms)` (`application_form_screen.dart:77`)
성공해 navigate한 후에도 1.5초간 로딩 유지 → mounted 가드로 안전하지만 의도가 코드만으로 안 보임. 주석 한 줄 권장: `// anti-double-tap throttle`.

### m-4. `MainShell._buildScaffold` `addPostFrameCallback` 리다이렉트 (`main_shell.dart:46-49, 58-60`)
앤티패턴. 이미 `routerProvider`의 `redirect`가 이 책임을 갖고 있어 중복 가드. profile null 케이스만 router redirect에 추가하면 두 군데 다 제거 가능.

### m-5. `ApplicationModel.applicationId` 미설정
`submitApplication`(`application_repository.dart:74-82`)이 `applicationId` 필드를 쓰지 않음. `fetchApplications` 결과는 `applicationId: ''`로 채워짐. 의도가 "doc id == jobId == applicationId" 라면 toJson 또는 fromJson에서 doc id 주입을 명시.

---

## 4. 잘 된 점 (유지 권장)

1. **`JobFilter` sentinel 패턴** (`job_filter.dart:8`) — null vs 미변경 구분이 정확. 회귀 테스트도 존재.
2. **`TimestampHelper`** (`utils/timestamp_helper.dart`) — Firestore Timestamp/String 양방향 처리를 한 곳에서. 모델 5개가 모두 이 헬퍼 통과 → 일관성.
3. **`AppRoutes` builder 패턴** (`router/app_router.dart:34-36`) — `applyRoute(jobId)` 같은 빌더로 하드코딩 방지.
4. **Repository 생성자 DI** (`firestore`, `auth` 옵셔널) — 테스트 친화. spec_10 PR로 `ApplicationRepository`까지 통일됨.
5. **`PrimaryButton`** — 56dp/12dp 라운드 단일화. 시니어 UX(spec_10 T-UI-02) 보장 지점.
6. **`AppRoutes`/`AppColors`/`AppTextStyles`** 3대 god node — 토큰 단일 소스.

---

## 5. 권장 후속 작업 (우선순위)

| 우선순위 | 작업 | 영향 |
|---|---|---|
| P0 | M-2: `physicalBadges` enum 정합 | 데모 시연 시 텍스트 깨짐 방지 |
| P1 | M-1: `authStateProvider` 일관 사용 | 토큰 만료/외부 로그아웃 시 안정성 |
| P1 | M-3: Bookmark dead code 결정(삭제 or TODO 명시) | 코드베이스 신호 명확화 |
| P2 | m-1, m-2 중복 추출 | 유지보수성 |
| P3 | m-3, m-4, m-5 정리 | 코드 의도 명확화 |

---

## 6. 결론

레이어링과 디자인 토큰 단일화가 잘 되어 있어 **MVP 기준 합격선**. 그래프상 god node도 인프라/토큰만 잡혀 도메인 의존이 깨끗.

다만 **M-2(badge 드리프트)는 데모 차단 위험**이 있으므로 spec_10 완료 직후 패치 권장. M-1(auth watch 패턴)과 M-3(bookmark dead code)는 다음 spec 진입 전에 정리하면 부채가 누적되지 않음.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
