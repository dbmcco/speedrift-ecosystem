# Northstardrift

`northstardrift` is the ecosystem module that measures whether Speedrift is actually moving toward the north star:

> an autonomous dark-factory workflow that keeps repos operating, improving, coordinating, and recovering with low human intervention

It is not a vanity dashboard.
It is the control loop that turns raw repo activity into:

- effectiveness scores over time
- narrated operator awareness
- regression detection
- bounded follow-up task emission into local graphs

## Operating Contract

`northstardrift` should combine three layers:

1. Deterministic collection
   - gather repo, graph, daemon, drift, and upstream facts
2. Deterministic scoring
   - compute normalized sub-scores and a weighted north-star score
3. Model-mediated interpretation
   - explain what changed, why it matters, and what to do next

The model does not invent telemetry.
It interprets deterministic telemetry and proposes bounded interventions.

## Cadence

- every ecosystem cycle:
  - update live snapshot and repo-level score deltas
- hourly:
  - roll up recent effectiveness window for operator awareness
- daily:
  - write a durable scorecard ledger entry
- weekly:
  - emit trend narrative and repeated-failure analysis

## Inputs

`northstardrift` should read from the existing ecosystem surfaces instead of creating a parallel state model.

- central register:
  - repo reporting status
  - heartbeat freshness
  - active task ids
  - local service mode/status
- repo workgraph state:
  - open, ready, in-progress, blocked, done task counts
  - stale task age
  - loopback edges
  - continuation edges
  - dependency edges
- factory execution ledgers:
  - attempted actions
  - succeeded actions
  - failed actions
  - policy-gated skips
- session-driver ledgers:
  - dispatch attempts
  - worker completions
  - empty-response failures
  - retry/timeout counts
- drift lane outputs:
  - `secdrift` findings and severities
  - `qadrift` findings and verification pressure
  - `plandrift` findings for missing tests, missing loopbacks, broken continuation edges
- repo hygiene facts:
  - dirty working tree
  - untracked file pressure
  - branch divergence from `main`
  - daemon stopped while ready work exists
- upstream funnel:
  - candidate packets emitted
  - candidate PRs opened
  - candidate PRs merged
  - repeated local patches that should be upstreamed

## Artifacts

`northstardrift` should write into the ecosystem central service tree:

- `.workgraph/service/ecosystem-central/northstardrift/current.json`
- `.workgraph/service/ecosystem-central/northstardrift/ledgers/effectiveness.jsonl`
- `.workgraph/service/ecosystem-central/northstardrift/ledgers/regressions.jsonl`
- `.workgraph/service/ecosystem-central/northstardrift/ledgers/interventions.jsonl`
- `.workgraph/service/ecosystem-central/northstardrift/daily/YYYY-MM-DD.json`

These artifacts let the dashboard show both live state and durable trend history.

## Scorecard

`northstardrift` should compute five top-level axes.

### 1) Continuity

Question:
Is the factory staying in motion?

Inputs:

- daemon uptime
- heartbeat freshness
- percent of repos reporting
- percent of repos with ready work that are actually advancing
- median ready-to-start latency
- stalled task count and age

Formula:

```text
continuity =
  0.25 * reporting_coverage +
  0.20 * daemon_uptime_score +
  0.20 * active_progress_coverage +
  0.15 * heartbeat_freshness_score +
  0.10 * ready_latency_score +
  0.10 * stall_penalty_inverse
```

### 2) Autonomy

Question:
Is work advancing without requiring the human to constantly restart or restitch it?

Inputs:

- percent of tasks completed without human intervention
- autonomous recovery success after failures
- overnight progress hours
- retry success rate
- repeated failure loop rate

Formula:

```text
autonomy =
  0.35 * autonomous_completion_rate +
  0.20 * recovery_success_rate +
  0.15 * overnight_progress_score +
  0.15 * retry_success_rate +
  0.15 * loop_penalty_inverse
```

### 3) Quality

Question:
Is the factory producing clean, verified, low-regret work?

Inputs:

- verification pass rate
- open `qadrift` pressure
- open `secdrift` pressure
- regression count
- repo dirtiness pressure
- branch divergence pressure

Formula:

