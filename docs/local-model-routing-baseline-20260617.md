# Speedrift Local Model Routing Baseline

Date: 2026-06-17

This is the current PI-selectable local-model baseline for Speedrift planning,
execution, and evaluation routes. Treat it as policy input for PlanForge,
Agency profiles, and drift checks. Do not replace existing runtime routes only
because a larger local model exists; prove the replacement on that workload.

## PI-Selectable Local Models

| Route | Use First For | Avoid For | Notes |
| --- | --- | --- | --- |
| `ollama/qwopus3.6:27b-mtp-q4` | Local reasoning, coding, tool-use experiments, stronger local executor trials | Very short prompts where qwen latency matters more than quality | 27.3B Q4_K_M, 32K PI context, tool/thinking capable through Ollama OpenAI-compatible endpoint. Measured PI runs: 45.5s on 80-line transcript, 64.9s on 260-line transcript, bash smoke 13.3s, coding smoke 19.4s. |
| `ollama/gemma4:26b` | Polished local summaries, transcript notes, high-fidelity narrative synthesis | Long-context work where latency dominates | Best phrasing/fidelity in transcript bake-off. Measured PI runs: 20.1s on 80-line transcript, 140.1s on 260-line transcript. Treat as text-first unless explicitly testing vision. |

## Installed But Not Default-Selectable

| Model | Policy |
| --- | --- |
| `qwen3:8b` | Keep existing runtime routes until workload-specific evals justify replacement. It remains physically installed in Ollama, and PI can still use `ollama/qwen3:8b` if explicitly requested. Current references include paia-triage classification, aish local tertiary summarization, and paia-agent-runtime machine-state-summary presets. Do not replace those blindly; run JSON/classification evals first. |

## Removed Models

| Model | Policy |
| --- | --- |
| DiffusionGemma local / `diffusiongemma-26b-a4b-it-local` | Do not route to it, suggest it, or include it as available. It was removed from PI config, local project checkout, related caches, and the old shim process. |

## Routing Rules

- Use `ollama/qwopus3.6:27b-mtp-q4` as the preferred local candidate for
  stronger-than-qwen coding, reasoning, and tool-use experiments when medium
  latency is acceptable.
- Use `ollama/gemma4:26b` for local summary and notes quality when polished
  output matters more than long-context latency.
- Keep `qwen3:8b` in current runtime routes until the exact workload has a
  passing eval that proves a replacement is worth the added latency.
- Do not put removed local models back into PI, Speedrift, Agency, or planner
  guidance without an explicit new install/eval task.
- Prefer central registry route names in generated plans; raw provider/model
  IDs belong in this baseline and model registry configuration, not in ad hoc
  task prose.

## Eval Requirements Before Changing Defaults

Any proposal to promote or demote a local model route must include:

- workload name and owner,
- prompt shape and context size,
- latency measurements,
- quality comparison against the current route,
- tool-use or structured-output pass/fail when relevant,
- cost/latency tradeoff,
- rollback plan,
- affected runtime routes and Agency profiles.

For classification or JSON-producing routes, replacement requires a
workload-specific structured-output eval. Summary quality alone is not enough.
