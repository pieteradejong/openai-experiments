#!/usr/bin/env bash
# run.sh — entry points. Run ./init.sh once first. Needs OPENAI_API_KEY and OPENAI_ORG_ID.
#   ./run.sh stream      app/main.py — one streamed chat completion printed to stdout
#   ./run.sh test        every check, offline (delegates to ./test.sh)
#   ./run.sh [help]      this text (default)
set -euo pipefail
cd "$(dirname "$0")"
VENV=.venv
PY="$VENV/bin/python"

cmd="${1:-help}"
[ $# -gt 0 ] && shift
case "$cmd" in
  help|-h|--help) sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  test) exec ./test.sh "$@" ;;
  stream) ;;
  *) echo "unknown command: $cmd" >&2; exit 2 ;;
esac
[ -x "$PY" ] || { echo "no $VENV: run ./init.sh first" >&2; exit 1; }
case "$cmd" in
  stream) cd app && exec ../"$PY" main.py "$@" ;;
  *) echo "unknown command: $cmd" >&2; sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2 ;;
esac
