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

---

### D3. The `tests` pre-push gate is disabled — a gate that cannot run is not a gate

**Context**: `koni-setup` vendors a default `gates.conf` that includes a pre-push
`tests` check running `npm test`. That default assumes a **code** profile. This repo is
content profile: no `package.json`, no test runner, and — per
[docs/tests/STRATEGY.md](tests/STRATEGY.md) — nothing executable to test. The first
`git push` failed with `ENOENT: no such file or directory, open '…/package.json'`.

**Decision**: Comment the `tests` line out of `.koni-harness/gates.conf`, leaving it in
place with an explanation of why, rather than deleting the line or leaving it failing.

**Rationale**: The three alternatives are worse. *Leave it broken* — every push fails,
so the first person under time pressure reaches for `--no-verify`, which disables
**every** gate including credential-scan; a gate that trains people to bypass gates is
worse than no gate. *Add a stub `package.json` with a no-op `test` script* — invents a
code-profile artifact to satisfy a check that has nothing to check, and any future
reader would reasonably assume this repo has a test suite. *Delete the line* — loses the
information that a test gate exists in the standard and was consciously turned off here.

Commenting it out with the reason keeps the fact visible to the next person and makes
re-enabling a one-character edit the day this repo grows something runnable.

**Impact**: `.koni-harness/gates.conf` — one line commented. Pre-push now runs
`credential-scan` only. The real coverage gaps this repo *does* have (the template has
never been compiled, run, or backtested) are tracked as
[F-1 → F-3](tests/findings.md) — they are unaffected by this, because no `npm test`
would have caught them either.

