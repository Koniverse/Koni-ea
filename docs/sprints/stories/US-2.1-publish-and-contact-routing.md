---
id: US-2.1
title: "Publish the repository and route all contact through GitHub"
epic: EPIC-2
status: done
priority: P1
points: 5
sprint: sprint-2026-W31
assignee: jindo9986
commit: 136087c
created: 2026-08-02
updated: 2026-08-02
version_shipped: 0.3.5
---

# US-2.1 — Publish the repository and route all contact through GitHub

## Goal

Take the repository public with a working private-disclosure channel and no published
contact address, so partners and users work through issues, discussions and pull
requests rather than an inbox.

## Background

Three problems surfaced in sequence, each from the previous fix.

The repository was renamed to `Koniverse/Koni-ea`, leaving every documented clone and
install path pointing at the old name. Two of those references sat inside **committed**
CONTEXT entries.

`CODE_OF_CONDUCT.md` and `SECURITY.md` then shipped with the operator's **personal
email** as the project's contact point — pulled from the working session's ambient
context and never authorized for publication. The owner caught it on review.

Replacing it with an organizational address was still wrong. A published address is
harvested for spam within days of a repo going public and gives a reporter no
confirmation anyone read it; for a partner channel it is worse, because an inbox is
invisible to everyone except the two people in it.

**Lessons applied:** §4 (append-only protects committed history, not drafts) — which
is why the D1/D4 quotes were left stale and recorded in D5 rather than edited.

## Acceptance criteria

1. Every documented path names `Koniverse/Koni-ea`; the git remote is re-pointed.
2. No contact email appears in any tracked file.
3. Questions route to Discussions, defects to Issues, changes to pull requests.
4. Security **and** conduct reports route to GitHub private security advisories, with
   GitHub's abuse reporting as a second route for conduct.
5. The repository is public and `/security/advisories/new` resolves.
6. Private vulnerability reporting is enabled.
7. A pre-publication sweep confirms no secrets, binaries, or personal identifiers in
   tracked content.

## Tasks

- [x] Re-point the git remote; update 13 files to the canonical repository name
- [x] Leave the two quotes inside committed D1/D4 untouched; record the rename as D5
- [x] Replace the personal email with an organizational one, then remove all emails
- [x] Rewrite `SUPPORT.md` as a routing table with a reason per row
- [x] Route security **and** conduct reports to the private advisory form
- [x] Enable GitHub Discussions — `SUPPORT.md` had linked to it since 0.3.0 while the
      feature was off, so every one of those links was a 404
- [x] Redact three surviving addresses in append-only files, with visible markers (D6)
- [x] Run the pre-publication sweep: 100 tracked files, all text, no secrets
- [x] Flip visibility to public; enable private vulnerability reporting; verify

## Dev notes — Architecture constraints

- **Private vulnerability reporting is a public-repository feature.** The API returned
  a bare `404` while the repo was private, indistinguishable from a wrong URL. This is
  why enabling it had to be a publication *step*, not a backlog item.
- **A conduct report cannot go to a public issue.** It exposes the reporter to the
  person they are reporting. The advisory form is labelled for security and is used
  for conduct too, because it is the only private channel this repository has.

## Dev notes — What we did NOT do

- **Did not rewrite git history** to remove the personal author email from commits.
  Doing so would invalidate every SHA recorded under RULE-2. The trade-off was put to
  the owner, who chose to publish without it.
- **Did not keep a fallback address** for the private channels. Still harvested, still
  no reply guarantee, and it splits the workflow across two systems.

## Dev notes — References

- [D5](../../CONTEXT.md) — the rename and why D1/D4 keep the old casing
- [D6](../../CONTEXT.md) — no contact email, and the PII carve-out from RULE-7
- [F-6](../../tests/findings.md) — closed by publication

## Verification commands

```bash
git ls-files | xargs grep -nE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
gh api repos/Koniverse/Koni-ea/private-vulnerability-reporting --jq .enabled
curl -sL -o /dev/null -w '%{http_code}\n' https://github.com/Koniverse/Koni-ea/security/advisories/new
```

## Changelog entry

```markdown
### Changed
- The repository is public; all contact routes through GitHub — Discussions, Issues,
  pull requests, and private advisories for security and conduct.

### Removed
- Every contact email.
```

## Implementation notes

The near-miss worth recording: a working-tree `sed` for the rename rewrote two quotes
inside committed CONTEXT entries. It was caught by reading `git diff` before staging,
reverted, and replaced with D5. The rule had been written and taught the same day and
still nearly went in, because the correct action on those same strings one commit
earlier had been to edit them in place.

Lessons: §6 (a bulk find-and-replace does not know which files are append-only),
§8 (context an agent is given is not content it may publish).

## Files modified

`README.md`, `CONTRIBUTING.md`, `SUPPORT.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`,
`AGENTS.md`, `docs/SETUP.md`, `templates/mql5/STARTER_EA/README.md`, the `.github/`
templates, `docs/CONTEXT.md` (D5, D6), `docs/LESSONS.md` (§6, §8),
`docs/tests/findings.md` (F-6).
