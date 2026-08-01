---
id: US-1.4
title: "Meet the open-source standard — community health files, CI, English everywhere"
epic: EPIC-1
status: done
priority: P1
points: 5
sprint: sprint-2026-W31
assignee: jindo9986
commit: pending
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.3.0
---

# US-1.4 — Meet the open-source standard — community health files, CI, English everywhere

## Goal

Bring the repository up to what a contributor expects from a credible open-source
project: the community health files GitHub surfaces, issue and PR templates that
collect what a maintainer actually needs, CI that runs the checks the docs claim,
and one language throughout.

## Background

After US-1.3 the repository had a real template, a license, and documentation
written for a public audience — but none of the scaffolding a contributor looks for
before deciding whether a project is maintained. No `CODE_OF_CONDUCT.md`, no
`SECURITY.md`, no issue templates, no CI. GitHub's own community-standards check
would have flagged four of five items missing.

The language problem was sharper and not cosmetic. `koni-ea-ops` is one of the two
skills this repo **publishes**, and its `documentation.md` instructed every consumer
to write per-version EA documents in **Vietnamese**. A partner installing that skill
receives a standard telling them to document in a language they may not read. The
template shipped beside it had the same defect: `STARTER_EA_v1.00.md`, the one file
a new user opens to understand what they copied, was unreadable to most of the
intended audience.

Two gstack and Anthropic skills framed the work. `devex-review` supplied the DX lens
— first five minutes, fight uncertainty, every default needs an escape hatch — and
its own rule that untestable dimensions be marked rather than guessed. The
`elements-of-style` skill set the prose bar for the new documents.

**Lessons applied:** §2 (never report a verification you could not run) — the CI
deliberately does not fake an MQL5 compile step, and both the workflow and
`verify.sh` say so in place; §3 (count what a public repo actually commits) — the
new `.github/` tree was checked against the tracked-file list before committing.

## Acceptance criteria

1. `CODE_OF_CONDUCT.md`, `SECURITY.md`, and `SUPPORT.md` exist and are specific to
   this project rather than unmodified boilerplate.
2. `.github/` provides issue templates (bug, feature), a PR template with the
   correctness checklist, `CODEOWNERS`, and a CI workflow.
3. `scripts/verify.sh` runs every automatable check and is the same entry point CI
   uses.
4. CI runs on push and pull request, and does **not** claim to verify the MQL5
   compile.
5. No tracked file contains Vietnamese or CJK text.
6. `skills/koni-ea-ops/references/documentation.md` mandates English, including its
   prescribed section names.
7. `.editorconfig` encodes MetaEditor's 3-space/CRLF convention for `.mq5` and
   `.set` files.
8. `./scripts/verify.sh` passes.

## Tasks

- [x] Audit the repo against the OSS community-standards checklist
- [x] Translate `STARTER_EA_v1.00.md` to English
- [x] Rewrite the language mandate and section names in `koni-ea-ops/documentation.md`
- [x] Write `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1 + trading-specific standards)
- [x] Write `SECURITY.md` with a threat model appropriate to a repo that ships trading code
- [x] Write `SUPPORT.md` including what the project explicitly does not help with
- [x] Add `.github/ISSUE_TEMPLATE/{bug_report,feature_request,config}.yml`
- [x] Add `.github/PULL_REQUEST_TEMPLATE.md` carrying the correctness checklist
- [x] Add `.github/CODEOWNERS`
- [x] Write `scripts/verify.sh`
- [x] Add `.github/workflows/verify.yml` calling that script, plus a gitleaks job
- [x] Add `.editorconfig`
- [x] Wire the new files into README, CONTRIBUTING, AGENTS, REPO_STRUCTURE
- [x] Record CONTEXT D4; close finding F-4

## Dev notes — Architecture constraints

- **One verification entry point.** `scripts/verify.sh` is what a contributor runs
  and what CI runs. Two separate check definitions drift, and the drift always
  surfaces as a CI failure nobody can reproduce locally.
- **The English check keys on Vietnamese diacritics and CJK ranges**, not on all
  non-ASCII. Em dashes and typographic quotes are legitimate English typography and
  appear throughout this repository; a naive ASCII-only check would fail every file.
- **CI does not compile MQL5.** MetaEditor is Windows-only and not redistributable.
  Both the workflow and the script state this in place rather than omitting it.

## Dev notes — Cross-story dependencies

Depends on US-1.3 (the public-facing documents these files reference). Closes
[F-4](../../tests/findings.md) from the QA findings register.

## Dev notes — What we did NOT do

- **Did not add markdown linting.** It would flag hundreds of stylistic lines across
  existing documents on day one, and a check whose first run is a wall of noise gets
  disabled rather than fixed.
- **Did not retroactively translate Vietnamese EA documents in other Koniverse
  repos.** D4 binds new work; a sweep across repos is separate scope.
- **Did not add a root `CHANGELOG.md`.** The koni-docs canonical location is
  `docs/CHANGELOG.md`; a root pointer file would be a second thing to keep in sync
  for no gain. README links it directly instead.
- **Did not claim a DX score.** `devex-review` is built around browse-testing a live
  product surface; this repo has none, so the skill supplied its principles rather
  than a scorecard. Inventing scores for untested dimensions is exactly what that
  skill forbids.

## Dev notes — References

- gstack `devex-review` — DX first principles, the untestable-dimension rule
- Anthropic `elements-of-style:writing-clearly-and-concisely` — prose standard
- [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct.html)
- CONTEXT D4 — the English decision and why the carve-out was removed

## Verification commands

```bash
./scripts/verify.sh
git ls-files | grep -c '^.github/'
```

## Changelog entry

```markdown
### Added
- Community health files, `.github/` templates, `scripts/verify.sh`, and CI.

### Changed
- English everywhere, enforced by CI. The koni-ea-ops Vietnamese carve-out is removed.
```

## Implementation notes

The verification script caught its own defect on first run. Its link checker flagged
two "broken links" that were `sed 's/^](//'` snippets inside fenced shell blocks in
the documentation — text that looks exactly like a markdown link and is not one.
Fixed by stripping fenced code blocks before extracting links. Worth recording
because the failure mode generalizes: a checker that reads documentation as data
will eventually read the documentation's examples as instructions.

The `SECURITY.md` threat model needed real thought rather than a template. This repo
ships no service, so the usual categories do not apply. What it does ship is MQL5
source other people run against real money, and skills that instruct AI agents inside
consumers' repositories — which puts malicious template logic, hidden order routing,
and skill prompt injection in scope, and puts a grey area around correctness bugs
whose consequence is financial rather than informational. That grey area is stated
explicitly, with a "report privately when unsure" default.

Lessons: §5 (a checker that reads documentation as data will read its examples as
instructions) — written from the link-checker defect above.

## Files modified

Added: `CODE_OF_CONDUCT.md`, `SECURITY.md`, `SUPPORT.md`, `.editorconfig`,
`scripts/verify.sh`, `.github/CODEOWNERS`, `.github/PULL_REQUEST_TEMPLATE.md`,
`.github/ISSUE_TEMPLATE/*.yml`, `.github/workflows/verify.yml`.
Rewritten: `templates/mql5/STARTER_EA/v1/v1.00/STARTER_EA_v1.00.md` (English),
`skills/koni-ea-ops/references/documentation.md` (language mandate + section names).
Updated: `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, `REPO_STRUCTURE.md`,
`docs/CONTEXT.md`, `docs/tests/findings.md`, `VERSION` → 0.3.0.
