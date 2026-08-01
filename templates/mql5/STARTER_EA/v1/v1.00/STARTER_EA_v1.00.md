# STARTER_EA v1.00 — Algorithm Document

**File**: `STARTER_EA_v1.00.mq5`
**Version**: v1.00
**Language**: MQL5
**Updated**: 2026-08-02

> [!WARNING]
> **This is a structural template, not a strategy.** The entry signal is a naive EMA
> cross with **no statistical edge**. It exists only to show where your logic plugs
> in. Do not run this version on a live account.

---

## 1. Strategy overview

STARTER_EA is a **reference chassis** for an MQL5 Expert Advisor on MetaTrader 5. It
implements every piece of *infrastructure* a Koniverse EA must have, correctly: the
event lifecycle, indicator-handle management, a closed-bar signal gate, risk-percent
sizing, SL/TP that respects the broker stop level, the safety cut-outs (equity
breaker, daily loss limit, cooldown), operational filters, and state recovery after
a restart.

The **only** function you rewrite is `Signal()`. Everything else is infrastructure
and should stay as it is.

**Strategy type**: trend-following (placeholder — replace with your own).
**Money management**: fixed risk percent of equity per trade, one position at a
time, no DCA, no martingale.

---

## 2. Version improvements

None — `v1.00` is the first version.

---

## 3. Input parameters

### General

| Input | Default | Type | Description |
|---|---|---|---|
| `InpMagicNumber` | `990001` | `long` | Instance identifier. **Must be > 0 and unique per running instance.** MT5 does not enforce uniqueness — two EAs sharing a magic will manage each other's positions. |
| `InpTradeComment` | `STARTER_EA` | `string` | Comment prefix attached to orders, for tracing in the Journal. |

### Signal (replace this section)

| Input | Default | Type | Description |
|---|---|---|---|
| `InpFastPeriod` | `12` | `int` | Fast EMA period for the placeholder signal. |
| `InpSlowPeriod` | `26` | `int` | Slow EMA period for the placeholder signal. Must exceed `InpFastPeriod`. |

### Position sizing

| Input | Default | Type | Description |
|---|---|---|---|
| `InpUseRiskPercent` | `true` | `bool` | `true` sizes by percent of equity; `false` uses a fixed lot. |
| `InpRiskPercent` | `1.0` | `double` | `[InpUseRiskPercent=true]` Risk per trade, as a percent of equity. |
| `InpFixedLot` | `0.01` | `double` | `[InpUseRiskPercent=false]` Fixed volume per trade. |

### Stop loss / take profit

| Input | Default | Type | Description |
|---|---|---|---|
| `InpAtrPeriod` | `14` | `int` | ATR period used to compute the SL distance. |
| `InpAtrSLMult` | `2.0` | `double` | SL distance = `ATR * this multiplier`. |
| `InpRR` | `1.5` | `double` | TP distance = `SL distance * this` (reward-to-risk ratio). |

### Risk management

| Input | Default | Type | Description |
|---|---|---|---|
| `InpMaxPositions` | `1` | `int` | Maximum concurrent positions for this magic. |
| `InpEquityBreakerPct` | `20.0` | `double` | Halt when drawdown from the equity peak reaches this percent. **Latched** — it does not clear itself. |
| `InpResetBreaker` | `false` | `bool` | Set `true` **once** to clear a latched halt, then set it back to `false`. |
| `InpDailyLossLimitPct` | `5.0` | `double` | Stop opening new positions once the day's loss reaches this percent. `0` disables. |
| `InpCooldownBars` | `3` | `int` | Bars to wait after a stop-out. `0` disables. |

### Operational filters

| Input | Default | Type | Description |
|---|---|---|---|
| `InpMaxSpreadPoints` | `30` | `int` | Skip entry when the spread exceeds this. `0` disables. |
| `InpMaxGapPoints` | `200` | `int` | Skip entry when the bar opens with a gap larger than this. `0` disables. |
| `InpUseSessionFilter` | `false` | `bool` | Restrict trading to an hour window. |
| `InpSessionStartHourUtc` | `7` | `int` | `[InpUseSessionFilter=true]` Session start hour, **UTC**. |
| `InpSessionEndHourUtc` | `20` | `int` | `[InpUseSessionFilter=true]` Session end hour, **UTC**. A value below the start hour wraps the window past midnight. |

### Execution

| Input | Default | Type | Description |
|---|---|---|---|
| `InpSlippagePoints` | `10` | `int` | Maximum price deviation accepted, in points. |

