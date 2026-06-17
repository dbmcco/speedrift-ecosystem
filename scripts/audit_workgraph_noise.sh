#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-/Users/braydon}"
PROJECTS="${PROJECTS:-/Users/braydon/projects}"
ECOSYSTEM="${ECOSYSTEM:-/Users/braydon/projects/experiments/speedrift-ecosystem}"

echo "== Workgraph directory inventory =="
{
  find "$ROOT" \
    \( -path '*/Library' -o -path '*/node_modules' -o -path '*/.git' -o -path '*/target' -o -path '*/dist' -o -path '*/build' -o -path '*/.venv' -o -path '*/venv' -o -path '*/__pycache__' -o -path '*/.cache' \) -prune \
    -o \( -name .workgraph -o -name .wg \) -print 2>/dev/null || true
} |
  sort |
  awk '
    /\/archive\/cleanup\// {archive++ ; next}
    /\/output\/wg-drift/ {output++ ; next}
    /\/\.wg-worktrees\/agent-/ {agentwt++ ; next}
    /\/\.config\/superpowers\/worktrees\// {superwt++ ; next}
    /\/\.worktrees\// {repo_wt++ ; next}
    /\/web\/\.workgraph$/ {nestedweb++ ; next}
    /\/src\/\.workgraph$/ {nestedsrc++ ; next}
    /\/test-workgraph\/\.workgraph$/ {testgraph++ ; next}
    {normal++}
    END {
      printf "archive_cleanup\t%d\n", archive+0
      printf "output_test\t%d\n", output+0
      printf "agent_worktrees\t%d\n", agentwt+0
      printf "superpowers_worktrees\t%d\n", superwt+0
      printf "repo_worktrees\t%d\n", repo_wt+0
      printf "nested_web\t%d\n", nestedweb+0
      printf "nested_src\t%d\n", nestedsrc+0
      printf "test_graphs\t%d\n", testgraph+0
      printf "normal_or_review\t%d\n", normal+0
    }'

echo
echo "== Large known buckets =="
for path in \
  "$PROJECTS/experiments/speedrift-ecosystem/.workgraph/service/ecosystem-central/ecosystem-hub/history" \
  "$PROJECTS/experiments/speedrift-ecosystem/.workgraph/service/ecosystem-central/ecosystem-hub/factory/history" \
  "$PROJECTS/experiments/speedrift-ecosystem/.workgraph/service/ecosystem-central/northstardrift" \
  "$HOME/.config/superpowers/worktrees" \
  "$PROJECTS/experiments/paia-program/.wg-worktrees" \
  "$PROJECTS/experiments/state-system/.wg-worktrees" \
  "$PROJECTS/experiments/paia-work/.wg-worktrees" \
  "$PROJECTS/experiments/paia-agent-runtime/.wg-worktrees"; do
  if [[ -e "$path" ]]; then
    du -sh "$path" 2>/dev/null || true
  fi
done

echo
echo "== Central register =="
register="$ECOSYSTEM/.workgraph/service/ecosystem-central/ecosystem-hub/register"
factory_register="$ECOSYSTEM/.workgraph/service/ecosystem-central/ecosystem-hub/factory/register"
if [[ -d "$register" ]]; then
  printf "current_register_json\t%s\n" "$(find "$register" -maxdepth 1 -type f -name '*.json' | wc -l | tr -d ' ')"
  find "$register" -maxdepth 1 -type f -name '*.json' -print |
    while read -r file; do
      generated="$(jq -r '.generated_at // "unknown"' "$file" 2>/dev/null || echo unknown)"
      project="$(jq -r '.project_dir // .project // "unknown"' "$file" 2>/dev/null || echo unknown)"
      printf "%s\t%s\t%s\n" "$(basename "$file")" "$generated" "$project"
    done |
    sort
fi
if [[ -d "$factory_register" ]]; then
  printf "factory_register_json\t%s\n" "$(find "$factory_register" -maxdepth 1 -type f -name '*.json' | wc -l | tr -d ' ')"
fi

echo
echo "== Central history by repo =="
history="$ECOSYSTEM/.workgraph/service/ecosystem-central/ecosystem-hub/history"
if [[ -d "$history" ]]; then
  find "$history" -mindepth 1 -maxdepth 1 -type d |
    while read -r dir; do
      size="$(du -sh "$dir" 2>/dev/null | awk '{print $1}')"
      printf "%s\t%s\t%s\n" "$(basename "$dir")" "$(find "$dir" -type f -name '*.json' | wc -l | tr -d ' ')" "${size:-unknown}"
    done |
    sort
fi

echo
echo "== Supported worktree GC dry-run examples =="
for spec in \
  "/Users/braydon/projects/experiments/paia-work/.workgraph|30d" \
  "/Users/braydon/projects/experiments/paia-program/.workgraph|21d" \
  "/Users/braydon/projects/experiments/state-system/.workgraph|14d" \
  "/Users/braydon/projects/experiments/paia-agent-runtime/.workgraph|7d"; do
  dir="${spec%%|*}"
  older="${spec##*|}"
  if [[ -d "$dir" ]]; then
    echo "--- $dir older=$older"
    wg --dir "$dir" worktree gc --older "$older" --dead-only | sed -n '1,40p'
  fi
done
