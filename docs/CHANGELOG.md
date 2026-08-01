# Changelog

All notable changes to **koni-ea** are recorded here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **RULE-1 / RULE-2 (koni-docs)**: every shipping commit bumps `VERSION` AND adds
> an entry here in the same commit, with a real commit SHA — never `pending`. A
> commit's own SHA cannot be inside it, so it is backfilled by a follow-up commit,
> never `--amend`-ed in.

---

## [Unreleased]

(empty — track here while in dev but not yet shipped)

---

## [0.3.6] — 2026-08-02 — five gate checks were never running — v0.3.6

### Fixed
- **[F-7](tests/findings.md) — the commit gate was enforcing less than half of what it
  is configured to enforce.** `install-gate.sh` writes a pre-commit hook hardcoded to
  `--phase work-commit`, and nothing ever invokes `--phase release-commit`, so
  `story-lint`, `changelog-anchor`, `lesson-capture`, `design-first` and
  `koni-docs-validate` never fired on their own. They had been run by hand during
  setup, which is exactly why nobody noticed.

  `story-lint` and `changelog-anchor` are stateless, so they now run inside
  `scripts/verify.sh` where CI executes them on every push and pull request. The local
  hook now invokes both phases.

  **Still open**: `lesson-capture` and `design-first` read `git diff --cached`, so they
  only work in a hook — and hooks are not committed. A fresh clone still gets neither,
  even after `install-gate.sh`. The durable fix belongs upstream in `Koni-Skills`.

### Added
- **[LESSONS §9](LESSONS.md)** — do not document a channel until you have opened it.
  `SECURITY.md` routed vulnerability reports to a URL that returned 404 for five
  versions, and `CODE_OF_CONDUCT.md` joined it in 0.3.4 when the last contact email
  was removed. A documented channel is a promise, not a claim: a wrong claim is found
  by anyone who checks, a broken channel is found only by someone already in trouble.

---

## [0.3.5] — 2026-08-02 — the repository is public and the security channel works — v0.3.5

### Changed
- **The repository is public.** `Koniverse/Koni-ea` was private through 0.3.4; every
  document written since 0.2.0 was written for this moment.

### Fixed
- **[F-6](tests/findings.md) closed — `/security/advisories/new` no longer 404s.**
  Private vulnerability reporting is a public-repository feature, so it could not be
  enabled while the repo was private and the API returned a bare `404` rather than an
  explanation. Publishing made it available; it is now enabled
  (`{"enabled":true}`). The form returns a sign-in redirect that resolves back to
  itself, and `/security`, `/security/policy`, `/discussions`, `/issues` and the three
  community-health files all resolve.

  This was the only documented channel for **both** security and conduct reports, so
  until now the private-report path in `SECURITY.md` and `CODE_OF_CONDUCT.md` did not
  work. It does now.

### Pre-publication sweep
Publishing is a one-way door — clones and forks outlive any later change of mind — so
the tree was checked before flipping: 100 tracked files, all text, no binaries or
archives, no credentials, personal paths, or personal email addresses in tracked
content. The only `password` matches are the instructions telling reporters *not* to
paste one. The gitleaks history scan had passed in CI on `f98eacc`.

### Accepted on publication
Both were known and taken deliberately rather than discovered afterwards:
- **Commit author metadata is now public.** All commits are authored under a personal
  address. Rewriting history to change it would invalidate every SHA recorded under
  RULE-2 in the stories and CHANGELOG.
- **The template still has not been compiled** ([F-1](tests/findings.md) → F-3).
  Every document that mentions it says so.

---

## [0.3.4] — 2026-08-02 — no contact email; everything routes through GitHub — v0.3.4

Partner and user communication moves entirely onto GitHub: issues, discussions, pull
requests, and private advisories. No published address ([D6](CONTEXT.md)).

### Removed
- **Every contact email.** A published address is harvested for spam within days of a
  repository going public and gives a reporter no confirmation that a human read the
  message. It is also the wrong shape for a partner channel: an inbox is invisible to
  everyone except the two people in it, so the same questions get answered privately,
  over and over.

### Changed
- **`SUPPORT.md` is now a routing table.** Question or idea → Discussions. Defect →
  Issue. Change you already wrote → pull request. Security → private advisory.
  Conduct → private advisory titled `Code of Conduct`. Each row states why that
  channel and not another.
