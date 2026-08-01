# templates/ — bot starter kits

Copyable starting points for building a trading bot you can deploy on Senti.
Each template is a complete, correct structure with one deliberately trivial
strategy stub for you to replace.

## Available templates

| Template | Platform | Deploys to Senti | Start here |
|---|---|---|---|
| [`mql5/STARTER_EA/`](mql5/STARTER_EA/) | MetaTrader 5 (MQL5) | ✅ yes — upload `.ex5` + `.set` | [README](mql5/STARTER_EA/README.md) |

## Why only MQL5

Senti executes on **real MetaTrader 5 accounts at licensed brokers**. The upload
path it accepts today is a compiled `.ex5` plus its `.set` preset, so MQL5 is the
one language with a working route from your editor to a live Senti deployment.

Templates for other runtimes will land here when Senti opens a path for them. An
empty directory promising a template that does not exist is worse than no
directory, so there are none.

## What every template guarantees

Not a strategy — a **correct chassis**. Each one ships with:

- The full EA lifecycle: `OnInit` validation, handle creation and release, the
  new-bar gate, `OnDeinit` cleanup
- Signals evaluated on **closed bars only**, so nothing repaints
- Position sizing that respects the risk budget, including the sub-minimum-lot skip
- SL/TP clamped to the broker's `SYMBOL_TRADE_STOPS_LEVEL`
- A latched equity circuit breaker, a daily loss limit, and a post-stop-out cooldown
- A margin **pre**-check (a pending order's placement retcode tells you nothing
  about whether the fill is affordable)
- State that survives a restart, recompile, or parameter change
- Positions filtered by symbol **and** magic in every query

Each of those is a bug a green backtest hides. They are implemented so you can
spend your attention on the part that is actually yours: the entry decision.

## The rule for adding a template

See [REPO_STRUCTURE.md](../REPO_STRUCTURE.md#adding-a-template). Short version: a
template with no `README.md` is not a deliverable, no build output or credentials
get committed, and the version layout is `<ALGO>/v<major>/v<X.YY>/`.
