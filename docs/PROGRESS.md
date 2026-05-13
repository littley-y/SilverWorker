# PROGRESS — SilverWorkerNow 개발 현황

> 최종 업데이트: 2026-05-14
> 전체 목표: 2주 데모 (Day 1 ~ Day 14) + 2차 AI 기능 (spec_13~17)
> 참조 스펙: `docs/planning/spec_01~17.md`

---

## 현재 단계: Day 14 완료 — 2차 AI 기능 기획 확정 (spec_13~17)

---

## 스펙별 진행 상황

| Spec | 제목 | 상태 | 대상 Day | 비고 |
|---|---|---|---|---|
| [spec_01](planning/spec_01_project_setup.md) | 프로젝트 초기 세팅 | ✅ 완료 | Day 1 | PR #1 수정 완(2차 리뷰 승인) |
| [spec_02](planning/spec_02_auth.md) | 인증 및 프로필 등록 | ✅ 완료 | Day 2 | PR #2 머지 완 (Claude/Gemini 승인) |
| [spec_03](planning/spec_03_job_data.md) | 공고 데이터 준비 | ✅ 완료 | Day 3 | 경로 A: Mock 30개 Firestore 등록 (PR #3 머지 완 - Claude/Gemini 승인) |
| [spec_04](planning/spec_04_job_list_ui.md) | 공고 목록 UI | ✅ 완료 | Day 4 | PR #4 — Claude/Gemini 모두 승인 (Claude round 2 fc59d48: B-1·M-1·M-2 해결). 머지 가능. |
| [spec_05](planning/spec_05_job_detail.md) | 공고 상세 + 세이프티 배지 | ✅ 완료 | Day 5 | PR #5 머지 완 (Claude/Gemini 승인) |
| [spec_06](planning/spec_06_application.md) | 지원 기능 | ✅ 완료 | Day 8 | PR #6 머지 완 (Claude/Gemini 승인, round 3) |
| [spec_07](planning/spec_07_mypage.md) | 마이페이지 | ✅ 완료 | Day 9 | PR #7 머지 완 (Claude Round 2 / Gemini 승인)
| [spec_08](planning/spec_08_navigation.md) | 네비게이션 | ✅ 완료 | Day 10 | PR #9 머지 완 (Claude/Gemini 승인). ShellRoute + BottomNav 3탭, auth redirect, PopScope |
| [spec_09](planning/spec_09_ui_system.md) | 시니어 UI 시스템 | ✅ 완료 | Day 4, 11 | PR #8 머지 완 (Claude Round 3 / Gemini 승인). AppTextStyles/AppColors 정렬, PrimaryButton/SnackUtils 공통 위젯화 |
| [spec_10](planning/spec_10_test_criteria.md) | 테스트 기준 + DoD | ✅ 완료 | Day 12 | |
| [spec_11](planning/spec_11_senior_ui_enhancement.md) | 시니어 특화 UI/UX 고도화 | ✅ 완료 | Day 13 | PR #10 머지 완 (Claude/Gemini 승인). 113/113 테스트 통과. |
| [spec_12](planning/spec_12_home_ui_refinement.md) | 홈 화면 UI 개선 | ✅ 완료 | Day 14 | PR #11 머지 완 (Claude/Gemini 승인). 122/122 테스트 통과. |
| [spec_13](planning/spec_13_review_system.md) | 리뷰 시스템 | ⬜ 대기 | 2차 | 리뷰 CRUD + 별점/평점. Firestore 직접 접근. |
| [spec_14](planning/spec_14_ai_review_summary.md) | AI 리뷰 자동 요약 | ⬜ 대기 | 2차 | Gemini 2.5 Flash + 캐시. spec_13 선행 필요. |
| [spec_15](planning/spec_15_career_agent.md) | 대화형 커리어 에이전트 | ⬜ 대기 | 2차 | STT + LLM 이력서 변환. 가장 임팩트 높음. |
| [spec_16](planning/spec_16_liveness_attendance.md) | 안면 확인 출근 인증 | ⬜ 대기 | 2차 | ML Kit(MVP) → AWS Rekognition(운영). 유료 전환 시 도입 권장. |
| [spec_13a](planning/overview/05_ai_feature_analysis.md) | AI 기능 기술 분석 | ✅ 완료 | — | 기술 스택 확정, 비용 분석, 구현 우선순위. |

**상태 범례**: ✅ 완료 / 🔄 진행 중 / ⛔ 블로커 / ⬜ 대기

---

## 현재 블로커

없음

---

## 알려진 리스크

| 리스크 | 영향 Spec | 대응 |
|---|---|---|
| 고용24 API 키 미발급 | spec_03 | ✅ Mock 데이터 30개로 대응 완료 (경로 A). API 키 발급 시 경로 B(Cloud Functions)로 전환 가능. |
| Firebase Phone Auth SMS 지연 | spec_02 | Firebase 테스트 번호 사용 |

---

## 완료 이력

- **2026-04-25** — Day 1 (spec_01) 완료: PR #1 머지. Firebase 의존성 추가, lib/ 디렉토리 구조 및 골격 코드 생성, firestore.rules 작성, `flutter analyze` 0경고 확인. Claude/Gemini 2차 리뷰 승인.
- **2026-04-25** — Firebase Console 연동 완료: 프로젝트 생성, Android 앱 등록(`com.silverworkernow.app`), Phone Auth 활성화, 테스트 번호 등록, Firestore DB 생성 + rules 배포, `flutterfire configure`, `main.dart` 정리. `flutter analyze` 0경고.
- **2026-04-25** — Claude/Gemini post-merge review 완료. BLOCKER(`firestore.rules` OPEN ACCESS) 수정: spec_01 §5 / 04_db_schema §3 규칙 복원 후 재배포(`60a20a7`).
- **2026-04-25** — Graphify 지식 그래프 구축 완료: 147 nodes, 139 edges, 29 communities. 3플랫폼(Claude Code, OpenCode, Gemini CLI) always-on hooks 설치, Git post-commit auto-rebuild hooks, GitHub Pages workflow (with auto-rebuild step), docs/ 위키 설정. Claude/Gemini post-setup review 완료: M-1~M-5, N-4, Gemini-2.2~2.3 수정 반영. `google-services.json` commit 유지 + GCP API key restriction 권장. 히스토리: `docs/history/2026-04-25-graphify-setup.md`.
- **2026-04-27** — 모노레포 통합 완료: `General/` 폴더와 4개 빈 worktree(`_dev`, `_design`, `_devops`, `_qa`) 제거. 모든 프로젝트 자산(docs, tools, `.claude/`, `.gemini/`, `.opencode/`, `graphify-out/`)을 `SilverWorkerNow/`로 통합 후, git repo를 `Projects/SilverWorker/` 루트로 이동. `tools/scripts/intercept_git.py`, `hook_pre_git.py`, `hook_session_start.py` 경로 수정. `.gitignore`에 `node_modules/`, `.venv/`, `.obsidian/` 추가. 전역 `~/.claude/settings.json` PostToolUse hook 제거. Claude/Gemini 리뷰 완료. 히스토리: `docs/history/2026-04-27-monorepo-consolidation.md`.
- **2026-04-28** — Day 2 (spec_02) PR #2 머지 완료: Firebase Phone Auth 흐름 구현. go_router 기반 라우팅, PhoneInputScreen, OtpInputScreen, ProfileSetupScreen. Claude/Gemini 3차 리뷰 승인 후 master 머지. AGENTS.md 규칙 업데이트: 최종 리뷰 승인 시 master 직접 푸시 허용. 히스토리: docs/history/2026-04-28-day2-auth.md.
- **2026-04-30** — Day 3 (spec_03) 경로 A 완료: 고용24 API 키 미발급으로 Mock 데이터 30개 Firestore `/jobs` 컬렉션에 등록 (`tools/scripts/seed_jobs.py` + Firebase Admin SDK). `JobRepository.fetchJobs()` Firestore 연동 구현. Firestore 복합 인덱스 4종 배포. `firestore.rules`에 serviceAccount.json, seed_jobs.json gitignore 추가. `flutter analyze` 0경고, `flutter test` 8/8 통과. 향후 API 키 발급 시 경로 B(Cloud Functions 프록시) 추가 가능.
- **2026-05-01** — Day 3 (spec_03) PR #3 머지 완료: Claude/Gemini 1차 리뷰 Blocker 2건(B-1 jobId 유실, M-1 복합 인덱스 누락) 수정 반영. `test/models/job_model_test.dart` 회귀 테스트 3건 추가. Claude/Gemini 2차 리뷰 승인 후 master 머지. `flutter test` 11/11 통과.
- **2026-05-05** — Day 4 (spec_04) PR #4 머지 완료: 공고 목록 UI (JobCard, FilterBar, JobListScreen). AppTextStyles/AppColors spec_09 정렬. `main.dart` GoRouter 버그 수정. Claude 1차 리뷰 Blocker 1건(B-1 시급/일급 표시 버그), Major 2건(M-1 폰트 하한, M-2 copyWith null) 수정 반영. Claude/Gemini 2차 리뷰 승인 후 master 머지. `flutter test` 33/33 통과 (신규 위젯 테스트 22건).
- **2026-05-05** — Day 5 (spec_05) PR #5 머지 완료: 공고 상세 화면 (SafetyCurationSection, JobDetailScreen). physicalIntensity 3단계 컬러 등급 + physicalBadges 6종 배지. 하단 고정 지원하기 버튼. `JobModel.formattedSalary` getter로 중복 제거. Claude 1차 리뷰 Major 1건(M-1 버튼 무반응), Minor 4건(m-1~m-4) 수정 반영. Claude/Gemini 2차 리뷰 승인 후 master 머지. `flutter test` 44/44 통과.
- **2026-05-05** — Day 8 (spec_06) PR #6 머지 완료: 지원 기능 (ApplicationFormScreen, ApplicationResultScreen). `_isSubmitting` 오터치 방어, `runTransaction`으로 race condition 해결, `sealed class` ApplicationException, `hasApplied()` 사전 체크. Claude round 1 Blocker→round 2 Major→round 3 승인. `flutter test` 51/51 통과.
- **2026-05-06** — Day 9 (spec_07) PR #7 머지 완료: 마이페이지 (MyPageScreen) + 지원 내역 (ApplicationListScreen, ApplicationCard). 프로필 요약 카드, 지원 횟수 뱃지, 메뉴 리스트, 로그아웃 확인 다이얼로그. 상태 배지 5종 색상 구분. Claude Round 1 Major 3건(M-1~M-3), Minor 3건(m-1~m-3), Nit 2건(n-1~n-2) 수정 반영. Claude Round 2 / Gemini 승인. `flutter analyze` 0경고, `flutter test` 62/62 통과.
- **2026-05-07** — 전체 리펙토링 PR #8 머지 완료: 데드코드 2건 삭제, 중복 코드 2건 제거, 하드코딩 3건 정리, 코드 품질 3건 개선, 공통 유틸 2건 신규. `flutter analyze` 0경고, `flutter test` 62/62 통과. Claude Round 3 / Gemini 승인. 히스토리: `docs/history/2026-05-07-refactoring.md`.
- **2026-05-07** — Day 10 (spec_08) PR #9 머지 완료: 네비게이션 구조 개편. `MainShell` + `BottomNavigationBar` (홈/지원현황/마이페이지 3탭) via `go_router` `ShellRoute`. `initialLocation` → `/home`. 인증 화면 `PopScope`로 Android 백 버튼 시 앱 종료. `MainScreen` 제거 및 profile guard를 `MainShell`로 이전. 잔여 하드코딩 경로 상수화. Claude Round 1 Minor/Nit 수정 (중복 메뉴 제거, 포맷 정리, grey 상수 교체). 히스토리: `docs/history/2026-05-07-navigation.md`.
- **2026-05-10** — Day 12 (spec_10) 완료: 테스트 기준 및 DoD. `application_repository_test.dart` (7건: 중복 지원 방지, 공고 없음/마감 예외), `job_filter_test.dart` (6건: 필터 조합, copyWith null 설정), `physical_badge_test.dart` (8건: 강도 레이블, 배지 파싱). `ApplicationRepository`에 `FirebaseAuth` 생성자 주입 추가로 테스트 가능하도록 리팩토링. `flutter analyze` 0경고, `flutter test` 84/84 통과. 추가로 Android release APK 크래시 2건 수정: `MainActivity.kt` 누락 (`ClassNotFoundException`), `INTERNET` 권한 누락.
- **2026-05-10** — 헤파이스토스 아키텍처 검수 완료: P0 4건(P0-1 AuthException sealed class, P0-2 ErrorRetryView 통합, P0-3 디자인 토큰 교체, P0-4 MainShell dead code 제거) + P1 5건(P1-5 profile_register 분해, P1-6 otp_input 분해 + OtpPinBox 테스트, P1-8 PhoneAuthNotifier로 리팩토링 + cache invalidation, P1-9 Clock 주입) + 기타 3건(A~C). Claude 구현 리뷰 round 2 승인. `flutter analyze` 0경고, `flutter test` 97/97 통과, `verify_local.sh` 6/6. 히스토리: `docs/history/2026-05-10-architecture-fix.md`.
- **2026-05-12** — Day 13 (spec_11) PR #10 생성 및 리뷰 대응. 시니어 특화 UI/UX 고도화: MascotWidget (TweenAnimationBuilder 등장 애니메이션), FontSizeNotifier (SharedPreferences, 0.86~1.33 범위), SettingsScreen (Slider + 실시간 미리보기), MyPage 설정 메뉴, `/settings` 라우트. Round 1: B-1(MaterialApp.builder), M-2(마스코트 3곳), M-3(고대비 P1 강등), M-1(MediaQuery.textScaler 테스트), m-1~m-3, n-1 수정. Round 2: N-1(ValueKey 제거), U-1(builder 와이어링 테스트), U-2(scale 범위 조정). `flutter analyze` 0경고, `flutter test` 113/113 통과. 사업계획서 PDF 수정본 생성. 히스토리: `docs/history/2026-05-12-spec-11-senior-ui.md`.
- **2026-05-14** — 🔄 리뷰 대기 (PR #12): 공고 상세 UI 개편 + 지원현황 네비게이션 + 설정 고정 + 마스코트 은일이 교체. Claude 리뷰 M-1~M-3, m-1~m-2 수정 중.


---

## 업데이트 방법 (에이전트용)

1. 작업 시작 시: 해당 Spec 상태를 `🔄 진행 중` 으로 변경
2. 작업 완료 시: 상태를 `✅ 완료` 로 변경 + "완료 이력"에 날짜와 함께 기록
3. 블로커 발생 시: 상태를 `⛔ 블로커` 로 변경 + "현재 블로커" 절에 상세 내용 추가
4. **최종 업데이트 날짜 항상 갱신**
