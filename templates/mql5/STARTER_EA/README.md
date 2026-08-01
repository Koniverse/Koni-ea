# STARTER_EA — MQL5 bot template

The reference skeleton for a MetaTrader 5 Expert Advisor you can deploy on
[Senti](https://github.com/Koniverse/koni-ea#what-senti-expects). Copy it, replace
one function, ship.

> **This is a structure, not a strategy.** Every lifecycle, risk and safety
> mechanic is implemented and correct. The entry signal is a deliberately naive
> EMA cross marked `>>> REPLACE THIS <<<`. It has no edge. Do not run v1.00 on a
> real account.

## What you get

```
STARTER_EA/
└── v1/v1.00/
    ├── STARTER_EA_v1.00.mq5   ← the EA source (replace Signal(), keep the rest)
    ├── STARTER_EA_v1.00.set   ← default preset, upload alongside the .ex5
    ├── STARTER_EA_v1.00.md    ← per-version doc (Vietnamese, per koni-ea-ops)
    └── backtest/              ← your exported MT5 HTML report goes here
```

That nesting is not decoration — it is the Koniverse release layout
(`<ALGO>/v<major>/v<X.YY>/`). Keep it and your archive stays honest about which
version is running where.

## The 6-step loop

### 1. Copy and rename

```bash
cp -r templates/mql5/STARTER_EA templates/mql5/MY_STRATEGY   # or into your own repo
cd templates/mql5/MY_STRATEGY/v1/v1.00
for f in STARTER_EA_v1.00.*; do mv "$f" "MY_STRATEGY_v1.00.${f##*.}"; done
```

`<ALGO>` is `UPPER_SNAKE_CASE`. Every basename repeats the full version — the
folder, the three files, and `#property version` inside the `.mq5` must all agree
on `X.YY`. A file claiming one version while sitting in another's directory is the
first sign an archive has drifted.

### 2. Update the header

```mq5
#property version     "1.00"
#property description "MY_STRATEGY — one line on what it does. M15."
#property copyright   "Your Name / Your Company"
```

Set `copyright` to yourself. Leaving the MetaEditor default is how six EAs in the
source corpus shipped anonymous.

### 3. Replace `Signal()` — and only `Signal()`

It is the one function you rewrite. The contract:

| Rule | Why |
|---|---|
| Read closed bars only — `[1]`, `[2]`, never `[0]` | The forming bar repaints. A backtest will not show you the damage; a live account will. |
| Return `+1` long, `-1` short, `0` stand aside | Keeps the decision pure and testable. |
| Place no orders, mutate no globals | Entry, sizing and risk are already handled downstream. |

Need more indicator data? Create the handle in `OnInit`, check it against
`INVALID_HANDLE`, release it in `OnDeinit`, and read it through `BufferValue()` so
a short read still cannot burn the bar.

### 4. Tune the inputs

Everything else is configuration, not code. Adjust `InpAtrSLMult`, `InpRR`,
`InpRiskPercent`, the filters. Two rules that are not negotiable:

- **`InpMagicNumber` must be unique per running instance.** MT5 does not enforce
  this. Two instances sharing a magic silently manage each other's positions —
  every `POSITION_MAGIC` filter matches both.
- **Keep the `.set` and the doc's input table in sync.** They are part of the
  released artifact.

### 5. Compile clean

Open in MetaEditor → F7. **Zero errors and zero warnings.** A warning in MQL5 is
usually a real type or scope bug, not style noise.

### 6. Backtest honestly

Strategy Tester → **"Every Tick Based on Real Ticks"**, minimum 3 months, on the
timeframe you will actually run. Export the HTML report into `backtest/`.

"Open Prices Only" overstates win rate by 10–15% because intra-bar SL/TP ordering
is faked. Use it to iterate fast, never to decide.

## Before you go live — the checklist

Walk this before the EA touches real money. Each line is a production bug the
template already avoids; the point is to confirm your edits did not reintroduce one.

- [ ] `#property version`, the folder name, and all three basenames state the same `X.YY`
- [ ] `#property copyright` is you, not MetaQuotes
- [ ] `InpMagicNumber > 0` and unused by any other running instance
- [ ] `Signal()` reads `[1]`/`[2]` only — grep the file for `, 0,` in `CopyBuffer` calls
- [ ] Every new indicator handle is checked in `OnInit` and released in `OnDeinit`
- [ ] Compiles with zero errors **and** zero warnings
- [ ] Backtested "Every Tick Based on Real Ticks", ≥ 3 months, report saved in `backtest/`
- [ ] Tested on a **demo** account for at least one full trading week
- [ ] The `.set` file matches the input table in the `.md`
- [ ] You have read the risk warning and accept that you own the outcome

## Deploying to Senti

Senti accepts a compiled `.ex5` plus its `.set`. Upload both; the bot lands in
your private catalog (only you see it) and deploys through the same path as
platform bots.

```
MetaEditor F7  →  MY_STRATEGY_v1.00.ex5
                  MY_STRATEGY_v1.00.set
                        ↓  upload both
                  Senti → your private bot catalog
                        ↓
                  deploy to a linked MT5 account
```

The `.ex5` is a build artifact and is gitignored on purpose — commit the `.mq5`
source and compile per release, so what you ship is always reproducible from what
you committed.

## Going deeper

The template encodes a standard; the standard explains itself:

| Question | Read |
|---|---|
| Why is the code shaped like this? | [`skills/koni-ea-dev/`](../../../skills/koni-ea-dev/) — the MQL5 programming standard |
| What breaks only in production? | [`koni-ea-dev/references/mql5-pitfalls.md`](../../../skills/koni-ea-dev/references/mql5-pitfalls.md) |
| How do I version and release this? | [`skills/koni-ea-ops/`](../../../skills/koni-ea-ops/) |
| What counts as a minor vs major bump? | [`koni-ea-ops/references/versioning.md`](../../../skills/koni-ea-ops/references/versioning.md) |

If you work with an AI assistant, point it at `skills/koni-ea-dev/SKILL.md` — it is
written to be read by an agent and will apply the standard to your code as it goes.
