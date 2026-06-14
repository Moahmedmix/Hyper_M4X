#!/bin/bash
# Run all unit tests for Hyper_M4X
# Usage: bash tests/run_all.sh

set -e
cd "$(dirname "$0")/.."

PASS=0
FAIL=0
RESULTS=""

echo "╔══════════════════════════════════════════════════╗"
echo "║         Hyper_M4X Unit Test Runner               ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

for test_file in tests/test_*.lua; do
    name=$(basename "$test_file" .lua)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if lua5.3 "$test_file"; then
        PASS=$((PASS + 1))
        RESULTS="$RESULTS\n  ✓ $name"
    else
        FAIL=$((FAIL + 1))
        RESULTS="$RESULTS\n  ✗ $name"
    fi
    echo ""
done

echo "═══════════════════════════════════════════════════"
echo "RESULTS:"
echo -e "$RESULTS"
echo ""
echo "Passed: $PASS  Failed: $FAIL  Total: $((PASS + FAIL))"
echo "═══════════════════════════════════════════════════"

if [ $FAIL -gt 0 ]; then
    exit 1
fi
