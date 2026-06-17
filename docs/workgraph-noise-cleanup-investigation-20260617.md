# Workgraph Noise Cleanup Investigation

Date: 2026-06-17

## Scope

Investigated stale or noisy Workgraph state under:

- `/Users/braydon`
- `/Users/braydon/projects`
- `/Users/braydon/projects/experiments/speedrift-ecosystem/.workgraph/service/ecosystem-central`

No destructive cleanup was performed. Findings below are based on filesystem
inventory, Speedrift runtime status, tmux agent status, central registry files,
and supported `wg` dry-run cleanup commands.

## Summary

The mess is real, but it is concentrated in a few buckets:

| Bucket | Evidence | Cleanup Posture |
| --- | ---: | --- |
| Central ecosystem history | `ecosystem-hub/history` is 51G; factory history is 776M; about 26k hub JSON files and 12.6k factory JSON files are older than 30 days | Add retention policy; compress or archive old snapshots; keep current register and recent history |
| Agent worktrees | 718 `.wg-worktrees/agent-*` dirs with `.workgraph` under `/Users/braydon/projects`; supported dry-run finds hundreds removable | Use `wg worktree gc --dead-only --older ... --execute` per repo after dry-run review |
| Superpowers worktrees | `/Users/braydon/.config/superpowers/worktrees` is 35G; several old Workgraph-bearing worktrees remain | Separate cleanup lane; verify branches/worktrees before archive/removal |
| Test/output graphs | Four `experiments/output/wg-drift-*` graphs from 2026-02-14 | Safe archive/delete candidates |
| Existing cleanup archive graphs | Two `.workgraph` dirs inside `/Users/braydon/projects/archive/cleanup/**` | Review archive retention; already archived, not active |
| Root/meta Workgraphs | `/Users/braydon/.workgraph` 16K, `/Users/braydon/projects/.workgraph` 4.7M, `/Users/braydon/projects/experiments/.workgraph` 81M | Review before removal; these may be intentional meta-graphs |

## Central Registry Findings

Current central register path:

```text
/Users/braydon/projects/experiments/speedrift-ecosystem/.workgraph/service/ecosystem-central/ecosystem-hub/register
```

Observed:

- only 8 current register JSON files exist there,
- generated timestamps range from 2026-03-06 to 2026-05-26,
- `ecosystem.toml` declares many more canonical repos than the current register mirrors,
- history directories are very large:
  - `ecosystem-hub/history`: 51G
  - `ecosystem-hub/factory/history`: 776M
  - `northstardrift`: 118M

History distribution:

| Repo | Files | Size |
| --- | ---: | ---: |
| driftdriver | 17,543 | 33G |
| paia-program | 8,914 | 18G |
| paia-shell | 204 | 217M |
| paia-memory | 54 | 187M |
| third-layer-news | 128 | 178M |
| folio | 61 | 135M |
| paia-os | 9 | 31M |
| meridian | 3 | 2.1M |

Factory history distribution:

| Project | Files | Size |
| --- | ---: | ---: |
| driftdriver | 13,329 | 776M |
| lfw-ai-graph-crm | 2 | 56K |
| grok-aurora-cli | 1 | 24K |

Recommended registry cleanup:

1. Keep current register files and the newest history snapshots per repo.
2. Add retention to the ecosystem hub writer:
   - keep last 7 days uncompressed,
   - keep daily rollups for 30 days,
   - compress or archive older raw snapshots,
   - cap per-repo raw snapshot count.
3. Add a freshness check that flags current register entries older than 24h
   when the hub daemon is expected to be active.
4. Rebuild the current register from `ecosystem.toml` plus live discovery so it
   reflects the canonical repo set.

## Agent Worktree Findings

Supported dry-runs:

```bash
wg --dir /Users/braydon/projects/experiments/paia-work/.workgraph worktree gc --older 30d --dead-only
wg --dir /Users/braydon/projects/experiments/paia-program/.workgraph worktree gc --older 14d --dead-only
wg --dir /Users/braydon/projects/experiments/state-system/.workgraph worktree gc --older 7d --dead-only
wg --dir /Users/braydon/projects/experiments/paia-agent-runtime/.workgraph worktree gc --older 2d --dead-only
```

