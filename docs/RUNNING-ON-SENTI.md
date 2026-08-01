# Where your bot actually runs

**Read this before you build anything.** It is one idea, and getting it wrong is the
most expensive mistake available in this repository.

## The one thing to understand

> **You build the bot on your MetaTrader 5. It runs on Senti's.**

MetaTrader on your machine is a **workshop** — an editor, a compiler, and a test
harness. It is where you write the code, press F7, and run the Strategy Tester.

It is **not** where your bot lives. When your bot is finished you upload it to Senti,
and Senti runs it on Senti's own MT5 terminals, against the broker account you linked.

Your machine can be off. It usually should be.

## The two halves

```
┌─ YOUR MACHINE ─────────────────┐      ┌─ SENTI ────────────────────────────────┐
│                                │      │                                        │
│  MetaEditor                    │      │  Windows VPS, Singapore / Vietnam DC    │
│    write .mq5                  │      │    MT5 terminals, running 24/5          │
│    F7 → .ex5                   │      │    logged into YOUR linked broker acct  │
│                                │      │                                        │
│  MT5 Strategy Tester           │      │  Node Manager                          │
│    backtest on history         │      │    downloads your .ex5, verifies it,    │
│    forward-test on demo        │      │    applies it to a terminal            │
│                                │      │                                        │
│  A workshop.                   │      │  Live dashboard in your browser        │
│  Turn it off when done.        │      │    ticks, positions, equity, real time │
│                                │      │                                        │
│         .ex5 + .set  ──────────┼──────┼──▶  upload  ──▶  deploy  ──▶  running   │
└────────────────────────────────┘      └────────────────────────────────────────┘
```

## Why it works this way

Three reasons, and each is a thing your desktop cannot do.

**Uptime.** Markets run 24/5. A bot on your laptop stops when the lid closes, when
Windows updates, when the power blips, when your connection drops. It stops
*mid-position*, with a trade open and nothing managing it. Senti's terminals run
continuously on infrastructure built for it.

**Latency.** Senti's terminals sit in the same datacenter region as the broker
(Singapore / Vietnam). Order round-trips are single-digit milliseconds. From a home
connection, that is tens to hundreds — and slippage is paid in money.

**Visibility.** Once deployed, ticks, positions and equity stream to your browser in
real time. A bot on your desktop tells you nothing unless you are sitting at it.

## Who does what

| | You | Senti |
|---|---|---|
| Write the strategy | ✅ | |
| Compile to `.ex5` | ✅ (MetaEditor F7) | |
| Backtest and demo-test | ✅ | |
| Store the binary | | ✅ (checksum-verified) |
| Run a terminal 24/5 | | ✅ |
| Log into your broker account | | ✅ (credentials encrypted, decrypted only in memory) |
| Attach the bot to a chart | | ✅ (automatic on deploy) |
| Restart after a crash | | ✅ |
| Show you what it is doing | | ✅ (live dashboard) |
| Decide when to stop it | ✅ | |

Notice which column has "attach the bot to a chart." **You never do that in
production.** Deploying on Senti does it for you.

## The mistake that costs money

> [!WARNING]
> **Never run the same bot on your own MT5 and on Senti against the same broker
> account.**

This is the specific failure this document exists to prevent, and it is easy to walk
into. You finish the bot, attach it to a chart locally to "see it work," then upload
it to Senti and deploy. Both are now logged into the same account. Both see the same
signal. Both open a position.

You get **double the size you configured**. Your risk-percent setting is now
meaningless. Worse, each instance manages positions filtered by MagicNumber — so if
they share one, each will close trades it did not open, and if they differ, neither
will close the other's. Both outcomes are bad, and neither announces itself. You find
out from the account balance.

The rule is simple: **local MT5 uses a demo account, always.** Your real account is
linked to Senti and nothing else.

## Where MetaTrader still matters

Your local MT5 is not optional — you cannot build without it:

- **MetaEditor is the only MQL5 compiler.** It is Windows-only. On macOS or Linux you
  need a Windows VM or Wine.
- **The Strategy Tester is the only backtester.** Run "Every Tick Based on Real
  Ticks", at least 3 months, on the timeframe you will actually deploy.
- **A demo account is the only honest forward test.** Run one full trading week before
  you upload anything. A backtest cannot show you slippage, requotes, weekend gaps, or
  how your bot behaves across a terminal restart.

All three are development. None of them is production.

## The path, end to end

1. **Copy** [`templates/mql5/STARTER_EA/`](../templates/mql5/STARTER_EA/) — do not start
   from a blank file.
2. **Write** your entry logic in `Signal()`. That is the only function you replace.
3. **Compile** in MetaEditor: F7, zero errors, zero warnings.
4. **Backtest** in the Strategy Tester, "Every Tick Based on Real Ticks", ≥ 3 months.
5. **Forward-test** on a **demo** account for at least one trading week.
6. **Upload** the `.ex5` and the `.set` to Senti.
7. **Deploy** to your linked account from the Senti dashboard.
8. **Watch** it on the live dashboard. Stop it there when you want it stopped.

Steps 1–5 happen on your machine. Steps 6–8 happen on Senti. The handoff is two
files.

## Details worth knowing

**Your bot lands in your private catalog.** Only you see it. It is not published, not
shared, and not visible to other users unless you later choose otherwise.

**The `.set` file is part of the artifact, not a suggestion.** Senti applies it when
it deploys. If you change parameters, that is a new version — see
[`koni-ea-ops`](../skills/koni-ea-ops/references/versioning.md).

**MagicNumber uniqueness is per account, not per machine.** Two bots on one linked
account need different magics, even if they were built years apart. See
[Running your own registry](../skills/koni-ea-ops/references/registry-and-magic.md#running-your-own-registry).

**Your bot must survive a restart.** Senti restarts terminals — after a crash, a node
reboot, a maintenance window. The template already rebuilds its state from open
positions and GlobalVariables; if you add state of your own, it has to do the same, or
your bot wakes up with a live position it does not know about.
