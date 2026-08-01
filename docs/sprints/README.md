# Sprints — agile schema & workflow

How work is tracked in this repo. The schema is koni-docs; this file is the local
map of it.

## The hierarchy

```
EPIC-N            a coherent body of work, spanning sprints
└── US-N.M        a user story — the contract between the epic and the code
    └── Tasks     checkboxes inside the story, ticked as you go
```

Sprints are a **calendar window**, not a container. A story belongs to an epic
permanently and to a sprint temporarily.

## Files

| Path | What it is | Who writes it |
|---|---|---|
| `epics/EPIC-N.md` | The epic: goal, scope, out-of-scope, story table | You |
| `stories/US-N.M-<slug>.md` | The story: AC, tasks, dev notes, changelog entry | You |
| `sprint-YYYY-WNN.md` | The active sprint: goal + scope table | You |
| `archive/` | Closed sprints | You, on sprint close |
| `STATUS.md` | The kanban + deadline board | **Auto-generated — never hand-edit** |

`STATUS.md` is rebuilt by `koni-docs status`. Editing it by hand means your change
disappears on the next regeneration and the board silently lies until then.

## Story lifecycle

```
backlog → ready → in-progress → review → done
                       ↓
                    blocked
```

`deprecated` exists for work that was specced then abandoned — use it instead of
deleting, so the reasoning stays findable.

## Working a story

**Before you start.** Read [LESSONS.md](../LESSONS.md) — skim every title,
full-read the two or three that touch your area. Then flip the story to
`status: in-progress` and set `sprint:` to the active sprint.

**While you work.** Tick tasks `[x]` as you complete them, not in one pass at the
end. Made an architectural or scope call? Append a [CONTEXT.md](../CONTEXT.md)
entry immediately — the reasoning is perishable and you will not reconstruct it
next week. Hit a trap worth not repeating? Append to [LESSONS.md](../LESSONS.md).

**When you finish.** Walk the pre-commit checklist in
[docs/README.md](../README.md), set `status: done` and `version_shipped:` (bare
semver, no `v`), then regenerate:

```bash
npx @koniverse/koni-docs sync   --docs-path docs/
npx @koniverse/koni-docs status --docs-path docs/
```

## Frontmatter that the gate enforces

`story-lint` runs on every release commit and **blocks**. Every story needs:

`id` · `title` · `epic` · `status` · `priority` · `points` · `sprint` ·
`assignee` · `commit` · `created` · `updated` — plus `version_shipped` once
`status: done`.

Three that are easy to get wrong:

- **`points`** — Fibonacci only (1/2/3/5/8/13). A consolidated story carries the
  sum of its rounds.
- **`assignee`** — the GitHub *login*, never a git `user.name`. They differ often
  enough that a wrong one breaks every lookup.
- **`version_shipped`** — bare semver (`0.2.0`), never `v0.2.0`.

Stories also carry a `Lessons applied:` line — evidence LESSONS.md was actually
read at the start, citing sections or an explicit "none — why". The gate checks it
because reading LESSONS is the step everyone skips.

## `due` is not the sprint end

Set `due:` **only** when the work owes a date to someone *outside* the sprint
rhythm — a contract, a customer demo, an audit. "Must land this sprint" is not a
`due`; `sprint:` already says that, and the sprint's end date is never inherited.

When a `due` moves, that is a CONTEXT entry in the same commit: old date, new
date, why. A silently-moved deadline is a deadline that never existed.

## Sizing

| Points | Shape |
|---|---|
| 1–2 | A chore. One file, one obvious change. |
| 3–5 | Standard story. Needs background and dev notes. |
| 8–13 | Large or cross-cutting. Needs every section, and probably should be split. |

If a story keeps growing past 13, that is the schema telling you it is an epic.

## No PRD in this repo

koni-docs normally binds a story to a PRD functional requirement via `prd_ref`.
This is a **content-profile** repo with no `PRD.md` — [REPO_STRUCTURE.md](../../REPO_STRUCTURE.md)
carries the organizational conventions instead. So stories here carry no `prd_ref`,
and epics state their own scope directly rather than enumerating FRs.

If this repo later grows a spec'd product surface, add `PRD.md` from the koni-docs
template and start populating `prd_ref` from that point forward — do not backfill
old stories with invented FR numbers.

## Sprint numbering

`sprint-YYYY-WNN` uses the **ISO week** — `date +%G-W%V`. Weeks run Monday to
Sunday.
