#!/usr/bin/env bash
#
# compile.sh - Byte-compile and native-compile Emacs configuration
#
# Pre-compiles init.el and early-init.el for faster startup.
# Run this after making changes to either file.
#
set +e  # Don't exit on error - report all failures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo "ERROR: Cannot cd to $SCRIPT_DIR"; exit 1; }

echo "=== Emacs Config Compiler ==="
echo "Directory: $PWD"
echo ""

START_TIME=$(date +%s%N)
HAS_ERRORS=0

# --- Byte Compilation ---
echo "--- Byte-compiling early-init.el ---"
if emacs -Q --batch -f batch-byte-compile early-init.el; then
    echo "  ✓ Done"
else
    echo "  ✗ FAILED"
    HAS_ERRORS=1
fi

echo "--- Byte-compiling init.el ---"
if emacs -Q --batch -f batch-byte-compile init.el; then
    echo "  ✓ Done"
else
    echo "  ✗ FAILED"
    HAS_ERRORS=1
fi

echo ""

# --- Native Compilation ---
echo "--- Native-compiling init.el and early-init.el ---"
if emacs -Q --batch \
    --eval "(native-compile-async \"~/.emacs.d/init.el\" '())" \
    --eval "(native-compile-async \"~/.emacs.d/early-init.el\" '())"; then
    echo "  ✓ Done"
else
    echo "  ✗ FAILED"
    HAS_ERRORS=1
fi

echo ""

END_TIME=$(date +%s%N)
ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

if [ $HAS_ERRORS -eq 0 ]; then
    echo "✓ All compilation steps completed successfully. (${ELAPSED_MS}ms)"
else
    echo "⚠ Some compilation steps failed. (${ELAPSED_MS}ms)"
    exit 1
fi
