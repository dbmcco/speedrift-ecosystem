# Workgraph Upstream Migration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt current `graphwork/workgraph` upstream into `dbmcco/workgraph` without regressing Speedrift execution, routing, coordinator, worktree, graph, or sentinel behavior.

**Architecture:** Use a phased upstream adoption in an isolated Workgraph worktree. Preserve Speedrift-critical downstream behavior as explicit invariants, validate each phase with targeted Workgraph and Driftdriver gates, then install the merged `wg` only after rollback has been prepared and tested.

**Tech Stack:** Rust Workgraph, Python Driftdriver/Speedrift, Workgraph `.workgraph`, cargo tests, pytest compatibility gates, `driftdriver upstream-tracker`.

---

## Current State

- Downstream adopted Workgraph: `fork/main` at `8f00826a8bf87d4a00758219722e993c37c69a1e` (`2026-05-20`, `Add OpenCode ZAI executor routing`).
- Upstream Workgraph: `origin/main` at `d938e96c8d67dbce94fa7cdd633af4a152ee30d7` (`2026-06-15`, `feat: fix-nex-large`).
- Merge base: `6617ef03dcc0d55d96268fd8872519144435bdd1`.
- Divergence: `67` downstream-only commits and `76` upstream-only commits.
- Upstream tracker classification: `api-surface`, `critical_change=true`, `action=needs_update`.
- Dry merge conflict count: 12 direct conflicts.

Direct conflict files:

- `docs/GUIDE.md`
- `src/cli.rs`
- `src/commands/opencode_handler.rs`
- `src/commands/spawn/worktree.rs`
- `src/commands/spawn_task.rs`
- `src/config_defaults.rs`
- `src/dispatch/handler_for_model.rs`
- `src/dispatch/plan.rs`
- `src/main.rs`
- `tests/integration_canonical_config.rs`
- `tests/integration_coordinator_agent.rs`
- `tests/spawn_site_isolation.rs`

Risk rating: high. Do not reset or fast-forward the downstream fork to upstream. Use a controlled merge/adoption branch.

## Upstream Themes To Adopt

1. Standalone `nex` became a first-class binary/runtime.
   - Key files: `Cargo.toml`, `src/bin/nex.rs`, `src/nex_cli.rs`, `src/nex_runtime.rs`, `src/commands/nex.rs`, `src/session_lock.rs`, `src/executor/native/*`, `tests/integration_nex_entrypoint.rs`.
   - Review commits first: `35acdedd`, `ecfa919a`, `21e6db3c`, `36fd1a16`, `ef3a1626`, `d938e96c`.

2. Executor routing was generalized into an executor arena.
   - Key files: `src/dispatch/plan.rs`, `src/commands/spawn/execution.rs`, `src/executor_discovery.rs`, `src/service/executor.rs`, `src/commands/opencode_handler.rs`, `templates/executors/*.toml.example`.
   - Review commits first: `8fec3d3d`, `dfd09547`, `555ee962`, `fc3af3ef`, `34789590`, `3eeb2117`, `55c7fb28`, `657a3d6c`.

3. Config/profile semantics changed materially.
   - Key files: `src/config.rs`, `src/config_defaults.rs`, `src/profile/named.rs`, `src/profile/templates/*.toml`.
   - Upstream removed downstream `src/model_routes.rs`.
   - Profiles are full snapshots, not overlays.
   - `.wg` is preferred upstream, with `.workgraph` compatibility.

4. Native install/upgrade/release became upstream surfaces.
   - Key files: `.github/workflows/release.yml`, `dist-workspace.toml`, `scripts/install-wg.sh`, `scripts/install-wg.ps1`, `src/commands/upgrade.rs`, `tests/upgrade/main.rs`.

5. Service/coordinator recovery and graph schema hardened.
   - Key files: `src/atomic_file.rs`, `src/commands/service/mod.rs`, `src/commands/service/coordinator_agent.rs`, `src/graph.rs`, `src/query.rs`, `src/chat_sessions.rs`.

## Downstream Invariants To Preserve

These are non-negotiable Speedrift compatibility requirements.

1. Central Speedrift defaults
   - Preserve route registry lookup from `src/model_routes.rs`.
   - Preserve Codex-first no-config defaults in `src/config.rs`.
   - Preserve route builders in `src/config_defaults.rs`.
   - Preserve tests in `src/model_routes.rs`, `tests/integration_canonical_config.rs`, and `tests/integration_config.rs`.

