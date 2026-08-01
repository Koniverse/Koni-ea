---
id: EPIC-1
title: "Repo foundation & first public release"
status: done
created: 2026-08-02T00:00:00.000Z
updated: 2026-08-02T00:00:00.000Z
---
# EPIC-1 — Repo foundation & first public release

## Goal

Stand up `koni-ea` as the public delivery repo for the Koniverse EA/bot domain:
own the EA skills outright, ship a template a partner can actually build from, and
present the whole thing so an AI agent can read it and follow the pattern without
guessing.

Done means a partner clones the repo, copies one directory, replaces one function,
and has a bot that deploys to Senti.

## Business context

Senti runs trading bots on real MetaTrader 5 accounts. Its custom-bot upload path
(`.ex5` + `.set`, private scope) is live, so partners *can* ship bots today — but
the barrier is MQL5 itself. An Expert Advisor is roughly 5% strategy and 95%
chassis, and every part of that chassis has a wrong version that compiles, runs,
backtests green, and then loses money live.

This epic removes the chassis from the problem. It does not try to make anyone's
strategy profitable — that is explicitly out of scope, and conflating the two is
how people lose money.

## Feature pillars

1. **Own the domain skills.** `koni-ea-dev` and `koni-ea-ops` move here from
   `Koni-Skills`, with exactly one copy so the two cannot drift.
2. **Ship a real template.** A complete, correct MQL5 skeleton with one placeholder
   `Signal()` — not a directory promising a template that does not exist.
3. **Make the repo agent-readable.** `AGENTS.md` leads with the build-a-bot
   workflow; the rules are stated with their failure mode, not as taste.
4. **Be safely public.** MIT license, contribution bar, risk disclaimer, no
   proprietary strategy IP, no vendored third-party content.

## Out of scope

- **Profitable strategies.** The shipped stub is a naive EMA cross documented as
  having no edge. This epic ships correctness, not returns.
- **Non-MQL5 runtimes.** Senti's upload path accepts `.ex5` + `.set`; the crypto
  bot pathway is not open. No `python/`, `pine/`, `js/`, `mql4/` templates.
- **A backtesting or optimization engine.** MT5's Strategy Tester owns that.
- **The Senti platform itself.** Upload, catalog and deployment are Senti's; this
  repo stops at a compiled artifact.
- **Compile verification in CI.** MetaEditor is Windows-only; there is no
  cross-platform compile step to automate here yet.

## Requirements coverage

This is a content-profile repo with no `PRD.md`, so there are no `FR-N` to
enumerate — see [sprints/README.md §No PRD in this repo](../README.md#no-prd-in-this-repo).
The epic's scope is stated above and in [BRIEF.md](../../BRIEF.md); the structural
conventions it establishes are in [REPO\_STRUCTURE.md](../../../REPO_STRUCTURE.md).

## Stories

| ID                                                   | Title                                                                          | Goal                                                                                                      | Status | Version |
| ---------------------------------------------------- | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- | ------ | ------- |
| [US-1.1](../stories/US-1.1-repo-bootstrap.md)        | Bootstrap the repo to the Koniverse standard                                   | Doc tree, skill wiring, commit gate, agent integration surface — a repo that enforces its own conventions | ✅ done | v0.1.0  |
| [US-1.2](../stories/US-1.2-relocate-ea-skills.md)    | Relocate koni-ea-dev + koni-ea-ops from Koni-Skills                            | One copy of each EA skill, owned here, with every consumer re-pointed                                     | ✅ done | v0.1.0  |
| [US-1.3](../stories/US-1.3-public-release-format.md) | Format for public release — template, license, agent entry point               | A working MQL5 template, MIT license, and entry-point docs an agent can follow                            | ✅ done | v0.2.0  |
| [US-1.4](../stories/US-1.4-open-source-standard.md)  | Meet the open-source standard — community health files, CI, English everywhere | Community health files, `.github/` templates, CI, and one language throughout                             | ✅ done | v0.3.0  |

Total: 19 points.

## Cross-cutting invariants

These hold across every story in the epic and outlive it:

- **One copy of a skill, ever.** A skill lives in exactly one repo. Duplication
  across repos is the failure mode Koniverse conventions name explicitly.
- **`skills/` is owned; `.claude/skills/` and `.agents/skills/` are consumed.**
  The first is the product, the second is tooling. Editing through a consumed
  symlink silently modifies a different repository.
- **Nothing ships as profitable.** Any template, example, or doc that could be read
  as an endorsed money-making bot must carry the explicit disclaimer.
- **The repo is public and MIT.** Anything merged is redistributable by anyone,
  forever. No third-party strategy logic, no credentials, no vendored external
  skill content.
- **Version identity is triple-stated.** An EA's `#property version`, its folder,
  and all three basenames agree on `X.YY`, or the archive has drifted.

## Cross-story testing requirements

There is no test *code* in this repo — it ships markdown and MQL5 source that this
repo cannot compile. Verification is therefore documentary and structural:

- Every internal markdown link resolves (checked per story)
- `koni-docs validate` passes
- No credential or absolute-local-path leaks in tracked files
- The template's self-consistency: version identity, handle create/release parity,
  no `CopyBuffer` reading bar `[0]`

Compile verification is deferred to a Windows host and is **not** claimed by any
story in this epic. See [LESSONS §2](../../LESSONS.md).

## Acceptance criteria

1. `koni-ea-dev` and `koni-ea-ops` exist in `skills/` and nowhere else in the
   Koniverse tree; all consumers point here.
2. `templates/mql5/STARTER_EA/` ships four artifacts in the koni-ea-ops version
   layout, implementing the full koni-ea-dev chassis with one marked placeholder.
3. `AGENTS.md` opens with an ordered build-a-bot workflow and a rules table pairing
   each rule with its failure mode.
4. `LICENSE` (MIT), `CONTRIBUTING.md`, and a risk disclaimer are present.
5. Tracked files contain no vendored third-party skill content and no secrets.
6. `koni-docs validate` passes and every internal link resolves.
