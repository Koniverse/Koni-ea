# BRIEF — koni-ea

## The problem

Senti runs trading bots on its own MT5 terminals, against the broker account a user
links — 24/5, in a datacenter near the broker. Getting a bot onto it requires MQL5,
and MQL5 is where most people who want to automate a strategy stop.

The bot is *for Senti*; MetaTrader is only where it gets built. That distinction is
load-bearing and is documented at [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md) — a user
who thinks the goal is "an EA on my MetaTrader" builds the right code for the wrong
runtime, and can end up double-trading one account.

The barrier is not the strategy. It is everything around it. An Expert Advisor is
maybe 5% entry logic and 95% chassis: order placement, position sizing, stop
distances that respect the broker's minimum, restart recovery, risk cut-outs,
handle lifecycle. Every one of those has a wrong version that **compiles, runs, and
backtests green** — and then loses money live for a reason the author never sees.

A partial list, all of them real production failures:

- Reading the forming bar `[0]` instead of the last closed bar, so a repainting
  indicator looks perfect in backtest and evaporates live
- `ArraySetAsSeries` omitted, which inverts every signal because `[0]` is the
  *oldest* element by default
- Rounding a lot *up* to the volume step, quietly overshooting the risk budget
- Treating a pending order's `TRADE_RETCODE_DONE` as proof the fill was affordable
- Two instances sharing a MagicNumber, silently managing each other's positions

None of these announce themselves. They are the tax on writing an EA from scratch,
and it is paid in real money.

## What this repo does

It removes the chassis from the problem.

**A correct template.** [`templates/mql5/STARTER_EA/`](../templates/mql5/STARTER_EA/)
implements the whole chassis to a standard derived from a live EA corpus. What is
left for the builder is one function — the entry decision — marked
`>>> REPLACE THIS <<<`.

**A standard an agent can apply.** [`skills/koni-ea-dev/`](../skills/koni-ea-dev/)
and [`skills/koni-ea-ops/`](../skills/koni-ea-ops/) encode the same knowledge as
agent skills. Installed into a partner's project, an AI assistant writes EA code
that follows the standard instead of code that merely looks plausible — which
matters most here, because plausible-looking MQL5 is exactly the failure mode.

## Who it is for

| Audience | What they take |
|---|---|
| **Senti partners** building bots for their own users | Both — template as the base, skills so their AI tooling holds the line |
| **Senti users** automating a strategy they already trade manually | The template, plus the step-by-step loop |
| **Developers** who know MQL5 already | The skills, as a review standard and a pitfall checklist |

Senti's market is Vietnam-first, but this repository is **English throughout** —
code, identifiers, documentation, and commits. It ships to partners in any market, and
a standard nobody can read is not a standard ([CONTEXT D4](CONTEXT.md), enforced by
`scripts/verify.sh`).

## What it is not

- **Not a strategy source.** The shipped stub is a naive EMA cross, documented as
  having no edge. This repo makes bots *correct*, not *profitable* — those are
  different problems and conflating them is how people lose money.
- **Not a backtesting or optimization engine.** MT5's Strategy Tester does that.
- **Not the platform.** Senti owns upload, catalog, and deployment. This repo gets
  a partner to a compiled `.ex5` and a `.set`; the platform takes it from there.
- **Not a strategy marketplace.** Nothing here is listed, ranked, or sold.

## Success looks like

A partner who has never written MQL5 goes from `git clone` to a bot running on a
Senti demo account, having written only their entry logic — and the resulting EA
passes the correctness checklist without them having had to learn why each item is
on it.

The second measure is quieter and matters more: the failure classes listed at the
top of this brief stop appearing in partner bots.

## Constraints

- **MetaEditor is Windows-only.** Compiling requires Windows, a VM, or Wine. This
  is MetaQuotes' constraint, not something this repo can remove.
- **The repo is public and MIT-licensed.** No proprietary strategy logic, no
  credentials, no third-party EA source can be committed — anything merged is
  redistributable by anyone, forever.
- **Senti's upload path accepts `.ex5` + `.set`.** That is why MQL5 is the only
  platform with a template today.
