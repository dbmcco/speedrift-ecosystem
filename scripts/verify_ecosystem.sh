#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/Users/braydon/projects/experiments}"
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

echo "== Local checkout validation =="
for repo in "${REPOS[@]}"; do
  dir="$ROOT/$repo"
  if [[ ! -d "$dir/.git" ]]; then
    echo "[FAIL] $repo missing at $dir"
    exit 1
  fi
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  status="$(git -C "$dir" status --porcelain)"
  origin="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
  if [[ -z "$origin" ]]; then
    echo "[FAIL] $repo has no origin remote"
    exit 1
  fi
  if [[ -n "$status" ]]; then
    echo "[FAIL] $repo is dirty on branch $branch"
    exit 1
  fi
  echo "[OK] $repo clean on $branch ($origin)"
done

if ! command -v gh >/dev/null 2>&1; then
  echo "gh not found; skipping remote visibility checks."
  exit 0
fi

echo
echo "== Remote repo visibility =="
for repo in "${REPOS[@]}"; do
  if gh repo view "dbmcco/$repo" --json name,visibility >/dev/null 2>&1; then
    vis="$(gh repo view "dbmcco/$repo" --json visibility -q .visibility)"
    echo "[OK] dbmcco/$repo ($vis)"
  else
    echo "[FAIL] dbmcco/$repo not reachable"
    exit 1
  fi
done

echo
echo "Ecosystem verification passed."
