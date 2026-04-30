#!/usr/bin/env bash
# SilverWorker CI — Local pre-push validation (mirrors GitHub Actions)
#
# Usage:
#   tools/verify_local.sh           # Quick: lint + test + pages
#   tools/verify_local.sh --ci      # Full:   above + Android debug build
#
# Mirrors .github/workflows/ci.yml (lint → test → build_android)
# and .github/workflows/pages.yml (wiki site assembly)

set -euo pipefail

FLUTTER="${FLUTTER:-/home/dudxo13/development/flutter/bin/flutter}"
DART="${DART:-/home/dudxo13/development/flutter/bin/dart}"
START=$(date +%s)
CI_MODE=false

red()    { echo -e "\033[31m$*\033[0m"; }
green()  { echo -e "\033[32m$*\033[0m"; }
cyan()   { echo -e "\033[36m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ci) CI_MODE=true; shift ;;
        *)    WORK_DIR="$1"; shift ;;
    esac
done

WORK_DIR="${WORK_DIR:-$(pwd)}"
cd "$WORK_DIR"

STEPS_DONE=0
TOTAL_STEPS=6
$CI_MODE && TOTAL_STEPS=7

step() {
    STEPS_DONE=$((STEPS_DONE + 1))
    cyan "\n[${STEPS_DONE}/${TOTAL_STEPS}] $1"
}

# ── 1. Dependencies ────────────────────────────────────────────

step "Installing dependencies (flutter pub get)..."
"$FLUTTER" pub get --suppress-analytics > /dev/null 2>&1
green "✅ Dependencies resolved."

# ── 2. Format ──────────────────────────────────────────────────

step "Checking code formatting..."
if ! "$DART" format --set-exit-if-changed lib/ test/ > /dev/null 2>&1; then
    red "❌ Formatting issues found!"
    red "   Run: dart format lib/ test/"
    exit 1
fi
green "✅ Formatting is clean."

# ── 3. Lint ────────────────────────────────────────────────────

step "Running static analysis (flutter analyze)..."
if ! "$FLUTTER" analyze --suppress-analytics 2>&1; then
    red "❌ Static analysis failed!"
    exit 1
fi
green "✅ Zero warnings."

# ── 4. Unit tests ──────────────────────────────────────────────

step "Running unit tests (flutter test)..."
if ! "$FLUTTER" test --suppress-analytics 2>&1; then
    red "❌ Some tests failed!"
    exit 1
fi
green "✅ All tests passed."

# ── 5. Pages build simulation ──────────────────────────────────

step "Simulating GitHub Pages build (pages.yml)..."
PAGES_TMP=$(mktemp -d)
trap "rm -rf $PAGES_TMP" EXIT

cp -r docs/planning   "$PAGES_TMP/" 2>/dev/null || { red "  ❌ docs/planning/ missing"; exit 1; }
cp -r docs/history    "$PAGES_TMP/" 2>/dev/null || { red "  ❌ docs/history/ missing"; exit 1; }
cp -r docs/PR_Review  "$PAGES_TMP/" 2>/dev/null || { red "  ❌ docs/PR_Review/ missing"; exit 1; }
cp docs/PROGRESS.md   "$PAGES_TMP/" 2>/dev/null || { red "  ❌ docs/PROGRESS.md missing"; exit 1; }
cp docs/AGENTS.md     "$PAGES_TMP/" 2>/dev/null || { red "  ❌ docs/AGENTS.md missing"; exit 1; }
cp docs/README.md     "$PAGES_TMP/" 2>/dev/null || { red "  ❌ docs/README.md missing"; exit 1; }
cp AGENTS.md          "$PAGES_TMP/" 2>/dev/null || { red "  ❌ AGENTS.md missing"; exit 1; }
cp REVIEWER_PROMPT.md "$PAGES_TMP/" 2>/dev/null || { red "  ❌ REVIEWER_PROMPT.md missing"; exit 1; }
cp IMPLEMENTER_PROMPT.md "$PAGES_TMP/" 2>/dev/null || { red "  ❌ IMPLEMENTER_PROMPT.md missing"; exit 1; }
cp docs/wiki.html     "$PAGES_TMP/index.html" 2>/dev/null || { red "  ❌ docs/wiki.html missing (index page)"; exit 1; }

green "✅ Pages build simulation passed (all assets copyable)."

# ── 6. Graphify uncommitted check ──────────────────────────────

step "Checking for uncommitted graphify changes..."
GRAPHFY_DIRTY=$(git status --short graphify-out/ 2>/dev/null || true)
if [ -n "$GRAPHFY_DIRTY" ]; then
    yellow "⚠️  graphify-out/ has uncommitted changes (auto-rebuilt on commit)."
    yellow "   Consider: git add graphify-out/ && git commit -m 'chore(graphify): update'"
fi
green "✅ Graphify check done."

# ── 7. (CI mode) Android debug build ───────────────────────────

if $CI_MODE; then
    step "Building Android APK (debug) — mirrors ci.yml build_android..."

    if ! "$FLUTTER" build apk --debug --suppress-analytics 2>&1; then
        red "❌ Android debug build failed!"
        exit 1
    fi
    green "✅ Android APK built successfully."
fi

# ── Done ───────────────────────────────────────────────────────

END=$(date +%s)
DURATION=$((END - START))
green "\n🚀 LOCAL CI PASSED (${STEPS_DONE}/${TOTAL_STEPS} steps, ${DURATION}s)"
echo "   Safe to push."
