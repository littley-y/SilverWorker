#!/usr/bin/env bash
# Must Go Out Now - Local CI Validation Script (WSL Native)
# 검증 단계: pub get → dart format → flutter analyze → flutter test → pages check

set -euo pipefail

FLUTTER="/home/dudxo13/development/flutter/bin/flutter"
DART="/home/dudxo13/development/flutter/bin/dart"
START=$(date +%s)

# 색상 출력
red()    { echo -e "\033[31m$*\033[0m"; }
green()  { echo -e "\033[32m$*\033[0m"; }
cyan()   { echo -e "\033[36m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }

# 작업 디렉토리: 인수로 받거나 현재 디렉토리
WORK_DIR="${1:-$(pwd)}"
cd "$WORK_DIR"

cyan "\n[1/5] Running 'flutter pub get'..."
"$FLUTTER" pub get --suppress-analytics > /dev/null 2>&1
green "✅ Dependencies updated."

cyan "\n[2/5] Verifying Code Formatting..."
if ! "$DART" format --set-exit-if-changed . > /dev/null 2>&1; then
    red "❌ Formatting issues found!"
    red "Run 'dart format .' to fix your code style."
    exit 1
fi
green "✅ Formatting is perfect."

cyan "\n[3/5] Analyzing Project Source (Lint)..."
if ! "$FLUTTER" analyze --suppress-analytics 2>&1; then
    red "❌ Static analysis failed!"
    exit 1
fi
green "✅ Analysis passed with no issues."

cyan "\n[4/5] Running Unit Tests..."
if ! "$FLUTTER" test --suppress-analytics 2>&1; then
    red "❌ Some tests failed!"
    exit 1
fi
green "✅ All tests passed."

cyan "\n[5/5] Verifying GitHub Pages Build..."
PAGES_OK=true

# Check wiki.html exists (required by pages.yml)
if [ ! -f "docs/wiki.html" ]; then
    red "  ❌ docs/wiki.html is missing (required for GitHub Pages)"
    PAGES_OK=false
fi

# Check required paths referenced in pages.yml
REQUIRED_PATHS=(
    "docs/planning"
    "docs/history"
    "docs/PR_Review"
    "docs/PROGRESS.md"
    "docs/AGENTS.md"
    "docs/README.md"
    "AGENTS.md"
    "REVIEWER_PROMPT.md"
    "IMPLEMENTER_PROMPT.md"
)

for path in "${REQUIRED_PATHS[@]}"; do
    if [ ! -e "$path" ]; then
        red "  ❌ $path is missing (referenced in pages.yml)"
        PAGES_OK=false
    fi
done

if [ "$PAGES_OK" = false ]; then
    red "❌ GitHub Pages build would fail!"
    exit 1
fi
green "✅ GitHub Pages assets present."

END=$(date +%s)
DURATION=$((END - START))
green "\n🚀 LOCAL CI PASSED SUCCESSFULLY! (Total: ${DURATION}s)"
echo "You can now safely push your changes."
