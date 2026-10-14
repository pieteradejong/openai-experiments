#!/usr/bin/env bash
# test.sh — every check in one place, offline. Exit 0 = green. `run.sh test` runs this script.
#   ./test.sh            venv matches requirements, ruff (as CI), compile every tracked .py,
#                        pytest when tests exist, shell syntax and shellcheck, no tracked .env.
#                        Nothing here calls the OpenAI API.
#   ./test.sh --help     this text
set -euo pipefail
cd "$(dirname "$0")"
case "${1:-}" in -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

VENV=.venv
PY="$VENV/bin/python"
[ -x "$PY" ] || { echo "no $VENV: run ./init.sh first" >&2; exit 1; }

echo "== python"; "$PY" --version
echo "== deps"; "$PY" -m pip check
echo "== lint (ruff, as CI)"
if command -v ruff >/dev/null 2>&1; then git ls-files '*.py' | xargs ruff check
else echo "ruff not installed — skipped (brew install ruff)"; fi
echo "== compile (tracked .py)"
git ls-files '*.py' | xargs "$PY" -m compileall -q
echo "== unit"
if [ -n "$(git ls-files 'test_*.py' '*_test.py' 'tests/*' 'app/test*')" ]; then "$PY" -m pytest -q
else echo "no tests tracked — skipped"; fi
echo "== shell"
for f in ./*.sh; do bash -n "$f"; /bin/bash -n "$f"; done
if command -v shellcheck >/dev/null 2>&1; then shellcheck -S warning ./*.sh
else echo "shellcheck not installed — syntax-checked only (brew install shellcheck)"; fi
echo "== secrets"
tracked="$(git ls-files | grep -E '(^|/)\.env(\..+)?$' | grep -vE '\.env\.(example|template)$' || true)"
[ -z "$tracked" ] || { echo "tracked env files:"; echo "$tracked"; exit 1; }
echo "== all green"
