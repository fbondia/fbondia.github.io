#!/usr/bin/env bash

set -Eeuo pipefail

PDF_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PDF_PROJECT_DIR="$(cd "$PDF_SCRIPT_DIR/.." && pwd)"
PDF_LANGUAGE="${1:-all}"
PDF_OUTPUT_DIR="${2:-$PDF_PROJECT_DIR/output/pdf}"
PDF_WORK_DIR="$(mktemp -d -t fbondia-resume-pdf.XXXXXX)"
PDF_SERVER_PID=""

usage() {
  echo "Usage: $0 [en|pt|all] [output-directory]"
}

cleanup() {
  if [[ -n "$PDF_SERVER_PID" ]]; then
    kill "$PDF_SERVER_PID" 2>/dev/null || true
    wait "$PDF_SERVER_PID" 2>/dev/null || true
  fi

  if [[ -d "$PDF_WORK_DIR" && "$PDF_WORK_DIR" == */fbondia-resume-pdf.* ]]; then
    rm -rf -- "$PDF_WORK_DIR"
  fi
}

trap cleanup EXIT INT TERM

case "$PDF_LANGUAGE" in
  en|pt|all) ;;
  *)
    usage
    exit 2
    ;;
esac

find_chrome() {
  if [[ -n "${CHROME_BIN:-}" && -x "$CHROME_BIN" ]]; then
    echo "$CHROME_BIN"
    return
  fi

  local candidate
  for candidate in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done

  for candidate in google-chrome chromium chromium-browser; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return
    fi
  done

  echo "Chrome, Chromium, or Microsoft Edge was not found." >&2
  echo "Set CHROME_BIN to the browser executable and try again." >&2
  exit 1
}

if command -v rbenv >/dev/null 2>&1; then
  PDF_BUNDLE_COMMAND=(rbenv exec bundle)
else
  PDF_BUNDLE_COMMAND=(bundle)
fi

PDF_CHROME_BIN="$(find_chrome)"
PDF_BUILD_DIR="$PDF_WORK_DIR/site"
PDF_SERVER_LOG="$PDF_WORK_DIR/server.log"
PDF_PORT="${PDF_PORT:-$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')}"

mkdir -p "$PDF_OUTPUT_DIR"

echo "Building the Jekyll site..."
(
  cd "$PDF_PROJECT_DIR"
  "${PDF_BUNDLE_COMMAND[@]}" exec jekyll build --destination "$PDF_BUILD_DIR"
)

python3 -m http.server "$PDF_PORT" \
  --bind 127.0.0.1 \
  --directory "$PDF_BUILD_DIR" \
  >"$PDF_SERVER_LOG" 2>&1 &
PDF_SERVER_PID=$!

for _ in {1..50}; do
  if curl --silent --fail "http://127.0.0.1:$PDF_PORT/" >/dev/null; then
    break
  fi
  sleep 0.1
done

if ! curl --silent --fail "http://127.0.0.1:$PDF_PORT/" >/dev/null; then
  echo "The local preview server did not start." >&2
  cat "$PDF_SERVER_LOG" >&2
  exit 1
fi

generate_pdf() {
  local language="$1"
  local output_file="$PDF_OUTPUT_DIR/resume-$language.pdf"
  local page_url="http://127.0.0.1:$PDF_PORT/$language/resume.html"
  local chrome_profile="$PDF_WORK_DIR/chrome-$language"
  local chrome_log="$PDF_WORK_DIR/chrome-$language.log"
  local chrome_pid
  local current_size=0
  local previous_size=0
  local stable_checks=0

  echo "Generating $output_file..."
  rm -f -- "$output_file"
  "$PDF_CHROME_BIN" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --no-pdf-header-footer \
    --run-all-compositor-stages-before-draw \
    --virtual-time-budget=2000 \
    --user-data-dir="$chrome_profile" \
    --print-to-pdf="$output_file" \
    "$page_url" \
    >"$chrome_log" 2>&1 &
  chrome_pid=$!

  for _ in {1..300}; do
    if [[ -s "$output_file" ]]; then
      current_size="$(wc -c <"$output_file" | tr -d ' ')"
      if [[ "$current_size" == "$previous_size" ]]; then
        stable_checks=$((stable_checks + 1))
      else
        stable_checks=0
        previous_size="$current_size"
      fi

      if [[ "$stable_checks" -ge 5 ]]; then
        break
      fi
    fi

    if ! kill -0 "$chrome_pid" 2>/dev/null; then
      break
    fi
    sleep 0.1
  done

  if kill -0 "$chrome_pid" 2>/dev/null; then
    kill "$chrome_pid" 2>/dev/null || true
  fi
  wait "$chrome_pid" 2>/dev/null || true

  if [[ ! -s "$output_file" ]]; then
    echo "Failed to generate $output_file." >&2
    cat "$chrome_log" >&2
    exit 1
  fi
}

if [[ "$PDF_LANGUAGE" == "en" || "$PDF_LANGUAGE" == "all" ]]; then
  generate_pdf en
fi

if [[ "$PDF_LANGUAGE" == "pt" || "$PDF_LANGUAGE" == "all" ]]; then
  generate_pdf pt
fi

echo "PDF generation completed."
