#!/usr/bin/env bash
# init.sh — venv with pinned dependencies. Idempotent: reuses .venv/; --clean rebuilds it.
#   ./init.sh            create or reuse .venv/, install requirements.txt
#   ./init.sh --clean    remove .venv/ first
#   ./init.sh --help     this text
# Runtime needs OPENAI_API_KEY and OPENAI_ORG_ID in the environment (not stored here).
set -euo pipefail
cd "$(dirname "$0")"
case "${1:-}" in -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

VENV=.venv
# fastapi 0.97 / pydantic 1.x: CI tests 3.9–3.11, so prefer 3.11, then 3.12.
pick_python() {
  local p
  for p in python3.11 python3.12 python3; do
    command -v "$p" >/dev/null 2>&1 && { echo "$p"; return 0; }
  done
  echo "python3 not found" >&2; return 1
}
PYTHON="${PYTHON:-$(pick_python)}"

[ "${1:-}" = "--clean" ] && rm -rf "$VENV"
if [ -x "$VENV/bin/python" ] && ! "$VENV/bin/python" -c 'import sys' >/dev/null 2>&1; then
  echo "$VENV points at an interpreter that no longer exists; rebuilding"; rm -rf "$VENV"
fi
if [ -x "$VENV/bin/python" ]; then echo "reusing $VENV ($("$VENV/bin/python" --version))"
else echo "creating $VENV with $PYTHON"; "$PYTHON" -m venv "$VENV"; fi
"$VENV/bin/python" -m pip install --quiet --disable-pip-version-check -r requirements.txt
echo "ready: export OPENAI_API_KEY OPENAI_ORG_ID; ./run.sh stream"
