# Monorepo Consolidation — 2026-04-27

## Session Objective
Eliminate multi-worktree overhead by consolidating all project assets into a single git repository.

---

## 1. Problem Statement

The project was using Git worktrees (`SilverWorkerNow_dev/`, `_design/`, `_devops/`, `_qa/`) plus a shared `General/` folder outside git. This structure introduced:

- **Sync overhead**: `sync_worktrees.sh`, post-merge hooks, manual coordination
- **Empty worktrees**: 4 of 5 worktrees had zero commits
- **Path complexity**: Scripts hardcoded `General/` and worktree paths
- **Non-portability**: `General/` was outside git; other PCs needed manual setup

**Decision**: Dissolve multi-worktree architecture → single repo.

---

## 2. Structural Changes

### 2.1 Deleted
| Path | Reason |
|---|---|
| `SilverWorkerNow_dev/` | Empty worktree, zero commits |
| `SilverWorkerNow_design/` | Empty worktree |
| `SilverWorkerNow_devops/` | Empty worktree |
| `SilverWorkerNow_qa/` | Empty worktree |
| `General/` (outside git) | Dissolved into `docs/` + `tools/` inside repo |
| `General/scripts/sync_worktrees.sh` | Obsolete (no worktrees to sync) |
| `General/scripts/hook_post_pr_merge.py` | Obsolete |

### 2.2 Created / Moved
| New Path | Source | Contents |
|---|---|---|
| `SilverWorkerNow/docs/` | `General/planning/`, `General/history/`, etc. | Specs, history, PR_Review, Page_Review, ERROR, PROGRESS.md, README.md |
| `SilverWorkerNow/tools/` | `General/scripts/`, `General/config/`, `General/verify_local.sh`, `General/notify.py` | Automation scripts, Flutter config, CI script |
| `SilverWorkerNow/.claude/` | Project root `.claude/` | Claude Code settings |
| `SilverWorkerNow/.gemini/` | Project root `.gemini/` | Gemini CLI settings |
| `SilverWorkerNow/.opencode/` | Project root `.opencode/` | OpenCode settings |
| `SilverWorkerNow/graphify-out/` | Project root `graphify-out/` | Knowledge graph output |

### 2.3 Updated Files
| File | Changes |
|---|---|
| `AGENTS.md` | Removed worktree table; added `docs/` + `tools/` structure diagram |
| `IMPLEMENTER_PROMPT.md` | `General/` → `docs/` or `tools/`; removed `[role]` refs; feature branch naming |
| `REVIEWER_PROMPT.md` | Same path updates; removed `[role]` refs |
| `docs/AGENTS.md` | `General/` → `docs/` + `tools/`; removed worktree refs |
| `docs/PROGRESS.md` | `General/` → `docs/`; removed dev worktree mentions |
| `docs/planning/overview/05_implementation_plan.md` | Removed "Git worktree 정상 동작 확인" checklist item |
| `tools/scripts/hook_pre_git.py` | `General/verify_local.sh` → relative `tools/verify_local.sh`; removed `ORCHESTRATOR_DIRS` |
| `tools/scripts/hook_session_start.py` | `General/` → `docs/`; collapsed ROLE_DOCS to `orchestrator` only |
| `.gitignore` | Removed `.claude/`, `.gemini/`, `General/`, `/history/` exclusions; kept only build artifacts |

---

## 3. Path Mapping Reference

| Old Path | New Path |
|---|---|
| `General/PROGRESS.md` | `docs/PROGRESS.md` |
| `General/planning/` | `docs/planning/` |
| `General/history/` | `docs/history/` |
| `General/ERROR/` | `docs/ERROR/` |
| `General/PR_Review/` | `docs/PR_Review/` |
| `General/Page_Review/` | `docs/Page_Review/` |
| `General/config/` | `tools/config/` |
| `General/scripts/` | `tools/scripts/` |
| `General/verify_local.sh` | `tools/verify_local.sh` |
| `General/notify.py` | `tools/notify.py` |
| `General/AGENTS.md` | `docs/AGENTS.md` |
| `General/README.md` | `docs/README.md` |

---

## 4. Verification

### 4.1 Path Check
```bash
cd SilverWorkerNow
grep -r "General/" AGENTS.md IMPLEMENTER_PROMPT.md REVIEWER_PROMPT.md \
  docs/AGENTS.md docs/PROGRESS.md docs/planning/AGENTS.md
# Result: 0 matches
```

### 4.2 Historical Files
Files in `docs/history/2026-04-25-*.md` and `docs/Page_Review/2026-04-25-*.md` intentionally retain `General/` and worktree references — they are historical records and must not be rewritten.

### 4.3 Git Status
```
105 files changed, 9529 insertions(+), 84 deletions(-)
Commit: dbcca89 — chore(monorepo): consolidate all project assets into single repo
```

---

## 5. New Repository Structure

