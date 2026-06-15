# Speedrift vNext Operating Doctrine

Date: 2026-06-15

## Purpose

Speedrift vNext makes the system more opinionated about planning, verification,
review, and drift control. The core shift is:

- strong models plan and critique,
- Agency composes the right worker shape,
- smaller models execute only after ambiguity is removed,
- drift modules verify continuously against scope, spec, build, tests, and the north star,
- roborev reviews every material diff before approval.

The goal is not more process. The goal is better handoffs, fewer vague tasks,
and more reliable execution by cheaper or local models.

## Execution Pipeline

| Stage | Owner | Required Gates | Output |
| --- | --- | --- | --- |
| Intake | PlanForge | north-star fit, scope clarity | refined objective |
| Plan | PlanForge planner | plandrift, Agency role selection, test obligation assignment | executable plan |
| Adversarial review | bounded critic | missing tests, missing UX, review risk, drift risk, small-model readiness | repair list or waiver list |
| Materialize | PlanForge | schema validation, Workgraph task contracts, model routes | task graph |
| Execute | assigned worker | coredrift precheck, scoped implementation, local verification | implementation diff |
| Verify | worker plus qadrift | unit, integration, and UX/e2e obligations | evidence log |
| Review | roborev plus optional critic | code review, design review where needed | findings or approval |
| Repair | fixdrift | failed tests, roborev findings, drift findings | repair tasks |
| Approve | orchestrator | qadrift, northstardrift, final drift check | done or blocked |

## Mandatory Planner Outputs

PlanForge must not emit vague implementation tasks. A task is executable only
when it has enough detail for a smaller model to run without rediscovering the
architecture.

Every materialized task must include:

- objective and non-goals,
- files and directories to read first,
- exact touch set,
- ordered implementation steps,
- expected edge cases,
- unit test obligation,
- integration test obligation,
- end-user UX or e2e obligation when applicable,
- verification commands,
- roborev requirement,
- drift gates,
- rollback or recovery notes,
- model route and Agency profile,
- acceptance criteria,
- conditions that require escalation or replan.

If a test class is not applicable, the plan must include an explicit waiver and
reason. Silent omission is a planning failure.

## Test Policy

| Test Class | Default | Required When | Waiver Rule |
| --- | --- | --- | --- |
| Unit tests | Required | logic, parsing, routing, policy, transforms, state transitions | only for pure docs or mechanical metadata |
| Integration tests | Required for material work | CLI, service, graph, persistence, provider, package, runtime, cross-module changes | must name why no integration boundary changed |
| End-user UX or e2e tests | Conditional required | UI, TUI, CLI ergonomics, setup, onboarding, browser workflows, user-visible behavior | must state no user-facing workflow changed |
| Regression tests | Required after bug fixes | any defect, review finding, incident, or repeated failure | must state why existing coverage already catches it |
| Smoke tests | Required before handoff | install, runtime, deploy, service, generated binary, or local tooling changes | no waiver for install/runtime work |

## Roborev Policy

Roborev is automatic for material diffs.

| Change Type | Required Review |
| --- | --- |
| Narrow code change | roborev code review |
| Architecture, schema, service, install, security, or runtime change | roborev code review plus design review |
| User-facing workflow change | roborev plus UX/e2e evidence |
| Generated or mechanical-only change | roborev optional, but qadrift must confirm scope |
| Docs-only doctrine/spec change | review optional unless it changes execution policy |

Roborev findings become Workgraph tasks or explicit waivers. They should not
remain only in chat.

## Agency Policy

Agency is the default composition layer. PlanForge must select or request an
Agency profile for every non-trivial task.

Each task must specify:

- role,
- required capabilities,
- model route,
- context budget,
- expected autonomy level,
- review requirement,
- fallback profile if Agency is unavailable.

If Agency is unreachable, Speedrift may continue with a generic worker only when
the task is low risk. The task log must record that the generic fallback was
used.

## Model Routing Policy

Use central registry route names only. Do not hardcode model IDs or provider
credentials in plans.

| Role | Preferred Shape |
| --- | --- |
| Planner | strong reasoning model |
| Critic | independent strong or mid model with adversarial prompt |
| Small executor | Haiku, GPT mini, Qwen, GLM, Kimi, or similar route |
| Medium executor | Codex/Codexd or equivalent route |
| Reviewer | roborev plus critic route where needed |
| Repair worker | route selected by failure class and task scope |

Small-model execution is allowed only when `handoff_detail_level` is high enough
and all required fields are present.

## Drift Module Policy

