#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCTRINE="$ROOT/docs/speedrift-vnext-operating-doctrine-20260615.md"
BASELINE="$ROOT/docs/local-model-routing-baseline-20260617.md"
SCHEMA="${PLANFORGE_SCHEMA_PATH:-}"
POLICY="$ROOT/.workgraph/drift-policy.toml"
README="$ROOT/README.md"
EXECUTORS=(
  "$ROOT/.workgraph/executors/codex.toml"
  "$ROOT/.workgraph/executors/claude.toml"
  "$ROOT/.workgraph/executors/session-driver.toml"
)

if [[ -z "$SCHEMA" ]]; then
  for candidate in \
    "$ROOT/../braydon-workspace-skills/skills/planforge/schemas/planforge-plan-v2.schema.json" \
    "$ROOT/../claude-agent-toolkit/skills/planforge/schemas/planforge-plan-v2.schema.json" \
    "$ROOT/../../claude-agent-toolkit/skills/planforge/schemas/planforge-plan-v2.schema.json"; do
    if [[ -f "$candidate" ]]; then
      SCHEMA="$candidate"
      break
    fi
  done
fi

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
  if ! grep -Fiq "$needle" "$path"; then
    echo "[FAIL] expected '${needle}' in ${path#$ROOT/}"
    exit 1
  fi
}

reject_text() {
  local needle="$1"
  local path="$2"
  if grep -Fq "$needle" "$path"; then
    echo "[FAIL] forbidden text '${needle}' found in ${path#$ROOT/}"
    exit 1
  fi
}

require_schema_required() {
  local object_path="$1"
  shift
  python3 - "$SCHEMA" "$object_path" "$@" <<'PY'
import json
import sys
from pathlib import Path

schema_path = Path(sys.argv[1])
object_path = sys.argv[2]
fields = sys.argv[3:]
schema = json.loads(schema_path.read_text())

node = schema
for part in object_path.split("."):
    if not part:
        continue
    node = node[part]

required = set(node.get("required", []))
missing = [field for field in fields if field not in required]
if missing:
    print(f"[FAIL] schema {object_path}.required missing: {', '.join(missing)}")
    sys.exit(1)
PY
}

require_toml_enabled() {
  local path="$1"
  shift
  python3 - "$path" "$@" <<'PY'
import sys
import tomllib
from pathlib import Path

policy = tomllib.loads(Path(sys.argv[1]).read_text())
sections = sys.argv[2:]
missing = []
disabled = []
for section in sections:
    value = policy.get(section)
    if not isinstance(value, dict):
        missing.append(section)
    elif value.get("enabled") is not True:
        disabled.append(section)

if missing:
    print(f"[FAIL] missing drift policy sections: {', '.join(missing)}")
    sys.exit(1)
if disabled:
    print(f"[FAIL] drift policy sections not enabled=true: {', '.join(disabled)}")
    sys.exit(1)
PY
}

require_file "$DOCTRINE"
require_file "$BASELINE"
require_file "$SCHEMA"
require_file "$POLICY"
require_file "$README"

echo "== Doctrine and baseline =="
require_text "Adversarial review is valuable when it is bounded" "$DOCTRINE"
require_text "Roborev is automatic for material diffs" "$DOCTRINE"
require_text "Unit tests" "$DOCTRINE"
require_text "Integration tests" "$DOCTRINE"
require_text "End-user UX or e2e tests" "$DOCTRINE"
require_text "If a test class is not applicable" "$DOCTRINE"
require_text "Agency is the default composition layer" "$DOCTRINE"
require_text "local-model-routing-baseline-20260617.md" "$DOCTRINE"
require_text "ollama/qwopus3.6:27b-mtp-q4" "$BASELINE"
require_text "ollama/gemma4:26b" "$BASELINE"
require_text "qwen3:8b" "$BASELINE"
reject_text "diffusiongemma-26b-a4b-it-local" "$DOCTRINE"

echo "== PlanForge schema =="
require_schema_required "" \
  agency_plan \
  review_plan \
  adversarial_review \
  handoff_quality
require_schema_required "\$defs.workgraph_node" \
  read_first \
  implementation_steps \
  edge_cases \
  rollback_notes \
  roborev_required \
  agency_profile \
  handoff_detail_level \
  small_model_ready \
  escalation_conditions \
  routing

for field in \
  agency_plan \
  review_plan \
  adversarial_review \
  handoff_quality \
  read_first \
  implementation_steps \
  edge_cases \
  rollback_notes \
  roborev_required \
  agency_profile \
  handoff_detail_level \
  small_model_ready \
  escalation_conditions \
  routing; do
  require_text "\"$field\"" "$SCHEMA"
done

for module in \
  qadrift \
  secdrift \
  plandrift \
  factorydrift \
  northstardrift \
  evolverdrift \
  debatedrift \
  reviewdrift \
  agencydrift; do
  require_text "\"$module\"" "$SCHEMA"
done

echo "== Drift policy =="
require_toml_enabled "$POLICY" qadrift plandrift northstardrift speedriftd
require_text "require_integration_tests = true" "$POLICY"
require_text "require_e2e_tests = true" "$POLICY"
require_text "respect_manual_claims = true" "$POLICY"

echo "== Executor envelope =="
for path in "${EXECUTORS[@]}"; do
  require_file "$path"
  require_text "Speedrift vNext Envelope" "$path"
  require_text "Agency" "$path"
  require_text "roborev" "$path"
  require_text "unit" "$path"
  require_text "integration" "$path"
  require_text "UX" "$path"
  require_text "Small Model Ready" "$path"
  require_text "drifts check" "$path"
  require_text "wg log" "$path"
done

echo "== README =="
require_text "verify_speedrift_vnext_policy.sh" "$README"
require_text "verify_model_routing_policy.sh" "$README"

echo "Speedrift vNext policy verification passed."