```
SilverWorkerNow/              ← git clone → full project
├── lib/                      ← Flutter source
├── android/ ios/ web/        ← Platform code
├── docs/                     ← Documentation, specs, history
│   ├── PROGRESS.md
│   ├── planning/
│   ├── history/
│   ├── PR_Review/
│   └── ...
├── tools/                    ← Scripts, configs, CI
│   ├── scripts/
│   ├── config/
│   ├── verify_local.sh
│   └── notify.py
├── graphify-out/             ← Knowledge graph
├── .claude/                  ← Claude Code settings
├── .gemini/                  ← Gemini CLI settings
├── .opencode/                ← OpenCode settings
├── AGENTS.md
├── IMPLEMENTER_PROMPT.md
└── REVIEWER_PROMPT.md
```

---

## 6. Impact on Workflows

| Workflow | Before | After |
|---|---|---|
| Clone to new PC | `git clone` + manually set up `General/` | `git clone` only |
| Run verify | `bash General/verify_local.sh <worktree>` | `bash tools/verify_local.sh` |
| Read progress | `General/PROGRESS.md` | `docs/PROGRESS.md` |
| Read specs | `General/planning/spec_XX.md` | `docs/planning/spec_XX.md` |
| Push branch | `git push origin role/dev` | `git push origin feat/spec-XX-name` |
| Review request doc | `General/PR_Review/YYYY-MM-DD-role_dev-prN-request.md` | `docs/PR_Review/YYYY-MM-DD-prN-request.md` |
| GitHub Pages | `General/.github/workflows/pages.yml` | `.github/workflows/pages.yml` |

---

## 7. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| `.claude/`, `.gemini/`, `.opencode/` paths contain absolute paths | Verified: settings files use relative paths or environment-independent config |
| `tools/verify_local.sh` hardcodes Flutter path | Pre-existing; works on both PCs if Flutter installed at same path. Can be parameterized later. |
| `graphify-out/` cache files are large | Acceptable; they are generated artifacts but needed for cross-PC knowledge graph continuity. |
| History files reference deleted paths | Intentional — historical documents must not be rewritten. |

---

## 8. Definition of Done (This Task)

- [x] All 4 extra worktrees deleted
- [x] `General/` dissolved into `docs/` + `tools/`
- [x] `.claude/`, `.gemini/`, `.opencode/`, `graphify-out/` moved into repo
- [x] All active `.md` files updated (0 remaining `General/` refs in AGENTS.md, IMPLEMENTER_PROMPT.md, REVIEWER_PROMPT.md, docs/AGENTS.md, docs/PROGRESS.md, docs/planning/AGENTS.md)
- [x] `.gitignore` only excludes build artifacts
- [x] `tools/scripts/` updated for single-repo paths
- [x] Git commit created: `dbcca89`
- [x] History file written: `docs/history/2026-04-27-monorepo-consolidation.md`

---

## 9. Repo Root Migration (SilverWorkerNow/ → SilverWorker/)

**Claude/Gemini Review Findings** (2026-04-27)

After initial monorepo consolidation, reviewers identified that the repo was still nested inside `SilverWorkerNow/`, creating a pointless parent-wrapper folder (`SilverWorker/`).

### 9.1 Changes
| Action | Detail |
|---|---|
| Move `.git/` | From `SilverWorkerNow/.git/` to `SilverWorker/.git/` |
| Move all files | `SilverWorkerNow/*` and `SilverWorkerNow/.*` → `SilverWorker/` root |
| Delete wrapper | `rmdir SilverWorkerNow` |
| Remove root artifacts | `.claudeignore`, `.geminiignore`, `.gitignore`, `.ignore` |

### 9.2 Path Fixes After Migration
| File | Fix |
|---|---|
| `tools/scripts/hook_pre_git.py` | `REPO_DIRS`: `.../SilverWorker/SilverWorkerNow` → `.../SilverWorker` |
| `tools/scripts/hook_session_start.py` | `CWD_MAP`: `"SilverWorkerNow"` → `"SilverWorker"` |
| `IMPLEMENTER_PROMPT.md` | "Work in `SilverWorkerNow/`" → "Work in this repository" |
| `.gitignore` | Added `node_modules/`, `.venv/`, `.obsidian/` |
| `.graphifyignore` | Removed old worktree refs (`SilverWorkerNow_dev/`, etc.); added `.venv/`, `.obsidian/`, `.firebase/` |
| `~/.claude/settings.json` | Removed broken `PostToolUse` hook (called deleted `hook_post_pr_merge.py`) |

### 9.3 Post-Migration Structure
```
SilverWorker/                  ← git clone → full project (no wrapper)
├── lib/
├── docs/
├── tools/
├── graphify-out/
├── .claude/
├── .gemini/
├── .opencode/
├── AGENTS.md
├── IMPLEMENTER_PROMPT.md
└── REVIEWER_PROMPT.md
```

---

## 10. Next Steps

- **Day 2**: `spec_02_auth.md` — Firebase Phone Auth, SMS verification, profile registration
