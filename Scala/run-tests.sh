#!/bin/sh
set -eu

FOLDER_NAME="${1:-test-1}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "=== Running benchmark for folder: $FOLDER_NAME ==="

cd "$SCRIPT_DIR"
make DIR="$FOLDER_NAME" clean
make DIR="$FOLDER_NAME" test
cd "$FOLDER_NAME"
scala -cp test_runner Tests