#!/usr/bin/env bash
set -euo pipefail

AGENT_KEY="${1:-claude}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CHANGED="$(git -C "$PROJECT_ROOT" diff --name-only HEAD 2>/dev/null || true)"
STAGED="$(git -C "$PROJECT_ROOT" diff --name-only --cached 2>/dev/null || true)"
UNTRACKED="$(git -C "$PROJECT_ROOT" ls-files --others --exclude-standard docs/PR_Review/ 2>/dev/null || true)"

ALL_CHANGES="${CHANGED}
${STAGED}
${UNTRACKED}"

if echo "$ALL_CHANGES" | grep -q "docs/PR_Review/"; then
  python3 "$PROJECT_ROOT/tools/notify.py" "$AGENT_KEY" \
    "리뷰 파일이 생성/수정되었습니다. docs/PR_Review/ 에서 피드백을 확인하세요." 2>/dev/null || true
fi