- **`SECURITY.md`** routes exclusively to
  [GitHub private security advisories](https://github.com/Koniverse/Koni-ea/security/advisories/new).
- **`CODE_OF_CONDUCT.md`** routes conduct reports to the same private advisory form,
  and additionally to GitHub's own abuse reporting — a route that works even when a
  maintainer is the subject of the report. A public issue is explicitly the wrong
  venue for both: it exposes a reporter to the person they are reporting.
- **Added a partner section** to `SUPPORT.md` explaining what a public issue buys
  that a private message cannot — a record attached to the change, one answer serving
  every partner, and a visible status.

### Fixed
- **GitHub Discussions enabled on the repository.** `SUPPORT.md` and the issue
  templates had linked to it since 0.3.0; the feature was off, so every one of those
  links was a 404.

### Redacted
- Three mentions of an address inside `docs/CHANGELOG.md` and `docs/LESSONS.md` —
  append-only files — were removed **with a visible marker** naming the date and
  pointing at [D6](CONTEXT.md). A narrow, deliberate exception to RULE-7: append-only
  protects reasoning from quiet revision, and a redaction that announces itself
  preserves that contract while removing a personal identifier from a public file.
  Silent redaction would have been the violation.

### Known gap
- **[F-6](tests/findings.md)** — private vulnerability reporting is a
  public-repository feature and returns 404 while this repo is private. The documented
  security and conduct channel will not work until it is enabled, which makes enabling
  it a **publication step**, not a backlog item.

---

## [0.3.3] — 2026-08-02 — the public contact address is organizational, not personal — v0.3.3

### Fixed
- **`CODE_OF_CONDUCT.md` and `SECURITY.md` listed the operator's personal email** as
  the project's contact point for conduct complaints and private security reports.
  The address came from the working session's ambient context and was never
  authorized for publication. Replaced with an organizational address —
  itself removed in 0.3.4, which drops every contact email in favour of GitHub
  issues and private advisories. *(Address redacted 2026-08-02; see D6.)*

Recorded as [LESSONS §8](LESSONS.md) — context an agent is given is not content it may
publish. The value was correct and already at hand, which is exactly what made it read
as a lookup rather than as the publishing decision it was.

### Known gap
- **Commit author metadata still carries a personal email.** All commits to date were
  authored under a personal address *(redacted 2026-08-02; see D6)*. Editing a file
  cannot change this; it lives in
  each commit object. Changing it for existing commits means rewriting history, which
  would invalidate every SHA recorded under RULE-2 in the story files and CHANGELOG.
  Left for an explicit decision rather than actioned unilaterally.

---

## [0.3.2] — 2026-08-02 — the verification script actually runs now — v0.3.2

The first CI run failed on a check that had passed locally every time. `verify.sh`
promised "a green run here is a green run there" and was not delivering it.

### Fixed
- **The English-only check was a no-op on the author's machine.** It used `grep -lP`;
  a shell function shadowing `grep` routed to a different implementation with
  different flags, matched nothing, and reported success. Rewritten in `perl -CSD`,
  which has identical regex and UTF-8 semantics on macOS and Linux. The check now
  **fails loudly** when its interpreter is missing instead of passing quietly, and it
  has been proven to catch Vietnamese text rather than merely assumed to.
- **The character class was a blocklist and too broad.** It flagged
  `Σ(open·vol)/Σvol` — mathematical notation — as non-English. Replaced with an
  allowlist of the typography, math, arrow, box-drawing and emoji ranges this repo
  legitimately uses. Every new exception is now a visible decision.
- **The check is scoped to authored content.** `.koni-harness/` is vendored by
  `install-gate.sh` and overwritten on every reinstall; its one Vietnamese comment is
  upstream's to fix, and flagging it produced a failure no contributor here could act
  on.
- **The gitleaks job required a paid license.** `gitleaks-action` is licensed per
  organization and failed with "missing gitleaks license"; this repo is
  org-owned. The gitleaks **CLI** is MIT, so CI now installs a pinned binary and runs
  it directly.

- **The secret scan flagged a content hash as a credential.** `_bmad/_config/files-manifest.csv`
  carries a `hash` column of SHA-256 digests, one per installed BMAD file; a
  64-character hex string has the entropy of a credential and none of the context
  that distinguishes it. Added `.gitleaks.toml` with an allowlist scoped to the three
  manifest files — not to `_bmad/` as a whole, so a real credential landing elsewhere
  under that tree is still caught. The allowlist states why it exists so a future
  reader can re-evaluate it rather than trust it blindly.

Recorded as [LESSONS §7](LESSONS.md) — a check that depends on ambient tooling fails
open, reporting success while doing nothing, and grows more trusted the longer it
does so.

---

## [0.3.1] — 2026-08-02 — repository renamed to `Koniverse/Koni-ea` — v0.3.1

### Changed
- Every documented `git clone` and `npx skills add` path updated to the canonical
  `Koniverse/Koni-ea`, across README, CONTRIBUTING, SUPPORT, SECURITY, SETUP,
  AGENTS.md, the template README, and the `.github/` templates. The git remote was
  re-pointed.

### Deliberately not changed
- **The two quoted commands inside committed decision entries D1 and D4.** They are
  append-only history and now read as they did when written. GitHub's rename
  redirect keeps them working. See [D5](CONTEXT.md) — a working-tree `sed` had
  already rewritten them and was reverted on diff review.

---

## [0.3.0] — 2026-08-02 — open-source standard: community health files, CI, English everywhere — v0.3.0

Brings the repository up to what a contributor expects from a credible open-source
project, and removes the last non-English content
([US-1.4](sprints/stories/US-1.4-open-source-standard.md), [D4](CONTEXT.md)).

### Added
- **Community health files** — `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1, plus
  two trading-specific standards: no profitability claims, no soliciting funds or
  account access), `SECURITY.md` (a threat model for a repo that ships trading code
  rather than a service — malicious template logic, hidden order routing, skill
  prompt injection, and the grey area where a correctness bug costs money), and
  `SUPPORT.md`.
- **`.github/`** — issue templates for bugs and features, a pull request template
  carrying the full correctness checklist, `CODEOWNERS`, and `workflows/verify.yml`.
- **`scripts/verify.sh`** — one command that runs every automatable check:
  English-only text, internal link resolution, template version identity,
  indicator-handle create/release parity, closed-bar reads, committed binaries, and
  the VERSION/CHANGELOG pairing. CI calls the same script, so a green local run is a
  green CI run.
- **`.editorconfig`** — MetaEditor's 3-space/CRLF convention for `.mq5` and `.set`,
  2-space/LF elsewhere.

### Changed
- **English everywhere, enforced.** `STARTER_EA_v1.00.md` translated;
  `skills/koni-ea-ops/references/documentation.md` rewritten to mandate English,
  including its prescribed section names. **This changes what downstream consumers
  of the skill are told to do** — the prior revision preferred Vietnamese, which
  cannot survive a standard being published to partners who do not read it.
- README, CONTRIBUTING, AGENTS.md and REPO_STRUCTURE.md updated for the new files
  and the language rule.

### Fixed
- **The `tests` pre-push gate is disabled** ([D3](CONTEXT.md)). The vendored default
  runs `npm test`, which assumes a code profile; this is a content repo with no
  `package.json`, so every push failed with `ENOENT`. Commented out with the reason
  in place rather than deleted — a gate that fails on every push trains people to
  reach for `--no-verify`, which disables credential scanning too.
- **[F-4](tests/findings.md) closed** — link checking is now automated. It found two
  real defects on its first run: `sed` snippets inside fenced code blocks being
  parsed as markdown links.

### Known gaps
- The template still has never been compiled, run, or backtested
  ([F-1 → F-3](tests/findings.md)). CI deliberately does not fake this — MetaEditor
  is Windows-only, and both the workflow and `verify.sh` say so in place.

---

## [0.2.0] — 2026-08-02 — public release format: a real template, a license, an agent entry point — v0.2.0

The repo becomes a public product a Senti partner can inherit. Scope narrowed to
MQL5, a working template shipped, and the entry-point documents restructured so an
AI agent reads them and follows the pattern without guessing
([US-1.3](sprints/stories/US-1.3-public-release-format.md), [D2](CONTEXT.md)).

### Added
- **`templates/mql5/STARTER_EA/`** — the reference EA skeleton. Implements the full
  koni-ea-dev chassis (lifecycle, closed-bar signal gate with peek-then-commit
  new-bar detection, risk-% sizing with the sub-min-lot skip, SL/TP clamped to
  `SYMBOL_TRADE_STOPS_LEVEL`, latched equity breaker, daily loss limit, post-stop-out
  cooldown, margin **pre**-check, restart recovery via GlobalVariables,
  magic-filtered position queries) with exactly one placeholder `Signal()` marked
  `>>> REPLACE THIS <<<`. Ships `.mq5` + `.set` + Vietnamese per-version `.md` in the
  koni-ea-ops `<ALGO>/v<major>/v<X.YY>/` layout, plus a 6-step README and a
  pre-flight checklist.
- **`LICENSE`** (MIT) and **`CONTRIBUTING.md`** — a public repo states its terms and
  its correctness bar rather than implying them.
- **`docs/BRIEF.md`, `docs/SETUP.md`, `docs/README.md`, `docs/LESSONS.md`** and the
  full `docs/tests/` surface — real content replacing the bootstrap stubs.
- **[EPIC-1](sprints/epics/EPIC-1.md) + US-1.1/1.2/1.3 + [sprint-2026-W31](sprints/sprint-2026-W31.md)** —
  the work recorded to the koni-docs agile schema.

### Changed
- **`AGENTS.md` rewritten as an agent entry point.** Opens with the build-a-bot
  workflow (6 ordered steps with file pointers), then a rules table pairing each
  non-negotiable with what goes wrong without it.
- **`README.md` and `REPO_STRUCTURE.md`** rewritten for a public audience.
- **Templates scoped to MQL5.** Removed the empty `mql4/`, `python/`, `pine/` and
  `js/` directories. Senti's upload path accepts `.ex5` + `.set`, so MQL5 is the only
  platform with a working route to deployment; an empty directory promising a
  template that does not exist reads as "supported" and is worse than none.

### Removed
- **`.claude/skills/` and `.agents/skills/` are no longer tracked.** They hold ~500
  vendored BMAD skill files — dev tooling, not product. Committing them would
  republish third-party content under this repo's MIT license and bury the ~20 files
  that are the deliverable. **563 tracked files → 83.** Restore path:
  [SETUP §6](SETUP.md#6-setting-up-to-contribute); using the templates needs none of it.

### Known gaps
- **The template has never been compiled, run, or backtested.** MetaEditor is
  Windows-only and this work ran on macOS. Tracked as
  [F-1 → F-3](tests/findings.md); stated in `AGENTS.md` and
  [LESSONS §2](LESSONS.md) so no reader assumes otherwise.

---

## [0.1.0] — 2026-08-02 — repo bootstrap + EA skills relocated — v0.1.0

> **Note on history**: `0.1.0` and `0.2.0` were both produced on 2026-08-02 and land
> in the **initial commit** — this repo had no prior commits, so there is no separate
> `0.1.0` SHA to point at. The two sections are kept apart because they record
> genuinely different work ([US-1.1](sprints/stories/US-1.1-repo-bootstrap.md) +
> [US-1.2](sprints/stories/US-1.2-relocate-ea-skills.md) vs US-1.3), not because they
> shipped separately.

### Added
- **Repo bootstrapped** to the Koniverse content-profile standard via `koni-setup`:
  the `docs/` surface (BRIEF / SETUP / CONTEXT / LESSONS / CHANGELOG / README,
  `sprints/`, `tests/`, `design/`), `VERSION`, `AGENTS.md` as the canonical agent
  guide, `CLAUDE.md` as a thin pointer + Koni-Docs Integration block,
  `REPO_STRUCTURE.md`, Active Context Pattern B, and `skills-lock.json`.
- **`skills/koni-ea-dev/`** and **`skills/koni-ea-ops/`** — relocated from
  `Koni-Skills` (its v0.68.0 / D42). This repo is now their single source of truth;
  there is no second copy. See [CONTEXT.md D1](CONTEXT.md) for why moving beat
  copying or symlinking.
- **Skill wiring** — the core trio (`koni-docs`, `koni-harness`, `koni-qc`) plus
  `koni-setup` symlinked from the shared `Koni-Skills` checkout; the two EA skills
  wired to the local `skills/` copy. BMAD pack (46 skills) installed for
  claude-code, codex, cursor, and gemini.
- **koni-harness gate** vendored at `.koni-harness/` with chained pre-commit and
  pre-push hooks.
