---
id: US-2.3
title: "Make the published skills usable outside Koniverse"
epic: EPIC-2
status: done
priority: P1
points: 5
sprint: sprint-2026-W31
assignee: jindo9986
commit: be20ed4
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.4.0
---

# US-2.3 — Make the published skills usable outside Koniverse

## Goal

Make `koni-ea-dev` and `koni-ea-ops` work for someone who installs them with
`npx skills add` and has none of Koniverse's infrastructure.

## Background

Both skills were authored inside `Koni-Skills` for readers on the team. Published,
their audience changed and three defects appeared — all the same shape.

The worst was **unfollowable**. `registry-and-magic.md` stated a hard rule: *"Notion
assigns it — never hand-pick one."* A partner has no Notion table. The rule tells them
to obtain a number from a system they cannot reach and, in the same sentence, forbids
the only action available to them. An agent reading it stalls or violates it.

Neither skill mentioned the **template** — this repo's entire "copy it, replace one
function" proposition. `AGENTS.md` carries that instruction and does not travel with
`npx skills add`.

Both cited **private repositories** as authority, including a `CONTEXT D9` an outside
agent may waste a turn trying to fetch.

The review used the Anthropic skill-authoring guide and koni-qc's four grading
dimensions. The mechanical side was already clean: 12/12 references carry a TOC, 0
dangling links, both descriptions third-person trigger-form and mutually
discriminating.

**Lessons applied:** §2 (never report a verification you could not run) — no grade is
claimed here, because the rubric requires four independent graders and this was one.

## Acceptance criteria

1. No rule instructs a reader to use infrastructure they cannot have without a
   portable equivalent stated alongside it.
2. Both skills point at the template, cloneable in two lines.
3. Private repositories appear as marked provenance, never as authority to consult.
4. `deployment.md` states the path a partner actually takes.
5. `check-references.py` reports 0 dangling references in both skills.

## Tasks

- [x] Add **Running your own registry** to `registry-and-magic.md`: the four rules a
      MagicNumber scheme must satisfy, a worked `registry.yaml`, issue-and-increment
- [x] Open that file by sending non-Koniverse readers straight to it
- [x] Add the template pointer to both `SKILL.md` files
- [x] Reframe `Trading-Resources` / `Senti-Quant` as marked-internal provenance and
      restate everything load-bearing in-skill
- [x] Rewrite the compile-service section so the partner path is the documented one
- [x] File [F-8](../../tests/findings.md) — the certified grade has not been run

## Dev notes — Architecture constraints

- **A rule has a guarantee and a mechanism.** Inside one team they fuse: "use Notion"
  *is* "keep magics unique," because there is one way to do it. Publishing separates
  them, and only the guarantee travels.
- **A prohibition needs an available alternative.** "Never X" is actionable only
  beside a reachable "do Y instead."
- **The skill must carry what it assumes it ships with.** `AGENTS.md` and the template
  do not travel with the skill, so the pointer had to move into the skill itself.

## Dev notes — Cross-story dependencies

Depends on [US-1.2](US-1.2-relocate-ea-skills.md), which brought the skills here.
[US-2.4](US-2.4-senti-is-the-runtime-and-compiler.md) revised the same two files again
once the deployment model was corrected.

## Dev notes — What we did NOT do

- **Did not claim a score.** koni-qc's rubric requires four dimensions graded by four
  *separate* agents against a hard 95, precisely because one grader who likes a skill
  inflates every axis. This was one grader; reporting a number would be the thing the
  rubric exists to prevent. [F-8](../../tests/findings.md).
- **Did not change `Koni-Skills`' language policy.** [F-5](../../tests/findings.md) is
  upstream's.

## Verification commands

```bash
python3 <koni-docs>/scripts/check-references.py skills/koni-ea-dev
python3 <koni-docs>/scripts/check-references.py skills/koni-ea-ops
grep -rq 'STARTER_EA' skills/koni-ea-dev skills/koni-ea-ops
```

## Changelog entry

```markdown
### Fixed
- `koni-ea-ops` told external users to obtain a MagicNumber from a Notion table they
  do not have, and forbade the only alternative. Added a portable registry section.
- Neither skill knew the template existed.
- Both cited private repositories as authority.
```

## Implementation notes

Every defect was the same shape — the skills still assumed the reader was inside
Koniverse, which stopped being true the moment this repo went public. That framing is
invisible from inside: each sentence is correct for the audience it was written for.

Lessons: §10 (publishing a skill changes its audience, and some rules stop being
executable).

## Files modified

`skills/koni-ea-ops/SKILL.md`, `skills/koni-ea-ops/references/registry-and-magic.md`,
`skills/koni-ea-ops/references/deployment.md`, `skills/koni-ea-dev/SKILL.md`,
`docs/LESSONS.md` (§10), `docs/tests/findings.md` (F-8).
