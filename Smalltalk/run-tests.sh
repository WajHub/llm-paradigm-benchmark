#!/bin/sh
set -eu

FOLDER_NAME="${1:-test-1}"

echo "=== Running benchmark for folder: $FOLDER_NAME ==="

make DIR="$FOLDER_NAME" clean
make DIR="$FOLDER_NAME" test

DEPS=""
for f in "$FOLDER_NAME"/*.st; do
    case "$(basename "$f")" in
        Tests.st) ;;
        *) DEPS="$DEPS $f" ;;
    esac
done
gst -Q $DEPS "$FOLDER_NAME/Tests.st"
