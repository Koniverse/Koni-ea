---
id: US-1.3
title: "Format for public release — template, license, agent entry point"
epic: EPIC-1
status: done
priority: P1
points: 8
sprint: sprint-2026-W31
assignee: jindo9986
commit: 71ba0f8
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.2.0
---

# US-1.3 — Format for public release — template, license, agent entry point

## Goal

Turn a correctly-scaffolded private repo into a public product a Senti partner can
inherit: ship a real MQL5 template, state the license and the contribution bar, and
structure every entry-point document so an AI agent reads it and follows the
pattern without guessing.

## Background

After US-1.1 and US-1.2 the repo was structurally correct but not yet *useful*:
`templates/` held five empty platform directories, `docs/` held bootstrap stubs,
and there was no license. The owner then set the goal — a public repo that partners
and Senti users inherit to build bots quickly, formatted so an AI can follow the
template easily.

Three facts had to be established from source rather than assumed, because each one
changes the deliverable:

1. **Senti's contract.** Custom bot upload (`.ex5` + `.set`, `accessScope=private`)
   is shipped and live. Partners can deploy today, so MQL5 has a real route.
2. **The crypto path is not open.** The crypto bot framework is backlog, so a
   Python/ccxt template would target an unsettled contract.
3. **`Trading-Resources` is proprietary.** 14 live Koni strategies, ~21.7k lines,
   in a private org repo. None of it can go into a public MIT repo.

Together these forced the scope: MQL5 only, and a template that teaches structure
rather than shipping strategy IP.

**Lessons applied:** none at Frame — LESSONS.md was empty. This story wrote the
first three entries.

## Acceptance criteria

1. `templates/mql5/STARTER_EA/` ships four artifacts in the koni-ea-ops
   `<ALGO>/v<major>/v<X.YY>/` layout: `.mq5`, `.set`, Vietnamese `.md`, `backtest/`.
2. The `.mq5` implements the full koni-ea-dev chassis with exactly one placeholder
   marked `>>> REPLACE THIS <<<`.
3. The template is documented as having no edge, in the source header, the
   per-version doc, the template README, and the root README.
4. Platform directories with no route to Senti are removed.
5. `AGENTS.md` opens with an ordered build-a-bot workflow and a rules table pairing
   each rule with its failure mode.
6. `LICENSE` (MIT) and `CONTRIBUTING.md` with a correctness checklist exist.
7. `docs/BRIEF.md`, `docs/SETUP.md`, `docs/README.md` hold real content.
8. No vendored third-party skill content and no secrets are tracked.
9. Every internal markdown link resolves; `koni-docs validate` passes.

## Tasks

- [x] Read the Senti bot-upload contract from source; confirm FR-85 shipped
- [x] Confirm `Trading-Resources` is proprietary and must not be copied
- [x] Confirm scope with the owner: platforms, template depth, license
- [x] Remove `mql4/`, `python/`, `pine/`, `js/`
- [x] Write `STARTER_EA_v1.00.mq5` to the koni-ea-dev standard
- [x] Write `STARTER_EA_v1.00.set` matching the input declarations
- [x] Write `STARTER_EA_v1.00.md` — the 8-section Vietnamese per-version doc
- [x] Write the template README (6-step loop + pre-flight checklist) and `templates/README.md`
- [x] Add `LICENSE` (MIT) and `CONTRIBUTING.md`
- [x] Rewrite `AGENTS.md` as the agent entry point
- [x] Rewrite root `README.md` and `REPO_STRUCTURE.md` for a public audience
- [x] Write `docs/BRIEF.md`, `docs/SETUP.md`, `docs/README.md`
- [x] Scan for secrets and absolute local paths
- [x] Gitignore the consumed toolchain; document the restore path in SETUP §6
- [x] Update all org references after the move to `Koniverse`
- [x] Verify: link resolution, version identity, handle parity, validate

## Dev notes — Architecture constraints

- **The template is a delivered artifact, not a build target.** This repo cannot
  compile it. `.ex5` is gitignored so what ships is always reproducible from what
  was committed.
- **Version identity is triple-stated** — `#property version`, the folder, and all
  three basenames must agree on `X.YY`.
