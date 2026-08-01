# Test organization — koni-ea

The `koni-qc` `references/test-organization.md` standard, applied to this repo.
Where the standard assumes test *code*, this file states what replaces it here and
why.

## The standard, and this repo's shape

koni-qc organizes tests **by epic**, in three places that must stay in sync:

1. `docs/tests/test-cases/EPIC-N.md` — the specs
2. `<app>/tests/epic/EPIC-NN/` — the test **code**
3. `docs/tests/test-reports/EPIC-NN/<MMDDYYYY>/` — execution results

**This repo has no place 2.** It ships markdown and MQL5 source; there is no
application to test and no runtime to assert against. `koni-setup` correctly did
not scaffold a `tests/epic/` code root, because that is a code-profile artifact and
this is a content-profile repo.

So the sync contract here is two-place: **cases ↔ reports**. A case is written
once there is something to execute; a report lands when it is executed.

## Where each artifact goes

| Artifact | Path | Naming |
|---|---|---|
| Per-epic test plan | `test-plan/` | `EPIC-NN-<slug>.md` |
| Epic-level test cases | `test-cases/` | `EPIC-N.md` |
| Execution report (automated) | `test-reports/EPIC-NN/<MMDDYYYY>/` | `report.md` |
| Execution report (manual) | `test-reports/EPIC-NN/<MMDDYYYY>/` | `report-manual.md` |
| Per-release aggregate | `test-reports/releases/` | `vX.Y.Z.md` |
| Bug bash | `bug-bash/` | `sprint-YYYY-WNN.md` |
| One-off analysis | `audits/` | dated |
| Open findings | `findings.md` | — |

`test-reports/` is **created on the first run, never pre-made**. An empty report
directory implies a run that did not happen.

## Test-case taxonomy

The koni-qc case types, and what each means here:

| Type | Meaning | Applies here? |
|---|---|---|
| **E2E** | A full user journey | Yes — "partner clones → copies template → replaces Signal() → compiles → uploads" is the E2E path |
| **REG** | Regression — a bug that escaped once | Yes, once a template bug is found in the field |
| **SMK** | Smoke — the minimum that proves it is not broken | Yes — the template compiles and its `[INIT]` line appears in the Journal |
| **INT** | Integration between components | Rarely — the only integration is EA ↔ MT5 terminal |
| **UNIT** | A single function in isolation | **No.** MQL5 has no unit-test runner in this workflow |

Every acceptance criterion gets positive, negative, and boundary coverage. For an
EA the boundaries are the ones that bite live: minimum lot, maximum lot, stop level,
zero free margin, a short `CopyBuffer` read, a restart mid-position.

## Verification that replaces a test suite

Since there is no runner, these are the executable checks. They live in
[STRATEGY.md §What is verified](STRATEGY.md#what-is-verified-and-how) with the
commands; summarized here by what they cover:

| Layer | Covers | Automated? |
|---|---|---|
| koni-harness gate | Version/changelog coupling, secrets, story frontmatter, doc references | Yes — every commit |
| Link resolution sweep | Every internal markdown link | Manual command |
| Template self-consistency | Version identity, handle create/release parity, no bar `[0]` reads | Manual command |
| Correctness checklist | The 12 MQL5 bug classes | Manual review per contribution |
| MetaEditor compile | Syntax, types, scope | **Not run — Windows-only** |
| Strategy Tester backtest | Runtime behaviour over history | **Not run — depends on compile** |

The last two rows are the honest gap. They are tracked in
[findings.md](findings.md), not silently omitted.

## The three-place rule, adapted

When a template gains a test case:

1. Write the case in `test-cases/EPIC-N.md` with its AC↔TC mapping.
2. Execute it on a Windows host with MT5.
3. Record the result in `test-reports/EPIC-NN/<MMDDYYYY>/report-manual.md`.

A case with no report is **unverified**, and any document that cites it must say
so. That is the rule this repo most needs, because its current state is exactly
that: a reviewed template with no execution behind it.
