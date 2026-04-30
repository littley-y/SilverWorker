#!/usr/bin/env bash
# Pre-PR Checklist Script
# Run BEFORE creating a PR. Exits with error if any check fails.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() {
  echo -e "${GREEN}✅${NC} $1"
  PASS=$((PASS + 1))
}

fail() {
  echo -e "${RED}❌${NC} $1"
  FAIL=$((FAIL + 1))
}

warn() {
  echo -e "${YELLOW}⚠️${NC} $1"
}

echo "========================================"
echo "    Pre-PR Checklist"
echo "========================================"
echo

# 1. verify_local.sh
if bash tools/verify_local.sh >/dev/null 2>&1; then
  pass "verify_local.sh passed"
else
  fail "verify_local.sh FAILED. Run 'bash tools/verify_local.sh' to see errors."
fi

# 2. Review Request doc exists
TODAY=$(date +%Y-%m-%d)
if ls docs/PR_Review/"${TODAY}"-pr*-request.md 1>/dev/null 2>&1; then
  pass "Review Request doc found"
else
  fail "Review Request doc NOT FOUND. Create: docs/PR_Review/${TODAY}-pr<N>-request.md"
fi

# 3. PROGRESS.md has Review Pending for the spec being worked on
if grep -q "🔄 Review Pending" docs/PROGRESS.md; then
  pass "PROGRESS.md has 🔄 Review Pending"
else
  fail "PROGRESS.md NOT updated to 🔄 Review Pending"
fi

# 4. History file exists for today
if ls docs/history/"${TODAY}"-*.md 1>/dev/null 2>&1; then
  pass "History file found"
else
  warn "History file NOT FOUND for today (optional but recommended)"
fi

# 5. No forbidden files staged
FORBIDDEN_PATTERNS=(
  "AGENTS.md"
  "REVIEWER_PROMPT.md"
  "IMPLEMENTER_PROMPT.md"
)

FORBIDDEN_FOUND=0
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if git diff --cached --name-only 2>/dev/null | grep -qE "^${pattern}$"; then
    fail "Forbidden file staged: ${pattern}"
    FORBIDDEN_FOUND=1
  fi
done

if [ $FORBIDDEN_FOUND -eq 0 ]; then
  pass "No forbidden files staged"
fi

# 6. No reviewer files in staged changes
if git diff --cached --name-only 2>/dev/null | grep -qE "review_claude|review_gemini"; then
  fail "Reviewer files found in staged changes. Only reviewers can commit these."
else
  pass "No reviewer files staged"
fi

echo
echo "========================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "========================================"

if [ $FAIL -gt 0 ]; then
  echo -e "${RED}BLOCKED: Fix the failures above before creating a PR.${NC}"
  exit 1
fi

echo -e "${GREEN}All checks passed. Ready to create PR.${NC}"
exit 0