2. Provider/executor routing
   - Preserve `provider_to_executor` support for `codex`, `opencode`, `zai`, and `z-ai`.
   - Preserve `handler_for_model` routing in `src/dispatch/handler_for_model.rs`.
   - Preserve `plan_spawn` as the single spawn authority in `src/dispatch/plan.rs`.
   - Executor-qualified routes such as `opencode:openrouter/...` must not be parsed as provider-qualified model specs.

3. OpenCode/ZAI behavior
   - Preserve `ExecutorKind::OpenCode`.
   - Preserve `wg opencode-handler`.
   - Preserve `zai:*` and `z-ai:*` translation to the OpenCode executor and expected model strings.
   - Preserve `tests/integration_simplify_executor_taxonomy.rs` and `src/service/llm.rs` routing tests.

4. Coordinator subprocess/session locks
   - Preserve `SessionLock`.
   - Preserve Claude/OpenCode handler locking.
   - Preserve coordinator subprocess routing through `wg spawn-task`.
   - Preserve `tests/integration_coordinator_agent.rs`.

5. Worktree isolation/lifecycle
   - Preserve worktree creation/reuse in `src/commands/spawn/worktree.rs`.
   - Preserve retry-in-place behavior in `src/commands/spawn/execution.rs`.
   - Preserve safe cleanup predicates in `src/commands/service/worktree.rs`.
   - Preserve `tests/integration_spawn_worktrees.rs`.

6. Recovery and graph surgery
   - Preserve `insert`, `rescue`, and `reset`.
   - Preserve `tests/integration_recovery_commands.rs`.

7. Graph semantics
   - Preserve `before` to `after` normalization or explicitly migrate all Speedrift graph writers to canonical `after` edges before taking upstream semantics.
   - Preserve reverse-index readiness defenses in `src/query.rs`.
   - Preserve cycle/readiness tests.

## Tooling Preconditions

Complete these before touching Workgraph source.

- [ ] Repair Driftdriver dev env.

Run:

```bash
cd /Users/braydon/projects/experiments/driftdriver
git status --short --branch
rm -rf .venv
uv sync
uv run python -c 'import encodings; print("python-ok")'
uv run driftdriver upstream-tracker --help
```

Expected: Python imports `encodings`, and the source CLI exposes `upstream-tracker`, `--no-tasks`, and `--no-write-adoptions`.

- [ ] Reinstall the active Driftdriver CLI from source or otherwise align `/Users/braydon/.local/bin/driftdriver` with the checked-out source.

Run:

```bash
which driftdriver
driftdriver --dir /Users/braydon/projects/experiments/driftdriver upstream-tracker --help
```

Expected: installed CLI matches source syntax. If keeping backward compatibility, both `driftdriver upstream-tracker --json` and `driftdriver upstream-tracker run --json` should work.

- [ ] Add true read-only upstream tracker mode before relying on no-task audits.

Required behavior:

- `--no-tasks` prevents task emission.
- `--no-write-adoptions` prevents adoption JSON writes.
- A new `--no-write-pins` or equivalent prevents `.driftdriver/upstream-pins.toml` writes.
- A new `--no-write-state` or equivalent prevents `.driftdriver/upstream-tracker-last.json` writes.

- [ ] Refresh sentinel state before merge without advancing adopted SHA.

Run only after read-only semantics are clear:

```bash
cd /Users/braydon/projects/experiments/driftdriver
driftdriver --dir "$PWD" upstream-tracker --json --no-tasks
```

Expected: current Workgraph upstream is detected and a migration task exists or is confirmed. Do not mark `d938e96c...` as adopted before merge validation.

## Migration Phases

### Task 1: Prepare Isolated Worktree

**Files:**
- No source edits.
- Worktree path: `/Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615`

- [ ] Create an isolated worktree.

Run:

```bash
cd /Users/braydon/projects/experiments/workgraph
git fetch origin main
git fetch fork main
git worktree add /Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615 -b adopt-upstream-20260615 fork/main
```

- [ ] Record baseline refs.

Run:

```bash
cd /Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615
git rev-parse HEAD
git rev-parse origin/main
git rev-parse fork/main
git merge-base fork/main origin/main
git rev-list --left-right --count fork/main...origin/main
```

Expected refs match the Current State section unless upstream moved after this plan.

### Task 2: Baseline Existing Behavior

**Files:**
- No source edits.
- Log results to Workgraph task `workgraph-upstream-migration-plan-20260615` or its execution successor.

- [ ] Capture installed `wg` backup.

Run:

```bash
OLD_WG="$(command -v wg)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
cp -p "$OLD_WG" "$OLD_WG.pre-workgraph-upstream-$STAMP"
git -C /Users/braydon/projects/experiments/workgraph rev-parse fork/main > "$OLD_WG.pre-workgraph-upstream-$STAMP.sha"
```

