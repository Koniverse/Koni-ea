# AGENTS.md — koni-ea

> **This file is the single source of truth for all AI agent instructions in this
> project.** Cursor, Gemini, Codex CLI, Copilot CLI, and Claude Code all read it.
> [`CLAUDE.md`](CLAUDE.md) is a thin pointer back here plus a Koni-Docs config
> block; on any conflict, AGENTS.md wins.

## What this repo is

`koni-ea` gives partners, customers, and users of **Senti** everything needed to
build a trading bot and deploy it — an agent skill set that encodes the MQL5
standard, and a working template to copy.

Senti is a trading-bot platform that executes on **real MetaTrader 5 accounts at
licensed brokers**. A bot reaches it as a compiled `.ex5` plus its `.set` preset,
uploaded to the user's private catalog.

This is a **content/distribution repo**. It has no build step and no app of its
own. The code under `templates/` is a delivered artifact, not something this repo
compiles or runs.

---

## If you were asked to build a bot, start here

This is the most common task in this repo. Follow it in order.

### Step 0 — load the standard

Read [`skills/koni-ea-dev/SKILL.md`](skills/koni-ea-dev/SKILL.md) before writing
any MQL5. It is written to be read by an agent, and it names the non-negotiables.
Load its `references/*.md` on demand as each step needs them — do not read all
seven up front.

### Step 1 — copy the template, do not start from a blank file

```bash
cp -r templates/mql5/STARTER_EA <destination>/MY_STRATEGY
```

[`templates/mql5/STARTER_EA/`](templates/mql5/STARTER_EA/) already implements every
lifecycle, risk and safety mechanic correctly. Starting blank means re-deriving all
of it, and the failure mode is silent: the code runs, the backtest is green, and
the bug only appears on a live account.

### Step 2 — rename to the version layout

`<ALGO>` is `UPPER_SNAKE_CASE`. The folder, all three basenames, and
`#property version` inside the `.mq5` must state the same `X.YY`:

```
MY_STRATEGY/v1/v1.00/
    MY_STRATEGY_v1.00.mq5
    MY_STRATEGY_v1.00.set
    MY_STRATEGY_v1.00.md
    backtest/
```

### Step 3 — replace `Signal()`, and only `Signal()`

Everything else in the template is infrastructure. The signal contract:

- Read **closed** bars only — `[1]` and `[2]`. Never `[0]`; the forming bar
  repaints and no backtest will show you the damage.
- Return `+1` long, `-1` short, `0` stand aside.
- Place no orders and mutate no globals — keep it a pure decision.

Adding an indicator means: create the handle in `OnInit`, check it against
`INVALID_HANDLE`, release it in `OnDeinit`, read it via `BufferValue()`.

### Step 4 — update the artifacts together

The `.set` defaults, the input table in the `.md`, and the `input` declarations in
the `.mq5` are three views of one thing. Change one, change all three.

### Step 5 — verify before claiming done

- Compile in MetaEditor: **zero errors and zero warnings**
- Walk [`references/mql5-pitfalls.md`](skills/koni-ea-dev/references/mql5-pitfalls.md)
  as a checklist
- Backtest "Every Tick Based on Real Ticks", ≥ 3 months, report into `backtest/`

**You cannot compile MQL5 on macOS or Linux.** MetaEditor is Windows-only. If you
are running on a non-Windows host, say so plainly rather than claiming the code
compiles — an unverified compile reported as verified is worse than an honest gap.

---

## Rules that are never negotiable

These come from production failures, not taste. Each is a bug that a green
backtest hides. Full reasoning:
[`mql5-pitfalls.md`](skills/koni-ea-dev/references/mql5-pitfalls.md).

| Rule | What goes wrong without it |
|---|---|
| Signals on closed bars `[1]`/`[2]`, never `[0]` | Repainting indicator looks perfect in backtest, evaporates live |
| `CTrade`, never raw `OrderSend` | Hand-filled request/result fields fail silently |
| Check `ResultRetcode()`, not just the bool | The bool means *accepted*, not *filled* — you track a phantom position |
| Release every indicator handle in `OnDeinit` | Handles survive recompiles and leak |
| `ArraySetAsSeries(buf, true)` before `CopyBuffer` | Not the default — `[0]` is the *oldest* bar, inverting every signal |
| Check `CopyBuffer` return, commit the bar only after | A transient short read silently burns the bar forever |
| `NormalizeDouble(price, _Digits)`; lots snapped and rounded **down** | Unnormalized price is rejected; rounding up overshoots the risk budget |
| Clamp SL/TP to `SYMBOL_TRADE_STOPS_LEVEL` | Server rejects a too-close stop |
| Margin **pre**-check, never post-check | A pending order's `DONE` retcode says nothing about whether the fill is affordable |
| One `MagicNumber` per instance, `> 0`, never reused | MT5 does not enforce it — two EAs silently manage each other's positions |
| Rebuild state after restart | A recompile wipes memory while positions stay open |
| English for code, identifiers, comments, commits | Mixed-language code in a public repo |

