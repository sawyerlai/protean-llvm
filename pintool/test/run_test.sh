#!/usr/bin/env bash
set -e

PINTOOL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PIN="${PIN_ROOT:?Set PIN_ROOT to your PIN installation directory}/pin"
TOOL="${PINTOOL_DIR}/obj-intel64/prot_count.so"
TARGET="${PINTOOL_DIR}/test/test_target"

if [ ! -f "$TOOL" ]; then
    echo "FAIL: tool not built at $TOOL"
    exit 1
fi

if [ ! -f "$TARGET" ]; then
    echo "FAIL: test target not found at $TARGET (run Task 2 first)"
    exit 1
fi

OUTPUT=$("$PIN" -t "$TOOL" -- "$TARGET" 2>/dev/null)

if ! echo "$OUTPUT" | grep -q "=== PROT prefix execution counts ==="; then
    echo "FAIL: missing header in output"
    echo "$OUTPUT"
    exit 1
fi

if ! echo "$OUTPUT" | grep -q "^Total:"; then
    echo "FAIL: missing Total: line"
    echo "$OUTPUT"
    exit 1
fi

if ! echo "$OUTPUT" | grep -q "secret_work"; then
    echo "FAIL: secret_work not found in per-function output"
    echo "$OUTPUT"
    exit 1
fi

TOTAL=$(echo "$OUTPUT" | grep "^Total:" | awk '{print $2}')
if [ "$TOTAL" -le 0 ] 2>/dev/null; then
    echo "FAIL: total count is 0"
    exit 1
fi

echo "PASS: total=$TOTAL"
echo "---"
echo "$OUTPUT"