**Date**: 2026-08-02
**Version**: 0.2.0
**Reference**: [docs/tests/STRATEGY.md](tests/STRATEGY.md), [findings.md](tests/findings.md), [D2](#d2-the-repo-goes-public--scope-narrows-to-mql5-and-the-toolchain-leaves-git).

---

### D4. English everywhere, enforced — the Vietnamese carve-out does not survive going public

**Context**: The `koni-ea-ops` standard specified that a released EA's per-version
document be written in **Vietnamese**, reasoning that the document is operational
rather than code. `STARTER_EA_v1.00.md` was written to that rule. The reasoning held
while the standard lived in a private repo read by one team.

It stopped holding the moment this repo became a public product. `koni-ea-ops` is
itself one of the two skills this repo *publishes*: a partner in Jakarta or Warsaw
runs `npx skills add Koniverse/koni-ea --skill koni-ea-ops`, and the standard they
install instructs them to write documentation in a language they may not read, to a
rule they never agreed to. The template shipped beside it had the same problem —
the one file a new user reads to understand what they just copied was unreadable to
most of the audience.

**Decision**: English everywhere, with no exception. Translate
`STARTER_EA_v1.00.md`; rewrite the language mandate in
`skills/koni-ea-ops/references/documentation.md` and its prescribed section names;
remove the carve-out from `AGENTS.md`. A team working in one language may keep a
translation alongside the English original, but the **shipped artifact is English**.

Enforce it rather than request it: `scripts/verify.sh` fails on Vietnamese
diacritics and CJK in any tracked file, and CI runs that same script.

**Rationale**: A language rule that is only written down drifts within one release —
the next contributor writes what feels natural and nobody notices until a partner
files an issue they cannot phrase. The alternatives were worse. *Keep the carve-out
and translate only the template* — leaves the published standard telling every
downstream user to do the thing this repo just stopped doing. *Ship both languages* —
doubles every per-version document and guarantees the two drift, with no rule for
which wins. *Ask contributors politely* — the exact class of rule that a mechanical
check exists for.

The check keys on Vietnamese diacritics and CJK ranges rather than on all non-ASCII,
because em dashes and typographic quotes are legitimate English typography and this
repository uses them throughout.

**Impact**: `templates/mql5/STARTER_EA/v1/v1.00/STARTER_EA_v1.00.md` translated;
`skills/koni-ea-ops/references/documentation.md` mandate and section names rewritten
— **this changes what downstream consumers of the skill are told to do**;
`AGENTS.md`, `REPO_STRUCTURE.md`, `README.md` updated. New `scripts/verify.sh` and
`.github/workflows/verify.yml` enforce it. Existing Vietnamese EA documents in other
Koniverse repos are not retroactively translated — this decision binds new work.

**Date**: 2026-08-02
**Version**: 0.3.0
**Reference**: [D2](#d2-the-repo-goes-public--scope-narrows-to-mql5-and-the-toolchain-leaves-git), `skills/koni-ea-ops/references/documentation.md`, [scripts/verify.sh](../scripts/verify.sh).

---

### D5. The repo is `Koniverse/Koni-ea` — and D1/D4 keep the old casing on purpose

**Context**: The repository was renamed from `Koniverse/koni-ea` to
`Koniverse/Koni-ea`. GitHub redirects the old path, so nothing breaks, but every
documented `git clone` and `npx skills add` command in the repo named a path that is
no longer canonical.

Two of those references sit inside **committed** decision entries: D1 quotes
`npx skills add Koniverse/koni-ea --skill koni-ea-dev` in its rationale, and D4
quotes the same command for `koni-ea-ops`.

**Decision**: Update every operational reference — README, CONTRIBUTING, SUPPORT,
SECURITY, SETUP, AGENTS.md, the template README, the `.github/` templates, and the
git remote. **Leave the two quotes inside D1 and D4 exactly as written**, and record
the rename here instead.

**Rationale**: This is the same question [D4's sibling lesson](LESSONS.md) settled
one commit earlier, arriving from the other direction. When those URLs were
uncommitted drafts, correcting them in place was right — nothing had been published,
so there was no record to protect. They are committed now. A reader of D1 should see
what D1 actually said when the decision was made, not a tidied version that implies
the author knew about a rename that had not happened yet.

The cost of leaving them is one stale command in two historical entries, next to a
pointer explaining why. The cost of editing them is that every future reader has to
wonder which parts of the decision log were quietly revised. That trade is not close.

A sed across the working tree does not know about this distinction, which is exactly
how the edit nearly landed — it was caught by reviewing the diff before committing,
not by the rule being remembered in advance.

**Impact**: 13 files updated; `git remote set-url origin` re-pointed. D1 and D4 are
untouched; the commands quoted in them resolve through GitHub's rename redirect and
are correct in substance, only stale in casing.

**Date**: 2026-08-02
**Version**: 0.3.1
**Reference**: [D1](#d1-the-ea-skills-live-here-not-in-koni-skills--and-there-is-only-one-copy), [D4](#d4-english-everywhere-enforced--the-vietnamese-carve-out-does-not-survive-going-public), [LESSONS §4](LESSONS.md).

---

### D6. No contact email anywhere — and a PII carve-out from the append-only rule

**Context**: `CODE_OF_CONDUCT.md` and `SECURITY.md` carried a contact address. Two
problems with that in a public repository. A published address is harvested for spam
within days of the repo going public, and it gives a reporter no confirmation that a
human ever read the message — no thread, no status, no record. For partners and users
it is also the wrong shape of channel: an inbox is invisible to everyone except the
two people in it, so the same twenty questions get answered privately, twenty times.

Removing the address is easy for support questions — they become issues. It is not
obvious for the two channels that **must** stay private: a security report and a
conduct report. Telling someone to open a public issue about a vulnerability
publishes the vulnerability; telling someone to open a public issue about harassment
exposes them to the person they are reporting.

**Decision**: Publish **no contact email at all**. Route every channel through GitHub:

- Questions and ideas → Discussions (enabled on the repository as part of this change)
- Defects → Issues, via the templates
- Changes → Pull requests
- **Security reports → GitHub private security advisories**
- **Conduct reports → the same private advisory form, titled `Code of Conduct`**, plus
  GitHub's own abuse reporting for anything that also violates GitHub policy — that
  route works even when a maintainer is the subject

The advisory form is labelled for security and is being used for conduct too, on
purpose: it is the only channel on this repository that is private between a reporter
and the maintainers, and it gives the reporter a thread and a reply rather than
silence.

**The append-only carve-out**: three mentions of an address survived inside
`docs/CHANGELOG.md` and `docs/LESSONS.md` — files that are append-only and already
committed. They were **redacted in place**, each with a visible marker naming the date
and pointing here.

That is a deliberate exception to RULE-7 and it is narrow. Append-only exists so a
reader can trust that the *reasoning* in a past entry has not been quietly revised.
Removing a personal identifier changes no reasoning; leaving one in a public file
defeats the entire purpose of this decision, in the one place nobody thinks to look.
The redaction announces itself precisely so the contract survives: a reader sees that
something was removed, when, and why, rather than finding a sentence that reads as
though it was always written that way. Silent redaction would be the violation. This
is not.

**Rationale for the shape of the routing**: the alternatives were worse. *Keep an
address for the private channels only* — still harvested, still no reply guarantee,
and it splits the workflow across two systems. *Route conduct reports to a public
issue* — actively harmful. *Provide no private channel at all* — makes responsible
disclosure impossible and would be dishonest in a `SECURITY.md`.

**Impact**: `CODE_OF_CONDUCT.md`, `SECURITY.md`, `SUPPORT.md` rewritten around GitHub
channels; Discussions enabled on the repository (the previous links to it were 404,
having been written before the feature was turned on). Three redactions in append-only
files. `.active-context.example.md` keeps `you@example.com` — a placeholder in a local
developer template, not a contact address.

**Not yet possible**: GitHub private vulnerability reporting is a **public-repository
feature** and returns 404 while this repo is private. `SECURITY.md` points at the
advisory URL, which will work the moment the repo is published. Enabling it is a
publication step — tracked as [F-6](tests/findings.md).

**Date**: 2026-08-02
**Version**: 0.3.4
**Reference**: [LESSONS §8](LESSONS.md), [D4](#d4-english-everywhere-enforced--the-vietnamese-carve-out-does-not-survive-going-public), [F-6](tests/findings.md).
