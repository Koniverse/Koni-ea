# Where your bot runs

**Read this before you build anything.** It is one idea, and getting it wrong is the
most expensive mistake available in this repository.

## The one thing to understand

> **You write MQL5 source. Senti compiles it and runs it.**

You never produce an `.ex5`. You never install MetaTrader to ship a bot. You paste
`.mq5` source into Senti's **Author Studio**, press **Compile**, press **Save as EA**,
and deploy it to your linked account.

Senti then runs it on **Senti's** MT5 terminals — Windows hosts in a datacenter near
the broker, 24/5, logged into the account you linked. Your machine can be off. It
usually should be.

## The whole path

```
YOU                                    SENTI — Author Studio
  write MQL5                             ① + New draft
  (Claude, the built-in                  ② paste your .mq5 → Compile
   assistant, or by hand)                     L1 safety scan → headless MetaEditor
        │                                     0 errors / 0 warnings
        └── copy the .mq5 source ──────▶  ③ Save as EA
                                              → private EaDefinition + preset
                                          ④ Deploy to your linked account
                                              → runs on a Senti terminal, 24/5
```

Four clicks. There is no file to upload, no binary to produce, and no MetaTrader on
your side of the line.

## What you do and do not need

| | Needed? |
|---|---|
| Write MQL5 source | ✅ you (with Claude, the built-in assistant, or by hand) |
| **MetaEditor / a local compiler** | ❌ **No.** Senti compiles. This is the part people assume and it is wrong. |
| Produce an `.ex5` | ❌ No. Senti produces and stores it; you never see the binary. |
| Write a `.set` file | ❌ No. Senti creates the preset from your `input` defaults on save. |
| A Windows machine | ❌ No. Author Studio is a web page. |
| A Senti account with a linked broker account | ✅ yes — that is the runtime |
| A local MT5 | ⚪ optional — only if you want to run the Strategy Tester yourself today |

**If you have been told you need a Windows VM to build a bot for Senti, that is
wrong.** You need a browser.

## Author Studio, step by step

**① New draft.** `+ New` in the DRAFTS panel. Each draft is a named version you can
keep, duplicate, and come back to.

**② Paste and compile.** Drop your `.mq5` into the editor and press **Compile**.
Senti runs two things:

- **The L1 safety scan** — a static check that rejects dangerous constructs *before*
  compiling. See [What the safety scan rejects](#what-the-safety-scan-rejects).
- **A headless MetaEditor compile** on Senti's build host. Errors and warnings come
  back as inline markers and a Problems panel, with an **Ask AI to fix** action.

A release needs **0 errors and 0 warnings**. The panel shows `0E 0W` when you are
there.

**③ Save as EA.** The publish checklist has to be green — generation finished, no
build running, last compile passed, *that build is of the code on screen*, EA name
set. Saving registers a **private** EA definition plus a preset built from your input
defaults.

That fourth check matters more than it looks: it means editing the code after a
successful compile invalidates the build. Compile again before saving, or you publish
a binary that is not the code you are reading.

**④ Deploy.** Pick the EA and the linked account. Senti attaches it to one of its
terminals, restarts it if the terminal goes down, and streams ticks, positions and
equity to your browser.

## Writing the code with Claude

Install these skills into whatever project you write in, and your assistant applies
the MQL5 standard as it works:

```bash
npx skills add Koniverse/Koni-ea --skill koni-ea-dev --skill koni-ea-ops
```

Then start from [`templates/mql5/STARTER_EA/`](../templates/mql5/STARTER_EA/) rather
than a blank file, replace `Signal()`, and paste the result into Author Studio.

Author Studio also has its own assistant — describe the strategy in natural language
and it writes MQL5 into the editor. The two approaches produce source that goes
through the same compile and the same safety scan.

## What the safety scan rejects

Code that does any of these is blocked **before** it compiles. Nothing here is
something a trading strategy needs, and none of it is guessable — check your code
against the list before you paste:

| Blocked | Why |
|---|---|
| Any `#import` | Loading a DLL or external library is the sandbox escape. No exceptions. |
| `WebRequest` | Rejected outright today — the domain allowlist ships empty. Also rejected when the URL is not a literal string, because an unverifiable URL cannot be checked. |
| `FileDelete`, `FolderDelete`, `FolderClean`, `FileMove` | Destructive file operations on a shared host. |
| `SendFTP` | Data exfiltration. |

The template in this repository uses none of them. If you add a library or a network
call to your strategy, expect it to be refused, and design around it rather than
trying to slip past — the scan runs on the exact source you submit.

## Why Senti runs it and not you

Three reasons, each a thing a desktop cannot do.

**Uptime.** Markets run 24/5. A bot on your laptop stops when the lid closes, when
Windows updates, when the power blips. It stops *mid-position*, with a trade open and
nothing managing it. Senti's terminals run continuously and restart after a crash.

**Latency.** Senti's terminals sit in the same region as the broker. Order round-trips
are single-digit milliseconds; from a home connection they are tens to hundreds, and
slippage is paid in money.

**Visibility.** Ticks, positions and equity stream to your browser in real time. A bot
on your desktop tells you nothing unless you are sitting at it.

## The mistake that costs money

> [!WARNING]
> **Never run the same bot on your own MT5 and on Senti against the same broker
> account.**

This is easy to walk into if you compile locally to test. Both instances log into the
same account, both see the same signal, both open a position.

You get **double the size you configured** — your risk-percent setting is now
meaningless. Each instance manages positions filtered by MagicNumber, so if they share
one, each closes trades it did not open; if they differ, neither closes the other's.
Both outcomes are bad and neither announces itself. You find out from the balance.

**Anything you run locally uses a demo account.** Your real account is linked to Senti
and nothing else.

## Where a local MT5 still helps

You do not need it to ship. You may still want it for:

- **The Strategy Tester.** Backtesting your own build, "Every Tick Based on Real
  Ticks", at least 3 months. Senti is bringing on-demand backtesting into the platform
  — until that ships, running it yourself is the way to get a backtest.
- **Watching an EA behave** on a demo chart while you develop the logic.

Both are development. Neither is production, and neither is required to get a bot
running on Senti.

## Details worth knowing

**Your bot lands in your private catalog.** Only you see it. Nothing is published or
shared unless you later choose otherwise.

**Inputs become the preset.** The `input` defaults in your source are what Senti
saves. Getting them right in the code is how you get them right on the platform.

**Changing parameters is a new version.** Keep the source, the preset, and the
per-version doc in step — see
[`koni-ea-ops`](../skills/koni-ea-ops/references/versioning.md).

**MagicNumber uniqueness is per account, not per machine.** Two bots on one linked
account need different magics. See
[Running your own registry](../skills/koni-ea-ops/references/registry-and-magic.md#running-your-own-registry).

**Your bot must survive a restart.** Senti restarts terminals after crashes, node
reboots, and maintenance windows. The template already rebuilds its state from open
positions and GlobalVariables; if you add state of your own, it has to do the same, or
your bot wakes up with a live position it does not know about.
