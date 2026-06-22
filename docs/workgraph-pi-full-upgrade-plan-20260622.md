# Workgraph PI Full Upgrade Plan - 2026-06-22

## Goal

Bring downstream Workgraph and Speedrift up to the current upstream PI work
without regressing provider/model-agnostic dispatch, PAIA routing, or Speedrift
drift-control behavior.

Done means:

- Workgraph downstream is current with `origin/main` and the relevant active PI
  implementation branches, or each skipped branch has a recorded waiver.
- PI is a first-class optional executor/profile/plugin path, not the default.
- Claude/Codex assumptions remain hints only; configured model/provider routes
  drive executor selection.
- Provider health/backoff and failover still skip auth, rate, session, and
  capacity failures.
- Speedrift can track the adopted Workgraph ref and seed/check PI work through
  small, explicit Workgraph tasks.
- The installed local `wg`/`nex` binaries come from the verified integration
  branch.

## Current State

- Local Workgraph integration branch:
  `/Users/braydon/projects/experiments/workgraph`,
  `integrate/pi-harness-upstream-speedrift-20260622`.
- `origin/main` PI state adopted through `5e47d1f0`.
- Local downstream provider-failover preservation is on top of that merge.
- Active upstream PI implementation branches exist but are not on `origin/main`.
- The existing Speedrift PI tasks are paused and need to be expanded with the
  implementation branch evidence.

Relevant upstream implementation commits:

- `8190e2de` - `ExecutorKind::Pi`, route/discovery/service hooks.
- `e130ed95` - PI profile registration and `src/profile/templates/pi.toml`.
- `8382b287` - `pi-plugin/` Node/TypeScript package and SDK host.
- `cb4396cb` - Rust terminal host scaffolding.
- `17ebb8cc` - upstream PI patch package for default-off `PI_NO_TUI`.
- `9f1c4bd1` - plugin-first integration plan v2.

## Non-Negotiables

- No broad merge of PI implementation branches until branch bases are reconciled.
  Raw diffs include large unrelated deletions from the current downstream tree.
- No Anthropic-only defaults in PAIA/Speedrift paths.
- No PI default executor promotion until credentialed smoke tests pass.
- No autonomous Speedrift dispatch during the upgrade unless explicitly armed.
- No secrets in logs, fixtures, Workgraph descriptions, or docs.

## Upgrade Waves

### Wave 0 - Reconcile And Fence The Work

1. Update `docs/workgraph-pi-upstream-adoption-20260622.md` to state that
   `origin/main` has docs, while active implementation branches carry real code.
2. Update existing Workgraph PI tasks with upstream commit IDs, branch names, and
   selective-adoption warnings.
3. Add missing tasks for plugin package, terminal host, upstream PI patch, and
   final promotion decision.
4. Run drift prechecks against each task before edits.

Verification:

- `wg list --all`
- `git status --short --branch` in Workgraph, Driftdriver, and
  Speedrift ecosystem.
- `driftdriver --dir "$PWD" --json speedriftd status --refresh`

### Wave 1 - Adopt PI Executor Kind And Discovery

Adopt the substance of upstream commit `8190e2de`, selectively adapted to the
current downstream codebase.

Implementation scope:

- Add `ExecutorKind::Pi`.
- Add string round-trip behavior for `pi`.
- Route `pi:*` model specs to the PI executor path.
- Teach executor discovery that PI is an external CLI and experimental until
  smoke-tested.
- Preserve provider-qualified dispatch and provider-health failover.

Tests:

- Unit: `ExecutorKind::Pi` `as_str`/parse round-trip.
- Unit: `pi:*` route maps to PI without falling through to Claude/Codex.
- Unit/integration: discovery handles missing `pi` binary as unavailable, not
  fatal.
- Regression: existing provider health, Z.ai, Codex route, and fallback tests.

Model fit:

- Cheapest good coding model is sufficient: `ollama/qwopus3.6:27b-mtp-q4` or
  a cheap cloud coding route.
- Escalate only if current dispatch internals diverge significantly from the
  upstream patch.

### Wave 2 - Implement Minimal `wg pi-handler`

Implement a minimal, testable handler before adopting broader plugin/TUI work.

Implementation scope:

- Add `src/commands/pi_handler.rs`.
- Register `wg pi-handler` in CLI/command modules.
- Support one-shot worker mode with clean stdout/stderr separation.
- Support chat/RPC mode enough for Workgraph to launch PI as a chat-capable
  external CLI.
