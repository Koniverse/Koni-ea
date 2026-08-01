---
id: US-1.1
title: "Bootstrap the repo to the Koniverse standard"
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

# US-1.1 — Bootstrap the repo to the Koniverse standard

## Goal

Take an empty `koni-ea` git repo to the Koniverse content-profile standard — doc
tree, skill wiring, commit gate, agent integration surface — so that every
subsequent story lands in a repo that already enforces its own conventions.

## Background

`koni-ea` existed as an initialised git repo with no commits and no files. The
Koniverse standard for a new repo is codified in the `koni-setup` skill, which was
not installed on this machine; it lives in the shared `Koni-Skills` checkout
alongside `koni-qc`.

Profile choice matters here and was confirmed with the owner rather than inferred:
**content**, not code. The repo distributes markdown skills and MQL5 source as
*delivered artifacts*; it has no application of its own and therefore no
`package.json`, no `agile:*` npm aliases, and no `PRD.md` / `ARCHITECTURE.md`.
`REPO_STRUCTURE.md` carries the organizational conventions instead.

**Lessons applied:** none — LESSONS.md was empty at Frame; this repo had no prior
history to learn from. The first entries were written by US-1.3.

## Acceptance criteria

1. `koni-setup` and `koni-qc` are installed and invocable.
2. The content-profile doc tree exists: `docs/` with BRIEF / SETUP / CONTEXT /
   LESSONS / CHANGELOG / README, `sprints/` (README, STATUS, epics, stories,
   archive), `tests/` per the koni-qc test-organization standard, `design/`.
3. `VERSION` holds bare semver `0.1.0`.
4. The Koniverse core trio (`koni-docs`, `koni-harness`, `koni-qc`) is wired into
   both `.claude/skills/` and `.agents/skills/`, with no dangling symlinks.
5. The koni-harness gate is vendored at `.koni-harness/` with chained pre-commit
   and pre-push hooks.
6. The BMAD pack is installed.
7. `AGENTS.md` is canonical; `CLAUDE.md` is a thin pointer carrying the Koni-Docs
   Integration config block.
8. Active Context Pattern B: `.active-context.example.md` committed,
   `.active-context.md` gitignored.
9. `koni-docs validate` passes.

## Tasks

- [x] Pull the shared `Koni-Skills` checkout (was 6 commits behind)
- [x] Install `koni-setup` + `koni-qc` as global symlinks, matching the existing convention
- [x] Confirm scope with the owner: profile, distribution model, platforms, context pattern
- [x] Create the content-profile directory skeleton + `VERSION`
- [x] Add the `skills/` and `templates/` domain directories
- [x] Write `.gitignore` (baseline + MQL5 and Python artifacts)
- [x] Wire the core trio + `koni-setup` into `.claude/skills` and `.agents/skills`
- [x] Run `install-gate.sh` to vendor `.koni-harness/` and chain the git hooks
- [x] Install the BMAD pack non-interactively for claude-code, codex, cursor, gemini
- [x] Write `CLAUDE.md` + `AGENTS.md` from the koni-docs integration template
- [x] Copy `.active-context.example.md`; confirm `.active-context.md` is ignored
- [x] Write `REPO_STRUCTURE.md`, root `README.md`, `skills-lock.json`
- [x] Run the koni-setup §4 verification

## Dev notes — Architecture constraints

- **Content profile means no `package.json`.** The koni-docs CLI is invoked
  directly (`npx @koniverse/koni-docs …`), not through `agile:*` aliases. Any
  instruction that assumes npm scripts does not apply to this repo.
- **Skill wiring is a two-hop chain**: `.claude/skills/<s>` → `../../.agents/skills/<s>`
  → the real directory. One physical copy serves every agent tool.
- **The gate installs after the doc tree and VERSION exist** — its version-phase,
  changelog-anchor and validate checks read them.

## Dev notes — What we did NOT do

- No `PRD.md` or `ARCHITECTURE.md` — deliberate for a content profile, and recorded
  in `AGENTS.md` and `docs/README.md` so their absence reads as a decision rather
  than an omission.
- No CI. There is nothing to build, and the one thing worth automating (MQL5
  compile) needs a Windows host.

## Dev notes — References

- `koni-setup` skill — §2 bootstrap workflow, `references/scaffold-checklist.md`,
  `references/skill-wiring.md`, `references/skill-inventory.md`
- `koni-docs` skill — `references/templates/integration.md`
- Reference repos for the content profile: `koni-growth`, `koni-training`

## Verification commands

```bash
test -f VERSION && cat VERSION
for s in koni-docs koni-harness koni-qc; do test -e ".claude/skills/$s" || echo "$s not wired"; done
test -f .koni-harness/gate-runner.sh || echo "gate missing"
find .claude/skills -maxdepth 1 -name 'bmad-*' | wc -l          # expect ~46
npx @koniverse/koni-docs validate --docs-path docs/
```

## Changelog entry

```markdown
### Added
- **Repo bootstrapped** to the Koniverse content-profile standard via `koni-setup`:
  `docs/` surface, `VERSION`, `AGENTS.md` canonical + `CLAUDE.md` pointer,
  `REPO_STRUCTURE.md`, Active Context Pattern B, `skills-lock.json`.
- **Skill wiring** — core trio symlinked from the shared `Koni-Skills` checkout;
  BMAD pack (46 skills) for claude-code, codex, cursor, gemini.
- **koni-harness gate** vendored at `.koni-harness/` with chained git hooks.
```

## Implementation notes

The BMAD installer is interactive by default. It was driven non-interactively with
`--yes --modules bmm --tools claude-code,codex,cursor,gemini`, discovered via
`--help` and `--list-tools` rather than assumed.

The installer writes into `.claude/skills/` and `.agents/skills/` — the same
directories holding the freshly-created Koni symlinks. It proved additive: all six
symlinks survived, verified by an explicit post-install dangling scan rather than
by assuming.

Lessons: none new — the bootstrap followed the koni-setup skill without surprises.

## Files modified

Created: `VERSION`, `.gitignore`, `CLAUDE.md`, `AGENTS.md`, `REPO_STRUCTURE.md`,
`README.md`, `skills-lock.json`, `.active-context.example.md`, the `docs/` tree,
`skills/`, `templates/`, `.koni-harness/`, `_bmad/`.
