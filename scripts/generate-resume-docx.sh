#!/usr/bin/env bash

set -Eeuo pipefail

DOCX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCX_PROJECT_DIR="$(cd "$DOCX_SCRIPT_DIR/.." && pwd)"
DOCX_LANGUAGE="${1:-all}"
DOCX_OUTPUT_DIR="${2:-$DOCX_PROJECT_DIR/output/docx}"
DOCX_BUNDLED_PYTHON="/Users/fbondia/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"

case "$DOCX_LANGUAGE" in
  en|pt|all) ;;
  *)
    echo "Usage: $0 [en|pt|all] [output-directory]" >&2
    exit 2
    ;;
esac

if [[ -n "${DOCX_PYTHON:-}" ]]; then
  DOCX_PYTHON_BIN="$DOCX_PYTHON"
elif [[ -x "$DOCX_BUNDLED_PYTHON" ]]; then
  DOCX_PYTHON_BIN="$DOCX_BUNDLED_PYTHON"
else
  DOCX_PYTHON_BIN="$(command -v python3)"
fi

if ! "$DOCX_PYTHON_BIN" -c 'import docx, PIL' >/dev/null 2>&1; then
  echo "The selected Python runtime needs python-docx and Pillow." >&2
  echo "Set DOCX_PYTHON to a compatible Python executable and try again." >&2
  exit 1
fi

mkdir -p "$DOCX_OUTPUT_DIR"

"$DOCX_PYTHON_BIN" "$DOCX_SCRIPT_DIR/generate-resume-docx.py" \
  "$DOCX_LANGUAGE" \
  "$DOCX_OUTPUT_DIR" \
  "$DOCX_PROJECT_DIR"

