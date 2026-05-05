#!/usr/bin/env bash
set -euo pipefail

AGENT_KEY="${1:-system}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

STAMP_FILE="/tmp/silverworker_notify_${AGENT_KEY}.stamp"
NOW="$(date +%s)"

if [ -f "$STAMP_FILE" ]; then
  LAST="$(cat "$STAMP_FILE")"
  DIFF=$((NOW - LAST))
  if [ "$DIFF" -lt 60 ]; then
    exit 0
  fi
fi

SUMMARY="$(git -C "$PROJECT_ROOT" log -1 --format="%s" --since="2 minutes ago" 2>/dev/null || true)"
if [ -z "$SUMMARY" ]; then
  SUMMARY="작업 완료"
fi

LABEL=""
case "$AGENT_KEY" in
  opencode) LABEL="OpenCode" ;;
  claude)   LABEL="Claude" ;;
  gemini)   LABEL="Gemini" ;;
  *)        LABEL="System" ;;
esac

echo "$NOW" > "$STAMP_FILE"
python3 "$PROJECT_ROOT/tools/notify.py" "$AGENT_KEY" \
  "[${LABEL}] ${SUMMARY}" 2>/dev/null || true