- [ ] Run Workgraph baseline gates.

Run:

```bash
cd /Users/braydon/projects/experiments/workgraph
cargo fmt --check
cargo check --all-targets
cargo test --lib
cargo test --bins
cargo test --tests
```

- [ ] Run Speedrift baseline gates.

Run:

```bash
cd /Users/braydon/projects/experiments/driftdriver
PYTHONPATH=$PWD pytest tests/test_executor_shim.py tests/test_upstream_tracker.py tests/test_handlers.py tests/test_unified_install.py -q

cd /Users/braydon/projects/experiments/speedrift-ecosystem
driftdriver --dir "$PWD" --json speedriftd status --refresh
./scripts/public_smoke_check.sh
```

### Task 3: Merge Upstream, Resolve Graph/Service First

**Files:**
- `src/graph.rs`
- `src/query.rs`
- `src/commands/service/mod.rs`
- `src/commands/service/coordinator.rs`
- `src/commands/service/coordinator_agent.rs`
- `src/session_lock.rs`
- `tests/integration_coordinator_agent.rs`

- [ ] Merge upstream into the isolated worktree.

Run:

```bash
cd /Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615
git merge --no-ff origin/main
```

Expected: conflicts. Resolve graph/service/coordinator conflicts first.

- [ ] Preserve Speedrift graph semantics.

Acceptance:

- Speedrift graph writers still use CLI APIs or canonical `after` edges.
- If upstream no longer normalizes `before`, Speedrift compatibility either restores normalization or migrates every local writer before installing.
- `FailedPendingEval`, `PendingEval`, `Incomplete`, and `FailureClass::ExecutorConfig` are accounted for in readiness/retry handling.

- [ ] Validate graph/service phase.

Run:

```bash
cargo check --all-targets
cargo test --test integration_coordinator_agent -- --nocapture
cargo test test_unclaim_task -- --nocapture
cargo test test_kill_agent_not_found -- --nocapture
cargo test reconfigure -- --nocapture
cargo test resolve_daemon_config -- --nocapture
```

### Task 4: Resolve Config/Profile And SpawnPlan

**Files:**
- `src/config.rs`
- `src/config_defaults.rs`
- `src/model_routes.rs` or its migrated replacement
- `src/profile/named.rs`
- `src/profile/templates/*.toml`
- `src/dispatch/plan.rs`
- `src/dispatch/handler_for_model.rs`
- `tests/integration_canonical_config.rs`
- `tests/integration_config.rs`

- [ ] Choose the central model route design.

Decision:

- Keep Speedrift central registry behavior.
- If upstream removed `src/model_routes.rs`, either restore it or move the registry lookup into upstream's new config/profile structure without hardcoding Speedrift routes.

- [ ] Preserve `plan_spawn` as the routing boundary.

Acceptance:

- Explicit executor choice remains final.
- Model strings can select provider/model without silently overriding an explicit executor.
- `opencode:openrouter/...` is executor-qualified, not provider-only.

- [ ] Validate config/profile phase.

Run:

```bash
cargo test --test integration_canonical_config -- --nocapture
cargo test --test integration_config -- --nocapture
cargo test handle_reconfigure -- --nocapture
cargo test effective_executor -- --nocapture
cargo test agent_effective_executor_ -- --nocapture
cargo test parse_model_spec -- --nocapture
cargo test task_route_ -- --nocapture
cargo test test_init_writes_model_and_endpoint_config -- --nocapture
cargo test --test integration_config init_with_endpoint_and_model -- --nocapture
cargo test --test integration_config config_set_endpoint_url_with_model -- --nocapture
cargo test --test integration_config config_models_set_endpoint_and_show_json -- --nocapture
```

### Task 5: Resolve Executor Arena, OpenCode, And ZAI

**Files:**
- `src/commands/opencode_handler.rs`
- `src/commands/spawn_task.rs`
- `src/commands/spawn/execution.rs`
- `src/commands/native_exec.rs`
- `src/executor/native/*`
- `src/executor_discovery.rs`
- `src/service/executor.rs`
- `templates/executors/*.toml.example`
- `tests/integration_simplify_executor_taxonomy.rs`
- `tests/integration_native_executor.rs`

- [ ] Preserve OpenCode/ZAI routing while adopting upstream executor arena.

Acceptance:

