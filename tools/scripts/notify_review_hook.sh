#!/usr/bin/env bash
set -euo pipefail

AGENT_KEY="${1:-claude}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RECENT="$(find "$PROJECT_ROOT/docs/PR_Review" -name '*.md' -mmin -5 2>/dev/null || true)"

if [ -n "$RECENT" ]; then
  python3 "$PROJECT_ROOT/tools/notify.py" "$AGENT_KEY" \
    "리뷰 파일이 생성/수정되었습니다. docs/PR_Review/ 에서 피드백을 확인하세요." 2>/dev/null || true
fi
