#!/usr/bin/env bash
set -euo pipefail

AGENT_KEY="${1:-system}"
FILE_PATH="${2:-}"
MESSAGE=""

case "$AGENT_KEY" in
  opencode)
    MESSAGE="OpenCode 구현 작업이 완료되었습니다. PR 및 코드 확인이 필요합니다."
    ;;
  claude)
    if [[ "$FILE_PATH" == *"docs/PR_Review/"* || "$FILE_PATH" == *"review"* ]]; then
      MESSAGE="Claude 리뷰가 완료되었습니다. 피드백을 확인하세요."
    else
      exit 0
    fi
    ;;
  gemini)
    if [[ "$FILE_PATH" == *"docs/PR_Review/"* || "$FILE_PATH" == *"review"* ]]; then
      MESSAGE="Gemini 리뷰가 완료되었습니다. 피드백을 확인하세요."
    else
      exit 0
    fi
    ;;
  *)
    MESSAGE="시스템 알림이 발생했습니다."
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

python3 "$PROJECT_ROOT/tools/notify.py" "$AGENT_KEY" "$MESSAGE" 2>/dev/null || true
