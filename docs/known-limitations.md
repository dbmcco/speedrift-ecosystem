# Known Limitations (Public Beta)

Last updated: April 15, 2026.

## Packaging

- Most modules are currently installed from GitHub (`pipx install git+https://...`) rather than pinned package releases.

## Stability

- Config fields and defaults may change across modules as beta feedback lands.
- Artifact formats are still being normalized across lanes.

## Operational Scope

- The suite is optimized for Workgraph-first flows. Non-Workgraph projects currently need custom wiring.
- Multi-agent daemon/orchestration patterns are still evolving; use bounded loops and explicit phase checks for long runs.

## Dashboard Freshness

- The hub serves periodic snapshots rather than recomputing every repo on every request.
- During heavy coordinator churn, per-repo task counts or service fields can lag reality by up to the collector interval.
- Use the websocket/live refresh path for current operator awareness; treat static API reads as a near-real-time control snapshot, not a hard transactional view.

## Control Repo State

- This repo keeps local hub runtime data under `.workgraph/`.
- That directory is operational state for the control plane and is intentionally not part of the committed source tree.

## Recommended Beta Practice

- Run the full quickstart smoke flow in a throwaway repo before applying to production repos.
- Enable only the drift lanes you need for the current domain to keep loops understandable.