One documentation exception to the English rule: the per-version EA `.md` is
written in **Vietnamese**, per the koni-ea-ops standard. Code stays English.

---

## Repo map

```
skills/                  ← OWNED: the skills this repo publishes
├── koni-ea-dev/         ← the MQL5 programming standard
└── koni-ea-ops/         ← versioning, registry, deployment, release backtest
templates/               ← OWNED: the starter kits partners copy
└── mql5/STARTER_EA/     ← the reference skeleton
docs/                    ← koni-docs surface (see docs/README.md)
.claude/skills/          ← CONSUMED: toolchain symlinks — gitignored, never hand-edit
.agents/skills/          ← CONSUMED: same, for Codex / Cursor / Gemini / Copilot
```

The distinction between **owned** and **consumed** matters and is easy to get
wrong here: `skills/` is the product this repo ships; `.claude/skills/` and
`.agents/skills/` are tools this repo uses, populated by symlinks and installers.
Edit the first, never the second.

The consumed dirs are **gitignored** — a fresh clone has none of them, and that is
correct. Using the templates needs no toolchain at all. If you are contributing and
they are missing, restore them with [docs/SETUP.md §6](docs/SETUP.md#6-setting-up-to-contribute).

Full conventions: [REPO_STRUCTURE.md](REPO_STRUCTURE.md).

---

## Skill catalog

### Owned — `skills/`

Authored and versioned here; this repo is their single source of truth. Relocated
from `Koni-Skills` on 2026-08-02 ([CONTEXT.md](docs/CONTEXT.md) D1).

| Skill | Invoke it when |
|---|---|
| `koni-ea-dev` | Writing or reviewing MQL5 EA / indicator code — lifecycle, trading and risk mechanics, production pitfalls, compiling clean |
| `koni-ea-ops` | Versioning, MagicNumber assignment, deployment to MT5, release backtest, per-version docs |

### Consumed — `.claude/skills/` + `.agents/skills/`

Symlinked from a shared [`Koni-Skills`](https://github.com/Koniverse/Koni-Skills)
checkout, plus the BMAD pack (46 `bmad-*` skills) from `npx bmad-method install`.
`gstack` is installed globally at `~/.claude/skills/gstack`, never per-repo.

| Skill | Invoke it when |
|---|---|
| `koni-docs` | Updating docs, opening a story, writing a changelog entry, recording a decision |
| `koni-harness` | Working the commit gate or the agentic loop |
| `koni-qc` | Writing test cases, coverage matrices, or a security review |
| `koni-setup` | Auditing this repo against the Koniverse standard |

---

## How consumers install

```bash
npx skills add Koniverse/koni-ea --list                     # browse
npx skills add Koniverse/koni-ea --skill koni-ea-dev        # one skill
npx skills add Koniverse/koni-ea --skill '*' --agent '*'    # everything
npx skills experimental_install                             # restore from lockfile
```

Templates are copied, not installed — clone and take the directory you need.

---

## Documentation

- [BRIEF.md](docs/BRIEF.md) — what this repo is for and who it serves
- [SETUP.md](docs/SETUP.md) — clone → build a bot → deploy
- [CONTEXT.md](docs/CONTEXT.md) — append-only decision log
- [LESSONS.md](docs/LESSONS.md) — accumulated lessons
- [CHANGELOG.md](docs/CHANGELOG.md) — release history
- [sprints/](docs/sprints/) — epics, stories, auto-generated [STATUS.md](docs/sprints/STATUS.md)
- [tests/](docs/tests/) — QA surface (koni-qc `test-organization` standard)
- [VERSION](VERSION) — bare semver, no `v` prefix

`docs/PRD.md` and `docs/ARCHITECTURE.md` are intentionally absent — this is a
content-profile repo and [REPO_STRUCTURE.md](REPO_STRUCTURE.md) carries the
organizational conventions instead.

---

## Working in this repo

**Commit discipline.** The koni-harness gate runs as a pre-commit / pre-push hook
from `.koni-harness/` — version phase, changelog anchor, doc references, secret
scanning. Do not bypass with `--no-verify` without recording why in CONTEXT.md.
Every shipping change bumps `VERSION` and adds a `[Unreleased]` CHANGELOG entry in
the same commit.

**This repo is public and MIT-licensed.** Anything committed here is
redistributable by anyone, forever. Never add: proprietary or third-party strategy
logic, credentials or account numbers (including in a `.set` or a commented-out
line), compiled binaries, or performance claims presented as expected returns.

**Never present a template as profitable.** The shipped strategy stubs are
deliberately naive and documented as such. If asked to make one "actually work,"
build the strategy the user describes — do not quietly upgrade a stub and leave it
labelled a template.
