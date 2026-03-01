# Speedrift Ecosystem

Speedrift is a drift control system for agentic software development. It keeps plans, code, specs, and decisions synchronized while agents work at full speed.

[Workgraph](https://graphwork.github.io/) is the execution spine — task graph, dependencies, agent dispatch. Speedrift wraps it with 10 specialized drift lanes, an ecosystem intelligence layer, a model-mediated judgment architecture, and a full-loop project autopilot.

**[See the story deck](https://dbmcco.github.io/speedrift-ecosystem/decks/speedrift-ecosystem-story.html)** — arrow keys or footer controls to navigate

## Acknowledgements

Speedrift builds on [Workgraph](https://graphwork.github.io/), an independent project led by [Erik Garrison](https://github.com/ekg) and contributors.
Speedrift is a separate ecosystem that uses Workgraph as its execution spine.

## Status

`speedrift` is in **public beta** and under active development.

- APIs and defaults will continue evolving.
- Modules are usable now; polish and release ergonomics are still in progress.
- The near-term goal is real-world dogfooding and measurable reliability gains.

## North Star

**Goal in. Done out.**

Give the system a goal. It decomposes the work, dispatches parallel agents, runs drift checks at every boundary, performs evidence-based milestone review, and produces a report. Humans get called in for judgment — not supervision.

That means:

- plans, code, specs, and decisions stay synchronized over time
- teams can run multiple agents in parallel with bounded risk
- drift is surfaced and redirected early, not discovered at release time
- the full loop — research, plan, build, verify, review — runs autonomously

## Why This Exists

Agentic coding can produce code faster than humans can supervise. The result is drift:

- **code drift**: fix-on-fix behavior and local workarounds
- **spec drift**: implementation diverges from agreed behavior
- **intent drift**: tasks optimize for the moment instead of the mission
- **loop drift**: self-healing/guardrail logic can recurse without clear limits

Speedrift keeps momentum high while continuously countersteering toward alignment.

## What Speedrift Is

Speedrift is five things working together:

### 1. Drift Lanes (Telemetry)

10 specialized analyzers that produce evidence, not opinions:

| Lane | What it watches |
|------|----------------|
| `coredrift` | Baseline code quality, hardening patterns, contract compliance |
| `specdrift` | Spec/code alignment — does the build match the agreement? |
| `datadrift` | Schema and data model drift |
| `archdrift` | Architecture-intent drift against ADRs and design docs |
| `depsdrift` | Dependency freshness, security, compatibility |
| `uxdrift` | UX task/design drift with POV packs (Don Norman, etc.) |
| `therapydrift` | Self-healing loop quality — are guardrails compounding? |
| `yagnidrift` | Overbuild and complexity drift |
| `redrift` | Brownfield v1→v2 rebuild coordination |
| `drifts` | Orchestrator — runs the right lanes for the right task |

### 2. Model-Mediated Judgment

Speedrift separates execution from judgment:

- **Pipes execute**: lane CLIs gather evidence, run checks, produce deterministic outputs.
- **Models decide**: agents interpret evidence, choose tradeoffs, propose next actions.
- **Graph records intent**: contracts, fences, and `wg log` entries keep decisions visible and auditable.
- **Follow-ups over hidden fixes**: uncertain work becomes explicit tasks, not silent workaround code.

Practical effect: faster parallel agent work without losing architectural intent, less fix-on-fix drift because decisions are externalized in the graph, and easier resume/restart because context lives in artifacts — not in transient chat memory.

### 3. Project Autopilot

The full autonomous loop:

```
Goal → Decompose → Workers (parallel, session-driver) → Drift Check → Milestone Review → Report
         ↑                                                    |
         └──────── follow-up tasks loop back ─────────────────┘
```

```bash
driftdriver autopilot --goal "Build authentication system with JWT tokens"
```

The autopilot:
- Decomposes goals into workgraph tasks via an LLM planner
- Dispatches parallel workers using [claude-session-driver](https://github.com/obra/claude-session-driver) — each worker is a full Claude Code session
- Runs drift checks at task boundaries
- Escalates stuck tasks (repeated drift failures) instead of spinning
- Performs evidence-based milestone review using 4 rules: map the execution graph, trace claims through code, distinguish delegation from absence, test empirically
- Produces a structured report

Workers are not limited agents — they have full tool access, codebase research, TDD capabilities. The controller orchestrates; workers execute.

See [driftdriver](https://github.com/dbmcco/driftdriver) for autopilot flags and configuration.

### 4. Ecosystem Intelligence

Driftdriver monitors the health and evolution of every tool in the ecosystem:

- **External dependency awareness**: watches Workgraph, Amplifier, superpowers, claude-session-driver, mira-OSS, beads, and freshell for upstream changes
- **Automated daily scanning**: queries GitHub repos, watched users, and report URLs; surfaces findings as Workgraph eval tasks
- **Review history**: timestamped JSON + Markdown snapshots retained under `.workgraph/.driftdriver/reviews/`
- **Advisory, not automatic**: no auto-updates — humans decide via generated eval tasks

The ecosystem is self-aware. Driftdriver tracks upstream changes and alerts when they may affect your project.

### 5. Runtime Integration

Speedrift is runtime-agnostic. The control plane stays the same regardless of which agent framework runs underneath:

- **Claude Code**: native integration via driftdriver CLI + claude-session-driver
- **Amplifier**: [amplifier-bundle-speedrift](https://github.com/dbmcco/amplifier-bundle-speedrift) integration bundle
- **Any CLI agent**: workgraph tasks + drift wrappers work with any tool that reads/writes files

This keeps `speedrift` as the suite/control plane and treats runtime frameworks as interchangeable execution cockpits.

## Mental Model

Think in motorsports terms:

- **Track**: Workgraph is the shared track and lap plan (tasks, deps, loops).
- **Pit wall**: `driftdriver` is race control (policy, orchestration, wrappers).
- **Telemetry**: drift lanes produce signals and evidence.
- **Countersteer**: findings create logs and follow-up tasks instead of silent bloat.
- **Pit stop**: recovery loops (`therapydrift`, `redrift`) re-sync before failures compound.

## Usage Process

### 1) Start In 10 Minutes (Public Beta Path)

Prerequisites:

- `wg` (Workgraph CLI)
- `pipx`
- `git`

Install the currently-packaged core set:

```bash
pipx install git+https://github.com/dbmcco/driftdriver.git
pipx install git+https://github.com/dbmcco/coredrift.git
pipx install git+https://github.com/dbmcco/specdrift.git
pipx install git+https://github.com/dbmcco/datadrift.git
pipx install git+https://github.com/dbmcco/archdrift.git
pipx install git+https://github.com/dbmcco/depsdrift.git
pipx install git+https://github.com/dbmcco/uxdrift.git
pipx install git+https://github.com/dbmcco/therapydrift.git
pipx install git+https://github.com/dbmcco/yagnidrift.git
pipx install git+https://github.com/dbmcco/redrift.git
```

Create a tiny working graph and run one drift check:

```bash
wg init
wg add --id start-1 "Bootstrap speedrift" --description "Create first speedrift task"
wg claim start-1
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
./.workgraph/drifts check --task start-1 --write-log --create-followups
```

Optional for Linux CI/containers:

```bash
uxdrift install-browsers
```

Expected outcome:

- wrappers exist under `./.workgraph/` (`drifts`, `coredrift`, `specdrift`, etc.)
- task `start-1` has a `wg-contract` in its description
- `wg show start-1` includes a `Coredrift:` log entry

### 2) Resume A Project

```bash
driftdriver install --wrapper-mode portable --with-uxdrift --with-therapydrift --with-yagnidrift --with-redrift
./.workgraph/coredrift ensure-contracts --apply
```

### 3) Run The Day-To-Day Loop

**Autopilot mode** — give a goal and let the system handle decomposition, dispatch, drift, and review:

```bash
driftdriver autopilot --goal "Add user authentication with JWT tokens"
```

**Manual mode** — run drift checks per claimed task:

```bash
./.workgraph/drifts check --task <task_id> --write-log --create-followups
```

For redrift rebuild tasks, run explicit gate verification before final done checks:

```bash
./.workgraph/redrift wg verify --task <task_id> --write-log
./.workgraph/redrift wg check --task <task_id> --run-verify --write-log --create-followups
```

For complex apps, rebuilds, or data+app redo tasks:

```bash
./.workgraph/drifts check --task <task_id> --lane-strategy all --write-log --create-followups
```

Optional continuous mode:

```bash
./.workgraph/drifts orchestrate --write-log --create-followups
```

### UX POV Discipline (uxdrift)

For UX-heavy tasks, run `uxdrift` with an explicit POV pack so model reasoning is consistent across runs.

Current built-in POV:

- `doet-norman-v1` (Design of Everyday Things mindset)

Example Workgraph task fence:

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

Example direct run:

```bash
uxdrift wg check --task <task_id> --llm --pov doet-norman-v1 --write-log --create-followups
```

### 4) Run Brownfield Rebuilds

Use `redrift` when rebuilding toward v2 with phased artifacts:

```bash
./.workgraph/redrift wg execute --task <root_task_id> --v2-repo <target_path> --write-log --phase-checks
```

Recommended closeout sequence per phase task:

```bash
./.workgraph/redrift wg verify --task redrift-exec-<phase>-<root_task_id> --write-log
./.workgraph/drifts check --task redrift-exec-<phase>-<root_task_id> --write-log --create-followups
./.workgraph/redrift wg commit --task redrift-exec-<phase>-<root_task_id> --phase <phase>
```

## Ecosystem Map

Naming:

- Suite name: `speedrift` (ecosystem)
- Orchestrator CLI: `driftdriver`
- Baseline lane: `coredrift`
- Optional lanes: `specdrift`, `datadrift`, `archdrift`, `depsdrift`, `uxdrift`, `therapydrift`, `yagnidrift`
- Rebuild lane: `redrift`

### Core Suite

| Repo | Role | URL |
|---|---|---|
| driftdriver | Orchestrator: autopilot, policy, ecosystem monitoring, wrappers | https://github.com/dbmcco/driftdriver |
| coredrift | baseline drift telemetry + redirect | https://github.com/dbmcco/coredrift |
| specdrift | spec/code drift | https://github.com/dbmcco/specdrift |
| datadrift | data/schema drift | https://github.com/dbmcco/datadrift |
| archdrift | architecture-intent drift | https://github.com/dbmcco/archdrift |
| depsdrift | dependency drift | https://github.com/dbmcco/depsdrift |
| uxdrift | UX task/design drift | https://github.com/dbmcco/uxdrift |
| therapydrift | self-healing/loop quality lane | https://github.com/dbmcco/therapydrift |
| yagnidrift | overbuild and complexity drift | https://github.com/dbmcco/yagnidrift |
| redrift | v1->v2 re-spec/rebuild lane | https://github.com/dbmcco/redrift |
| amplifier-bundle-speedrift | Amplifier runtime integration for Speedrift protocols | https://github.com/dbmcco/amplifier-bundle-speedrift |

### External Dependencies

| Repo | Role | URL |
|---|---|---|
| Amplifier | Agent runtime (Microsoft) | https://github.com/microsoft/amplifier |
| amplifier-core | Core library | https://github.com/microsoft/amplifier-core |
| amplifier-app-cli | Reference CLI | https://github.com/microsoft/amplifier-app-cli |
| amplifier-foundation | Foundation library | https://github.com/microsoft/amplifier-foundation |
| Workgraph | Task graph spine, `wg` CLI (Erik Garrison / graphwork) | https://github.com/graphwork/workgraph |
| superpowers | Core skills/workflow plugin (Jesse Vincent / obra) | https://github.com/obra/superpowers |
| superpowers-chrome | Chrome DevTools browser control (Jesse Vincent / obra) | https://github.com/obra/superpowers-chrome |
| claude-session-driver | Worker session orchestration (Jesse Vincent / obra) | https://github.com/obra/claude-session-driver |
| freshell | Shell framework (Dan Shapiro) | https://github.com/danshapiro/freshell |
| mira-OSS | Discrete memory decay + modular system prompt (Taylor Satula) | https://github.com/taylorsatula/mira-OSS |
| beads | Git-backed task tracking, `bd` CLI (Steve Yegge) | https://github.com/steveyegge/beads |

### Watched Users / Orgs

The driftdriver daily ecosystem scanner monitors these for new repos and activity:

- [@obra](https://github.com/obra) — superpowers, claude-session-driver, superpowers-chrome
- [@2389](https://github.com/2389) — 2389-research
- [@danshapiro](https://github.com/danshapiro) — Freshell
- [@taylorsatula](https://github.com/taylorsatula) — MIRA
- [@steveyegge](https://github.com/steveyegge) — Beads
- [@ramparte](https://github.com/ramparte) — Amplifier bundles/extensions
- [@ekg](https://github.com/ekg) — Erik Garrison (Workgraph / graphwork)
- [@dsifry](https://github.com/dsifry) — Metaswarm (multi-agent orchestration)
- [@Joi](https://github.com/Joi) — AI agent learnings

The vibez community ("code code code" group) is an additional discovery source — repos and tools shared by members are triaged via [vibez-monitor](https://github.com/dbmcco/vibez-monitor) and added to the scanner when relevant.

Guide: [Amplifier Stories](https://ramparte.github.io/amplifier-stories/)

## Module Install Matrix

Most users should start with:

- `driftdriver + coredrift + specdrift + depsdrift`

Add modules by need:

- `datadrift`: schema/migration-heavy codebases
- `archdrift`: architecture docs/ADRs must track system changes
- `therapydrift`: repeated drift loops and auto-recovery control
- `yagnidrift`: complexity-control in early architecture phases
- `redrift`: brownfield rebuilds and v2 planning/execution
- `uxdrift`: browser-based UX drift checks; for production loops prefer task fences + `./.workgraph/drifts check` with `pov = "doet-norman-v1"`

## Known Limitations

Current beta limitations and workarounds are tracked in:

- `docs/known-limitations.md`

## Story Deck

Main deck source in this repo:

- `docs/decks/speedrift-ecosystem-story.html`

## Migration Note

Legacy lane repo `dbmcco/speedrift` is retained as a deprecation pointer.
If a repo still has `./.workgraph/speedrift`, reinstall wrappers and run:

```bash
./.workgraph/coredrift ensure-contracts --apply
```

## Validation

Run ecosystem-level verification from this repo:

```bash
./scripts/verify_ecosystem.sh
```

Public-readiness smoke checks:

```bash
./scripts/public_smoke_check.sh
```

## License

MIT. See `LICENSE`.
