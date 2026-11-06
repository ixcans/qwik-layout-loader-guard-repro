#!/usr/bin/env bash
# Asks the production server for the root layout's loader the way the client does after a
# navigation (default options, so no page-path header is sent), and prints what comes back.
#
#   npm install && npm run build && ./check.sh
#
# Expected: the layout loader's data ("d"). With 2.0.0-rc.4 and with main: the redirect ("r")
# thrown by src/routes/index.tsx's own loader.
set -u
PORT="${PORT:-4173}"
cd "$(dirname "$0")" || exit 2

node node_modules/vite/bin/vite.js preview --port "$PORT" --strictPort >preview.log 2>&1 &
PID=$!
trap 'kill "$PID" 2>/dev/null' EXIT
for _ in $(seq 1 60); do curl -sf -o /dev/null "localhost:$PORT/home/" && break; sleep 0.5; done

HASH=$(curl -s "localhost:$PORT/home/" | grep -o 'q:manifest-hash="[^"]*"' | head -1 | cut -d'"' -f2)
HASH="${HASH:-x}"

ASKED_AT_ROOT="/q-loader-layout-data.$HASH.json"
ASKED_AT_HOME="/home/q-loader-layout-data.$HASH.json"

echo "root layout loader, requested at \"/\" (where the client requests it when you click a link):"
echo "  GET $ASKED_AT_ROOT"
ROOT_ANSWER=$(curl -s "localhost:$PORT$ASKED_AT_ROOT")
echo "  -> $ROOT_ANSWER"
RUNS=$(grep -c 'useLanding ran' preview.log)
echo "  src/routes/index.tsx's useLanding ran $RUNS time(s) for this request"
echo
echo "the same loader, requested at \"/home/\":"
echo "  GET $ASKED_AT_HOME"
echo "  -> $(curl -s "localhost:$PORT$ASKED_AT_HOME")"
echo

case "$ROOT_ANSWER" in
	'[5,[0,"r"'*) echo "REPRODUCED: the layout loader was answered with the redirect of the index page's loader." ;;
	'[5,[0,"d"'*) echo "not reproduced: the layout loader answered with its own data." ;;
	*) echo "unexpected answer" ;;
esac