| Module | Status | Force When | Improve | Retire or Merge |
| --- | --- | --- | --- | --- |
| coredrift | always forced | every task | enforce touch set and follow-up discipline | keep |
| specdrift | forced for non-trivial work | created or existing spec anchor | compare against plan and north-star intent | keep |
| plandrift | always forced before execution | every PlanForge materialization | reject vague plans and weak handoffs | keep |
| qadrift | forced before approval | every material task | verify declared tests exist and ran | keep |
| northstardrift | forced at roots and milestones | root task, milestone, strategy-sensitive changes | score against explicit north-star statement | keep |
| fixdrift | forced on failure | failed tests, roborev, drift findings | generate scoped repair tasks | keep |
| depsdrift | conditional forced | dependency, upstream, runtime, package, toolchain changes | verify pins and adopted refs after adoption | keep |
| secdrift | conditional forced | auth, secrets, network, subprocess, install, file permissions | add explicit hard-stop thresholds | keep |
| uxdrift | conditional forced | UI, TUI, CLI ergonomics, setup, onboarding, user workflow | focus on workflow evidence, not generic UX prose | keep |
| archdrift | conditional forced | schema, service, runtime, cross-module, boundary changes | flag oversized tasks and boundary leaks | keep |
| redrift | specialized | v2 rebuild, rewrite, migration, parity lane | keep out of ordinary feature work | keep |
| factorydrift | ecosystem cadence | portfolio planning cycles | keep as plan/ledger unless autonomy is explicit | keep |
| evolverdrift | learning loop | repeated drift patterns | only trigger from recurring failures | keep |
| debatedrift | bounded critic lane | high ambiguity or high blast radius | strict triggers, budget, and stop rules | keep bounded |
| yagnidrift | merged | planning and core scope checks | fold necessity checks into plandrift/coredrift | retire as routine lane |
| therapydrift | rename or merge | agent/operator health, sensitive human-facing agent behavior | move to agencydrift or northstardrift | retire name |

## Adversarial Review Boundaries

Adversarial review is valuable when it is bounded. It should challenge plans and
diffs, not create open-ended debate.

### Trigger It

Use adversarial review when any of these are true:

- architecture, schema, runtime, install, security, dependency, or service
  boundary changes,
- task will be handed to a smaller model and ambiguity remains,
- blast radius is high,
- the plan touches many modules,
- prior attempt failed,
- north-star or spec tradeoff is unclear,
- user-facing workflow could regress trust,
- roborev or drift checks found high-severity issues.

### Do Not Trigger It

Skip adversarial review for:

- mechanical fixes,
- narrow test updates,
- docs-only changes that do not alter policy or semantics,
- already-reviewed repair tasks,
- low-risk leaf tasks with clear acceptance criteria,
- generated metadata where verification is deterministic.

### Debate Rules

| Boundary | Rule |
| --- | --- |
| Scope | Review the plan, task contract, or diff only. Do not reopen product strategy unless north-star risk is explicit. |
| Rounds | One critic pass by default. Second pass only after material repairs. |
| Authority | Critic emits findings, waivers, or replan recommendations. It cannot expand scope directly. |
| Output | Findings must be structured: severity, evidence, impacted task, recommended action, and stop/go decision. |
| Stop condition | Stop after no critical/high findings or after two rounds. |
| Escalation | Human gate only for unresolved high-risk disagreement. |
| Budget | No premium-model debate for low-risk work. |
| Persistence | Findings become Workgraph tasks, plan repairs, or explicit waivers. |

## PlanForge Schema Delta

The current `planforge-plan-v2.schema.json` already has `testing`,
`model_assignments`, `fix_loops`, `drift_gates`, and Workgraph nodes. vNext
should make the following additions mandatory.

Top-level required fields to add:

- `agency_plan`
- `review_plan`
- `adversarial_review`
- `handoff_quality`

Extend `testing` with:

- `unit_tests`
- `integration_tests`
- `ux_tests`
- `waivers`

Extend each Workgraph node with:

- `read_first`
- `implementation_steps`
- `edge_cases`
- `rollback_notes`
- `roborev_required`
- `agency_profile`
- `handoff_detail_level`
- `small_model_ready`
- `escalation_conditions`

Extend `speedrift_module.name` enum with:

- `qadrift`
- `secdrift`
- `plandrift`
- `factorydrift`
- `northstardrift`
- `evolverdrift`
- `debatedrift`
- `reviewdrift`
- `agencydrift`

Deprecate in schema guidance:

- `yagnidrift` as a standalone routine lane,
- `therapydrift` as a name.

## Acceptance For A Valid vNext Plan

A PlanForge vNext plan is valid only if:

- every implementation task has a small-model handoff rating,
- every task has a model route and Agency profile,
- unit, integration, and UX/e2e obligations are explicit,
- roborev is scheduled for material code diffs,
- adversarial review is either triggered with bounds or explicitly skipped with
  a reason,
- coredrift and plandrift gates are present,
- qadrift and final northstardrift checks are present before approval,
- repair loops exist for test, drift, and review failures,
- all waivers include evidence and owner.

## Implementation Sequence

1. Update PlanForge schema with the vNext fields.
2. Update the PlanForge persona prompt and critic prompt to enforce the doctrine.
3. Update materialization so Workgraph tasks include the new contract sections.
4. Add plandrift checks for handoff detail and small-model readiness.
5. Add qadrift checks for declared versus executed test obligations.
6. Add reviewdrift or roborev integration as automatic post-implementation tasks.
7. Add agencydrift or Agency validation for role/profile/model-route coverage.
8. Retire or alias routine `yagnidrift` and `therapydrift` usage.
9. Run the doctrine against one real medium-risk repo task before broad rollout.
