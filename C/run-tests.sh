#!/bin/sh
set -eu

FOLDER_NAME="${1:-test-1}"

echo "=== Running benchmark for folder: $FOLDER_NAME ==="

make DIR="$FOLDER_NAME" clean
make DIR="$FOLDER_NAME" test
valgrind --leak-check=full --error-exitcode=1 ./test_runner