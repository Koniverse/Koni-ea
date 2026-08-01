---
id: sprint-2026-W31
status: closed
start: 2026-07-27T00:00:00.000Z
end: 2026-08-02T00:00:00.000Z
goal: >-
  Stand up koni-ea as the public EA/bot delivery repo — own the EA skills, ship
  a working MQL5 template, release v0.2.0
---
# Sprint 2026-W31

## Sprint scope

| US     | Title                                                                          | Epic   | Pri | Points | Status | Ship   | Story file                                                                                                 |
| ------ | ------------------------------------------------------------------------------ | ------ | --- | ------ | ------ | ------ | ---------------------------------------------------------------------------------------------------------- |
| US-1.1 | Bootstrap the repo to the Koniverse standard                                   | EPIC-1 | P1  | 3      | ✅ done | v0.1.0 | [stories/US-1.1-repo-bootstrap.md](stories/US-1.1-repo-bootstrap.md)                                       |
| US-1.2 | Relocate koni-ea-dev + koni-ea-ops from Koni-Skills                            | EPIC-1 | P1  | 3      | ✅ done | v0.1.0 | [stories/US-1.2-relocate-ea-skills.md](stories/US-1.2-relocate-ea-skills.md)                               |
| US-1.3 | Format for public release — template, license, agent entry point               | EPIC-1 | P1  | 8      | ✅ done | v0.2.0 | [stories/US-1.3-public-release-format.md](stories/US-1.3-public-release-format.md)                         |
| US-1.4 | Meet the open-source standard — community health files, CI, English everywhere | EPIC-1 | P1  | 5      | ✅ done | v0.3.0 | [stories/US-1.4-open-source-standard.md](stories/US-1.4-open-source-standard.md)                           |
| US-2.1 | Publish the repository and route all contact through GitHub                    | EPIC-2 | P1  | 5      | ✅ done | v0.3.5 | [stories/US-2.1-publish-and-contact-routing.md](stories/US-2.1-publish-and-contact-routing.md)             |
| US-2.2 | Make the verification tooling actually verify                                  | EPIC-2 | P1  | 5      | ✅ done | v0.3.6 | [stories/US-2.2-verification-actually-verifies.md](stories/US-2.2-verification-actually-verifies.md)       |
| US-2.3 | Make the published skills usable outside Koniverse                             | EPIC-2 | P1  | 5      | ✅ done | v0.4.0 | [stories/US-2.3-skills-portable-outside-koniverse.md](stories/US-2.3-skills-portable-outside-koniverse.md) |
| US-2.4 | Correct the deployment model — Senti is the runtime and the compiler           | EPIC-2 | P0  | 8      | ✅ done | v0.6.0 | [stories/US-2.4-senti-is-the-runtime-and-compiler.md](stories/US-2.4-senti-is-the-runtime-and-compiler.md) |

**Committed**: 19 points across 4 stories under [EPIC-1](epics/EPIC-1.md).
**Added mid-sprint**: 23 points across 4 stories under [EPIC-2](epics/EPIC-2.md) — every one a correction, none of it planned.
**Delivered**: 42 points, 8 stories, 12 releases (`0.1.0` → `0.6.0`).

## Sprint note

The whole sprint landed on its final day, which is worth stating plainly rather
than smoothing over: the repo was empty at the start of the week and the work ran
as one continuous session on 2026-08-02. The sprint file was seeded by `koni-setup`
during bootstrap and opened retroactively when the docs were standardized.

Scope grew twice. The first growth was deliberate. US-1.1 was the whole
committed ask; US-1.2 came from the owner recognising the EA skills sat in the wrong
repo; US-1.3 came from the goal sharpening to a *public* repo, which invalidated
several bootstrap defaults at once — five empty platform directories, an empty
`templates/`, and a fully vendored toolchain that would have shipped \~500
third-party files under an MIT license.

Two things were verified against source rather than assumed, and both changed the
plan: Senti's custom-bot upload is shipped and live (which made an MQL5-only scope
correct rather than merely convenient), and `Trading-Resources` is proprietary
(which ruled out shipping any real strategy as a template).

One thing was deliberately **not** verified: the template's MQL5 compile.
MetaEditor is Windows-only and this ran on macOS. It is recorded as an open gap in
`AGENTS.md` and [LESSONS §2](../LESSONS.md) rather than claimed.

## A correction to this record

An earlier revision of this file said the sprint "closed at v0.3.0" and called
everything after it a post-sprint follow-up. That was tidy and not true.

The sprint window is 2026-07-27 → 2026-08-02 and **all twelve releases landed inside
it**, on the final day. Declaring closure at v0.3.0 was premature — work continued for
another nine versions, and calling it "after close" made a mid-sprint scope change
look like something else. [EPIC-2](epics/EPIC-2.md) and US-2.1 through US-2.4 record
it properly.

Lessons: §13 — a gate that validates what exists cannot notice what is missing. The
CHANGELOG stayed perfect across all twelve releases because `version-phase` and
`changelog-anchor` enforce it; the story record drifted because `story-lint` grades
the stories that exist and has no opinion about a shipped version with none.

Sprint files are not append-only, so this is a correction rather than a revision
entry — but it is stated rather than silently rewritten, because the earlier version
was committed and someone may have read it.

## Carry-over

None — every committed story closed.

## Next sprint candidates

- Compile-verify `STARTER_EA_v1.00.mq5` on a Windows host; run the release backtest
  and populate `backtest/`
- Decide whether the repo flips from private to public, and on what trigger
- Consider a second template once a distinct, genuinely different chassis shape
  earns one (a DCA/grid skeleton is the obvious candidate — its restart-recovery
  and margin pre-check story differs materially from the single-position case)
