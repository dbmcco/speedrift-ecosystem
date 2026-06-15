# Workgraph Upstream Baseline - 2026-06-15

## Scope

Baseline for adopting Workgraph upstream `origin/main` into downstream `fork/main` without changing the installed `wg` binary.

## Refs

- Downstream/fork HEAD: `8f00826a8bf87d4a00758219722e993c37c69a1e`
- Upstream HEAD: `d938e96c8d67dbce94fa7cdd633af4a152ee30d7`
- Merge base: `6617ef03dcc0d55d96268fd8872519144435bdd1`
- Divergence: `67` downstream commits, `76` upstream commits
- Isolated migration worktree: `/Users/braydon/.config/superpowers/worktrees/workgraph/adopt-upstream-20260615`
- Migration branch: `adopt-upstream-20260615`

## Installed Binary Backup

- Installed binary: `/Users/braydon/.cargo/bin/wg`
- Backup: `/Users/braydon/.cargo/bin/wg.pre-workgraph-upstream-20260615T195642Z`
- Backup SHA marker: `/Users/braydon/.cargo/bin/wg.pre-workgraph-upstream-20260615T195642Z.sha`

The backup SHA marker records downstream Workgraph `8f00826a8bf87d4a00758219722e993c37c69a1e`.

## Baseline Gates

Command attempted from `/Users/braydon/projects/experiments/workgraph`:

```bash
cargo fmt --check && cargo check --all-targets && cargo test --lib && cargo test --bins && cargo test --tests
```

Results:

- `cargo fmt --check`: passed
- `cargo check --all-targets`: passed
- `cargo test --lib`: failed on the current downstream baseline
- `cargo test --bins`: hung in `target/debug/deps/wg-*` after roughly five minutes and was stopped
- `cargo test --tests`: not run because earlier gates established a red baseline

Current downstream `cargo test --lib` failures:

- `chat_sessions::tests::daemon_style_coordinator_registration_creates_both_paths`: coordinator registration assertion mismatch
- `config::tests::test_load_merged_no_local_file`: expected `claude`/native default, observed `codex`
- `config::tests::test_resolve_triage_default`: expected `anthropic`, observed `codex`
- `dispatch::plan::tests::test_default_executor_is_claude`: expected Claude, observed Codex from downstream `codex:gpt-5.5` default
- `federation::tests::resolve_store_finds_bare_store`: macOS `/private/var` versus `/var` path canonicalization
- `federation::tests::resolve_store_finds_direct_agency_dir`: macOS `/private/var` versus `/var` path canonicalization
- `federation::tests::resolve_store_finds_project_store`: macOS `/private/var` versus `/var` path canonicalization
- `service::llm::tests::test_lightweight_llm_dispatch_resolves_model`: expected `anthropic`, observed `codex`
- `service::tests::has_active_children_with_child_process`: child-process liveness assertion failed
- `smoke::tests::sweep_removes_old_subdirs_only`: BSD `touch -d` incompatibility

Observed `cargo test --bins` failures before the hang:

- `commands::agency_remote::tests::resolve_store_with_remotes_uses_named_remote`
- `commands::chat::tests::test_generate_request_id_unique`

## Compatibility Cross-Check

Driftdriver compatibility tests against current Workgraph downstream stayed green:

```bash
PAIA_MODEL_ROUTE_REGISTRY_PATH=/Users/braydon/projects/experiments/paia-agent-runtime/config/cognition-presets.toml \
PYTHONPATH=/Users/braydon/projects/experiments/driftdriver \
pytest tests/test_executor_shim.py tests/test_upstream_tracker.py tests/test_handlers.py tests/test_unified_install.py -q
```

Result: `73 passed, 1 warning`.

Speedrift supervisor refresh from `/Users/braydon/projects/experiments/speedrift-ecosystem` succeeded and remained in `observe` mode.

## Migration Implication

The upstream merge can proceed in the isolated worktree, but validation must compare against this known-red baseline rather than requiring immediate full-suite green. The adoption is blocked from installation until:

- direct merge conflicts are resolved,
- downstream executor/config defaults are preserved deliberately,
- baseline failures are separated from merge-introduced failures,
- Driftdriver compatibility tests remain green,
- a rollback path to the backed-up installed `wg` remains available.
