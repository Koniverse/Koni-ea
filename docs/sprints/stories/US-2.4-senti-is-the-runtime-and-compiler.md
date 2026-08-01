---
id: US-2.4
title: "Correct the deployment model — Senti is the runtime and the compiler"
epic: EPIC-2
status: done
priority: P0
points: 8
sprint: sprint-2026-W31
assignee: jindo9986
commit: 153d359
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.6.0
---

# US-2.4 — Correct the deployment model: Senti is the runtime and the compiler

## Goal

Make every document teach the same, true model: **the user writes MQL5 source; Senti
compiles it and runs it.** No MetaEditor, no `.ex5`, no `.set`, no Windows machine.

## Background

Two framing errors, found in sequence, both by the owner.

**The runtime.** Through v0.4.0 the README opened *"Build a MetaTrader 5 trading bot
and deploy it on Senti"* and `SETUP.md` §4 said *"Install into MetaTrader… attach the
EA to a chart."* Every sentence was true. The model they added up to was wrong — MT5
as the runtime, Senti as an optional last step.

**The compiler.** v0.5.0 fixed the runtime and got the route wrong: compile with F7,
upload `.ex5` + `.set`, and — for macOS and Linux — install a Windows VM first. Senti
has an **Author Studio**: paste `.mq5` into a web editor, press Compile, press Save as
EA. Senti runs a static safety scan, compiles headlessly on its own build host, and
builds the preset from the source's `input` defaults.

The architecture docs had been read and were not wrong. `FR-85` (upload `.ex5` +
`.set`) is real and the compile service is described exactly as built — but `FR-85` is
the **admin** path. The user-facing path is a different epic, and the line saying so
was one row in a table of 175 requirements. A screenshot answered it in seconds.

**Lessons applied:** §11 (name a product by its destination, not its toolchain) — this
story wrote it, then immediately demonstrated the sibling failure it did not cover.

## Acceptance criteria

1. No document tells a user they need MetaEditor, an `.ex5`, a `.set`, or Windows.
2. The Author Studio flow is documented end to end, including the publish checklist.
3. Senti's safety scan is documented wherever a user might write disallowed code.
4. The double-trade hazard appears wherever a user might run a bot locally.
5. Both skills carry the model, since they travel without `AGENTS.md`.
6. `AGENTS.md` forbids agents from presenting chart-attachment as the final step or
   claiming the code compiles.
7. A repo-wide sweep finds no surviving contradiction.

## Tasks

- [x] Read `Senti-Quant` architecture for the runtime model — Node Manager, terminals,
      `deployEa` — rather than rewording
- [x] Write `docs/RUNNING-ON-SENTI.md`
- [x] Reframe README, `SETUP.md`, the template README, `AGENTS.md`, both skills
- [x] Correct again after the screenshot: Author Studio, not MetaEditor
- [x] Document the L1 safety scan and the "build is of the code on screen" check
- [x] Demote local MetaTrader to optional, for the Strategy Tester only
- [x] Close [F-1](../../tests/findings.md) — the template compiled 0E/0W
- [x] Sweep for the old framing; fix 7 live files, then the adjacent paragraphs the
      first sweep's edits made inconsistent

## Dev notes — Architecture constraints

- **Senti runs the bot on its own terminals.** Node Manager downloads the binary,
  verifies its checksum, and applies it to a terminal logged into the user's linked
  account. The user's machine is not involved at runtime.
- **The safety scan gates the compile.** Blocked: any `#import`; every `WebRequest`
  (allowlist ships empty; a non-literal URL is always refused); `FileDelete`,
  `FolderDelete`, `FolderClean`, `FileMove`; `SendFTP`. A refusal, not a compile error.
- **The `input` defaults become the deployed preset.** A careless default ships as a
  live parameter.
- **Editing after a successful compile invalidates the build** — the publish
  checklist's fourth item.

## Dev notes — Cross-story dependencies

Revises documents from [US-1.3](US-1.3-public-release-format.md) and
[US-1.4](US-1.4-open-source-standard.md), and the skills from
[US-2.3](US-2.3-skills-portable-outside-koniverse.md). Closes EPIC-2.

## Dev notes — What we did NOT do

- **Did not remove the internal compile-service documentation** from
  `koni-ea-ops/references/deployment.md`. It is real and used by the Koniverse team;
  it is now labelled as such, beside the partner path.
- **Did not run or backtest the template** — [F-2, F-3](../../tests/findings.md) stay
  open. Compiling is done; running is not.

## Dev notes — What the wrong model would have cost

A user who believes MT5 is the runtime attaches the finished EA to a local chart to
"see it work," then also deploys on Senti. Two instances, one broker account, same
signal: **double the configured position size**, each managing trades the other
opened, no warning. The docs never said to do it — they made the question invisible.

## Verification commands

```bash
./scripts/verify.sh
grep -rniE 'metaeditor.{0,40}(required|windows-only)|upload.{0,10}\.ex5' README.md AGENTS.md docs/ templates/ skills/
```

## Changelog entry

```markdown
### Changed
- Every user-facing document rewritten around the Author Studio flow: paste `.mq5`,
  Compile, Save as EA, Deploy. MetaEditor demoted to optional.

### Added
- `docs/RUNNING-ON-SENTI.md`; the safety scan documented in five places.

### Fixed
- F-1 closed — the template compiled 0 errors, 0 warnings on the first attempt.
```

## Implementation notes

The screenshot closed [F-1](../../tests/findings.md) as a side effect: the template
compiled `0 errors, 0 warnings` on the first attempt, after four versions open on the
premise that compiling it required a Windows host — the premise this story removed.

The sweep needed two passes. The first fixed seven files matching the grep; those
edits then made adjacent paragraphs inconsistent, and `docs/tests/` still described the
compile as an open gap after F-1 had closed.

Lessons: §11 (name a product by its destination, not its toolchain), §12 (read the
product's UI, not only its architecture docs).

## Files modified

Added `docs/RUNNING-ON-SENTI.md`. Rewritten: `README.md`, `docs/SETUP.md`,
`templates/mql5/STARTER_EA/README.md`, `AGENTS.md`, `templates/README.md`,
`docs/BRIEF.md`, `docs/tests/{README,STRATEGY,test-organization,test-cases/README}.md`,
`skills/koni-ea-dev/SKILL.md`, `skills/koni-ea-ops/SKILL.md`,
`skills/koni-ea-ops/references/deployment.md`, `scripts/verify.sh`,
`docs/LESSONS.md` (§11, §12), `docs/tests/findings.md` (F-1 closed).
