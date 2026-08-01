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
