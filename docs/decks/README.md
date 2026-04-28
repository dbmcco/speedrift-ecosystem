# Speedrift Decks

- `../assets/speedrift-ecosystem-summary.svg`: README-first summary image for readers who need the whole system at a glance
- `speedrift-ecosystem-story.html`: GitHub-facing narrative for the autonomous speedrift ecosystem
  - mental model shift: repo-local lane runner -> ecosystem operating fabric
  - architecture: repo plane + control plane + worker plane
  - authority contract: bounded central actions with explicit safety limits
  - autonomous loop: observe -> prioritize -> plan -> execute -> record/writeback
  - dashboard contract: narrated overview, repo cards, graphs, actionable queues
  - impact mechanics: formula-driven scorecard with illustrative (non-production) values
  - modules: factorydrift, sessiondriver, secdrift, qadrift, plandrift, northstardrift + core lanes
  - operating model: daemonized supervision on codified `:8777` endpoint (local + Tailscale)

Supporting spec:

- [`../northstardrift.md`](../northstardrift.md): concrete measurement, scoring, narration, and task-emission contract for the dark-factory north star

Open locally from repo root:

```bash
open docs/decks/speedrift-ecosystem-story.html
```

Public URL:

```text
https://dbmcco.github.io/speedrift-ecosystem/decks/speedrift-ecosystem-story.html
```

README entry point:

```text
../../README.md#start-here
```
