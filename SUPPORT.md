# Getting help

Start with the docs — most questions are answered there, faster than a round trip.

| Your question | Read this |
|---|---|
| How do I build a bot from the template? | [templates/mql5/STARTER_EA/README.md](templates/mql5/STARTER_EA/README.md) |
| How do I set up my machine? | [docs/SETUP.md](docs/SETUP.md) |
| My EA compiles but does nothing | [docs/SETUP.md § Troubleshooting](docs/SETUP.md#troubleshooting) |
| Why is the code written this way? | [skills/koni-ea-dev/](skills/koni-ea-dev/) |
| What breaks only on a live account? | [mql5-pitfalls.md](skills/koni-ea-dev/references/mql5-pitfalls.md) |
| How do I version and release my EA? | [skills/koni-ea-ops/](skills/koni-ea-ops/) |
| How do I contribute? | [CONTRIBUTING.md](CONTRIBUTING.md) |

## Still stuck

**Open a [Discussion](https://github.com/Koniverse/Koni-ea/discussions)** for
questions, ideas, and "is this the right approach" conversations.

**Open an [Issue](https://github.com/Koniverse/Koni-ea/issues)** when something in
this repository is wrong: a broken template, an incorrect instruction, a dead link.

**Report security problems privately** — see [SECURITY.md](SECURITY.md). Do not open
a public issue.

## What makes a question easy to answer

Include the specifics. "It doesn't work" costs a round trip that a paste of the
Journal output would have saved.

- Your MT5 build number and broker
- The symbol and timeframe
- The relevant Journal or Experts tab output, as text rather than a screenshot
- What you expected, and what happened instead
- The template and version you started from

Redact your account number and never include a password.

## What this project does not help with

**Strategy advice.** We can tell you whether your EA is *correct*. We cannot tell
you whether it will be *profitable*, and we will not review a strategy for expected
returns. Those are different problems, and treating them as one is how people lose
money.

**MetaTrader or broker issues.** Terminal crashes, order rejections from the server,
platform bugs — those belong with MetaQuotes or your broker.

**Running your bot for you.** This repository ships tools and templates. What you
deploy, and what it does, is yours.
