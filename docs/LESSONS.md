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

---

## 8. Context an agent is given is not content it may publish

**What happened (v0.3.3)**: `CODE_OF_CONDUCT.md` and `SECURITY.md` both need a contact
address for private reports. The working session carried the operator's email in its
ambient context, so that address went into both files as the project's public contact
point. Nobody asked for it and nobody was asked about it. The operator caught it on
review: the right address was an organizational one. *(That address was itself
removed in v0.3.4 — the project now publishes no contact email at all. Redacted here
2026-08-02; see [CONTEXT D6](CONTEXT.md).)*

**Why**: The failure is subtle because the information was not *wrong* and not
*obtained improperly* — it was correct, it was already there, and it filled a real
blank. What made it a mistake is the **change of audience**. Knowing an operator's
personal email so you can reason about a repository is one thing. Printing it in a
file that a public MIT-licensed repository serves to everyone, forever, as the
designated channel for security reports and conduct complaints is another act
entirely, and it is theirs to authorize.

Ambient context is dangerous precisely because it feels like established fact rather
than a decision. A blank field plus a plausible value in context reads as a lookup;
it is actually a publishing decision wearing a lookup's clothes.

**How to avoid**:
- **Personal identifiers are never a default.** Email, real name, phone, home
  directory paths, machine names, internal URLs. If a public-facing file needs one,
  ask — a one-line question costs less than a Git history.
- **Ask what the field is for, not what would fill it.** "Who should receive security
  reports for this project" has an organizational answer; "what email do I know"
  has a personal one, and only the first is the actual question.
- **Sweep before publishing.** `git ls-files | xargs grep -E '[a-z0-9._%+-]+@[a-z0-9.-]+'`
  over the tree catches this class in seconds, and it belongs in the pre-public
  checklist next to the credential scan.
- Note that a **commit author email** is the same exposure and cannot be fixed by
  editing a file — it is baked into every commit's metadata. Decide it before the
  first commit, not after.

---

## 9. Do not document a channel until you have opened it

**What happened (v0.3.0 → v0.3.5)**: `SECURITY.md` shipped in v0.3.0 routing all
vulnerability reports to `/security/advisories/new`. In v0.3.4 `CODE_OF_CONDUCT.md`
was rewritten to route conduct reports there too, and every contact email was removed
in favour of it. The URL returned **404** the entire time. It was written from
knowing GitHub has such a form, never from opening one.

Private vulnerability reporting is a **public-repository feature**; the repo was
private. So for five versions the two documents that most need to work — the ones a
person reads when something is wrong and they are already uncomfortable — pointed at
nothing. The operator found it by clicking the link.

**Why**: A documented channel is a **promise**, not a claim, and it fails differently.
A wrong claim is discovered by anyone who checks it. A broken channel is discovered
only by someone in trouble, at the worst possible moment, and their next move is
usually to give up rather than to file a bug about the bug reporter.

The API made it easy to miss: `PUT .../private-vulnerability-reporting` answered a
bare `404`, which is indistinguishable from a wrong URL, a typo, or missing
permissions. Nothing said "this feature does not exist for private repositories."
**An absent feature and a broken one return the same status code.**

**How to avoid**:
- **Open every channel you document, before you document it.** Load the URL. If it
  needs sign-in, load it signed in. A `200` behind a login redirect is fine; a `404`
  is not.
- Treat removing a fallback as raising the bar on what replaces it. Deleting the
  contact email made the advisory form the *only* private path — that is the moment to
  verify it, not after.
- When an API returns `404` for an action you expected to work, ask whether the
  feature exists **in this configuration** before assuming a bad request.
- Put the channel check in the publication checklist, next to the credential scan.

Sibling of §2 — that entry is about never reporting a verification you could not run;
this one is about never shipping a promise you never exercised.

---

## 10. Publishing a skill changes its audience, and some rules stop being executable

**What happened (v0.4.0)**: `koni-ea-ops` shipped a hard rule in
`registry-and-magic.md`: *"Notion assigns it — never hand-pick one."* Inside
Koniverse that is correct and load-bearing — the Notion table is the assigning
authority, and hand-picking is how two instances collide on one MagicNumber.

Published, the same sentence reaches a partner with no Notion table. It tells them to
obtain a number from a system they cannot reach, and in the same breath **forbids the
only action available to them**. An agent reading it has two options, and both are
bad: stall, or violate an explicitly stated rule. Neither is what the rule wanted.

Two milder versions of the same defect shipped alongside it: both skills cited private
repositories as authority (an outside agent may spend a turn trying to fetch a
`CONTEXT D9` that does not exist for it), and `deployment.md` presented an internal
compile service as *the* production path when `F7` in MetaEditor produces the
identical binary.

