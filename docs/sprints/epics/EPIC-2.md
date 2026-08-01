---
id: EPIC-2
title: "Post-publication corrections — make the public repo true"
status: done
created: 2026-08-02T00:00:00.000Z
updated: 2026-08-02T00:00:00.000Z
---
# EPIC-2 — Post-publication corrections: make the public repo true

## Goal

[EPIC-1](EPIC-1.md) made the repository *complete*. This epic made it *correct*.

Every story here started from a defect found after the work was declared done — by
CI, by a sweep, or by the owner looking at it. None of it was planned, and that is the
point: a repo written for an audience it has not met yet is wrong in ways only contact
reveals.

## Business context

Between v0.3.0 and v0.6.0 the repository went from private-and-plausible to
public-and-accurate. The defects it shed were not typos. Two of them would have
actively harmed the people this repo exists to serve:

- The documented security and conduct reporting channel returned **404** for five
  versions — the one link a person follows when something is already wrong.
- The docs required MetaEditor and a **Windows VM** to build a bot that needs
  neither, turning a browser tab into a weekend of setup for every macOS and Linux
  partner.

A third would have cost money: the docs never explained that the bot runs on Senti's
terminals, so a user could reasonably attach it to a local chart *and* deploy it —
two instances on one broker account, double size, silent.

## Feature pillars

1. **Publish safely.** Real contact routing, a working private-disclosure channel, no
   personal identifiers.
2. **Make the tooling honest.** A check that cannot run must fail loudly, not pass
   quietly.
3. **Make the skills portable.** A standard published to partners cannot assume
   internal infrastructure.
4. **Get the product model right.** Senti compiles and runs; the user writes source.

## Out of scope

- **Running or backtesting the template** — [F-2, F-3](../../tests/findings.md)
  remain open and belong to whoever has a demo account.
- **The certified four-agent skill grade** — [F-8](../../tests/findings.md); this epic
  reviewed the skills with one grader and claimed no score.
- **Fixing `Koni-Skills` upstream** — [F-5](../../tests/findings.md) (a vendored
  Vietnamese comment) and [F-7](../../tests/findings.md) (the gate hook writes only one
  phase) both belong to that repository.
- **Rewriting git history** to remove a personal author email. The trade-off was put
  to the owner and publication proceeded without it.

## Requirements coverage

Content-profile repo, no `PRD.md` — see
[sprints/README.md § No PRD in this repo](../README.md#no-prd-in-this-repo). Each story
states its own scope; the decisions are [D3–D6](../../CONTEXT.md).

## Stories

| ID                                                               | Title                                                                | Goal                                                                                       | Status | Version |
| ---------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ------ | ------- |
| [US-2.1](../stories/US-2.1-publish-and-contact-routing.md)       | Publish the repository and route all contact through GitHub          | Public repo, working private-disclosure channel, no contact email anywhere                 | ✅ done | v0.3.5  |
| [US-2.2](../stories/US-2.2-verification-actually-verifies.md)    | Make the verification tooling actually verify                        | A check that cannot run fails loudly; the gate enforces what it is configured to enforce   | ✅ done | v0.3.6  |
| [US-2.3](../stories/US-2.3-skills-portable-outside-koniverse.md) | Make the published skills usable outside Koniverse                   | No unfollowable rules, no private-repo authority, the template discoverable from the skill | ✅ done | v0.4.0  |
| [US-2.4](../stories/US-2.4-senti-is-the-runtime-and-compiler.md) | Correct the deployment model — Senti is the runtime and the compiler | Users understand they write source and Senti compiles and runs it                          | ✅ done | v0.6.0  |

Total: 23 points.

## Cross-cutting invariants

- **A documented channel is a promise.** Open it before documenting it; a broken one
  is found only by someone already in trouble.
- **A check that cannot run must fail.** Silence is indistinguishable from success and
  grows more trusted the longer it lasts.
- **A rule has a guarantee and a mechanism.** Publishing separates them; only the
  guarantee travels.
- **Append-only protects committed history, not drafts** — and PII redaction is a
  narrow, announced exception.
- **A decision is not applied until a sweep proves it**, and one sweep is not enough
  when the fix rewrites the surrounding sentences.

## Cross-story testing requirements

Verification is structural and documentary — see
[docs/tests/STRATEGY.md](../../tests/STRATEGY.md). Everything automatable landed in
`scripts/verify.sh`, which CI runs on every push:

- English-only text, internal link resolution, no committed binaries
- Template version identity, indicator-handle parity, closed-bar reads
- VERSION/CHANGELOG pairing, plus the stateless release-phase gate checks
- Secret scanning over full history (gitleaks CLI, org-license-free)

## Acceptance criteria

1. The repository is public, and `/security/advisories/new` resolves rather than 404s.
2. No contact email appears in any tracked file; every channel routes through GitHub.
3. `scripts/verify.sh` fails loudly when a checker cannot run, and has been proven to
   catch what it claims.
4. No skill instructs a reader to use infrastructure they cannot have, without a
   portable equivalent stated alongside.
5. No document tells a user they need MetaEditor, an `.ex5`, a `.set`, or Windows.
6. The double-trade hazard is stated wherever a user might run a bot locally.
7. `koni-docs validate` passes and CI is green.