- Normalize model specs:
  - `pi:provider/model`
  - `pi:openrouter/vendor/model`
  - future central route names that resolve to PI-backed providers.
- Use fake binary tests before credentialed PI tests.

Tests:

- Unit: model normalization.
- Unit: command argv construction.
- Integration: fake `pi` executable receives expected args and stdin.
- Regression: no logs/secrets leak into task output.
- Regression: provider failover still retries alternate routes on auth/rate/
  capacity/session failures.

Model fit:

- Start with `ollama/qwopus3.6:27b-mtp-q4` or `gptmini` for implementation.
- Escalate to a premium model if the PI RPC protocol or terminal behavior is
  underspecified.

### Wave 3 - Adopt PI Profile

Adopt upstream commit `e130ed95` selectively.

Implementation scope:

- Add `src/profile/templates/pi.toml`.
- Register the PI profile in `src/profile/named.rs`.
- Update quickstart/profile surfaces only where needed.
- Keep Agency/meta-task routes explicit and configurable.
- Avoid hardcoded Anthropic/Codex executor assumptions.

Tests:

- Profile template loads.
- `wg quickstart` or profile selection includes PI when requested.
- Config tests pass with PI profile.
- PAIA/non-Anthropic profile fixtures still route correctly.

Model fit:

- Small coding model is sufficient if tests are clear.

### Wave 4 - Adopt Plugin-First Plan V2

Adopt the doc and planning implications of upstream commit `9f1c4bd1`.

Implementation scope:

- Bring `docs/pi-integration/integration-plan-v2.md` into downstream.
- Compare plan v2 against Waves 1-7.
- Create follow-up tasks for any real requirements not covered by this plan.
- Do not let the doc import override downstream provider-agnostic policy.

Tests:

- Documentation lint if available.
- Speedrift/specdrift check against this plan.

Model fit:

- Cheap model or manual review is sufficient.

### Wave 5 - Adopt PI Plugin Package As Optional Surface

Adopt upstream commit `8382b287` after the minimal handler and profile work pass.

Implementation scope:

- Add `pi-plugin/` package.
- Verify package metadata, scripts, test runner, and lockfile strategy.
- Make the plugin optional: Rust core build must not require Node package build.
- Ensure plugin backend invokes `wg` safely and does not bypass route policy.
- Add Speedrift/Workgraph docs for when to use plugin mode versus CLI mode.

Tests:

- `npm test` or equivalent in `pi-plugin/`.
- TypeScript compile.
- Fake backend tests for graph commands.
- Smoke: plugin can list/inspect Workgraph tasks without mutating state.

Model fit:

- Cheap/standard coding model is fine for package adoption.
- Use a stronger model if SDK host protocol questions arise.

### Wave 6 - Adopt Terminal Host Scaffolding

Adopt upstream commit `cb4396cb` only after the plugin package has a passing
test surface.

Implementation scope:

- Add `src/terminal_host/mod.rs`.
- Register module in `src/main.rs` or a better crate boundary.
- Feature-gate if the host is not ready for stable users.
- Keep terminal/TUI behavior isolated from dispatcher correctness.

Tests:

- Rust unit tests for terminal host parsing/state transitions where available.
- `cargo check` with default features.
- Optional feature check if feature-gated.

Model fit:

- Standard or premium model recommended because terminal hosts are stateful and
  easy to regress.

### Wave 7 - Upstream PI Patch Package

Adopt upstream commit `17ebb8cc` as docs/patch material, then decide whether it
needs to be submitted upstream to the PI repo.

Implementation scope:

- Add `docs/pi-integration/upstream-patch/*`.
- Validate the patch still applies or document drift.
- If still useful, prepare an upstream issue/PR against `earendil-works/pi`.

Tests:

- Run `tui_guard_test.mjs` if its dependencies are locally available.
- Otherwise record exact blocker and expected command.

Model fit:

- Cheap model/manual is sufficient unless the patch no longer applies.

### Wave 8 - Speedrift And Driftdriver Integration

Update our ecosystem after Workgraph PI code lands.

Implementation scope:

- Update Driftdriver upstream tracker adopted ref from the temporary local branch
  to the pushed/merged Workgraph ref.
- Update Speedrift docs and central registry with:
  - PI executor support level.
  - PI profile support level.
  - plugin support level.
  - required smoke evidence.