Dry-run results:

| Repo | Candidate Worktrees | Age Filter | Notes |
| --- | ---: | --- | --- |
| paia-work | 428 | older than 30d | Mostly small 384K worktrees from late April |
| paia-program | 28 | older than 14d | Includes one 143M worktree plus many 8-11M worktrees |
| state-system | 37 | older than 7d | Mostly 580K-2.5M worktrees |
| paia-agent-runtime | 19 | older than 2d | Several 70-83M worktrees; use a longer age threshold if active work is suspected |

Parent distribution for agent worktrees with `.workgraph`:

| Parent | Count | Oldest | Newest |
| --- | ---: | --- | --- |
| `/Users/braydon/projects/experiments/paia-work` | 529 | 2026-04-28 | 2026-06-03 |
| `/Users/braydon/projects/experiments/paia-program` | 70 | 2026-04-28 | 2026-06-17 |
| `/Users/braydon/projects/experiments/state-system` | 37 | 2026-06-04 | 2026-06-04 |
| `/Users/braydon/projects/experiments/founder-finance` | 22 | 2026-05-03 | 2026-05-18 |
| `/Users/braydon/projects/experiments/eink-sync` | 21 | 2026-05-17 | 2026-05-27 |
| `/Users/braydon/projects/experiments/paia-agent-runtime` | 19 | 2026-06-14 | 2026-06-15 |

Recommended worktree cleanup:

1. Run `wg worktree gc --dead-only --older <threshold>` in dry-run mode for
   each repo.
2. Review the candidate list for any active tmux cwd, dirty worktree, or branch
   still needed.
3. Execute in conservative waves:
   - `paia-work`: start with `--older 30d`,
   - `paia-program`: start with `--older 21d` or `30d`, not today-active items,
   - `state-system`: start with `--older 14d`,
   - `paia-agent-runtime`: use `--older 7d` until the recent June 14-15 work is
     confirmed stale.
4. Use `wg worktree archive <agent-id> --remove` for any worktree with useful
   uncommitted work that should be preserved before removal.

## Root And Nested Graphs

Root/meta graphs:

| Path | Size | Notes |
| --- | ---: | --- |
| `/Users/braydon/.workgraph` | 16K | launcher/usage state, no graph.jsonl |
| `/Users/braydon/projects/.workgraph` | 4.7M | meta graph, 66 graph lines |
| `/Users/braydon/projects/experiments/.workgraph` | 81M | meta graph, 510 graph lines |

These should not be deleted automatically. They need an owner decision:

- keep as intentional portfolio/meta graphs,
- rename/archive if abandoned,
- or fold into `speedrift-ecosystem` central state.

Nested graphs worth reviewing:

- `*/web/.workgraph`
- `*/src/.workgraph`
- `paia-program/.workgraph/routing/.workgraph`
- `workgraph/test-workgraph/.workgraph`

These are not automatically unsafe, but they are context-polluting when broad
repo scans search for Workgraph roots.

## Proposed Cleanup Sequence

1. Add/commit a repeatable audit script for this inventory.
2. Add central registry retention to the hub writer.
3. Refresh/rebuild the current central register and add stale-register alerts.
4. Run per-repo `wg worktree gc` dry-runs and archive/remove dead worktrees in
   small batches.
5. Archive/delete obvious test/output graphs and stale cleanup-archive copies.
6. Decide owner policy for `/Users/braydon/projects/.workgraph` and
   `/Users/braydon/projects/experiments/.workgraph`.

## Safety Rules

- Do not remove canonical repo `.workgraph` directories declared in
  `ecosystem.toml`.
- Do not remove any worktree that is a tmux cwd.
- Do not remove dirty worktrees without archiving or explicitly deciding to
  discard.
- Prefer `wg worktree gc` / `wg cleanup orphaned` / `wg reap` over direct
  `rm -rf`.
- Central history cleanup should retain recent raw snapshots and roll up older
  history before deletion.
