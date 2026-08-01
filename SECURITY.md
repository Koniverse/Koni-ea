# Security Policy

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Report it privately through
[GitHub Security Advisories](https://github.com/Koniverse/Koni-ea/security/advisories/new),
or by email to **partners@koni.studio** with `[SECURITY]` in the subject.

Include what you found, how to reproduce it, and what an attacker gains. A proof of
concept helps; a working exploit against someone else's account does not — do not
test against accounts you do not own.

**Response targets**: acknowledgement within 3 business days, an initial assessment
within 10. We will tell you what we plan to do and when. If we disagree that a
report is a vulnerability, we will say so and explain why.

We will credit you in the advisory unless you ask us not to.

## What counts as a vulnerability here

This repository ships no running service. It ships **agent skills** and **MQL5
source that other people compile and run against real money**. That shapes the
threat model, and it is not the usual one.

Treat these as security issues:

| Class | Example |
|---|---|
| **Malicious template logic** | A template that routes orders to an attacker-chosen account, exfiltrates credentials, or trades against the user |
| **Hidden behavior** | Code whose observable effect differs from what its documentation and inputs describe |
| **Credential exposure** | A committed broker login, account number, API key, or terminal path — including in a `.set` file or a commented-out line |
| **Skill prompt injection** | Text in a `SKILL.md` or reference that manipulates an AI agent into unsafe actions in a consumer's repository |
| **Dependency or supply chain** | A compromised install path in the documented setup instructions |
| **A chassis defect with a money consequence** | A sizing, stop-loss, or magic-number bug that causes real loss — see the boundary below |

## What is not a vulnerability

- **A strategy losing money.** The shipped templates are structural skeletons with
  deliberately naive signals and no edge. Poor performance is documented, expected,
  and not a security issue.
- **MetaTrader or broker platform bugs.** Report those to MetaQuotes or your broker.
- **A user running a template on a live account without testing it.** The
  documentation says demo first, in several places.
- **A missing feature**, however desirable.

## The grey area, stated explicitly

Some correctness bugs *are* security bugs here, because the failure mode is
financial loss rather than data loss. A lot-sizing error that risks 10x what the
user configured, a stop loss that silently fails to attach, or a magic-number
collision that makes one EA close another's positions — report these **privately
first**. We would rather triage a false positive than read about a real one in a
public issue.

If you are unsure which side of the line something falls on, report it privately.
We will tell you if it can be public.

## Supported versions

| Version | Supported |
|---|---|
| `0.x` | Yes — current development line |

This project is pre-1.0. There is one supported line, and it is the latest release.
When 1.0 ships, this table will state a real support window.

## For users of this repository

Two things are your responsibility and cannot be fixed upstream:

1. **Read the code before you run it.** Every template is source you compile
   yourself. That is deliberate — `.ex5` binaries are gitignored so nothing ships as
   an opaque blob. Use it: read the `.mq5` before compiling.
2. **Test on a demo account first.** For at least one full trading week. A backtest
   cannot show you slippage, requotes, weekend gaps, or how the EA behaves across a
   terminal restart.

Never paste broker credentials, account numbers, or investor passwords into an
issue, a pull request, or a `.set` file. If you already have, change them now and
tell us so we can purge the content.
