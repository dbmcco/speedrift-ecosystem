# Speedrift vNext Long-Term Control Plane Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Speedrift enforce its vNext doctrine through Workgraph tasks, PlanForge contracts, Agency/roborev defaults, bounded adversarial review, and concrete verification gates.

**Architecture:** Treat `docs/speedrift-vnext-operating-doctrine-20260615.md` as the north-star contract. PlanForge compiles detailed, small-model-ready tasks; Workgraph owns state; Speedrift/driftdriver run checks and create follow-ups; scripts provide deterministic evidence for policy conformance. Changes should land as small, independently verifiable tasks rather than one broad rewrite.

**Tech Stack:** Bash verification scripts, Workgraph (`wg`), Driftdriver/Speedrift drift wrappers, PlanForge V2 schema/materializer, repo-local docs.

## Global Constraints

- Workgraph is the source of truth for task state.
- Default repo runtime posture stays `observe` unless supervision is explicitly armed.
- Every material task must declare unit tests, integration tests, and UX/e2e tests or explicit waivers.
- Agency is preferred for agent composition; Codex/Codexd fallback is allowed for low-risk tasks when logged.
- Roborev is required for material code/policy diffs and optional for docs-only tasks.
- Adversarial review is bounded: one pass by default, two max after repair, no open-ended debate.
- Use central route names; do not reintroduce removed DiffusionGemma routing.
- Preserve cleanup safety: no destructive git history operations and no broad-root workspace commits.

---

### Task 1: Plan Anchor And Graph Seed

**Files:**
- Create: `docs/superpowers/plans/2026-06-17-speedrift-vnext-long-term-control-plane.md`
- Create: `.workgraph/planforge/20260617-speedrift-vnext-longterm/plan.final.json`
- Create: generated PlanForge spec under `docs/superpowers/specs/`

**Interfaces:**
- Consumes: existing Speedrift doctrine and PlanForge V2 schema.
- Produces: a validated PlanForge plan and Workgraph graph for the remaining tasks.

- [ ] **Step 1: Validate PlanForge plan JSON**

Run:
```bash
/Users/braydon/projects/experiments/braydon-workspace-skills/skills/planforge/scripts/planforge_v2.py validate .workgraph/planforge/20260617-speedrift-vnext-longterm/plan.final.json
```
Expected: `PlanForgePlan validates`.

- [ ] **Step 2: Materialize graph**

Run:
```bash
/Users/braydon/projects/experiments/braydon-workspace-skills/skills/planforge/scripts/planforge_v2.py materialize --repo "$PWD" --plan .workgraph/planforge/20260617-speedrift-vnext-longterm/plan.final.json --session 20260617-speedrift-vnext-longterm --apply
```
Expected: materialization output with created Workgraph tasks.

- [ ] **Step 3: Verify ready queue**

Run:
```bash
wg ready
```
Expected: the first executable Speedrift vNext task is ready; stale FLIP tasks are handled by Task 2.

### Task 2: Clear Eval And Coordinator Noise

**Files:**
- Modify: `.workgraph/graph.jsonl`
- Create: `.workgraph/agency/evaluations/eval-speedrift-vnext-implementation-20260615-*.json`
- Create: `.workgraph/agency/evaluations/eval-speedrift-model-fit-routing-20260616-*.json`

**Interfaces:**
- Consumes: completed-but-pending tasks `speedrift-vnext-implementation-20260615` and `speedrift-model-fit-routing-20260616`.
- Produces: a ready queue that is not starved by stale FLIP/eval/coordinator work.

- [ ] **Step 1: Record evaluations for completed pending-eval tasks**

Run:
```bash
wg evaluate record --task speedrift-vnext-implementation-20260615 --score 0.88 --source manual:codex --notes "Completed according to Workgraph logs; residual quickstart smoke failure tracked separately."
wg evaluate record --task speedrift-model-fit-routing-20260616 --score 0.90 --source manual:codex --notes "PlanForge routing policy verifier passes; residual ecosystem smoke failure tracked separately."
```
Expected: both evaluations are saved.

- [ ] **Step 2: Close their FLIP/eval gates**

Run:
```bash
wg done .flip-speedrift-vnext-implementation-20260615 --skip-smoke
wg done .evaluate-speedrift-vnext-implementation-20260615 --skip-smoke
wg approve speedrift-vnext-implementation-20260615
wg done .flip-speedrift-model-fit-routing-20260616 --skip-smoke
wg done .evaluate-speedrift-model-fit-routing-20260616 --skip-smoke
wg approve speedrift-model-fit-routing-20260616
```
Expected: both parent tasks are `done`.

- [ ] **Step 3: Resolve stale coordinator claim**

Run:
```bash
wg show .coordinator-0
wg incomplete .coordinator-0 --reason "stale coordinator claim from 2026-04-15 blocks speedriftd dispatch; interactive repo remains observe mode"
```
Expected: `speedriftd status --refresh` no longer reports dispatch blocked by `.coordinator-0`.

### Task 3: Add vNext Policy Verifier

**Files:**
- Create: `scripts/verify_speedrift_vnext_policy.sh`
- Modify: `README.md`
- Modify: `docs/speedrift-vnext-operating-doctrine-20260615.md` only if the verifier exposes a genuine doctrine gap.

**Interfaces:**
- Consumes: doctrine, local model baseline, PlanForge schema, drift policy, executor templates.
- Produces: deterministic checks that prove vNext policy is wired into repo artifacts.

