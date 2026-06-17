#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE="$ROOT/docs/local-model-routing-baseline-20260617.md"
DOCTRINE="$ROOT/docs/speedrift-vnext-operating-doctrine-20260615.md"
README="$ROOT/README.md"

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "[FAIL] missing file: ${path#$ROOT/}"
    exit 1
  fi
}

require_text() {
  local needle="$1"
  local path="$2"
  if ! grep -Fq "$needle" "$path"; then
    echo "[FAIL] expected '${needle}' in ${path#$ROOT/}"
    exit 1
  fi
}

reject_text() {
  local needle="$1"
  local path="$2"
  if grep -Fq "$needle" "$path"; then
    echo "[FAIL] removed model reference '${needle}' found in ${path#$ROOT/}"
    exit 1
  fi
}

require_file "$BASELINE"
require_text "ollama/qwopus3.6:27b-mtp-q4" "$BASELINE"
require_text "ollama/gemma4:26b" "$BASELINE"
require_text "qwen3:8b" "$BASELINE"
require_text "Do not route to it" "$BASELINE"

require_text "local-model-routing-baseline-20260617.md" "$DOCTRINE"
require_text "docs/local-model-routing-baseline-20260617.md" "$README"

reject_text "diffusiongemma-26b-a4b-it-local" "$DOCTRINE"
reject_text "diffusiongemma-26b-a4b-it-local" "$README"

echo "Model routing policy verification passed."
