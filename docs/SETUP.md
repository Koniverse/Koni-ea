# SETUP — koni-ea

From nothing to a bot running on a Senti demo account.

There are two audiences here. **Building a bot** (§1–§5) needs no tooling beyond
MetaTrader. **Contributing back** (§6) sets up the repo's own doc and commit
machinery.

---

## 1. Prerequisites

| Requirement | Why | Notes |
|---|---|---|
| A **Senti account** with a linked broker account | **Everything** — compiling and running both happen here | Author Studio compiles your source; Senti's terminals run the result. |
| A **browser** | That is the toolchain | No MetaEditor, no `.ex5`, no Windows machine. |
| `git` | Clone this repo for the template | Or copy the template out of the GitHub UI. |
| A local **MetaTrader 5** | **Optional.** Only for running the Strategy Tester yourself. | Windows-only, and **not required** to build, compile, or ship. If you run one, keep it on a **demo** account. |

You do **not** need Node, Python, or any build tooling. You do **not** need MetaEditor
— Senti compiles your source. And once Senti deploys the bot, your computer plays no
part in running it. See [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md).

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

## 4. Compile on Senti

> **You do not compile locally.** Senti's Author Studio does it. There is no
> MetaEditor step and no `.ex5` to produce.

1. Open **Author Studio** in Senti.
2. **`+ New`** in the DRAFTS panel — each draft is a named version you can keep and
   come back to.
3. **Paste your `.mq5`** into the editor.
4. Press **Compile**.

Senti runs a static safety scan, then a headless MetaEditor compile on its build host.
Errors and warnings come back as inline markers and a Problems panel, with an **Ask AI
to fix** action. A release needs **0 errors and 0 warnings** — the panel shows `0E 0W`.

### What the safety scan rejects

Blocked **before** the compile runs, and none of it is guessable:

| Blocked | Why |
|---|---|
| Any `#import` | Loading a DLL or external library is the sandbox escape |
| `WebRequest` | Rejected outright today (the domain allowlist ships empty), and always rejected when the URL is not a literal string |
| `FileDelete`, `FolderDelete`, `FolderClean`, `FileMove` | Destructive file operations on a shared host |
| `SendFTP` | Data exfiltration |

The template uses none of them. If your strategy needs a library or a network call,
design around the restriction — the scan reads the exact source you submit.

## 5. Save as EA and deploy — where it goes live

Press **Save as EA**. The publish checklist has to be green:

- Generation finished
- No build running
- Last compile passed
- **That build is of the code on screen**
- EA name set

That fourth item matters more than it looks. Editing the code after a successful
compile invalidates the build — compile again before saving, or you publish a binary
that is not the code you are reading.

Saving registers a **private** EA definition plus a preset built from your `input`
defaults. **You never write a `.set` file**; the defaults in your source become the
preset.

Then **Deploy** to your linked account. Senti attaches the bot to one of its
terminals, restarts it if the terminal goes down, and streams ticks, positions and
equity to your browser. Stop it from the dashboard.

> [!WARNING]
> If you also compiled locally to test, **keep that MT5 on a demo account**. The same
> bot on your machine and on Senti against one broker account doubles every position
> and leaves each instance managing trades the other opened, silently.
> [Details](RUNNING-ON-SENTI.md#the-mistake-that-costs-money)

### Optional: backtest it yourself first

Senti is bringing on-demand backtesting into the platform. Until that ships, running
the MT5 Strategy Tester yourself is the way to get a backtest — that is the one reason
to install MetaTrader locally, and it is optional.

If you do: "Every Tick Based on Real Ticks", at least 3 months, on the timeframe you
will deploy. "Open Prices Only" overstates win rate by 10-15% because intra-bar SL/TP
ordering is faked.

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