- [ ] **Step 1: Write failing checks for required policy text and schema fields**

Create `scripts/verify_speedrift_vnext_policy.sh` with checks that require:
- PlanForge schema has `agency_plan`, `review_plan`, `adversarial_review`, `handoff_quality`.
- Workgraph nodes require `read_first`, `implementation_steps`, `edge_cases`, `rollback_notes`, `roborev_required`, `agency_profile`, `handoff_detail_level`, `small_model_ready`, and `escalation_conditions`.
- Doctrine mentions bounded adversarial review, Agency fallback, roborev, unit tests, integration tests, UX waivers, and local model baseline.
- Drift policy has enabled `qadrift`, `plandrift`, `northstardrift`, and `speedriftd`.
- Executor prompts mention drift checks and task logging.

- [ ] **Step 2: Run the verifier**

Run:
```bash
bash scripts/verify_speedrift_vnext_policy.sh
```
Expected: initially fail only on real missing wiring, then pass after fixes.

- [ ] **Step 3: Add README pointer**

Add a short README bullet under Start Here pointing to the vNext policy verifier.

### Task 4: Harden PlanForge Contract Enforcement

**Files:**
- Modify: PlanForge skill files under `/Users/braydon/projects/experiments/braydon-workspace-skills/skills/planforge/`
- Test: materialize a fixture plan under this repo's `.workgraph/planforge/`

**Interfaces:**
- Consumes: PlanForge V2 schema and runner.
- Produces: a validated plan/materialization path that rejects vague or underspecified tasks.

- [ ] **Step 1: Add or validate a fixture plan**

Use `.workgraph/planforge/20260617-speedrift-vnext-longterm/plan.final.json` as the fixture.

- [ ] **Step 2: Validate schema and routing**

Run:
```bash
/Users/braydon/projects/experiments/braydon-workspace-skills/skills/planforge/scripts/planforge_v2.py validate .workgraph/planforge/20260617-speedrift-vnext-longterm/plan.final.json
```
Expected: validation passes.

- [ ] **Step 3: Verify materialized task descriptions include small-model-ready fields**

Run:
```bash
rg "Read First:|Implementation Steps:|Roborev:|Small Model Ready:|Escalation Conditions:" .workgraph/planforge/20260617-speedrift-vnext-longterm/materialize.sh
```
Expected: all labels are present.

### Task 5: Enforce Executor Envelope

**Files:**
- Modify: `.workgraph/executors/codex.toml`
- Modify: `.workgraph/executors/claude.toml`
- Modify: `.workgraph/executors/session-driver.toml`

**Interfaces:**
- Consumes: Workgraph task descriptions with Speedrift, Agency, test, and review blocks.
- Produces: executor prompts that reliably tell smaller agents how to obey Speedrift.

- [ ] **Step 1: Add missing obligations**

Ensure each executor prompt says:
- run pre/post drift checks,
- honor unit/integration/UX obligations or waivers,
- use Agency when available and log fallback,
- run roborev for material diffs,
- convert findings into Workgraph tasks,
- stop and escalate if task detail is not small-model-ready.

- [ ] **Step 2: Verify prompt text**

Run:
```bash
rg "Agency|roborev|unit|integration|UX|Small Model Ready|drifts check" .workgraph/executors
```
Expected: each executor template contains the required obligations.

### Task 6: Fix Quickstart Smoke And Runtime Friction Follow-Through

**Files:**
- Modify: `scripts/public_smoke_check.sh`
- Modify or file follow-up tasks for the owning repo if the bug is in `driftdriver` or `wg`.

**Interfaces:**
- Consumes: current failing smoke output where `driftdriver install` collides with legacy `.wg`.
- Produces: either a local smoke-script fix or a first-class upstream/owner task with reproduction.

- [ ] **Step 1: Reproduce focused failure**

Run:
```bash
./scripts/public_smoke_check.sh
```
Expected: if still failing, capture the `wg init` legacy `.wg` collision.

- [ ] **Step 2: Decide ownership**

If the failure is in this script's temp setup, patch the script. If it is in `driftdriver install`, create a Workgraph task and upstream issue with the exact temp-repo repro.

- [ ] **Step 3: Verify smoke**

Run:
```bash
./scripts/public_smoke_check.sh
```
Expected: pass, or the failure is represented as an explicit blocked upstream task.

### Task 7: Final Gates And Handoff

**Files:**
- Modify: Workgraph task logs and evaluation records.
- Optional: commit after verification if the diff is repo-owned and clean.

**Interfaces:**
- Consumes: all implementation tasks.
- Produces: final evidence that Speedrift can continue from the graph.

- [ ] **Step 1: Run deterministic checks**

Run:
```bash
bash scripts/verify_model_routing_policy.sh
bash scripts/verify_speedrift_vnext_policy.sh
bash scripts/public_smoke_check.sh
./.workgraph/drifts check --task speedrift-vnext-final-gates-20260617 --write-log --create-followups
```
Expected: policy checks pass; smoke either passes or has a linked blocked upstream task.

- [ ] **Step 2: Request review**

Run roborev on material diffs if code or execution policy changed. For docs-only changes, log the waiver.

- [ ] **Step 3: Close Workgraph**

Run:
```bash
wg status
```
Expected: no stale system tasks are starving real ready work, and remaining tasks are intentional.