- Make PlanForge/Speedrift task generation aware of PI as an optional route,
  still honoring cheapest-sufficient model selection.
- Verify repo-change auto-update still refreshes managed guidance after Workgraph
  changes.

Tests:

- `uv run driftdriver --dir "$PWD" upstream-tracker --json`
- Speedrift drift check on the final promotion task.
- Workgraph task graph has no stale unblocked system tasks starving PI work.

Model fit:

- Standard model recommended because this crosses repos and policies.

### Wave 9 - Final Install, Smoke, And Promotion Decision

Implementation scope:

- Run full verification.
- Install local `wg`/`nex`.
- Run PI binary discovery.
- Run fake PI handler smoke.
- Run credentialed PI smoke if credentials and local PI install are available.
- Record promotion decision:
  - `experimental`: implementation exists but credentialed smoke blocked/failed.
  - `stable optional`: fake + credentialed smokes pass and Speedrift route checks
    pass.

Verification:

```bash
cd /Users/braydon/projects/experiments/workgraph
cargo fmt --check
cargo check
cargo test zai -- --nocapture
cargo test --test test_provider_health -- --nocapture
cargo test provider_health_skips -- --nocapture
cargo test model_provider_resolves -- --nocapture
cargo test codex_model_routes -- --nocapture
cargo test pi -- --nocapture
cargo install --path . --locked --force
wg --version
nex --version
```

```bash
cd /Users/braydon/projects/experiments/workgraph/pi-plugin
npm test
npm run build
```

```bash
cd /Users/braydon/projects/experiments/driftdriver
uv run driftdriver --dir "$PWD" upstream-tracker --json
```

```bash
cd /Users/braydon/projects/experiments/speedrift-ecosystem
./.workgraph/drifts check --task workgraph-pi-smoke-speedrift-20260622 --write-log --create-followups
```

## Workgraph Task Graph

Update or create these tasks:

1. `workgraph-pi-upstream-branch-audit-20260622`
   - Confirms each upstream PI branch/commit, records selective-adoption plan,
     and updates this doc.
2. `workgraph-pi-executor-kind-discovery-20260622`
   - Wave 1.
3. `workgraph-pi-handler-20260622`
   - Wave 2.
4. `workgraph-pi-profile-20260622`
   - Wave 3.
5. `workgraph-pi-plugin-plan-v2-20260622`
   - Wave 4.
6. `workgraph-pi-plugin-package-20260622`
   - Wave 5.
7. `workgraph-pi-terminal-host-20260622`
   - Wave 6.
8. `workgraph-pi-upstream-patch-20260622`
   - Wave 7.
9. `speedrift-workgraph-pi-integration-20260622`
   - Wave 8.
10. `workgraph-pi-smoke-speedrift-20260622`
   - Wave 9.
11. `speedrift-workgraph-pi-upstream-pins-20260622`
   - Final adoption pin update.

Dependency shape:

- Audit first.
- Executor before handler.
- Handler before profile.
- Profile and handler before smoke.
- Plugin plan before plugin package.
- Plugin package before terminal host.
- Speedrift integration after executor/profile and before final pins.
- Final pins after smoke/promotion decision.

## Risks And Mitigations

- Risk: broad merge deletes current downstream code.
  - Mitigation: cherry-pick or manually port only the implementation commits.
- Risk: PI CLI protocol differs locally.
  - Mitigation: fake binary tests first; credentialed smoke later.
- Risk: provider failover regresses back to Claude/Codex defaults.
  - Mitigation: keep provider health and route resolution tests in every wave.
- Risk: plugin package adds Node build fragility to Rust core.
  - Mitigation: optional package, separate tests, no core build dependency.
- Risk: terminal host complexity slows the upgrade.
  - Mitigation: feature-gate and promote after CLI/profile path is stable.
- Risk: Speedrift dispatch starvation reappears during rollout.
  - Mitigation: keep tasks paused until explicit wave execution; use scoped
    dispatch only.

## Promotion Criteria

PI remains `experimental` unless all are true:

- PI executor kind and handler tests pass.
- PI profile tests pass.
- Provider/model agnostic failover tests pass.
- Fake PI binary smoke passes.
- Credentialed PI one-shot and chat smoke pass, or a human explicitly waives
  credentialed promotion.
- Speedrift upstream tracker and drift checks pass.
- Local installed `wg`/`nex` come from the verified branch.
