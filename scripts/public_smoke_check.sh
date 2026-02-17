#!/usr/bin/env bash
set -euo pipefail

REPOS=(
  speedrift-ecosystem
  driftdriver
  coredrift
  redrift
  specdrift
  datadrift
  depsdrift
  uxdrift
  therapydrift
  yagnidrift
)

echo "== Public repo reachability =="
for repo in "${REPOS[@]}"; do
  url="https://github.com/dbmcco/${repo}.git"
  if git ls-remote --heads "$url" >/dev/null 2>&1; then
    echo "[OK] $url"
  else
    echo "[FAIL] cannot read $url anonymously"
    exit 1
  fi
done

echo
echo "== Public story deck reachability =="
DECK_URL="https://dbmcco.github.io/speedrift-ecosystem/decks/speedrift-ecosystem-story.html"
if curl -fsSL "$DECK_URL" >/dev/null; then
  echo "[OK] $DECK_URL"
else
  echo "[FAIL] cannot reach $DECK_URL"
  exit 1
fi

echo
echo "== Local CLI presence =="
REQUIRED_CMDS=(
  wg
  driftdriver
  coredrift
  specdrift
  datadrift
  depsdrift
  therapydrift
  yagnidrift
  redrift
)
for cmd in "${REQUIRED_CMDS[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd"
  else
    echo "[FAIL] missing command on PATH: $cmd"
    echo "Install with pipx using README instructions, then re-run this script."
    exit 1
  fi
done

echo
echo "== Quickstart behavior smoke run =="
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

cd "$TMP_DIR"
wg init >/dev/null
wg add --id start-1 "Bootstrap speedrift" --description "Create first speedrift task" >/dev/null
wg claim start-1 >/dev/null
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift >/dev/null
./.workgraph/coredrift ensure-contracts --apply >/dev/null
./.workgraph/drifts check --task start-1 --write-log --create-followups >/dev/null

if wg show start-1 | grep -q "Coredrift:"; then
  echo "[OK] drift check log written to task start-1"
else
  echo "[FAIL] drift check did not produce a Coredrift log entry"
  exit 1
fi

echo
echo "Public smoke check passed."
