# LESSONS.md — koni-ea

> Recurring traps and reusable patterns. A lesson earns its keep if it saves the
> next contributor time. Number sequentially; never reuse a number. An entry that
> needs to change is deleted and re-added with a new number, not edited in place —
> that preserves the citation contract.

---

## 1. Scan for consumers before moving a shared artifact, not after

**What happened (v0.1.0)**: Moving `koni-ea-dev` and `koni-ea-ops` out of
`Koni-Skills` looked like a two-step job — copy, delete. Before deleting, a sweep of
every repo under `~/Documents/GitHub` for references to those two skills found four
live consumers: two global symlinks in `~/.claude/skills/` and this repo's own
`.claude` / `.agents` wiring, all still pointing at the old location. Deleting first
would have left four dangling links across two repos and the user's global skill
directory.

**Why**: A skill is referenced by *symlink*, and a symlink records no back-pointer.
Nothing in the source directory tells you who depends on it. The dependency graph
exists only in the filesystem, and only a scan reveals it.

**How to avoid**:
- Before deleting or moving anything shared, sweep for consumers first. The scan is
  cheap; the cleanup after a bad delete is not.
- Re-point consumers **before** removing the source, so there is never a window
  where a link is broken.
- Verify the copy is byte-identical with `diff -r` **while the original still
  exists**. A verification that runs after the delete verifies nothing.

**Pattern**:
```bash
# 1. who depends on it?
for d in ~/Documents/GitHub/*/; do
  for s in <skill-a> <skill-b>; do
    p="$d.claude/skills/$s"; [ -L "$p" ] && echo "$p -> $(readlink "$p")"
  done
done
ls -la ~/.claude/skills/ | grep <skill>

# 2. copy, 3. verify, 4. re-point, 5. only then delete
diff -r <source> <destination> && echo IDENTICAL
```

See [CONTEXT.md D1](CONTEXT.md).

---

## 2. Never report a verification you could not run

**What happened (v0.2.0)**: `STARTER_EA_v1.00.mq5` was written to the koni-ea-dev
standard on macOS. MetaEditor — the only MQL5 compiler — is Windows-only, so "zero
errors and zero warnings" could not be checked. The honest options were to say so
or to let the phrase "compiles clean" appear unqualified in the docs. It was stated
as an open gap, in `AGENTS.md`, in the story, and in the sprint note.

**Why**: For a template whose entire value is being *correct*, an unverified claim
is worse than an admitted gap. A reader who believes the compile was checked will
not check it themselves, and the first person to discover otherwise is the one
running it against a live account.

The instruction now lives in `AGENTS.md` where the next agent will read it, because
the natural failure mode is not lying — it is an agent completing a code-writing
task and reaching for the phrase that usually ends it.

**How to avoid**:
- State the platform limit at the point of the claim, not in a footnote.
- When a checklist item cannot be executed, mark it unrun rather than passed.
- If a verification needs a host you do not have, name the host.

---

## 3. Count what a public repo actually commits, before it is public

**What happened (v0.2.0)**: The repo followed the Koniverse bootstrap faithfully,
which vendors the BMAD pack into `.claude/skills/` and `.agents/skills/`. Counting
what would land in the first commit gave **563 files, 4.2 MB** — roughly 500 of them
third-party BMAD skill content. The twenty files that are actually the product
(`skills/`, `templates/`, the entry-point docs) were a rounding error in their own
repository. Gitignoring the two consumed directories brought it to 83 files.

**Why**: Two separate problems wearing one disguise. **Licensing** — this repo is
MIT, and committing vendored third-party skills republishes someone else's content
under that grant. **Signal** — the stated goal was that an AI agent could read the
repo and follow the pattern; ~96% noise defeats that directly. Neither is visible
from the working tree, because a vendored directory looks exactly like an authored
one until you ask git what it is about to track.

The bootstrap default was not wrong — vendoring is a legitimate pattern for
*internal* clone-and-go repos. It was wrong *here*, and the trigger for rechecking
it was the repo turning public.

**How to avoid**:
- Before the first commit of a public repo, run `git add -An | wc -l` and read the
  list. If the product is not most of it, ask why.
- Separate **owned** from **consumed** directories explicitly, and state which is
  which in the repo's conventions. Consumed content is restored per-machine, not
  redistributed.
- Every gitignored directory that a contributor needs gets a documented restore
  path in the same change — see [SETUP.md §6](SETUP.md#6-setting-up-to-contribute).

**Pattern**:
```bash
git add -An | wc -l          # how many files will this commit track?
git add -An | sed 's/^add .//;s/.$//' | sort | head -50
du -sh */ .*/ 2>/dev/null    # where is the weight?
```

See [CONTEXT.md D2](CONTEXT.md).

---

## 4. Append-only protects committed history, not uncommitted drafts

**What happened (v0.2.0)**: The repo moved from a personal GitHub account to the
`Koniverse` org, making every `jindo9986/koni-ea` URL wrong — including ones inside
CONTEXT.md decision entries D1 and D42, which are append-only by RULE-7. The first
instinct was to leave them and add a new decision entry recording the org move.

That would have been wrong. Neither entry had been committed; both were written
minutes earlier in the same working session. Correcting a URL in an uncommitted
draft is finishing it, not rewriting history. A D3 entry saying "the URL changed"
would have added a row to the decision log that records no decision.

**Why**: The append-only rule exists so that a reader can trust what a past entry
*said at the time* — the protection is against retroactively editing the published
record. An unpublished draft has no readers and no record to protect. Applying the
rule to it is cargo-culting the ritual instead of the reason.

**How to avoid**:
- Ask what a rule protects before applying it. Append-only protects readers of
  committed history.
- The test is `git log`: if the text has never been committed, it is a draft.
- Once committed, the rule binds fully — corrections go in a new entry that
  references the original by ID.
