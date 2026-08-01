---
id: US-1.2
title: "Relocate koni-ea-dev + koni-ea-ops from Koni-Skills"
epic: EPIC-1
status: done
priority: P1
points: 3
sprint: sprint-2026-W31
assignee: jindo9986
commit: 71ba0f8
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.1.0
---

# US-1.2 — Relocate koni-ea-dev + koni-ea-ops from Koni-Skills

## Goal

Make `koni-ea` the single source of truth for the two EA domain skills, so that a
consumer running `npx skills add Koniverse/Koni-ea --skill koni-ea-dev` gets a real
skill and there is no second copy anywhere to drift from it.

## Background

`koni-ea-dev` and `koni-ea-ops` were authored in `Koni-Skills` (EPIC-3,
US-3.11→US-3.16, FR-41/FR-42) because that repo is the Koniverse skill workshop.
Once `koni-ea` existed as the EA/bot *delivery* repo, the two skills sat in the
wrong place: authored in the library, consumed from the product.

The tempting shortcut — copy here, leave the originals — is the duplication that
Koniverse conventions name explicitly as the thing to avoid. Two copies drift and
no rule says which wins.

The alternative of symlinking from `Koni-Skills` fails the premise of this repo: a
customer installing from `koni-ea` must get a real skill, not a dangling link into
a checkout they do not have.

**Lessons applied:** none — LESSONS.md was empty at Frame. The dependency-scan
practice used here later became [LESSONS §1](../../LESSONS.md).

## Acceptance criteria

1. `skills/koni-ea-dev/` (8 files) and `skills/koni-ea-ops/` (6 files) exist in
   this repo, byte-identical to the originals.
2. Both are removed from `Koni-Skills`.
3. Every consumer points at the new location, with no dangling symlinks:
   `.agents/skills/`, `.claude/skills/`, and the two global
   `~/.claude/skills/koni-ea-*` links.
4. `Koni-Skills` forward-looking docs point here; its **history is untouched**.
5. Both repos record the decision — `koni-ea` D1, `Koni-Skills` D42.
6. `koni-docs validate` passes in both repos.

## Tasks

- [x] Inventory both skills; confirm `koni-agent-monitoring` is not EA-related
- [x] Scan every repo under `~/Documents/GitHub` for consumers of the two skills
- [x] Copy both skill directories into `skills/`
- [x] Grep the copies for path references back to `Koni-Skills` (none found)
- [x] Re-point `.agents/skills` → `../../skills/<s>`, keep the `.claude` hop
- [x] Re-point the two global `~/.claude/skills/koni-ea-*` symlinks
- [x] Verify byte-identical with `diff -r` **before** deleting the source
- [x] `git rm` both skills from `Koni-Skills`
- [x] Update `Koni-Skills` AGENTS.md — move the rows to a "Relocated skills" table
- [x] Annotate `Koni-Skills` PRD FR-41 / FR-42 as moved, without removing them
- [x] Write `Koni-Skills` CONTEXT D42 + CHANGELOG 0.68.0; bump its VERSION
- [x] Write `koni-ea` CONTEXT D1
- [x] Verify both repos: symlinks, validate

## Dev notes — Architecture constraints

- **Symlink direction changed.** `.agents/skills/koni-ea-dev` previously pointed at
  the `Koni-Skills` checkout; it now points at `../../skills/koni-ea-dev` — inside
  this repo. The `.claude` → `.agents` hop is unchanged.
- **`Koni-Skills` history is append-only.** EPIC-3, the six stories, and prior
  CHANGELOG entries are the record of work that really happened there. They were
  not rewritten. Only forward-looking pointers (AGENTS.md catalog, PRD status
  column) were updated.
- **No compatibility shim.** Anyone symlinking these two from a `Koni-Skills`
  checkout gets a broken link, deliberately — a link that fails loudly beats a stub
  that resolves to nothing.

## Dev notes — Cross-story dependencies

Depends on US-1.1 for the `.claude` / `.agents` wiring directories and the gate.
Blocks US-1.3, which documents and ships these skills publicly.

## Dev notes — What we did NOT do

- **Did not carry git history across repos.** `git format-patch`/`am` was
  considered and rejected: the relevant commits also touch unrelated `Koni-Skills`
  files, so the replay would be lossy. The history stays queryable in the repo where
  it happened.
- **Did not move `koni-agent-monitoring`.** Despite the name pattern it monitors
  Claude Code usage, not EAs.

## Dev notes — References

- `Koni-Skills` CONTEXT D42 (the other half of this decision), EPIC-3, FR-41, FR-42
- `koni-setup` `references/skill-wiring.md` §repair — the `ln -sfn` re-point idiom

## Verification commands

```bash
diff -r ../Koni-Skills/skills/koni-ea-dev skills/koni-ea-dev   # before deletion
for s in koni-ea-dev koni-ea-ops; do
  echo "$s -> $(cd "$(dirname .claude/skills/$s/SKILL.md)" && pwd -P)"
done
for s in .claude/skills/* .agents/skills/*; do
  [ -L "$s" ] && { [ -e "$s" ] || echo "DANGLING: $s"; }
done
npx @koniverse/koni-docs validate --docs-path docs/
```

## Changelog entry

```markdown
### Added
- **`skills/koni-ea-dev/`** and **`skills/koni-ea-ops/`** — relocated from
  `Koni-Skills` (its v0.68.0 / D42). This repo is now their single source of truth;
  there is no second copy. See CONTEXT.md D1 for why moving beat copying or
  symlinking.
```

## Implementation notes

The dependency scan was the load-bearing step. Before deleting anything, every repo
under `~/Documents/GitHub` was swept for consumers, which found exactly two: the
global `~/.claude/skills/koni-ea-*` symlinks and this repo's own wiring. That made
the delete safe and bounded the re-point work to four links.

`diff -r` ran before the `git rm`, not after — verifying the copy while the
original still existed is the only ordering where the check means anything.

A later change moved the repo from a personal account to the `Koniverse` org. The
`Koniverse/Koni-ea` URLs in D1 and D42 were corrected directly rather than via a
revision entry, because neither had been committed yet — append-only protects
committed history, and both were still drafts.

Lessons: none new — see US-1.3, which recorded the dependency-scan practice as
[LESSONS §1](../../LESSONS.md).

## Files modified

Added: `skills/koni-ea-dev/**` (8), `skills/koni-ea-ops/**` (6), `docs/CONTEXT.md`.
Re-pointed: 4 symlinks in `.agents/skills`, `.claude/skills`, `~/.claude/skills`.
In `Koni-Skills`: removed 14 files; updated `AGENTS.md`, `docs/PRD.md`,
`docs/CONTEXT.md`, `docs/CHANGELOG.md`, `VERSION`.
