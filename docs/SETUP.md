# SETUP — koni-ea

From nothing to a bot running on a Senti demo account.

There are two audiences here. **Building a bot** (§1–§5) needs no tooling beyond
MetaTrader. **Contributing back** (§6) sets up the repo's own doc and commit
machinery.

---

## 1. Prerequisites

| Requirement | Why | Notes |
|---|---|---|
| **MetaTrader 5** + MetaEditor | **Build environment** — compile `.mq5` → `.ex5`, backtest, demo-test. Not where your bot runs. | **MetaEditor is Windows-only.** On macOS/Linux use a Windows VM (Parallels, UTM, VirtualBox) or MT5 under Wine / CrossOver. |
| A **demo** MT5 account | Local testing. **Keep it demo** — never point local MT5 at the account Senti trades. | Any broker. Matching your Senti-linked broker is ideal, so spread and execution behave the same. |
| `git` | Clone this repo | — |
| A **Senti account** with a linked broker account | **Runtime** — this is where the finished bot actually runs | Needed at §5. Senti runs the bot on its own terminals against your linked account. |

You do **not** need Node, Python, or any build tooling to use the templates. This
repo is markdown and MQL5 source.

You also do **not** need to keep a machine running. Once Senti deploys your bot, your
computer plays no part in it — see [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md).

---

## 2. Get the template

```bash
git clone https://github.com/Koniverse/Koni-ea.git
cd koni-ea
cp -r templates/mql5/STARTER_EA  ~/my-bot
```

Rename to your algorithm — `<ALGO>` in `UPPER_SNAKE_CASE`, and every basename
carries the full version:

```bash
cd ~/my-bot && mv STARTER_EA MY_STRATEGY 2>/dev/null; cd MY_STRATEGY/v1/v1.00
for f in STARTER_EA_v1.00.*; do mv "$f" "MY_STRATEGY_v1.00.${f##*.}"; done
```

Then open `MY_STRATEGY_v1.00.mq5` and update the header — `#property version`
must match the folder and basenames, and `#property copyright` should be you.

---

## 3. Write your strategy

Replace **`Signal()`** and nothing else. Everything around it is infrastructure
that is already correct.

```mq5
int Signal(const double fast1, const double fast2,
           const double slow1, const double slow2)
{
   //=================== REPLACE FROM HERE ==========================
   // return +1 to go long, -1 to go short, 0 to stand aside
   //==================== REPLACE TO HERE ===========================
}
```

Read **closed** bars only — `[1]` and `[2]`, never `[0]`. The full contract and the
6-step loop are in
[templates/mql5/STARTER_EA/README.md](../templates/mql5/STARTER_EA/README.md).

Adding an indicator: create the handle in `OnInit`, check it against
`INVALID_HANDLE`, release it in `OnDeinit`, read it through `BufferValue()`.

### Working with an AI assistant

Install the skills into your bot project so your assistant applies the standard as
it writes:

```bash
cd ~/my-bot
npx skills add Koniverse/Koni-ea --skill koni-ea-dev --skill koni-ea-ops
```

Then ask it to build the strategy. It will pull in the MQL5 standard and the
pitfall checklist on its own.

---

## 4. Build and test — on your machine

> **This section is development, not deployment.** Everything here happens in your
> local MetaTrader, which is a workshop: an editor, a compiler, and a test harness.
> Your bot is not live at the end of this section. It goes live in §5, when Senti
> deploys it. See [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md).

### Load into MetaEditor

Copy your `.mq5` into the terminal's data folder so the compiler can resolve
`<Trade\Trade.mqh>`:

```
MT5 → File → Open Data Folder → MQL5\Experts\
```

### Compile

Open the file in MetaEditor and press **F7**. Require **zero errors and zero
warnings** — an MQL5 warning is usually a real type or scope bug, not style noise.

### Load the preset and test it

Attach the EA to a chart → **Inputs** tab → **Load** → your `.set` file.

> [!WARNING]
> **Use a demo account here. Always.**
>
> This local run is a test, and it must never share a broker account with a bot
> deployed on Senti. Two instances on one account see the same signal and both act:
> you get double the position size you configured, and each one manages trades the
> other opened. Nothing warns you — you find out from the balance. Your real account
> is linked to Senti and to nothing else.

> Change `InpMagicNumber` before running. It must be unique per running instance.
> MT5 does not enforce this, and two instances sharing a magic will silently manage
> each other's positions.

### Backtest honestly

Strategy Tester → **"Every Tick Based on Real Ticks"**, minimum 3 months, on the
timeframe you will actually run. Save the HTML report into `backtest/`.

"Open Prices Only" overstates win rate by 10–15% because intra-bar SL/TP ordering
is faked. Use it to iterate fast; never to decide.

