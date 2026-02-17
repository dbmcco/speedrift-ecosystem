# Known Limitations (Public Beta)

Last updated: February 17, 2026.

## Packaging

- `uxdrift` is not yet distributed as a `pipx` app. Use the repo-local entrypoint (`./bin/uxdrift`) for now.
- Most modules are currently installed from GitHub (`pipx install git+https://...`) rather than pinned package releases.

## Stability

- Config fields and defaults may change across modules as beta feedback lands.
- Artifact formats are still being normalized across lanes.

## Operational Scope

- The suite is optimized for Workgraph-first flows. Non-Workgraph projects currently need custom wiring.
- Multi-agent daemon/orchestration patterns are still evolving; use bounded loops and explicit phase checks for long runs.

## Recommended Beta Practice

- Run the full quickstart smoke flow in a throwaway repo before applying to production repos.
- Enable only the drift lanes you need for the current domain to keep loops understandable.
