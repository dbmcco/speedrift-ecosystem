#!/usr/bin/env bash
set -euo pipefail

ECOSYSTEM="${ECOSYSTEM:-/Users/braydon/projects/experiments/speedrift-ecosystem}"
ARCHIVE_BASE="${ARCHIVE_BASE:-/Users/braydon/projects/archive/cleanup}"
OLDER_DAYS="${OLDER_DAYS:-30}"
KEEP_PER_REPO="${KEEP_PER_REPO:-10}"
EXECUTE=0

usage() {
  cat <<'USAGE'
Usage: scripts/cleanup_central_history.sh [--execute]

Archives old Speedrift central hub history snapshots with zstd, verifies the
archive entry count, then removes only the archived originals.

Environment:
  ECOSYSTEM       speedrift-ecosystem checkout
  ARCHIVE_BASE   archive root, default /Users/braydon/projects/archive/cleanup
  OLDER_DAYS     archive files older than this many days, default 30
  KEEP_PER_REPO  always keep this many newest raw snapshots per repo, default 10
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      EXECUTE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v zstd >/dev/null 2>&1; then
  echo "zstd is required for central history cleanup" >&2
  exit 1
fi

cd "$ECOSYSTEM"

run_id="$(date -u +%Y-%m-%d-workgraph-central-history)"
archive_root="$ARCHIVE_BASE/$run_id"
mkdir -p "$archive_root/manifests" "$archive_root/archives"

build_manifest() {
  local label="$1"
  local root="$2"
  local manifest="$archive_root/manifests/${label}-files.txt"
  : > "$manifest"

  [[ -d "$root" ]] || return 0
  find "$root" -mindepth 1 -maxdepth 1 -type d | while read -r repo_dir; do
    find "$repo_dir" -type f -name '*.json' -mtime +"$OLDER_DAYS" -print |
      sort -r |
      awk -v keep="$KEEP_PER_REPO" 'NR > keep { print }' >> "$manifest"
  done
}

archive_manifest() {
  local label="$1"
  local root="$2"
  local manifest="$archive_root/manifests/${label}-files.txt"
  local archive="$archive_root/archives/${label}-history-older-than-${OLDER_DAYS}d-keep${KEEP_PER_REPO}.tar.zst"
  local count

  count="$(wc -l < "$manifest" | tr -d ' ')"
  printf "%s_candidates\t%s\n" "$label" "$count"
  [[ "$count" -gt 0 ]] || return 0

  if [[ "$EXECUTE" -eq 0 ]]; then
    echo "dry-run: would archive to $archive"
    return 0
  fi

  tar -cf - -T "$manifest" | zstd -T0 -3 -o "$archive"
  zstd -t "$archive"

  local listed
  listed="$(zstd -dc "$archive" | tar -tf - | wc -l | tr -d ' ')"
  if [[ "$listed" != "$count" ]]; then
    echo "entry count mismatch for $label: manifest=$count archive=$listed" >&2
    exit 1
  fi

  while IFS= read -r file; do
    rm -f "$file"
  done < "$manifest"
  find "$root" -type d -empty -delete

  printf "%s_archive\t%s\n" "$label" "$archive"
  printf "%s_archive_size\t%s\n" "$label" "$(du -sh "$archive" | awk '{print $1}')"
  printf "%s_remaining_files\t%s\n" "$label" "$(find "$root" -type f -name '*.json' | wc -l | tr -d ' ')"
}

hub_root=".workgraph/service/ecosystem-central/ecosystem-hub/history"
factory_root=".workgraph/service/ecosystem-central/ecosystem-hub/factory/history"

build_manifest hub "$hub_root"
build_manifest factory "$factory_root"

archive_manifest hub "$hub_root"
archive_manifest factory "$factory_root"

if [[ "$EXECUTE" -eq 1 ]]; then
  jq -n \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg scope "$ECOSYSTEM/.workgraph/service/ecosystem-central/ecosystem-hub" \
    --argjson older_than_days "$OLDER_DAYS" \
    --argjson keep_newest_per_repo "$KEEP_PER_REPO" \
    '{timestamp:$timestamp, scope:$scope, recursive:true, cleanup_type:"speedrift-central-history-retention", policy:{older_than_days:$older_than_days, keep_newest_per_repo:$keep_newest_per_repo, archive_then_verify_before_remove:true}, reviewed:false, review_date:null}' \
    > "$archive_root/metadata.json"
  echo "metadata	$archive_root/metadata.json"
fi