### Forward-test on demo

Run on a **demo account for at least one full trading week** before real money. A
backtest cannot show you slippage, requotes, weekend gaps, or how your EA behaves
across a terminal restart.

---

## 5. Deploy to Senti — where it actually runs

**This is the step that makes your bot live.** Not attaching it to a chart in §4.

Senti takes two files:

| File | Where it comes from |
|---|---|
| `MY_STRATEGY_v1.00.ex5` | MetaEditor F7 output, in `MQL5\Experts\` |
| `MY_STRATEGY_v1.00.set` | MT5 Inputs tab → Save |

Upload both. Senti stores the binary and verifies its checksum, then attaches it to
one of **its** MT5 terminals — running 24/5 in a datacenter near the broker — logged
into the account you linked. It restarts the bot if the terminal ever goes down, and
streams ticks, positions and equity to your browser in real time.

Your bot lands in your **private catalog**: only you see it.

**Close MetaTrader on your machine when you are done building.** It has no role in
running the bot, and leaving a live-account instance attached is the
[mistake that costs money](RUNNING-ON-SENTI.md#the-mistake-that-costs-money).

Stop the bot from the Senti dashboard, not by closing anything locally.

Walk the pre-flight checklist in
[templates/mql5/STARTER_EA/README.md](../templates/mql5/STARTER_EA/README.md#before-you-go-live--the-checklist)
first. Every line on it is a production bug the template already avoids; the point
is confirming your edits did not reintroduce one.

---

## 6. Setting up to contribute

Only needed if you are changing this repo, not if you are using it.

```bash
git clone https://github.com/Koniverse/Koni-ea.git
cd koni-ea
cp .active-context.example.md .active-context.md   # gitignored; fill in your details
```

**Skill wiring.** `.claude/skills/` and `.agents/skills/` are **gitignored** — they
hold this repo's dev toolchain, not its product, so a fresh clone has none of it.
Nothing about using the templates needs them; restore them only if you are
contributing.

```bash
# 1. the owned EA skills — they live in skills/, no external checkout needed
mkdir -p .agents/skills .claude/skills
for s in koni-ea-dev koni-ea-ops; do
  ln -sfn "../../skills/$s"          ".agents/skills/$s"
  ln -sfn "../../.agents/skills/$s"  ".claude/skills/$s"
done

# 2. the shared Koniverse toolchain — needs a sibling Koni-Skills checkout
git clone https://github.com/Koniverse/Koni-Skills.git ../Koni-Skills
KONI_SKILLS="$(cd ../Koni-Skills && pwd)"
for s in koni-docs koni-harness koni-qc koni-setup; do
  ln -sfn "$KONI_SKILLS/skills/$s"   ".agents/skills/$s"
  ln -sfn "../../.agents/skills/$s"  ".claude/skills/$s"
done

# 3. the BMAD planning pack (~46 skills)
npx bmad-method install --yes --modules bmm --tools claude-code,codex,cursor,gemini
```

Verify nothing dangles:

```bash
for s in .claude/skills/* .agents/skills/*; do
  [ -L "$s" ] && { [ -e "$s" ] || echo "DANGLING: $s"; }
done
```

**The commit gate.** `.koni-harness/` installs pre-commit and pre-push hooks
checking version phase, changelog anchor, doc references, and secret leaks. It runs
automatically. If it is missing:

```bash
sh .claude/skills/koni-harness/scripts/install-gate.sh
```

**The doc CLI** (content repo — no npm scripts, call it directly):

```bash
npx @koniverse/koni-docs status   --docs-path docs/    # regenerate STATUS.md
npx @koniverse/koni-docs validate --docs-path docs/    # check all doc references
```

Conventions and the correctness bar: [CONTRIBUTING.md](../CONTRIBUTING.md).

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| MetaEditor "cannot open include file" | `<Trade\Trade.mqh>` not found | Compile from inside `MQL5\Experts\` in the terminal's data folder, not an arbitrary path |
| EA attaches but never trades | AutoTrading off, or a filter blocking | Check the AutoTrading button; read the Journal — every block logs a `[FILTER]` / `[MARGIN]` / `[SIZE]` line |
| `[SIZE] risk too small for one min-lot` | Risk % too small for the account | Raise `InpRiskPercent`, or use `InpUseRiskPercent=false` with a fixed lot |
| Entries stop after a drawdown | Equity breaker latched — working as designed | Set `InpResetBreaker=true` once, then back to `false` |
| Two EAs interfering | Shared MagicNumber | Give each instance its own `InpMagicNumber` |
| Nothing in the Journal at all | EA not actually running | Check the smiley face on the chart is not a sad face; re-check AutoTrading |