- `zai:*` and `z-ai:*` route to OpenCode.
- Chat sessions launched with Codex/OpenCode do not fall back to Claude.
- Global default endpoints do not leak into CLI executors.
- Named/inline endpoints are preserved for native/nex where expected.

- [ ] Validate executor phase.

Run:

```bash
cargo test endpoint_execution_ -- --nocapture
cargo test native_client_config_ -- --nocapture
cargo test --test integration_native_executor test_native_executor_config_from_toml -- --nocapture
cargo test --test integration_cli_endpoints -- --nocapture
cargo test --test integration_cli_workflows -- --nocapture
cargo test --test integration_simplify_executor_taxonomy -- --nocapture
cargo test --test integration_spawn_worktrees -- --nocapture
```

### Task 6: Adopt Nex/TUI After Core Routing Is Stable

**Files:**
- `Cargo.toml`
- `src/bin/nex.rs`
- `src/nex_cli.rs`
- `src/nex_runtime.rs`
- `src/commands/nex.rs`
- `src/tui/*`
- `tests/integration_nex_entrypoint.rs`
- `tests/smoke/scenarios/nex_*.sh`
- `tests/smoke/scenarios/tui_*.sh`

- [ ] Adopt standalone `nex` and TUI changes only after config/executor gates pass.

Acceptance:

- `nex` uses the same config/profile semantics as Workgraph.
- `nex` session locks do not conflict with coordinator/session locks.
- Large-output and EOF-resume upstream fixes are preserved.

- [ ] Validate nex/TUI phase.

Run:

```bash
cargo test --test integration_nex_entrypoint -- --nocapture
cd tests/smoke
bash scenarios/nex_large_output_nonrecursive.sh
bash scenarios/nex_openrouter_chat_stays_alive_and_resumes.sh
bash scenarios/nex_wg_openrouter_endpoint_auth.sh
bash scenarios/tui_plus_nex_chat.sh
bash scenarios/tui_plus_nex_endpoint_autocomplete.sh
bash scenarios/tui_plus_nex_global_endpoint_picker.sh
```

### Task 7: Adopt Install/Upgrade Last

**Files:**
- `.github/workflows/release.yml`
- `dist-workspace.toml`
- `scripts/install-wg.sh`
- `scripts/install-wg.ps1`
- `src/commands/upgrade.rs`
- `tests/upgrade/main.rs`

- [ ] Adopt upstream install/upgrade/release surfaces after runtime tests pass.

Acceptance:

- Existing local `cargo install --path . --locked --force` remains viable.
- New upstream installer does not bypass Speedrift rollback requirements.
- Release workflow changes are reviewed but not required for local migration success.

- [ ] Validate install/upgrade phase.

Run:

```bash
cargo test --test integration_setup -- --nocapture
cargo test --test integration_smoke_gate -- --nocapture
cargo test --test integration_init -- --nocapture
cargo test --test integration_e2e_smoke -- --nocapture
```

## Final Verification Gates

Run all before installing the new `wg`.

```bash
cd /Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615
cargo fmt --check
cargo check --all-targets
cargo test --lib
cargo test --bins
cargo test --tests
```

Run the Driftdriver configured Workgraph compatibility gates:

```bash
cd /Users/braydon/projects/experiments/driftdriver
PYTHONPATH=$PWD pytest tests/test_executor_shim.py tests/test_upstream_tracker.py -q
PYTHONPATH=$PWD pytest tests/test_handlers.py tests/test_unified_install.py -q

cd /Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615
cargo test --test integration_recovery_commands -- --nocapture
cargo test --test integration_spawn_worktrees -- --nocapture
cargo test --test integration_spawn_worktrees service_tick_reaps_marked_isolated_worktree_after_agent_exit -- --nocapture
cargo test handle_reconfigure -- --nocapture
cargo test effective_executor -- --nocapture
cargo test agent_effective_executor_ -- --nocapture
cargo test parse_model_spec -- --nocapture
cargo test task_route_ -- --nocapture
cargo test endpoint_execution_ -- --nocapture
cargo test native_client_config_ -- --nocapture
cargo test --test integration_native_executor test_native_executor_config_from_toml -- --nocapture
cargo test test_init_writes_model_and_endpoint_config -- --nocapture
cargo test --test integration_config init_with_endpoint_and_model -- --nocapture
cargo test --test integration_config config_set_endpoint_url_with_model -- --nocapture
cargo test --test integration_config config_models_set_endpoint_and_show_json -- --nocapture
cargo test reconfigure -- --nocapture
cargo test resolve_daemon_config -- --nocapture
cargo test run_set_executor -- --nocapture
cargo test test_append_error_writes_system_error_role -- --nocapture
cargo test test_unclaim_task -- --nocapture
cargo test test_kill_agent_not_found -- --nocapture
cargo test --test integration_coordinator_agent -- --nocapture
```

