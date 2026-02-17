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
PRIVATE_REPOS=(
  archdrift
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

if command -v gh >/dev/null 2>&1; then
  echo
  echo "== Private lane reachability (authenticated) =="
  for repo in "${PRIVATE_REPOS[@]}"; do
    if gh repo view "dbmcco/$repo" --json name,visibility >/dev/null 2>&1; then
      vis="$(gh repo view "dbmcco/$repo" --json visibility -q .visibility)"
      echo "[OK] dbmcco/$repo ($vis)"
    else
      echo "[WARN] dbmcco/$repo not reachable via gh auth (skipping)"
    fi
  done
fi

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
  archdrift
  depsdrift
  uxdrift
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
