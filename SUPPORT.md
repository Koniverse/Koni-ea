# Getting help

Everything happens on GitHub — issues, discussions, and pull requests. There is no
support email, and that is deliberate: a thread on this repository is searchable, it
has a status, the next person with your question finds the answer, and you can see
whether anyone has picked it up. An inbox gives you none of that.

## Read this first

Most questions are answered in the docs, faster than a round trip.

| Your question | Read this |
|---|---|
| How do I build a bot from the template? | [templates/mql5/STARTER_EA/README.md](templates/mql5/STARTER_EA/README.md) |
| How do I set up my machine? | [docs/SETUP.md](docs/SETUP.md) |
| My EA compiles but does nothing | [docs/SETUP.md § Troubleshooting](docs/SETUP.md#troubleshooting) |
| Why is the code written this way? | [skills/koni-ea-dev/](skills/koni-ea-dev/) |
| What breaks only on a live account? | [mql5-pitfalls.md](skills/koni-ea-dev/references/mql5-pitfalls.md) |
| How do I version and release my EA? | [skills/koni-ea-ops/](skills/koni-ea-ops/) |
| How do I contribute? | [CONTRIBUTING.md](CONTRIBUTING.md) |

## Then pick the right channel

| What you have | Where it goes | Why there |
|---|---|---|
| A question, an idea, "is this the right approach" | [Discussions](https://github.com/Koniverse/Koni-ea/discussions) | Open-ended. No obligation on anyone to close it. |
| Something in this repository is **wrong** — broken template, incorrect instruction, dead link | [New issue](https://github.com/Koniverse/Koni-ea/issues/new/choose) | It is a defect. It gets tracked and closed. |
| A change you already wrote | [Pull request](https://github.com/Koniverse/Koni-ea/pulls) | Code beats description. See [CONTRIBUTING.md](CONTRIBUTING.md). |
| A **security** problem | [Private advisory](https://github.com/Koniverse/Koni-ea/security/advisories/new) | Private between you and the maintainers. See [SECURITY.md](SECURITY.md). |
| A **conduct** problem | [Private advisory](https://github.com/Koniverse/Koni-ea/security/advisories/new), titled `Code of Conduct` | Same reason. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). |

**Never open a public issue for a security or conduct report.** Both channels above
are private for a reason.

## For partners

If you are building bots on Senti for your own users, the same channels apply — and
using them buys you things a private conversation cannot:

- **Your issue is a record.** When we change something because you asked, the reason
  is attached to the change, and it survives whoever happens to be on the thread.
- **Your question helps the next partner.** Most support load is the same twenty
  questions. Answered in public, each one gets answered once.
- **You can see the state.** Open, assigned, closed, released in which version. No
  wondering whether a message got lost.

For work that genuinely cannot be public — commercial terms, an unreleased strategy,
account-specific data — raise it through your existing Koniverse business contact.
That is a business conversation, not a support request, and this repository is not
the right venue for it.

## What makes a question easy to answer

Include the specifics. "It doesn't work" costs a round trip that a paste of the
Journal output would have saved.

- Your MT5 build number and broker
- The symbol and timeframe
- The relevant Journal or Experts tab output, as text rather than a screenshot
- What you expected, and what happened instead
- The template and version you started from

**Redact your account number and never include a password**, in an issue, a
discussion, or a `.set` file. If you already have, change the credential and tell us
so the content can be purged.

## What this project does not help with

**Strategy advice.** We can tell you whether your EA is *correct*. We cannot tell you
whether it will be *profitable*, and we will not review a strategy for expected
returns. Those are different problems, and treating them as one is how people lose
money.

**MetaTrader or broker issues.** Terminal crashes, order rejections from the server,
platform bugs — those belong with MetaQuotes or your broker.

**Running your bot for you.** This repository ships tools and templates. What you
deploy, and what it does, is yours.