**Why**: A rule has two parts — the **guarantee** it protects and the **mechanism**
that delivers it. Written for one team, they fuse: "use Notion" *is* "keep magics
unique," because there is only one way to do it. Publishing separates them, and only
the guarantee survives the move. What ships as an instruction is the mechanism, which
is the half that does not travel.

This is not the same as the language problem in [§9's sibling, D4](CONTEXT.md) —
translated prose is still followable. An unfollowable instruction reads perfectly and
cannot be obeyed, which makes it harder to spot: nothing about the sentence looks
wrong.

**How to avoid**:
- Before publishing a skill, read every hard rule as **someone with none of your
  infrastructure**. No internal tool, no shared repo, no team channel. Can they comply?
- For each rule that names a tool, separate the two halves and state both: *what must
  be true* (the standard) and *how we do it* (the instance). Ship the first as the
  rule; mark the second as one implementation.
- **A prohibition needs an available alternative.** "Never X" is only actionable
  beside a reachable "do Y instead." Without one it is a dead end wearing a rule's
  clothes.
- Cite private sources as **provenance, marked as unfetchable** — never as authority a
  reader is expected to consult. Restate anything load-bearing in the skill itself.
- Check what the skill assumes it is packaged *with*. `AGENTS.md` told agents to start
  from the template; `npx skills add` ships neither `AGENTS.md` nor the template, so
  the skill had to carry that pointer itself.

See [CHANGELOG v0.4.0](CHANGELOG.md), [F-8](tests/findings.md).

---

## 11. Name a product by its destination, not by its toolchain

**What happened (v0.5.0)**: For four versions the README opened with *"Build a
MetaTrader 5 trading bot and deploy it on Senti."* `SETUP.md` §4 was titled *"Compile
and test"* and began *"Install into MetaTrader… attach the EA to a chart."* Every
sentence was individually true. Together they taught the wrong model: that MT5 is
where the bot lives and Senti is an optional extra step at the end.

The operator corrected it. Senti runs the bot on **its own** terminals, in a
datacenter near the broker, 24/5, logged into the account the user linked. The user's
MetaTrader is a build environment — compiler, backtester, demo harness — and nothing
more.

The framing error had a concrete cost waiting behind it. A user who believes MT5 is
the runtime attaches the finished EA to a local chart to "see it work," then also
uploads it to Senti. Two instances, one broker account, same signal: **double the
position size configured**, each instance managing trades the other opened, no
warning. The docs never said "run it locally against your real account" — they simply
never said not to, because the model they taught made the question invisible.

**Why**: A product gets named after whatever the author looked at most while building
it. Four versions of writing MQL5, MetaEditor, `.mq5`, `.ex5`, Strategy Tester — and
the name that emerged was "a MetaTrader 5 bot." That is the *toolchain*. The
destination was one line in a table.

The tell is that the wrong framing is never a false statement. It is a true statement
with the wrong subject, which is why review does not catch it: every sentence passes,
and the model they add up to is still wrong.

**How to avoid**:
- **Write the first line of the README as the destination, not the technology.** "A
  bot for Senti" and "a MetaTrader 5 bot" describe the same artifact and produce
  different users.
- When a build tool and a runtime differ, **say which is which on every page that
  mentions either**. Not once in an architecture doc nobody opens.
- Ask what a reader would *do* after each section. If §4 ends with "attach it to a
  chart" and the reader stops there, the docs said they were finished.
- **Name the hazard the wrong model creates**, not just the correct model. "It runs on
  Senti" is forgettable; "two instances on one account double your size, silently" is
  not.

**A second-order finding from the same sweep**: a `grep` for the old framing turned up
two places still describing the per-version doc as Vietnamese — a rule [D4](CONTEXT.md)
had changed two versions earlier, in files nobody re-read because the decision felt
"done." A decision is not applied until a sweep proves it. Same class as
[§6](#6-a-bulk-find-and-replace-does-not-know-which-files-are-append-only), from the
other direction: there the sweep reached too far, here it did not reach far enough.

See [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md).

---

## 12. Read the product's UI, not only its architecture docs

**What happened (v0.6.0)**: v0.5.0 documented the deployment path as *"compile in
MetaEditor with F7, then upload the `.ex5` and `.set` to Senti."* Requirements told
macOS and Linux users to install a Windows VM. `SETUP.md` had a whole section on
resolving include paths in MetaEditor.

None of that is what a user does. Senti has an **Author Studio**: paste `.mq5` source
into a web editor, press **Compile**, press **Save as EA**. Senti runs the safety scan,
compiles headlessly on its own build host, and builds the preset from the source's
`input` defaults. No MetaEditor, no binary, no `.set` file, **no Windows machine**.

The correction arrived as a screenshot. It also closed [F-1](tests/findings.md) — the
template compiled `0 errors, 0 warnings` on the first try, a gap that had been open
for four versions because compiling it was supposedly impossible.

**Why**: the architecture docs were read, and they were right — `FR-85` (upload
`.ex5` + `.set`) is real, and the compile service is described exactly as
implemented. What the reading missed is that `FR-85` is the **admin** path. The
user-facing path is a *different* epic, and the sentence that would have said so was
one line in a table of 175 requirements.

Architecture docs describe **capabilities**. They rarely say which one a user actually
touches, because to the team that wrote them it is obvious. A screenshot of the UI
answers in seconds what an hour of reading specs did not.

The failure compounds in one direction: an invented prerequisite is not a small
inaccuracy. "You need a Windows VM to build a bot" turns a browser tab into a weekend
of setup, and the people it turns away never file a bug about it.

**How to avoid**:
- **Ask to see the screen** before documenting a user-facing flow. One screenshot
  outranks a specification, because the specification describes what is possible and
  the screen shows what is offered.
- When architecture names several paths to the same outcome, **find out which one is
  in the product's navigation.** "Supported" and "what a user does" are different
  questions.
- **Be most suspicious of prerequisites you are adding.** Every "you will need X"
  raises the cost of entry; verify each against the actual product, not against the
  toolchain you happened to be reasoning about.
- A capability marked *in progress* in a spec may already be shipped in the UI, and
  vice versa. The spec is a plan; the screen is the state.

Sibling of [§11](#11-name-a-product-by-its-destination-not-by-its-toolchain) — that
entry got the destination wrong, this one got the *route* wrong, and both came from
reasoning about the toolchain instead of looking at the product.

---

## 13. A gate that validates what exists cannot notice what is missing

**What happened (v0.6.1)**: Twelve releases shipped in one session. Every one had a
`VERSION` bump, a CHANGELOG entry, and where a decision was made, a CONTEXT entry.
That discipline held perfectly — because a gate enforces it: `version-phase` blocks a
bump without a matching changelog section, `changelog-anchor` blocks a missing anchor.

Four of those twelve had a story. The other eight did not, and nothing complained.

`story-lint` runs on every release commit and is thorough: mandatory frontmatter keys,
Fibonacci points, the id matching the filename, the sprint existing and not having
ended before the story was created, a real commit SHA, a `Lessons applied:` line. It
validates **every story file that exists**. It has no opinion about a shipped version
with no story file at all.

So the agile record degraded silently in the one direction the gate is blind to, while
the parts the gate watches stayed perfect for twelve consecutive releases. The
correlation is not a coincidence — it is the whole mechanism.

**Why**: gates are written against the failure the author had just experienced. The
motivating incident for `story-lint` was *badly-written stories* (8 shipped without
`points:`, 12 filed into a closed sprint), so it grades quality. Nobody had yet been
burned by *absent* stories, so absence went unchecked.

Presence checks are also harder, which is the second half of the reason. Validating a
file you can see is local; noticing a file that should exist means knowing what
"should" is — here, joining the CHANGELOG's version list against the stories'
`version_shipped` values. That is a real query, and it never got written.

The tell: **when quality is uniformly high on the axes a gate measures, ask what it
does not measure.** Uniform excellence is more often evidence of a narrow instrument
than of uniform care.

**How to avoid**:
- For every gate, write down the failure it *cannot* see. `story-lint` cannot see a
  missing story; `credential-scan` cannot see a secret nobody staged; `lesson-capture`
  cannot see a shallow lesson, only a missing one.
- **Prefer a cheap completeness query to a thorough quality check** when both cannot
  be had. `comm -13` over two sorted lists surfaces the candidates:
  ```bash
  # shipped versions that no story claims
  grep -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' docs/CHANGELOG.md | tr -d '#[] ' | sort -u > /tmp/shipped
  grep -h '^version_shipped:' docs/sprints/stories/*.md | awk '{print $2}' | sort -u > /tmp/storied
  comm -13 /tmp/storied /tmp/shipped
  ```
  **Read the output; do not gate on it.** Run against this repo it names six versions,
  and every one is a false positive: `version_shipped` records the version a story
  *closed at*, so a story spanning `0.3.1` → `0.3.5` claims only the last, and a
  docs-only bookkeeping release legitimately has no story at all.

  That is the honest shape of a completeness query — it is a **prompt to look**, not a
  verdict, and shipping it as a gate would produce exactly the wall of noise that gets
  a check disabled ([§5](#5-a-checker-that-reads-documentation-as-data-will-read-its-examples-as-instructions)).
  Making it precise would mean stories listing every version they cover, which is
  bookkeeping nobody will maintain. A query you re-read occasionally beats a field
  that rots.
- Audit the record when the work is going *well*, not when it is going badly. Drift
  accumulates fastest during a productive run, because nothing is forcing a pause.
