# Workgraph PI Upstream Adoption - 2026-06-22

## Status

Workgraph upstream `origin/main` has been reviewed and merged locally for the PI harness design work.

- Upstream reviewed: `5e47d1f0` (`docs: publish pi.dev integration docs to main`)
- Local integration branch: `/Users/braydon/projects/experiments/workgraph`, `integrate/pi-harness-upstream-speedrift-20260622`
- Local integrated head: `7e44aa8d` (`workgraph: fix recovery command description flags`)
- Upstream delta after merge: downstream-only commits and `0` upstream commits behind (`HEAD...origin/main`), meaning local integration has downstream work and is no longer behind upstream.
- Installed CLI: `cargo install --path . --locked --force` replaced `wg` and `nex` with the merged `worksgood` package.
- Speedrift sentinel: Driftdriver now tracks the adopted Workgraph ref as the local integration branch until it is pushed/merged back to `fork/main`.

## What Upstream Added

The PI-related upstream change is a design bundle, not production handler code:

- `docs/pi-integration/executor-research.md`
- `docs/pi-integration/model-mgmt-research.md`
- `docs/pi-integration/integration-plan.md`

The plan recommends an additive PI integration:

- Add `ExecutorKind::Pi` as a chat-capable external CLI.
- Add a `wg pi-handler` peer of `opencode_handler.rs`.
- Add a `src/profile/templates/pi.toml` starter profile.
- Add `wg chat model <id> <spec>` and later a TUI `/model` picker.
- Optionally support warm mid-chat model swaps through PI RPC.
- Do not make PI the default Workgraph foundation yet.

## Local Preservation Work

The merge preserved our provider/model-agnostic dispatcher work:

- Provider-qualified models remain authoritative for route selection.
- Stale Claude/Codex executor defaults are treated as hints, not hard pins, when the configured model requires another handler.
- Provider health/backoff participates in dispatch planning.
- Fatal provider/auth/session failures back off the provider route and retry the next configured healthy route instead of immediately failing the task.

## Verification

Run in `/Users/braydon/projects/experiments/workgraph`:

```bash
cargo check
cargo test zai -- --nocapture
cargo test --test test_provider_health -- --nocapture
cargo test provider_health_skips -- --nocapture
cargo test model_provider_resolves -- --nocapture
cargo test codex_model_routes -- --nocapture
cargo install --path . --locked --force
wg --version
nex --version
```

All verification commands completed successfully. The install emitted a locked-dependency warning for yanked `rquest v3.0.0`, but completed under the upstream `Cargo.lock`.

## Speedrift Follow-Up Graph

The remaining PI harness implementation should run as paused, explicit Workgraph tasks instead of an implicit autonomous wave:

1. Add PI executor kind and discovery.
2. Implement `wg pi-handler` chat and one-shot worker surfaces.
3. Add the PI starter profile without reintroducing Anthropic-only assumptions.
4. Add chat model switching and TUI picker support.
5. Add credentialed PI smoke tests and Speedrift route checks.
6. Move the Speedrift adopted Workgraph ref back to `fork/main` once the local integration branch is pushed or merged there.
