# Speedrift Ecosystem

Canonical suite repo for the Speedrift drift-control ecosystem.

This repo is the top-level map and operator guide. Each drift module remains a discrete CLI repo.

## Naming Model

- Suite name: `speedrift` (ecosystem)
- Orchestrator CLI: `driftdriver`
- Baseline lane: `speedrift`
- Optional lanes: `specdrift`, `datadrift`, `depsdrift`, `uxdrift`, `therapydrift`, `yagnidrift`
- Rebuild lane: `redrift`

This is intentional: `driftdriver` coordinates lanes; `speedrift` is one lane, not the full orchestrator.

## Repo Map

| Repo | Role | URL |
|---|---|---|
| driftdriver | Workgraph orchestration + policy + wrappers | https://github.com/dbmcco/driftdriver |
| speedrift | baseline drift telemetry + redirect | https://github.com/dbmcco/speedrift |
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
pipx install git+https://github.com/dbmcco/speedrift.git

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
./.workgraph/speedrift ensure-contracts --apply
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

## Validation

Run ecosystem-level checks from this repo:

```bash
./scripts/verify_ecosystem.sh
```
