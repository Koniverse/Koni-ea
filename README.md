# koni-ea

**Build a trading bot for [Senti](#where-your-bot-runs) — starting from a template
that already gets the hard parts right.**

> **Your bot runs on Senti, not on your MetaTrader.** MT5 on your machine is where you
> write, compile and test it. Senti is where it runs: on Senti's terminals, against
> your linked broker account, 24/5, whether your computer is on or not.
> **[Read this first →](docs/RUNNING-ON-SENTI.md)**

[![verify](https://github.com/Koniverse/Koni-ea/actions/workflows/verify.yml/badge.svg)](https://github.com/Koniverse/Koni-ea/actions/workflows/verify.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![MetaTrader 5](https://img.shields.io/badge/platform-MetaTrader%205-0a0a0a.svg)](https://www.metatrader5.com/)

Two things ship from this repo:

- **[`templates/`](templates/)** — a complete, correct MQL5 Expert Advisor
  skeleton. Copy it, replace one function, compile, deploy.
- **[`skills/`](skills/)** — agent skills that teach an AI assistant the MQL5
  standard, so it writes correct EA code with you instead of plausible-looking code.

---

## Quick start

```bash
git clone https://github.com/Koniverse/Koni-ea.git
cp -r koni-ea/templates/mql5/STARTER_EA  my-bot
```

Then follow [the 6-step loop](templates/mql5/STARTER_EA/README.md) — rename,
replace `Signal()`, tune inputs, compile, backtest on demo, **upload to Senti**.

The last step is the point. Steps 1-5 happen in MetaTrader on your machine; the bot
goes live when Senti deploys it, not when you attach it to your own chart.

Working with an AI assistant? Point it at
[`AGENTS.md`](AGENTS.md) and it will pick up the workflow and the rules.

---

## Where your bot runs

**On Senti.** Not on your machine.

```
YOUR MACHINE — the workshop          SENTI — where it runs
  MetaEditor: write, F7 → .ex5         MT5 terminals, 24/5, in-region
  Strategy Tester: backtest            logged into YOUR linked account
  demo account: forward-test           live dashboard in your browser
        │
        └── .ex5 + .set ──── upload ────▶ deploy ────▶ running
```

You build it, then hand over two files:

| File | What it is | How you get it |
|---|---|---|
| `MY_BOT_v1.00.ex5` | The compiled Expert Advisor | MetaEditor → F7 on your `.mq5` |
| `MY_BOT_v1.00.set` | Its parameter preset | MT5 Inputs tab → Save |

Senti stores the binary, verifies its checksum, attaches it to one of its terminals
against the account you linked, and restarts it if the terminal ever goes down. Your
bot lands in your **private catalog** — only you see it.

> [!WARNING]
> **Never run the same bot on your own MT5 and on Senti against the same account.**
> Two instances, one account, same signal — you get double the position size you
> configured, and each one manages trades the other opened. Keep your local MT5 on a
> **demo** account.

Why it works this way — uptime, latency, and visibility your desktop cannot provide —
is in **[docs/RUNNING-ON-SENTI.md](docs/RUNNING-ON-SENTI.md)**.

---

## Why start from the template

An Expert Advisor is mostly not the strategy. It is the chassis around it: order
placement, position sizing, stop distances, restart recovery, risk cut-outs. Get
any of those wrong and the failure is silent — the code runs, the backtest is
green, and the loss shows up on a live account.

The template implements that chassis correctly, so the only thing left for you is
the part that is actually yours:

```mq5
int Signal(...)
{
   //=================== REPLACE FROM HERE ==========================
   // your entry logic — return +1 long, -1 short, 0 stand aside
   //==================== REPLACE TO HERE ===========================
}
```

Already handled for you: signals on closed bars so nothing repaints · position
sizing that respects the risk budget · SL/TP clamped to the broker's minimum stop
distance · a latched equity circuit breaker · a daily loss limit · a margin
pre-check · state that survives a restart · positions filtered by symbol and magic.

Each of those is a specific production bug documented in
[`mql5-pitfalls.md`](skills/koni-ea-dev/references/mql5-pitfalls.md).

---

## Available skills

Install into your own project so your AI assistant applies the standard as it works:

```bash
npx skills add Koniverse/Koni-ea --list                  # browse
npx skills add Koniverse/Koni-ea --skill koni-ea-dev     # install one
npx skills add Koniverse/Koni-ea --skill '*' --agent '*' # install all, all agents
```

| Skill | What it does |
|---|---|
| [`koni-ea-dev`](skills/koni-ea-dev/) | Programming a correct MQL5 EA — lifecycle and event model, order placement and signal timing, position sizing and SL/TP, risk and money management, and the production pitfalls that only bite live |
| [`koni-ea-ops`](skills/koni-ea-ops/) | The lifecycle of a released EA — `v<X.YY>` versioning and bump rules, MagicNumber registry, deployment to an MT5 terminal, release backtest requirements, per-version documentation |

---

## Documentation

| Doc | For |
|---|---|
| [docs/RUNNING-ON-SENTI.md](docs/RUNNING-ON-SENTI.md) | **Where your bot runs, and why it is not your machine** |
| [templates/mql5/STARTER_EA/README.md](templates/mql5/STARTER_EA/README.md) | Building your first bot, step by step |
| [docs/SETUP.md](docs/SETUP.md) | Full setup, including the MetaTrader side |
| [AGENTS.md](AGENTS.md) | AI assistants — the workflow and the rules |
| [REPO_STRUCTURE.md](REPO_STRUCTURE.md) | Where things live and how to add one |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Sending a template or skill back upstream |
| [SUPPORT.md](SUPPORT.md) | Getting help, and what this project does not cover |
| [SECURITY.md](SECURITY.md) | Reporting a vulnerability, and the threat model |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Community standards |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Release history |

Everything in this repository is written in English — code, comments, docs, and
commit messages. CI enforces it.

---

## Requirements

- **MetaTrader 5** with MetaEditor — your **build environment**, not your runtime.
  MetaEditor is the only MQL5 compiler and it is **Windows-only**; on macOS or Linux
  use a Windows VM or Wine/CrossOver.
- A **demo account** for your local MT5. Keep it that way — your real account belongs
  to Senti, and running both against one account is the
  [mistake that costs money](docs/RUNNING-ON-SENTI.md#the-mistake-that-costs-money).
- A **Senti account** with a linked broker account — that is where the bot actually runs.
- No build tooling for this repo itself; it is markdown and MQL5 source.

---

## Risk

Automated trading can lose money faster than manual trading, and on a leveraged
account it can lose more than you deposited.

**The templates here are not profitable strategies.** Their shipped strategy stubs
are deliberately naive and documented as such — they exist to show you where your
logic plugs in. Nothing in this repository is financial advice. Test on a demo
account first. You own what your bot does.

---

## License

[MIT](LICENSE) — use it, modify it, ship commercial bots with it. No warranty.
