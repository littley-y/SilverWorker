# 🗺️ Project Orchestration Map (Common Constitution)

This document is the **Master Guide** for all AI agents. All agents must understand this structure before proceeding.

---

## 🎭 Role-Specific Instructions
After reading this master guide, proceed to your specific instructions:
- **IMPLEMENTERS (OpenCode)**: Read `IMPLEMENTER_PROMPT.md`
- **REVIEWERS (Claude/Gemini)**: Read `REVIEWER_PROMPT.md`

---

## 1. Project Overview & Tech Stack
- **Project Name**: SilverWorkerNow
- **Master Spec**: `General/planning/overview/03_mvp_specs.md` + `General/planning/spec_01~10.md`
- **Tech Stack**: `General/planning/overview/02_tech_stack.md`
- **Goal**: Zero-warning, spec-compliant implementation.
- **현재 진행 상황**: 작업 시작 전 반드시 `General/PROGRESS.md` 를 먼저 확인할 것.

---

## 2. Repository Structure
Single-repo architecture. All code lives in this repository; planning docs and shared assets live in `General/` (documentation-only, outside git).

### Folder Structure
```text
SilverWorkerNow/               # Flutter project (this repo)
├── lib/                       # Source code
├── android/
├── ios/
├── test/
├── AGENTS.md                  # This document
├── IMPLEMENTER_PROMPT.md      # Implementer rules
├── REVIEWER_PROMPT.md         # Reviewer rules
└── ...

General/                       # Documentation & shared assets (outside git)
├── PROGRESS.md                # ★ 개발 진행 현황 — 세션 시작 시 첫 번째로 확인
├── planning/                  # Specs, DB Schemas, Test Cases
│   ├── overview/              # 고수준 기획 문서 (01~05)
│   └── spec_01~10.md          # 구현 세부 스펙 (Day별)
├── config/                    # Shared Linter/L10n configs
├── scripts/                   # Automation scripts
├── history/                   # Session history
├── ERROR/                     # Fatal error logs
├── PR_Review/                 # Review feedback logs
├── verify_local.sh            # CI verification script
└── notify.py                  # Notification utility
```

---

## 3. Universal Rules (Mandatory)
- **Environment**: WSL / bash (No PowerShell).
- **진행 현황 확인**: 세션 시작 시 `General/PROGRESS.md` 를 가장 먼저 읽을 것.
- **Master Spec Priority**: `General/planning/spec_01~10.md` 가 구현의 기준. 충돌 시 `spec_*.md` 우선.
- **Git Flow**: No direct master push. Use `role/*` -> PR -> Review -> Merge.
- **Error Logging**: Record fatal issues in `General/ERROR/`.
- **Zero-Warning Policy**: Linter must return 0 errors and 0 warnings.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