```text
quality =
  0.30 * verification_pass_rate +
  0.20 * qadrift_pressure_inverse +
  0.20 * secdrift_pressure_inverse +
  0.15 * regression_penalty_inverse +
  0.10 * dirtiness_penalty_inverse +
  0.05 * divergence_penalty_inverse
```

### 4) Coordination

Question:
Are repos handing work to each other cleanly instead of silently blocking one another?

Inputs:

- repo-to-repo dependency coverage
- blocked dependency age
- inter-repo handoff success rate
- repos reporting to central register
- missing dependency metadata rate

Formula:

```text
coordination =
  0.30 * interrepo_reporting_coverage +
  0.25 * handoff_success_rate +
  0.20 * dependency_age_inverse +
  0.15 * dependency_metadata_score +
  0.10 * blocked_repo_penalty_inverse
```

### 5) Self-Improvement

Question:
Is the factory improving itself and the broader ecosystem instead of repeating the same mistakes?

Inputs:

- repeated failure classes eliminated
- runtime/tooling fixes rolled out across repos
- upstream candidate throughput
- upstream merge ratio
- `plandrift` plan-integrity coverage

Formula:

```text
self_improvement =
  0.25 * repeat_failure_elimination_rate +
  0.20 * rollout_coverage +
  0.20 * upstream_candidate_throughput_score +
  0.15 * upstream_merge_ratio +
  0.20 * plan_integrity_coverage
```

## Dark Factory Effectiveness Score

The top-level score should stay weighted toward continuity first.
If the factory is not staying alive, the rest is noise.

```text
dark_factory_effectiveness =
  0.25 * continuity +
  0.20 * autonomy +
  0.20 * quality +
  0.20 * coordination +
  0.15 * self_improvement
```

All scores are normalized to `0..100`.

Tier contract:

- `healthy`: `>= 80`
- `watch`: `60..79`
- `at-risk`: `< 60`

Trend contract:

- `improving`: `delta >= +3` over comparison window
- `flat`: `-2 < delta < +3`
- `worsening`: `<= -2`

## Ledger Schema

Each daily record should be durable and model-readable.

```json
{
  "ts": "2026-03-06T11:00:00Z",
  "window": "1d",
  "mode": "execute",
  "overall_score": 78.4,
  "overall_tier": "watch",
  "overall_trend": "improving",
  "axes": {
    "continuity": { "score": 82.1, "trend": "flat", "tier": "healthy" },
    "autonomy": { "score": 74.5, "trend": "improving", "tier": "watch" },
    "quality": { "score": 80.2, "trend": "flat", "tier": "healthy" },
    "coordination": { "score": 68.8, "trend": "worsening", "tier": "watch" },
    "self_improvement": { "score": 71.0, "trend": "improving", "tier": "watch" }
  },
  "repo_rollup": {
    "tracked": 14,
    "reporting": 12,
    "active": 5,
    "stalled": 2,
    "blocked": 3
  },
  "top_regressions": [
    {
      "kind": "dependency_age",
      "repo": "meridian",
      "summary": "blocked on paia-os interface task for 31 hours"
    }
  ],
  "top_improvements": [
    {
      "kind": "runtime_rollout",
      "repo": "driftdriver",
      "summary": "shared daemon wrapper now healthy across active repos"
    }
  ],
  "operator_prompts": [
    {
      "priority": "high",
      "repo": "paia-os",
      "prompt": "Review Speedrift coordination pressure for paia-os. Unblock the meridian dependency chain, update the local graph with the missing interface task, and add verification plus follow-up loopbacks before resuming execution."
    }
  ]
}
```

## Repo-Level Fields

Each repo card should expose the fields needed for sort, filter, and narration.

```json
{
  "repo": "meridian",
  "status": "watch",
  "score": 63,
  "trend": "worsening",
  "active_task_ids": ["p13-chat-user-space-provenance-links"],
  "stalled_reason": "service healthy but upstream dependency has aged past 24h",
  "dirty_state": "dirty",
  "dirty_file_count": 7,
  "diverged_commits": 3,
  "reporting": true,
  "heartbeat_age_seconds": 55,
  "ready_count": 4,
  "blocked_count": 2,
  "in_progress_count": 1,
  "prompts": {
    "claude": "Review meridian's aged dependency chain, update the blocked-by metadata, and either emit an unblock task in the source repo or close the stale edge with evidence.",
    "codex": "Investigate why meridian is on watch. Focus on the aged upstream dependency, confirm whether the source repo is progressing, and repair the graph plus verification loopbacks before resuming work."
  }
}
```

