# CONTEXT.md — koni-ea Decision Log

> Append-only (RULE-7). Never rewrite a past decision; record a revision entry
> that references the original by ID. Future-you reads this when wondering
> "why did we pick X over Y" — silently editing history breaks that contract.

---

## Phase 0 — Repo bootstrap (2026-08-02)

### D1. The EA skills live here, not in `Koni-Skills` — and there is only one copy

**Context**: `koni-ea-dev` and `koni-ea-ops` were built in `Koni-Skills`
(EPIC-3, US-3.11→US-3.16, FR-41/FR-42) because that is the Koniverse skill
workshop. This repo was then bootstrapped as the **delivery** repo for the EA/bot
domain — the place partners, customers, and end users install from. That split
the two roles across two repos: authored in the library, consumed from the
product. The tempting shortcut was to copy the skills here and leave the
originals in place.

**Decision**: Move them. `skills/koni-ea-dev/` and `skills/koni-ea-ops/` are
owned here and deleted from `Koni-Skills`. This repo is now their single source
of truth. `Koni-Skills` keeps the skills that are *infrastructure for building
anything* (koni-docs, koni-harness, koni-qc, koni-setup, koni-nextjs,
koni-agent-monitoring); this repo owns the skills that are *a domain
deliverable*. Their development history stays in `Koni-Skills` — the six stories,
EPIC-3, and the CHANGELOG entries are the record of what actually happened there
and are not replayed here.

**Rationale**: Copying to both repos was the alternative, and it fails the way
duplicated content always fails — two copies drift and no rule says which wins.
Koniverse conventions already name this the anti-pattern to avoid (koni-setup:
"never re-implement … that duplication is exactly what we are avoiding").
Symlinking from `Koni-Skills` instead of moving was the other option, and it
breaks the premise of this repo: a customer running
`npx skills add Koniverse/koni-ea --skill koni-ea-dev` must get a real skill, not
a dangling link into a checkout they do not have.

Verified rather than assumed: `diff -r` confirmed both copies byte-identical
before the source was deleted, and a dependency scan across `~/Documents/GitHub`
found exactly two consumers — the global `~/.claude/skills/koni-ea-{dev,ops}`
symlinks and this repo's own wiring — both re-pointed at `skills/`.

**Impact**: 14 files added under `skills/`; `.agents/skills/koni-ea-{dev,ops}`
now resolve to `../../skills/…` instead of the `Koni-Skills` checkout. Anyone who
symlinked these two from `Koni-Skills` must re-point at a `koni-ea` checkout.
`Koni-Skills` records the other half of this decision as its D42 (v0.68.0).

**Date**: 2026-08-02
**Version**: 0.1.0
**Reference**: `Koni-Skills` D42, EPIC-3, FR-41, FR-42.

---

### D2. The repo goes public — scope narrows to MQL5 and the toolchain leaves git

**Context**: The repo was bootstrapped with five platform directories (`mql5`,
`mql4`, `python`, `pine`, `js`) and a full vendored toolchain committed — 563 files,
of which ~500 were BMAD skills. Then the goal sharpened: this becomes a **public**
repo that Senti partners and users inherit to build bots quickly, and the measure of
success is that an AI agent can read it and follow the template without guesswork.
Those two facts invalidate several bootstrap defaults at once.

**Decision**: Three cuts, all in service of signal-to-noise.

1. **MQL5 only.** Deleted `mql4/`, `python/`, `pine/`, `js/`. Senti's upload path
   accepts a compiled `.ex5` + `.set`, so MQL5 is the one language with a working
   route from editor to live deployment. The other four had no route and no content.
2. **The consumed toolchain leaves git.** `.claude/skills/` and `.agents/skills/`
   are gitignored. `skills/` (owned, published) and `templates/` stay. 563 files → 83.
3. **A real template, not an empty directory.** `templates/mql5/STARTER_EA/` ships
   the full koni-ea-dev chassis with one placeholder `Signal()` marked
   `>>> REPLACE THIS <<<`, plus its `.set`, its Vietnamese per-version doc, and the
   koni-ea-ops `v<major>/v<X.YY>/` layout.

**Rationale**: An empty directory promising a template that does not exist is worse
than no directory — it reads as "supported" to both a human skimming and an agent
planning. Same logic for the toolchain: committing ~500 BMAD skill files would
republish third-party content under this repo's MIT LICENSE and bury the twenty
files that are actually the product. Nothing about *using* a template requires the
toolchain, so the cost of gitignoring it falls only on contributors, who have a
documented restore path (SETUP §6).

The template's strategy is deliberately naive and labelled as having no edge. The
alternative — shipping a plausible-looking strategy — would be read as an endorsed,
profitable bot by exactly the audience least able to evaluate it. A template's job
is to be *correct*, not *lucrative*; conflating the two is how people lose money.

Verified rather than assumed: the Senti contract was read from source, not assumed
— custom bot upload (`.ex5` + `.set`, private scope) is shipped and live, which is
what makes the MQL5-only cut safe. A credential and local-path scan over the working
tree returned no true positives.

**Impact**: 4 directories deleted; `templates/mql5/STARTER_EA/` added (4 artifacts +
README); `LICENSE` (MIT) and `CONTRIBUTING.md` added; `AGENTS.md` rewritten as an
agent entry point leading with the build-a-bot workflow; `README.md`, `REPO_STRUCTURE.md`,
`docs/{BRIEF,SETUP,README}.md` written for a public audience. Contributors on an
existing clone keep their `.claude/skills/` working — the gitignore only stops it
being tracked.

**Date**: 2026-08-02
**Version**: 0.2.0
**Reference**: [D1](#d1-the-ea-skills-live-here-not-in-koni-skills--and-there-is-only-one-copy), `koni-ea-dev`, `koni-ea-ops`.
