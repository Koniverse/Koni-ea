---
id: US-2.2
title: "Make the verification tooling actually verify"
epic: EPIC-2
status: done
priority: P1
points: 5
sprint: sprint-2026-W31
assignee: jindo9986
commit: 01c0336
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.3.6
---

# US-2.2 — Make the verification tooling actually verify

## Goal

Make the repository's own checks true: a check that cannot run must fail loudly, and
the commit gate must enforce what it is configured to enforce.

## Background

`scripts/verify.sh` shipped in v0.3.0 with a promise printed in its own header — *"CI
runs exactly this script, so a green run here is a green run there."* The first CI run
failed on a check that had passed locally every time.

The English-only check used `grep -lP`. A shell function shadowing `grep` on the
author's machine routed to a different implementation, matched nothing, and reported
success. GitHub's runner has plain GNU grep, ran the real pattern, and found two files.
`2>/dev/null` on the call made the difference invisible: a tool that errors and a tool
that finds nothing look identical when stderr is discarded.

A second gap ran deeper. `install-gate.sh` writes a pre-commit hook hardcoded to
`--phase work-commit`, and nothing ever invokes `--phase release-commit`. Five of the
nine configured checks therefore **never fired**: `story-lint`, `changelog-anchor`,
`lesson-capture`, `design-first`, `koni-docs-validate`. They had been run by hand
before every commit during setup, which is exactly why nobody noticed — a human was
standing in for the hook.

**Lessons applied:** §2 (never report a verification you could not run) — the same
principle, arriving from the tooling side rather than the reporting side.

## Acceptance criteria

1. The English check runs identically on macOS and Linux, and **fails** when its
   interpreter is missing rather than passing.
2. It is proven to catch what it claims, against a sentinel file.
3. Its character set is an allowlist, so every new exception is a visible decision.
4. The secret scan runs without a paid licence.
5. The stateless release-phase gate checks run in CI.
6. The local hook invokes both gate phases.
7. CI is green.

## Tasks

- [x] Rewrite the English check in `perl -CSD` — same regex engine and UTF-8 semantics
      on both platforms
- [x] Fail loudly when perl is absent instead of passing quietly
- [x] Replace the blocklist with an allowlist of the typography, math, arrow,
      box-drawing and symbol ranges this repo uses
- [x] Scope the check to authored content; exclude the vendored `.koni-harness/`
- [x] Prove it fails against a sentinel containing Vietnamese text
- [x] Replace `gitleaks-action` (org licence required) with the MIT CLI, pinned
- [x] Add `.gitleaks.toml` allowlisting BMAD manifest content hashes — scoped to three
      files, not to `_bmad/`
- [x] Move `story-lint` and `changelog-anchor` into `verify.sh` so CI runs them
- [x] Point the local pre-commit hook at both phases
- [x] File [F-7](../../tests/findings.md) for what cannot be fixed here

## Dev notes — Architecture constraints

- **`grep` on `PATH` is not one program.** BSD grep, GNU grep, ugrep, a shell
  function, or a shim — `-P` support, locale handling and default excludes all differ.
  `perl -CSD` is deterministic across hosts.
- **Allowlist over blocklist.** An early blocklist flagged `Σ(open·vol)/Σvol` —
  mathematical notation — as non-English. Enumerating forbidden scripts is endless;
  declaring what is permitted makes each addition a decision.
- **`lesson-capture` and `design-first` read `git diff --cached`.** They only work in
  a hook, and hooks are not committed. A fresh clone still gets neither.

## Dev notes — Cross-story dependencies

Depends on [US-1.4](US-1.4-open-source-standard.md), which introduced `verify.sh` and
the CI workflow. The gate-phase finding was discovered while working
[US-2.3](US-2.3-skills-portable-outside-koniverse.md), whose commit the gate blocked
for a missing lesson verdict — the first time it ever did.

## Dev notes — What we did NOT do

- **Did not add markdown linting.** Its first run would be a wall of stylistic noise
  across existing documents, and a check whose first run is noise gets disabled rather
  than fixed.
- **Did not fix the hook upstream.** `install-gate.sh` lives in `Koni-Skills`; that is
  where the durable fix belongs — [F-7](../../tests/findings.md).

## Verification commands

```bash
./scripts/verify.sh
printf 'sentinel with forbidden text\n' > /tmp/should-fail.md   # must be reported
sh .koni-harness/gate-runner.sh --phase release-commit --dry-run
```

## Changelog entry

```markdown
### Fixed
- The English-only check was a no-op on the author's machine; rewritten in perl and
  proven against a sentinel.
- The gitleaks job required a paid organization licence; replaced with the MIT CLI.
- Five configured gate checks never fired — the hook only ever ran one phase.
```

## Implementation notes

The two files CI found were both instructive in their own right. `Σ(open·vol)/Σvol`
was a **false positive** from an over-broad character class. The Vietnamese comment in
`.koni-harness/checks/design-first.sh` was **real but not ours** — vendored, and
overwritten on every gate reinstall, so it became [F-5](../../tests/findings.md)
rather than a local edit.

The gate gap was found by running `lesson-capture` by hand, watching it fail, and then
watching the commit succeed anyway.

Lessons: §7 (a check that depends on ambient tooling verifies nothing — it fails open,
reporting success while doing nothing, and grows more trusted the longer it does so).

## Files modified

`scripts/verify.sh`, `.github/workflows/verify.yml`, `.gitleaks.toml`,
`.git/hooks/pre-commit` (local only), `docs/LESSONS.md` (§7),
`docs/tests/findings.md` (F-5, F-7).