## Dashboard Contract

The dashboard order should stay fixed so operator attention is stable:

1. Narrated overview
2. Operational overview
3. Repo cards
4. Graph views
5. Attention queues

### Narrated Overview

Show:

- one model-written paragraph
- current top-level score and trend
- top 3 regressions
- top 3 improvements
- strongest active execution path across repos

The paragraph should answer:

- what is moving
- what is stuck
- what is risky
- what the factory should do next

### Operational Overview

Show:

- mode (`plan_only` vs `execute`)
- daemon health
- reporting coverage
- active repo count
- active task count
- dispatch success
- verification pass rate

### Repo Cards

Each repo card should support:

- filter by status, priority, dirtiness, reporting, active, blocked
- sort by score, trend, age pressure, dependency pressure, dirtiness
- a one-sentence `why watch/at-risk` explanation
- pulsing border if active
- click-to-focus graph

### Graph Views

Two views are required:

- focused repo graph
- inter-repo dependency graph

Graph overlays should show:

- pulsing active repos and active tasks
- blocked edges
- aged edges
- loopback edges
- continuation edges
- upstream candidate edges

### Attention Queues

Queues should be actionable, not just alarming.

Required queues:

- aging gaps
- dependency breaks
- stalled without heartbeat
- repeated failure loops
- dirty-but-active repos
- unreported repos
- upstream candidate packets
- security pressure
- quality pressure

Every queue item should include:

- severity
- age
- affected repo(s)
- evidence
- recommended owner
- a Claude prompt
- a Codex prompt

## Action Rules

`northstardrift` should prefer emitting work into local graphs over taking direct invasive action.

### Emit a local corrective task when

- a repo is dirty and active
- a dependency edge is missing metadata
- a blocked edge has aged beyond policy
- verification is repeatedly skipped
- plan-integrity controls are missing
- the same failure signature appears more than `N` times in a window

### Trigger a safe central action when

- daemon is stopped but repo has ready work and restart is explicitly allowed
- websocket/status process needs bounded restart
- deterministic drift lanes can run without touching unrelated work

### Do not act automatically when

- a repo is mid-flight on human-owned changes and policy says `observe_only`
- the worktree is dirty in a way that makes automated mutation ambiguous
- destructive git actions would be required
- evidence confidence is too low

In those cases, write a follow-up task and dashboard prompt instead.

## Model-Mediated Reasoning Contract

The model layer should classify each regression before actioning it.

Required classification:

- `operational`: daemon/reporting/dispatch issue
- `graph`: dependency metadata, loopbacks, continuation edges
- `quality`: tests, verification, UX, regression risk
- `security`: vulnerability or permissions issue
- `upstream`: reusable local improvement should become a candidate packet
- `human`: ambiguous or high-risk; needs operator review

The model output should include:

- explanation grounded in metrics
- confidence
- recommended lane/module
- prompt for Claude
- prompt for Codex
- whether to emit a local task, central task, or dashboard-only note

## Suggested Config

```toml
[northstardrift]
enabled = true
emit_review_tasks = true
emit_operator_prompts = true
daily_rollup = true
weekly_trends = true
score_window = "1d"
comparison_window = "7d"
dirty_repo_blocks_auto_mutation = true
max_auto_interventions_per_cycle = 3
require_metric_evidence = true
```

## Relationship To Other Modules

- `factorydrift` decides what safe actions to execute this cycle
- `sessiondriver` dispatches ready work into workers
- `secdrift` raises security pressure and remediation tasks
- `qadrift` raises UX, quality, and test pressure
- `plandrift` verifies that plans include tests, loopbacks, and continuation edges
- `northstardrift` measures whether all of that is actually moving the factory toward the north star

## Implementation Sequence

1. Add deterministic collectors and current snapshot output
2. Add score computation and daily ledger
3. Add narrated overview and prompt generation
4. Add regression classification and local task emission
5. Add weekly trend review and repeated-failure elimination tracking

That order matters.
Without deterministic evidence first, the model layer will be noisy.
