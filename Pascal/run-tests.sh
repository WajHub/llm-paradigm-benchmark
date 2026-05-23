#!/bin/sh
set -eu

FOLDER_NAME="${1:-test-1}"

echo "=== Running benchmark for folder: $FOLDER_NAME ==="

make DIR="$FOLDER_NAME" clean
make DIR="$FOLDER_NAME" test
# FPC places the linked binary inside the unit directory (e.g. test-1/test_runner)
valgrind --leak-check=full --error-exitcode=1 "$FOLDER_NAME/test_runner"
