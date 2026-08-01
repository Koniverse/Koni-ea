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
