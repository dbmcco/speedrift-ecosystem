# Speedrift Ecosystem

Canonical suite repo for the Speedrift drift-control ecosystem.

This repo is the top-level map and operator guide. Each drift module remains a discrete CLI repo.

## Why Speedrift

Agentic coding now outpaces human supervision. In that gap, projects accumulate:

- code drift (fix-on-fix behavior and local workarounds)
- spec drift (implementation diverges from agreed intent)
- task/intent drift (agents optimize for the moment instead of the plan)
- loop drift (self-healing or guardrail layers can recurse without clear bounds)

Speedrift exists to preserve development speed while continuously countersteering toward shared intent.
The core design is:

- **Workgraph as spine**: one shared source of task truth and dependency flow.
- **Driftdriver as pit wall**: unified routing, policy, and wrapper orchestration.
- **Drift lanes as control loops**: focused checks that log, redirect, and spawn follow-ups instead of hard-blocking by default.

This lets teams run parallel agents with lower supervision overhead and fewer hidden divergence costs.

## Story Deck

For the narrative, ecosystem map, and workflow graphics:

- `docs/decks/speedrift-ecosystem-story.html`

## Naming Model

- Suite name: `speedrift` (ecosystem)
- Orchestrator CLI: `driftdriver`
- Baseline lane: `coredrift`
- Optional lanes: `specdrift`, `datadrift`, `depsdrift`, `uxdrift`, `therapydrift`, `yagnidrift`
- Rebuild lane: `redrift`

This is intentional: `driftdriver` coordinates lanes; suite naming (`speedrift`) is separate from lane naming (`coredrift`).

## Repo Map

| Repo | Role | URL |
|---|---|---|
| driftdriver | Workgraph orchestration + policy + wrappers | https://github.com/dbmcco/driftdriver |
| coredrift | baseline drift telemetry + redirect | https://github.com/dbmcco/coredrift |
| specdrift | spec/code drift | https://github.com/dbmcco/specdrift |
| datadrift | data/schema drift | https://github.com/dbmcco/datadrift |
| depsdrift | dependency drift | https://github.com/dbmcco/depsdrift |
| uxdrift | UX task/design drift | https://github.com/dbmcco/uxdrift |
| therapydrift | self-healing/loop quality lane | https://github.com/dbmcco/therapydrift |
| yagnidrift | overbuild and complexity drift | https://github.com/dbmcco/yagnidrift |
| redrift | v1->v2 re-spec/rebuild lane | https://github.com/dbmcco/redrift |

## Quick Start (Any App Repo)

```bash
# install core
pipx install git+https://github.com/dbmcco/driftdriver.git
pipx install git+https://github.com/dbmcco/coredrift.git

# install optional lanes as needed
pipx install git+https://github.com/dbmcco/specdrift.git
pipx install git+https://github.com/dbmcco/datadrift.git
pipx install git+https://github.com/dbmcco/depsdrift.git
pipx install git+https://github.com/dbmcco/uxdrift.git
pipx install git+https://github.com/dbmcco/therapydrift.git
pipx install git+https://github.com/dbmcco/yagnidrift.git
pipx install git+https://github.com/dbmcco/redrift.git

# inside your app repo
wg init
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
```

For each claimed task, run:

```bash
./.workgraph/drifts check --task <task_id> --write-log --create-followups
```

Continuous pit-wall mode:

```bash
./.workgraph/drifts orchestrate --write-log --create-followups
```

## Operational Rule

Use the suite through `./.workgraph/drifts` for coordinated runs.
Use lane CLIs directly when you explicitly want a single-lane workflow.

## Migration (speedrift lane -> coredrift)

If an older repo still has `./.workgraph/speedrift`, reinstall wrappers:

```bash
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
```

Then run:

```bash
./.workgraph/coredrift ensure-contracts --apply
```

Legacy lane repo `dbmcco/speedrift` is retained only as a deprecation pointer.

## Validation

Run ecosystem-level checks from this repo:

```bash
./scripts/verify_ecosystem.sh
```
