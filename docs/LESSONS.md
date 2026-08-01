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

---

## 5. A checker that reads documentation as data will read its examples as instructions

**What happened (v0.3.0)**: The first run of `scripts/verify.sh` reported two broken
links. Neither was a link. Both were fragments of a shell snippet *inside a fenced
code block* in `docs/tests/STRATEGY.md` and a story file — the snippet that
demonstrates how to extract markdown links. The extractor found its own worked
example and tried to resolve it as a path.

Fixed by stripping fenced blocks. It then failed **again**, on this very lesson:
the same snippet quoted as an *inline* code span rather than a fenced block. One
trap, two syntaxes, and the first fix only covered one of them.

**Why**: A link extractor is a parser with no notion of context. Markdown fences are
semantic to a human and invisible to `grep`. The trap is specific to documentation
tooling and it is structural, not a coding slip: the more thoroughly a repository
documents its own checks, the more example text there is for those checks to
misread. A repo that documents nothing would never have hit this.

The generalization is worth keeping: **any tool that treats prose as data must
respect the prose's own quoting.** Fenced blocks in markdown, string literals in
source, `<pre>` in HTML, quoted text in a config file. If your parser cannot tell
"this is an example of X" from "this is an X", it will act on the example.

**How to avoid**:
- Strip **every** code syntax the format has, not the first one that fixes the
  symptom. Markdown has two: fenced blocks and inline spans. Fixing one and shipping
  is how a bug returns wearing different clothes.
- Strip fenced blocks before extracting anything from markdown:
  `awk '/^[[:space:]]*```/ { inblock = !inblock; next } !inblock'`
- Test a documentation checker **against this repository's own documentation**
  first. It is the most adversarial corpus available, because it is full of examples
  of the exact patterns being matched.
- When a check reports a failure that looks absurd, suspect the check before the
  content. Both "broken links" here pointed at paths no human would ever write.

See [US-1.4](sprints/stories/US-1.4-open-source-standard.md).

---

## 6. A bulk find-and-replace does not know which files are append-only

**What happened (v0.3.1)**: The repository was renamed, so a one-line `sed` swept the
working tree replacing the old path with the new one across thirteen files. It
worked. It also rewrote two quoted commands inside `docs/CONTEXT.md` decision entries
D1 and D4 — entries that had been **committed one commit earlier** and are
append-only by RULE-7. The edit was caught by reading `git diff` before committing,
reverted, and replaced with a new entry (D5) recording the rename.

Nothing was lost. But the rule had been written down, enforced, and taught in
[§4](#4-append-only-protects-committed-history-not-uncommitted-drafts) that same day,
and it still nearly went in.

**Why**: The rule lives in a document; the operation is a regex over a file glob. A
`sed -i` has no model of "this file is a historical record and that one is current
state" — it sees bytes matching a pattern. Every append-only guarantee in a repo is
enforced by a human deciding not to edit something, which means any tool that edits
in bulk routes straight around it.

The near-miss is also *why* it happened: the correct move on those same strings, one
commit earlier, had been to edit them in place, because they were uncommitted drafts.
The right action changed the moment the commit landed, and muscle memory did not.

**How to avoid**:
- Exclude append-only files from bulk edits by default:
  `--exclude=CONTEXT.md --exclude=LESSONS.md --exclude=CHANGELOG.md`, then handle
  them deliberately.
- Read `git diff` on the append-only files specifically before staging. Not the
  summary — the actual hunks.
- When a rename or refactor changes strings that appear in history, the history entry
  gets a **pointer**, not an edit. Stale text plus an explanation beats revised text
  with no signal that it was revised.

**Pattern**:
```bash
# sweep everything except the record
grep -rl 'old-string' . --exclude-dir=.git \
  --exclude=CONTEXT.md --exclude=LESSONS.md --exclude=CHANGELOG.md \
  | xargs sed -i '' 's|old-string|new-string|g'

git diff docs/CONTEXT.md docs/LESSONS.md docs/CHANGELOG.md   # must be empty or intentional
```

See [CONTEXT.md D5](CONTEXT.md). Sibling of §4 — that entry works out when the rule
applies; this one is what happens when it applies and the tooling does not care.

---

## 7. A check that depends on ambient tooling verifies nothing

**What happened (v0.3.1)**: `scripts/verify.sh` shipped with the promise printed in
its own header — "CI runs exactly this script, so a green run here is a green run
there." The first CI run failed on a check that had passed locally every time.

The English-only check used `grep -lP`. On the author's machine the shell had a
`grep` **function** shadowing the binary, routing to `ugrep` with different flags and
different `.gitignore` semantics. It matched nothing and reported success. GitHub's
runner has plain GNU grep, ran the real pattern, and found two files.

Both findings were then interesting in their own right. One was a **false positive** —
`Σ(open·vol)/Σvol` in `trading-mechanics.md`, mathematical notation the pattern had no
business flagging. The other was **real** but not ours: a Vietnamese comment inside
`.koni-harness/checks/design-first.sh`, a file vendored from Koni-Skills and
overwritten on every gate reinstall.

So the check was simultaneously not running, too broad, and pointed at a file the
repo does not own.

**Why**: `grep` on `PATH` is not one program. It is BSD grep, GNU grep, ugrep, a
shell function, or a shim, and `-P` support, locale handling, and default excludes
differ across all of them. A verification script that shells out to whatever `grep`
resolves to is measuring the machine, not the repository. The failure mode is the
worst kind: it fails **open**, reporting success while doing nothing, and the more
often it passes the more confident everyone gets.

`2>/dev/null` on the call made it silent. A tool that errors and a tool that finds
nothing look identical when stderr is discarded.

**How to avoid**:
- **Never silence a checker's stderr.** If the tool cannot run, the check must fail
  loudly, not pass quietly. `verify.sh` now fails outright when perl is missing.
- **Pick the deterministic implementation, not the convenient one.** `perl -CSD` has
  the same regex engine and the same UTF-8 semantics on macOS and Linux. `grep -P`
  does not.
- **Allowlist over blocklist** for character-class checks. Enumerating forbidden
  scripts is endless and gets edge cases wrong; declaring what is permitted makes
  every new exception a visible decision.
- **Prove a check catches what it claims.** Run it against a file that should fail.
  A check nobody has seen fail is a check nobody has seen work.
- **Scope to authored content.** Vendored trees are upstream's to fix; including them
  produces failures the contributor cannot act on.

**Pattern**:
```bash
# prove it fails before trusting that it passes
printf 'sentinel with the thing being forbidden\n' > /tmp/should-fail.md
./scripts/verify.sh   # must report a failure naming /tmp/should-fail.md
```

See [CONTEXT.md D5](CONTEXT.md), [tests/findings.md](tests/findings.md).