> This table and the `.set` file must always agree. Change one, change the other.

---

## 4. Algorithm detail

### Trigger: per bar, not per tick

Risk management runs on **every tick**. The entry decision runs **once per closed
bar**. Signals read bars `[1]` and `[2]` — **never `[0]`**, because the forming bar
repaints and a backtest will not show you the damage.

### OnTick flow

```
OnTick
 ├─ UpdateEquityPeakAndBreaker()        ← every tick
 ├─ bar = iTime(...,0)
 ├─ if bar == g_lastBarTime → return    ← not a new bar yet
 ├─ read fast[1] fast[2] slow[1] slow[2] atr[1]
 │    └─ short read → return (bar NOT committed, retry next tick)
 ├─ g_lastBarTime = bar                 ← commit only after every read succeeded
 ├─ RollDailyAnchorIfNeeded()
 ├─ gates: halt → position count → cooldown → daily loss → operational filters
 ├─ signal = Signal(...)                ← >>> THE PART YOU REPLACE <<<
 └─ signal != 0 → OpenTrade(signal, atr)
```

One detail deserves attention: `g_lastBarTime` is committed only **after** every
`CopyBuffer` succeeds. Committing first would let a transient short read burn the
bar, and the signal would be skipped on that bar forever.

### SL/TP formulas

```
minStop = SYMBOL_TRADE_STOPS_LEVEL * _Point
slDist  = max(ATR[1] * InpAtrSLMult, minStop + 3 * _Point)
tpDist  = slDist * InpRR

BUY  (fills at ASK):  SL = ask - slDist   TP = ask + tpDist
SELL (fills at BID):  SL = bid + slDist   TP = bid - tpDist
```

The stop loss is **written into the order** when it is sent, so it survives whether
or not the EA is running. Each side bases its stops on the price it actually fills
at; mixing ask and bid shifts every stop by half the spread.

### Sizing formula

```
risk = equity * InpRiskPercent / 100
lot  = risk / (slDist / tickSize * tickValue)

if lot < SYMBOL_VOLUME_MIN → SKIP the trade (return 0.0)
otherwise → round DOWN to SYMBOL_VOLUME_STEP, clamp to [MIN, MAX]
```

The sub-minimum skip happens **before** normalization. Clamping up to `VOLUME_MIN`
would still open the trade, but the real risk would exceed what the user
configured — and nobody would know.

---

## 5. Technical description

**Global state**

| Variable | Role | Survives restart |
|---|---|---|
| `g_lastBarTime` | New-bar gate | No (rebuilds on the next bar) |
| `g_equityPeak` | Equity peak, ratchets up only | Yes — GlobalVariable |
| `g_halt` | Equity breaker latch | Yes — GlobalVariable |
| `g_dayStartEquity` | Daily loss anchor | Yes — GlobalVariable |
| `g_dayAnchorDate` | The day that anchor belongs to | Yes — GlobalVariable |
| `g_cooldownUntil` | Cooldown expiry | No (lost on restart, acceptable) |

GlobalVariable keys are prefixed `STARTER_<magic>_<symbol>_<period>`, so multiple
instances on one terminal do not overwrite each other.

**Indicator handles**: `g_fastHandle`, `g_slowHandle`, `g_atrHandle` — created in
`OnInit`, each checked against `INVALID_HANDLE`, released in `OnDeinit` under a
guard and reset to `INVALID_HANDLE`. An unreleased handle survives a recompile and
leaks.

---

## 6. Recommended configuration

| Item | Value |
|---|---|
| Symbol | A low-spread pair (EURUSD, XAUUSD) |
| Timeframe | M15 |
| Account type | Hedging or netting both work |
| Timezone | The session filter uses **UTC**, not server time |

This configuration exists to exercise the chassis. It is not a profitable setup.

---

## 7. Risk and backtest notes

> [!WARNING]
> The placeholder signal is an EMA cross, one of the signals most punished by
> whipsaw in a ranging market. Backtest results for `v1.00` **say nothing** about
> your strategy.

**Required backtest mode for a release**: "Every Tick Based on Real Ticks", at least
3 months, on the timeframe the EA will actually run. "Open Prices Only" overstates
win rate by 10–15% because intra-bar SL/TP ordering is faked — use it to iterate
quickly, never to decide.

Version `v1.00` has **no release backtest**. The `backtest/` directory is empty on
purpose: it gets filled when you cut the first version of *your* strategy.
