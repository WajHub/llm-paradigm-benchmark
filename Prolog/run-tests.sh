#!/bin/sh
set -eu

FOLDER_NAME="${1:-test-1}"

echo "=== Running benchmark for folder: $FOLDER_NAME ==="

make DIR="$FOLDER_NAME" clean
make DIR="$FOLDER_NAME" test
cd "$FOLDER_NAME"
# --no-threads: under valgrind SWI-Prolog's GC thread crashes (brk segment overflow, exit 139).
# No --leak-check=full: the interpreter does not free its own memory at halt, which would turn
# every run into a failure regardless of the Prolog code under test.
valgrind --error-exitcode=1 swipl --no-threads -q -g main -t halt tests.pl
