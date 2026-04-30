#!/usr/bin/env bash
# OMO PreToolUse hook wrapper for gh pr create
# This script receives tool call info via stdin (JSON) and only runs the
# checklist when the Bash tool is about to execute 'gh pr create'.
#
# stdin format (from opencode-claude-hooks):
#   { "tool_name": "Bash", "tool_input": { "command": "gh pr create ..." }, ... }
#
# Exit codes:
#   0 - allow the tool call
#   2 - block the tool call (checklist failed)

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only intercept Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only trigger for 'gh pr create' commands (exact or with flags/args)
# Matches: gh pr create, gh pr create --title "...", gh pr create -f, etc.
if ! echo "$COMMAND" | grep -qE '^gh pr create(\s|$)'; then
  exit 0
fi

if bash tools/scripts/pre_pr_checklist.sh; then
  exit 0
else
  exit 2
fi
