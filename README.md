# Speedrift Ecosystem

Speedrift is a drift control system for agentic software development. It keeps plans, code, specs, and decisions synchronized while agents work at full speed.

[Workgraph](https://graphwork.github.io/) is the execution spine — task graph, dependencies, agent dispatch. Speedrift wraps it with 10 specialized drift lanes, an ecosystem intelligence layer, a model-mediated judgment architecture, and a full-loop project autopilot.

**[See the story deck](https://dbmcco.github.io/speedrift-ecosystem/decks/speedrift-ecosystem-story.html)** — arrow keys or footer controls to navigate

## Quick Reference

> **Reading intent:** This README is written for both AI coding agents and humans. Agents: the quick reference below is your operational playbook — scan it before doing anything in a speedrift-enabled repo. The narrative sections that follow provide architectural context and rationale. Humans: same applies, just slower.

### When to do what

| Situation | Command |
|-----------|---------|
| **New repo, first time** | `wg init && driftdriver install` then `coredrift ensure-contracts --apply` |
| **Returning to existing repo** | `driftdriver install` (idempotent) then `coredrift ensure-contracts --apply` |
| **Full autonomous run** | `driftdriver autopilot --goal "your goal"` |
| **Per-task drift check** | `./.workgraph/drifts check --task <id> --write-log --create-followups` |
| **Continuous drift monitor** | `./.workgraph/drifts orchestrate --write-log --create-followups` |
| **All lanes on a complex task** | `./.workgraph/drifts check --task <id> --lane-strategy all --write-log --create-followups` |
| **Brownfield rebuild** | `./.workgraph/redrift wg execute --task <id> --v2-repo <path> --write-log --phase-checks` |

### Where state lives

| Path | Contents |
|------|----------|
| `.workgraph/` | Task graph, wrappers (`drifts`, `coredrift`, etc.), logs |
| `.workgraph/.autopilot/` | Autopilot state: `run-state.json`, `workers.jsonl`, `milestone-review.md` |
| `.workgraph/.driftdriver/reviews/` | Ecosystem scan history (JSON + Markdown snapshots) |
| `.workgraph/output/` | Drift check output logs per task |
| Task descriptions | `wg-contract` blocks (acceptance criteria) and fenced `specrift`/`uxdrift` blocks (lane config) |

### Conventions

1. **Drift is advisory, not blocking.** Findings create follow-up tasks and log entries — never block the current task.
2. **Follow-ups over hidden fixes.** Out-of-scope drift becomes a new workgraph task, not a silent fix.
3. **Contracts on every task.** Run `coredrift ensure-contracts --apply` to auto-generate missing ones.
4. **Always `--write-log --create-followups`.** Findings must be auditable and trackable.
5. **Workers are full agents.** In autopilot, each worker is a full Claude Code session. The controller orchestrates; workers do the work.
6. **Evidence over assumptions.** "The controller doesn't do X" ≠ "X isn't done." Trace actual code paths.

### Key CLIs

| CLI | Install | Purpose |
|-----|---------|---------|
| `wg` | [graphwork/workgraph](https://github.com/graphwork/workgraph) | Task graph: `init`, `add`, `claim`, `done`, `show`, `log`, `ready` |
| `driftdriver` | `pipx install git+https://github.com/dbmcco/driftdriver.git` | Orchestrator: `install`, `autopilot`, `scan`, ecosystem monitoring |
| `coredrift` | `pipx install git+https://github.com/dbmcco/coredrift.git` | Baseline drift lane + contract management |
| Lane CLIs | `pipx install git+https://github.com/dbmcco/<lane>.git` | `specdrift`, `datadrift`, `archdrift`, `depsdrift`, `uxdrift`, `therapydrift`, `yagnidrift`, `redrift` |

---

## North Star

**Goal in. Done out.** The system decomposes work, dispatches parallel agents, runs drift checks at every boundary, performs evidence-based milestone review, and produces a report. Humans get called in for judgment — not supervision.

## Why This Exists

Agentic coding produces code faster than humans can supervise. The result is drift: **code drift** (fix-on-fix behavior), **spec drift** (implementation diverges from agreement), **intent drift** (tasks optimize for the moment instead of the mission), and **loop drift** (self-healing logic recurses without limits).

## How It Works

Speedrift is five things working together.

### Drift Lanes

10 specialized analyzers that produce evidence, not opinions:

| Lane | What it watches |
|------|----------------|
| `coredrift` | Baseline code quality, hardening patterns, contract compliance |
| `specdrift` | Spec/code alignment |
| `datadrift` | Schema and data model drift |
| `archdrift` | Architecture-intent drift against ADRs |
| `depsdrift` | Dependency freshness, security, compatibility |
| `uxdrift` | UX drift with POV packs (Don Norman, etc.) |
| `therapydrift` | Self-healing loop quality — are guardrails compounding? |
| `yagnidrift` | Overbuild and complexity drift |
| `redrift` | Brownfield v1→v2 rebuild coordination |
| `drifts` | Orchestrator — selects the right lanes per task |

### Model-Mediated Judgment

Pipes execute (deterministic checks). Models decide (interpret evidence, choose tradeoffs). The graph records intent (contracts, fences, `wg log`). Context lives in artifacts, not transient chat memory — so resume and restart work.

### Project Autopilot

```
Goal → Decompose → Workers (parallel, session-driver) → Drift Check → Milestone Review → Report
         ↑                                                    |
         └──────── follow-up tasks loop back ─────────────────┘
```

Decomposes goals into workgraph tasks, dispatches parallel workers via [claude-session-driver](https://github.com/obra/claude-session-driver), runs drift at task boundaries, escalates stuck tasks, and performs evidence-based milestone review. See [driftdriver](https://github.com/dbmcco/driftdriver) for flags and configuration.

### Ecosystem Intelligence

Driftdriver monitors upstream changes across Workgraph, Amplifier, superpowers, claude-session-driver, and other dependencies. Daily scans surface findings as eval tasks — advisory, never automatic.

### Runtime Integration

The control plane is runtime-agnostic: Claude Code (native), [Amplifier](https://github.com/dbmcco/amplifier-bundle-speedrift) (bundle), or any CLI agent that reads/writes files.

## Getting Started

Prerequisites: `wg` ([Workgraph CLI](https://github.com/graphwork/workgraph)), `pipx`, `git`.

Install core + optional lanes:

```bash
pipx install git+https://github.com/dbmcco/driftdriver.git
pipx install git+https://github.com/dbmcco/coredrift.git
pipx install git+https://github.com/dbmcco/specdrift.git
pipx install git+https://github.com/dbmcco/depsdrift.git
```

Add lanes by need: `datadrift` (schemas), `archdrift` (ADRs), `uxdrift` (browser checks), `therapydrift` (loop quality), `yagnidrift` (complexity), `redrift` (rebuilds).

First run:

```bash
wg init
wg add --id start-1 "Bootstrap speedrift" --description "Create first task"
wg claim start-1
driftdriver install --wrapper-mode portable
./.workgraph/coredrift ensure-contracts --apply
./.workgraph/drifts check --task start-1 --write-log --create-followups
```

### UX POV Discipline

For UX-heavy tasks, run `uxdrift` with a POV pack for consistent model reasoning:

```bash
uxdrift wg check --task <id> --llm --pov doet-norman-v1 --write-log --create-followups
```

Or declare it in a task fence:

````md
```uxdrift
schema = 1
url = "http://localhost:3000"
pages = ["/", "/checkout"]
llm = true
pov = "doet-norman-v1"
pov_focus = ["discoverability", "feedback", "error_prevention_recovery"]
```
````

### Brownfield Rebuilds

Use `redrift` for phased v1→v2 rebuilds:

```bash
./.workgraph/redrift wg execute --task <root_id> --v2-repo <path> --write-log --phase-checks
```

Per-phase closeout:

```bash
./.workgraph/redrift wg verify --task redrift-exec-<phase>-<root_id> --write-log
./.workgraph/drifts check --task redrift-exec-<phase>-<root_id> --write-log --create-followups
./.workgraph/redrift wg commit --task redrift-exec-<phase>-<root_id> --phase <phase>
```

## Ecosystem Map

### External Dependencies

| Repo | Role | URL |
|------|------|-----|
| Workgraph | Task graph spine, `wg` CLI | https://github.com/graphwork/workgraph |
| Amplifier | Agent runtime (Microsoft) | https://github.com/microsoft/amplifier |
| superpowers | Core skills/workflow plugin (obra) | https://github.com/obra/superpowers |
| superpowers-chrome | Chrome DevTools browser control (obra) | https://github.com/obra/superpowers-chrome |
| claude-session-driver | Worker session orchestration (obra) | https://github.com/obra/claude-session-driver |
| freshell | Shell framework (Dan Shapiro) | https://github.com/danshapiro/freshell |
| mira-OSS | Discrete memory decay (Taylor Satula) | https://github.com/taylorsatula/mira-OSS |
| beads | Git-backed task tracking (Steve Yegge) | https://github.com/steveyegge/beads |

### Watched Users

The ecosystem scanner monitors: [@obra](https://github.com/obra), [@ekg](https://github.com/ekg), [@danshapiro](https://github.com/danshapiro), [@taylorsatula](https://github.com/taylorsatula), [@steveyegge](https://github.com/steveyegge), [@ramparte](https://github.com/ramparte), [@dsifry](https://github.com/dsifry), [@Joi](https://github.com/Joi), [@2389](https://github.com/2389).

The [vibez community](https://github.com/dbmcco/vibez-monitor) is an additional discovery source.

## Acknowledgements

Speedrift builds on [Workgraph](https://graphwork.github.io/), an independent project led by [Erik Garrison](https://github.com/ekg) and contributors. Speedrift is a separate ecosystem that uses Workgraph as its execution spine.

## Status

Public beta. APIs evolving. Modules usable now. Near-term goal: real-world dogfooding and measurable reliability gains.

## Other

- Known limitations: `docs/known-limitations.md`
- Story deck source: `docs/decks/speedrift-ecosystem-story.html`
- Legacy `dbmcco/speedrift` repo is a deprecation pointer — reinstall wrappers if migrating.
- Validation: `./scripts/verify_ecosystem.sh` and `./scripts/public_smoke_check.sh`

## License

MIT. See `LICENSE`.