- **Owned vs consumed directories.** `skills/` is the product; `.claude/skills/`
  and `.agents/skills/` are tooling and are now gitignored. The distinction is
  stated in AGENTS.md and REPO_STRUCTURE.md because it is the most likely mistake
  in a repo that both ships and consumes skills.

## Dev notes — Cross-story dependencies

Depends on US-1.1 (doc tree, gate) and US-1.2 (the skills this repo documents and
ships). Closes EPIC-1.

## Dev notes — What we did NOT do

- **Did not ship a working strategy.** A plausible-looking one would be read as an
  endorsed profitable bot by exactly the audience least able to evaluate it.
- **Did not verify the compile.** MetaEditor is Windows-only and this work ran on
  macOS. Recorded as an explicit gap in AGENTS.md rather than glossed —
  [LESSONS §2](../../LESSONS.md).
- **Did not keep empty platform directories as placeholders.** An empty directory
  promising a template reads as "supported" to both a human skimming and an agent
  planning.
- **Did not add CI.** The one check worth automating needs a Windows runner.

## Dev notes — References

- `skills/koni-ea-dev/` — `ea-lifecycle.md`, `trading-mechanics.md`,
  `risk-management.md`, `inputs-and-naming.md`, `mql5-pitfalls.md`
- `skills/koni-ea-ops/` — `versioning.md` (folder layout), `documentation.md`
  (the 8-section per-version doc)
- CONTEXT D2 — the three scope cuts and their rationale

## Verification commands

```bash
# internal links resolve
for f in README.md AGENTS.md CONTRIBUTING.md REPO_STRUCTURE.md docs/*.md; do
  d=$(dirname "$f"); grep -oE '\]\([^)#]+\)' "$f" | sed 's/^](//;s/)$//' \
    | grep -v '^http' | while read -r l; do [ -e "$d/$l" ] || echo "BROKEN $f -> $l"; done
done
# template self-consistency
grep -o '#property version *"[0-9.]*"' templates/mql5/STARTER_EA/v1/v1.00/STARTER_EA_v1.00.mq5
grep -c 'IndicatorRelease' templates/mql5/STARTER_EA/v1/v1.00/STARTER_EA_v1.00.mq5   # must equal handles created
npx @koniverse/koni-docs validate --docs-path docs/
```

## Changelog entry

```markdown
### Added
- **`templates/mql5/STARTER_EA/`** — the reference EA skeleton implementing the full
  koni-ea-dev chassis with one placeholder `Signal()`.
- **`LICENSE`** (MIT) and **`CONTRIBUTING.md`**.
- **`docs/BRIEF.md`, `docs/SETUP.md`, `docs/README.md`** — real content.

### Changed
- **`AGENTS.md` rewritten as an agent entry point** — build-a-bot workflow first,
  then a rules table pairing each rule with its failure mode.
- **Templates scoped to MQL5** — removed four platform directories with no route to Senti.

### Removed
- **`.claude/skills/` and `.agents/skills/` no longer tracked** — ~500 vendored BMAD
  files. 563 tracked files → 83.
```

## Implementation notes

The scope cuts came out of reading source rather than reasoning from the brief.
Checking Senti's PRD showed custom-bot upload shipped at v0.2.18 — which is what
made "MQL5 only" safe rather than merely convenient, because it confirmed partners
have a live route today.

Gitignoring the consumed toolchain was not in the original ask. It surfaced from
counting what would actually be committed: 563 files, ~500 of them vendored BMAD
skills. For a public repo whose value is that an agent can read it, that ratio
defeats the goal, and it would have republished third-party content under this
repo's MIT license.

Lessons: §1 (scan for consumers before moving a shared artifact), §2 (never claim a
compile you cannot run), §3 (count what a public repo actually commits).

## Files modified

Added: `templates/mql5/STARTER_EA/**` (5), `templates/README.md`, `LICENSE`,
`CONTRIBUTING.md`, `docs/LESSONS.md`.
Rewritten: `AGENTS.md`, `README.md`, `REPO_STRUCTURE.md`, `docs/BRIEF.md`,
`docs/SETUP.md`, `docs/README.md`, `docs/CHANGELOG.md`.
Removed: `templates/{mql4,python,pine,js}/`.
Updated: `.gitignore`, `VERSION` → 0.2.0, `docs/CONTEXT.md` (D2).
