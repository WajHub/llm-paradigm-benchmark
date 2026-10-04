#!/bin/sh
# Run one benchmark folder for one language in an isolated copy of the repo layout.
# The repository itself is never modified.
#
# Usage:
#   verify.sh <repo_root> <Language> <test-N> <work_dir> [reference_dir]
#
#   <work_dir>       scratch directory; <work_dir>/<Language>/ is wiped and rebuilt
#   [reference_dir]  optional; every file in it is copied over <work_dir>/<Language>/<test-N>/
#                    (use it to overlay the reference implementation on top of the stub)
#
# Mode is chosen automatically: local toolchain if present, otherwise Docker Compose.
# Force with VERIFY_MODE=local or VERIFY_MODE=docker.
#
# Prints the test output, then a final line:  VERIFY <Language> <test-N> mode=<m> exit=<code>
set -u

REPO="$1"; LANG_DIR="$2"; TEST="$3"; WORK="$4"; REF="${5:-}"

SRC="$REPO/$LANG_DIR"
[ -d "$SRC/$TEST" ] || { echo "ERROR: $SRC/$TEST does not exist" >&2; exit 2; }

DST="$WORK/$LANG_DIR"
rm -rf "$DST"
mkdir -p "$DST"
for f in Dockerfile docker-compose.yml Makefile run-tests.sh; do
    cp "$SRC/$f" "$DST/$f"
done
cp -r "$SRC/$TEST" "$DST/$TEST"
# drop stale build artefacts that may be committed (e.g. Pascal *.ppu, test_runner)
find "$DST/$TEST" \( -name '*.o' -o -name '*.ppu' -o -name '*.hi' -o -name '*.class' -o -name 'test_runner' \) -prune -exec rm -rf {} + 2>/dev/null

if [ -n "$REF" ]; then
    [ -d "$REF" ] || { echo "ERROR: reference dir $REF does not exist" >&2; exit 2; }
    cp -r "$REF"/. "$DST/$TEST"/
fi

has() { command -v "$1" >/dev/null 2>&1; }
local_ok() {
    case "$LANG_DIR" in
        C)         has gcc && has make && has valgrind ;;
        Haskell)   has ghc && has make && has valgrind ;;
        Java)      has javac && has java && has make ;;
        Pascal)    has fpc && has make && has valgrind ;;
        Prolog)    has swipl && has make && has valgrind ;;
        Scala)     has scalac && has scala && has make ;;
        Smalltalk) has gst && has make ;;
        *)         return 1 ;;
    esac
}
docker_ok() { has docker && docker compose version >/dev/null 2>&1; }

MODE="${VERIFY_MODE:-auto}"
if [ "$MODE" = auto ]; then
    if local_ok; then MODE=local
    elif docker_ok; then MODE=docker
    else MODE=none
    fi
fi

case "$MODE" in
    local)
        (cd "$DST" && sh ./run-tests.sh "$TEST")
        CODE=$?
        ;;
    docker)
        (cd "$DST" && docker compose run --rm --build evaluator "$TEST")
        CODE=$?
        ;;
    *)
        echo "No local toolchain and no Docker available for $LANG_DIR - cannot verify."
        CODE=3
        ;;
esac

echo "VERIFY $LANG_DIR $TEST mode=$MODE exit=$CODE"
exit "$CODE"
