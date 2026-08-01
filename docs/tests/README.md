# docs/tests — QA hub

The verification surface for this repo. Standard: the `koni-qc` skill's
`references/test-organization.md`; the local application of it is
[test-organization.md](test-organization.md).

## Start here

| I want to… | Go to |
|---|---|
| Understand what is and is not verified | [STRATEGY.md](STRATEGY.md) |
| See where a test artifact goes | [test-organization.md](test-organization.md) |
| Check what is currently unverified or broken | [findings.md](findings.md) |
| Write test cases for an epic | [test-cases/README.md](test-cases/README.md) |

## The short version

This repo has **no test code**. It ships markdown and MQL5 source, and nothing here
compiles it — that happens in Senti's Author Studio, on Senti's build host.

Verification is therefore structural (links resolve, frontmatter is complete,
version identity holds, no secrets leak) plus a hand-reviewed correctness checklist
for every template contribution.

The template **does** compile — 0 errors, 0 warnings in Senti Author Studio. What
remains untested is running it and backtesting it, tracked in
[findings.md](findings.md) rather than papered over.

## Directory layout

```
docs/tests/
├── README.md              ← you are here
├── STRATEGY.md            ← whole-repo strategy: risk posture, priority, gaps
├── test-organization.md   ← the standard, applied locally
├── findings.md            ← open findings and coverage gaps
├── test-plan/             ← per-epic plans, EPIC-NN-<slug>.md
├── test-cases/            ← epic-level cases, EPIC-N.md
├── test-reports/          ← EPIC-NN/<MMDDYYYY>/ — created on first run
├── bug-bash/              ← sprint-YYYY-WNN.md
└── audits/                ← dated one-off analyses
```

Empty directories are kept so the first execution has somewhere to land.
`test-reports/` is deliberately absent until a run produces one.
