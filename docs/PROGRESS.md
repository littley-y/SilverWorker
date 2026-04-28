# PROGRESS — SilverWorkerNow 개발 현황

> 최종 업데이트: 2026-04-28
> 전체 목표: 2주 데모 (Day 1 ~ Day 14)
> 참조 스펙: `docs/planning/spec_01~10.md`

---

## 현재 단계: Day 3 시작 전 (spec_02 머지 완료)

---

## 스펙별 진행 상황

| Spec | 제목 | 상태 | 대상 Day | 비고 |
|---|---|---|---|---|
| [spec_01](planning/spec_01_project_setup.md) | 프로젝트 초기 세팅 | ✅ 완료 | Day 1 | PR #1 수정 완(2차 리뷰 승인) |
| [spec_02](planning/spec_02_auth.md) | 인증 및 프로필 등록 | ✅ 완료 | Day 2 | PR #2 머지 완 (Claude/Gemini 승인) |
| [spec_03](planning/spec_03_job_data.md) | 공고 데이터 준비 | ⬜ 대기 | Day 3 | 고용24 API 키 승인 여부에 따라 분기 |
| [spec_04](planning/spec_04_job_list_ui.md) | 공고 목록 UI | ⬜ 대기 | Day 4 | |
| [spec_05](planning/spec_05_job_detail.md) | 공고 상세 + 세이프티 배지 | ⬜ 대기 | Day 5 | |
| [spec_06](planning/spec_06_application.md) | 지원 기능 | ⬜ 대기 | Day 8 | |
| [spec_07](planning/spec_07_mypage.md) | 마이페이지 | ⬜ 대기 | Day 9 | |
| [spec_08](planning/spec_08_navigation.md) | 네비게이션 | ⬜ 대기 | Day 10 | |
| [spec_09](planning/spec_09_ui_system.md) | 시니어 UI 시스템 | ⬜ 대기 | Day 4, 11 | |
| [spec_10](planning/spec_10_test_criteria.md) | 테스트 기준 + DoD | ⬜ 대기 | Day 12 | |

**상태 범례**: ✅ 완료 / 🔄 진행 중 / ⛔ 블로커 / ⬜ 대기

---

## 현재 블로커

없음

---

## 알려진 리스크

| 리스크 | 영향 Spec | 대응 |
|---|---|---|
| 고용24 API 키 미승인 | spec_03 | Mock 데이터 30개로 즉시 전환 (spec_03 경로 A) |
| Firebase Phone Auth SMS 지연 | spec_02 | Firebase 테스트 번호 사용 |

---

## 완료 이력

- **2026-04-25** — Day 1 (spec_01) 완료: PR #1 머지. Firebase 의존성 추가, lib/ 디렉토리 구조 및 골격 코드 생성, firestore.rules 작성, `flutter analyze` 0경고 확인. Claude/Gemini 2차 리뷰 승인.
- **2026-04-25** — Firebase Console 연동 완료: 프로젝트 생성, Android 앱 등록(`com.silverworkernow.app`), Phone Auth 활성화, 테스트 번호 등록, Firestore DB 생성 + rules 배포, `flutterfire configure`, `main.dart` 정리. `flutter analyze` 0경고.
- **2026-04-25** — Claude/Gemini post-merge review 완료. BLOCKER(`firestore.rules` OPEN ACCESS) 수정: spec_01 §5 / 04_db_schema §3 규칙 복원 후 재배포(`60a20a7`).
- **2026-04-25** — Graphify 지식 그래프 구축 완료: 147 nodes, 139 edges, 29 communities. 3플랫폼(Claude Code, OpenCode, Gemini CLI) always-on hooks 설치, Git post-commit auto-rebuild hooks, GitHub Pages workflow (with auto-rebuild step), docs/ 위키 설정. Claude/Gemini post-setup review 완료: M-1~M-5, N-4, Gemini-2.2~2.3 수정 반영. `google-services.json` commit 유지 + GCP API key restriction 권장. 히스토리: `docs/history/2026-04-25-graphify-setup.md`.
- **2026-04-27** — 모노레포 통합 완료: `General/` 폴더와 4개 빈 worktree(`_dev`, `_design`, `_devops`, `_qa`) 제거. 모든 프로젝트 자산(docs, tools, `.claude/`, `.gemini/`, `.opencode/`, `graphify-out/`)을 `SilverWorkerNow/`로 통합 후, git repo를 `Projects/SilverWorker/` 루트로 이동. `tools/scripts/intercept_git.py`, `hook_pre_git.py`, `hook_session_start.py` 경로 수정. `.gitignore`에 `node_modules/`, `.venv/`, `.obsidian/` 추가. 전역 `~/.claude/settings.json` PostToolUse hook 제거. Claude/Gemini 리뷰 완료. 히스토리: `docs/history/2026-04-27-monorepo-consolidation.md`.
- **2026-04-28** — Day 2 (spec_02) PR #2 머지 완료: Firebase Phone Auth 흐름 구현. go_router 기반 라우팅, PhoneInputScreen, OtpInputScreen, ProfileSetupScreen. Claude/Gemini 3차 리뷰 승인 후 master 머지. AGENTS.md 규칙 업데이트: 최종 리뷰 승인 시 master 직접 푸시 허용. 히스토리: docs/history/2026-04-28-day2-auth.md.

---

## 업데이트 방법 (에이전트용)

1. 작업 시작 시: 해당 Spec 상태를 `🔄 진행 중` 으로 변경
2. 작업 완료 시: 상태를 `✅ 완료` 로 변경 + "완료 이력"에 날짜와 함께 기록
3. 블로커 발생 시: 상태를 `⛔ 블로커` 로 변경 + "현재 블로커" 절에 상세 내용 추가
4. **최종 업데이트 날짜 항상 갱신**
