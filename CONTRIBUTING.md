# Contributing to koni-ea

Thanks for wanting to add to this. The bar here is narrow on purpose: every skill
and template is something a partner will run against a real trading account, so
"it works on my chart" is not the standard.

## Before you start

```bash
git clone https://github.com/Koniverse/koni-ea.git
cd koni-ea
cp .active-context.example.md .active-context.md   # fill in your local details
```

Read [REPO_STRUCTURE.md](REPO_STRUCTURE.md) first — it says where things go and
why. Most rejected changes are things filed in the wrong place.

## What belongs here

| Contribution | Where | Bar to clear |
|---|---|---|
| A new bot template | `templates/<platform>/<ALGO>/` | Compiles clean, has a README, has a per-version doc, ships no strategy IP you do not own |
| A new agent skill | `skills/<name>/SKILL.md` | Trigger-shaped description, navigational body, deep material in `references/` |
| A fix to an existing template | its `v<X.YY>/` dir | **A fix is a new version** — see below |
| Docs, typos, clarity | anywhere | Just send it |

## What does not belong here

- **Strategies you did not write.** Do not port a paid EA, a leaked source, or a
  vendor's logic. This repo is public and MIT-licensed; anything merged here is
  redistributable by anyone forever.
- **Backtest reports as proof of profit.** A template's job is to be correct, not
  to be lucrative. Performance claims do not belong in this repo.
- **Credentials, broker logins, account numbers, API keys** — in any file,
  including a `.set` and including a commented-out line.
- **Compiled binaries.** `.ex5` / `.ex4` are gitignored. Ship source; let each
  consumer compile.

## Template contributions

### A change to a released template is a new version

This is the rule people miss most. Under
[koni-ea-ops](skills/koni-ea-ops/references/versioning.md):

| Change | Bump |
|---|---|
| Bug fix, new optional input, logging | minor — new `v<X.YY>/` directory |
| **A `.set` parameter change** | minor — parameters are part of the artifact |
| Breaking logic change, not `.set`-compatible | major — reset minor to `00` |

You do not edit `v1.00/` in place. You create `v1.01/` with all four artifacts.
An old version's doc is never rewritten — it describes that version as released.

### Correctness checklist

Every template must satisfy these before review. They are not style preferences;
each one is a bug class that a green backtest hides:

- [ ] Signals read **closed** bars only (`[1]`, `[2]`), never the forming bar `[0]`
- [ ] Orders go through `CTrade`, never raw `OrderSend`
- [ ] Both the boolean **and** `ResultRetcode()` are checked after every trade call
- [ ] Every indicator handle is checked against `INVALID_HANDLE` and released in `OnDeinit`
- [ ] `ArraySetAsSeries(buf, true)` before every `CopyBuffer`, return value checked
- [ ] Prices normalized to `_Digits`; lots snapped to `SYMBOL_VOLUME_STEP`, rounded **down**
- [ ] SL/TP clamped to `SYMBOL_TRADE_STOPS_LEVEL`
- [ ] Margin is **pre**-checked, never post-checked
- [ ] Positions filtered by symbol **and** magic in every query
- [ ] State survives a restart (latches in GlobalVariables, baskets rebuilt from open positions)
- [ ] Compiles with zero errors **and** zero warnings
- [ ] English for all code, identifiers, comments, and commit messages

The full reasoning for each is in
[`skills/koni-ea-dev/references/mql5-pitfalls.md`](skills/koni-ea-dev/references/mql5-pitfalls.md).

## Skill contributions

A skill's `description` is a **trigger condition**, not a summary — it tells an
agent *when to reach for this*, so write it as the situations that should invoke
it. Keep `SKILL.md` navigational and push depth into `references/<topic>.md`; a
body that must be read in full on every invocation is too long.

## Commits

This repo runs the koni-harness gate as a pre-commit and pre-push hook — version
phase, changelog anchor, doc references, and secret scanning. The gate itself is
vendored at `.koni-harness/` and is tracked, so it works from a fresh clone.

- Every shipping change bumps `VERSION` and adds an entry under `[Unreleased]` in
  [docs/CHANGELOG.md](docs/CHANGELOG.md), in the same commit
- Do not bypass the gate with `--no-verify`. If you genuinely must, record why in
  [docs/CONTEXT.md](docs/CONTEXT.md)
- Commit messages in English

## Risk disclaimer

Everything here is educational tooling for building trading software. Nothing in
this repository is financial advice, and no template is a profitable strategy —
the shipped strategy stubs are deliberately naive and documented as such.

Automated trading can lose money faster than manual trading, including more than
your initial deposit on a leveraged account. Test on a demo account first. You own
what your bot does.
