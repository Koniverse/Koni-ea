# koni-ea

**Build a MetaTrader 5 trading bot and deploy it on Senti — starting from a
template that already gets the hard parts right.**

[![verify](https://github.com/Koniverse/koni-ea/actions/workflows/verify.yml/badge.svg)](https://github.com/Koniverse/koni-ea/actions/workflows/verify.yml)
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
git clone https://github.com/Koniverse/koni-ea.git
cp -r koni-ea/templates/mql5/STARTER_EA  my-bot
```

Then follow [the 6-step loop](templates/mql5/STARTER_EA/README.md) — rename,
replace `Signal()`, tune inputs, compile, backtest, upload.

Working with an AI assistant? Point it at
[`AGENTS.md`](AGENTS.md) and it will pick up the workflow and the rules.

---

## What Senti expects

Senti runs bots on **real MetaTrader 5 accounts at licensed brokers** — real
money, real broker, full transparency. To get a bot onto it you upload two files:

| File | What it is | How you get it |
|---|---|---|
| `MY_BOT_v1.00.ex5` | The compiled Expert Advisor | MetaEditor → F7 on your `.mq5` |
| `MY_BOT_v1.00.set` | Its parameter preset | MT5 Inputs tab → Save |

The bot lands in your **private catalog** — only you can see it — and deploys to a
linked MT5 account through the same path as platform bots.

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
npx skills add Koniverse/koni-ea --list                  # browse
npx skills add Koniverse/koni-ea --skill koni-ea-dev     # install one
npx skills add Koniverse/koni-ea --skill '*' --agent '*' # install all, all agents
```

| Skill | What it does |
|---|---|
| [`koni-ea-dev`](skills/koni-ea-dev/) | Programming a correct MQL5 EA — lifecycle and event model, order placement and signal timing, position sizing and SL/TP, risk and money management, and the production pitfalls that only bite live |
| [`koni-ea-ops`](skills/koni-ea-ops/) | The lifecycle of a released EA — `v<X.YY>` versioning and bump rules, MagicNumber registry, deployment to an MT5 terminal, release backtest requirements, per-version documentation |

---

## Documentation

| Doc | For |
|---|---|
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

- **MetaTrader 5** with MetaEditor, to compile. MetaEditor is **Windows-only** —
  on macOS or Linux use a Windows VM, or MT5 under Wine/CrossOver.
- A **demo account** for testing. Use it before real money, not after.
- No build tooling for this repo itself — it is markdown and MQL5 source.

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