Run Speedrift-facing smoke:

```bash
cd /Users/braydon/projects/experiments/driftdriver
scripts/e2e_smoke.sh
scripts/ecosystem_hub_smoke.sh /Users/braydon/projects/experiments/speedrift-ecosystem

cd /Users/braydon/projects/experiments/speedrift-ecosystem
./scripts/public_smoke_check.sh
driftdriver --dir "$PWD" --json speedriftd status --refresh
```

## Install And Rollback

Install only after all final verification gates pass.

```bash
cd /Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615
OLD_WG="$(command -v wg)"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
cp -p "$OLD_WG" "$OLD_WG.pre-upstream-$STAMP"
git rev-parse HEAD > "$OLD_WG.pre-upstream-$STAMP.sha"

wg service stop || true
cargo install --path . --locked --force
hash -r
wg --version
ls -l "$(command -v wg)"
```

Post-install smoke:

```bash
cd /Users/braydon/projects/experiments/speedrift-ecosystem
./scripts/public_smoke_check.sh

cd /Users/braydon/projects/experiments/driftdriver
scripts/e2e_smoke.sh
```

Rollback:

```bash
WG_BIN="$(command -v wg)"
BACKUP="$(ls -t "$WG_BIN".pre-upstream-* | head -1)"
wg service stop || true
cp -p "$BACKUP" "$WG_BIN"
hash -r
wg --version
ls -l "$WG_BIN"

cd /Users/braydon/projects/experiments/speedrift-ecosystem
./scripts/public_smoke_check.sh

cd /Users/braydon/projects/experiments/driftdriver
scripts/e2e_smoke.sh
```

Only reset the Workgraph repo branch after confirming no unrelated user work exists:

```bash
cd /Users/braydon/projects/experiments/workgraph
git switch main
PRE_MERGE_SHA="$(cat "$(ls -t "$(command -v wg)".pre-upstream-*.sha | head -1)")"
git reset --hard "$PRE_MERGE_SHA"
```

## Workgraph Task Breakdown

Seed these as execution tasks after tooling preconditions are fixed.

1. `driftdriver-upstream-tracker-tooling-20260615`
   - Repair `driftdriver` `.venv`, align installed CLI with source, add true read-only tracker flags, and reconcile upstream-tracker docs.
   - Verify: `uv run python -c 'import encodings'`, `uv run driftdriver upstream-tracker --help`, installed `driftdriver upstream-tracker --help`, focused upstream tracker pytest.

2. `workgraph-upstream-baseline-20260615`
   - Create isolated Workgraph worktree, capture refs, back up installed `wg`, run baseline Workgraph and Speedrift gates.
   - Verify: baseline commands in Task 2.

3. `workgraph-upstream-graph-service-20260615`
   - Merge upstream and resolve graph/service/coordinator/session-lock conflicts first.
   - Verify: graph/service phase commands.

4. `workgraph-upstream-config-spawnplan-20260615`
   - Preserve central model defaults and reconcile upstream profile/config/`SpawnPlan` changes.
   - Verify: config/profile phase commands.

5. `workgraph-upstream-executor-arena-20260615`
   - Adopt upstream executor arena while preserving Codex/OpenCode/ZAI routing and endpoint semantics.
   - Verify: executor phase commands.

6. `workgraph-upstream-nex-tui-20260615`
   - Adopt standalone `nex` and TUI fixes after core routing is stable.
   - Verify: nex/TUI phase commands.

7. `workgraph-upstream-install-upgrade-20260615`
   - Adopt install/upgrade/release surfaces and run final Workgraph gates.
   - Verify: install/upgrade phase commands plus full cargo gates.

8. `speedrift-workgraph-postinstall-20260615`
   - Install merged `wg`, run Speedrift smoke, update adopted pins, close/supersede sentinel tasks, and document rollback.
   - Verify: install, post-install smoke, and sentinel refresh.

## Closeout Evidence

Before closing the execution task, log:

- Pre-merge SHAs: Workgraph HEAD, `origin/main`, `fork/main`, merge base.
- Installed `wg` path, version, mtime, backup path, backup SHA.
- Conflict files and resolution summary.
- Phase test results and skipped-test reasons.
- Final cargo and Speedrift/Driftdriver gate results.
- Installed `wg` evidence after `cargo install`.
- Rollback command evidence.
- Updated sentinel adopted SHA and any follow-up task IDs.
