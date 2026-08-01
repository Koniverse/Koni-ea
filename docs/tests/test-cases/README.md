# Test cases

Epic-level test specifications, one file per epic: `EPIC-N.md`.

## Current state

**Empty.** No epic has test cases yet.

That is a deliberate position rather than an oversight. [EPIC-1](../../sprints/epics/EPIC-1.md)
delivered documentation, a skill set, and MQL5 source that this repo cannot execute
— MetaEditor is Windows-only. Writing test cases before there is any way to run them
produces a document that looks like coverage and provides none.

The verification EPIC-1 *did* get is structural and is recorded in
[STRATEGY.md](../STRATEGY.md); the executable gap is tracked as
[F-1 through F-3](../findings.md).

## When to write a file here

Write `EPIC-N.md` when either becomes true:

- A Windows host is available, making MQL5 compile + runtime cases executable
- An epic delivers something with observable behaviour this repo can assert on

## Structure of an `EPIC-N.md`

Per the koni-docs test-cases template, ten sections:

1. **Scope** — what this epic's cases cover, and what they do not
2. **Stories in scope** — the US-N.M list
3. **Goals** — what passing actually proves
4. **Environment** — MT5 build, broker, symbol, timeframe, account type
5. **Cadence** — per-commit / per-release / on-demand
6. **Quick reference** — the case ID table at a glance
7. **Detail** — per case: preconditions, steps, expected, actual
8. **Coverage matrix** — AC ↔ TC, so an uncovered criterion is visible
9. **Open** — cases specified but not yet runnable
10. **Sign-off**

## Case ID convention

`TC-<EPIC>.<N>-<TYPE>` — e.g. `TC-1.3-SMK` for the third case of EPIC-1, a smoke
test. Types: `E2E` · `REG` · `SMK` · `INT`. `UNIT` is not used here; see
[test-organization.md §Test-case taxonomy](../test-organization.md#test-case-taxonomy).

## The rule that matters most

Every acceptance criterion needs **positive, negative, and boundary** coverage. For
an EA the boundaries are the ones that bite on a live account, not the ones that are
convenient to write:

minimum lot · maximum lot · a stop closer than `SYMBOL_TRADE_STOPS_LEVEL` · zero
free margin · a short `CopyBuffer` read · a restart while a position is open · two
instances sharing a MagicNumber.

A case with no execution report in `test-reports/` is **unverified**, and anything
citing it must say so.
