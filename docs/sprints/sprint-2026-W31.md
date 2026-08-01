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

| US     | Title                                                                          | Epic   | Pri | Points | Status | Ship   | Story file                                                                         |
| ------ | ------------------------------------------------------------------------------ | ------ | --- | ------ | ------ | ------ | ---------------------------------------------------------------------------------- |
| US-1.1 | Bootstrap the repo to the Koniverse standard                                   | EPIC-1 | P1  | 3      | ✅ done | v0.1.0 | [stories/US-1.1-repo-bootstrap.md](stories/US-1.1-repo-bootstrap.md)               |
| US-1.2 | Relocate koni-ea-dev + koni-ea-ops from Koni-Skills                            | EPIC-1 | P1  | 3      | ✅ done | v0.1.0 | [stories/US-1.2-relocate-ea-skills.md](stories/US-1.2-relocate-ea-skills.md)       |
| US-1.3 | Format for public release — template, license, agent entry point               | EPIC-1 | P1  | 8      | ✅ done | v0.2.0 | [stories/US-1.3-public-release-format.md](stories/US-1.3-public-release-format.md) |
| US-1.4 | Meet the open-source standard — community health files, CI, English everywhere | EPIC-1 | P1  | 5      | ✅ done | v0.3.0 | [stories/US-1.4-open-source-standard.md](stories/US-1.4-open-source-standard.md)   |

**Committed**: 19 points across 4 stories, all under [EPIC-1](epics/EPIC-1.md).
**Delivered**: 19 points, 4 stories. Shipped `0.1.0` (bootstrap), `0.2.0`
(public release) and `0.3.0` (open-source standard).

## Sprint note

The whole sprint landed on its final day, which is worth stating plainly rather
than smoothing over: the repo was empty at the start of the week and the work ran
as one continuous session on 2026-08-02. The sprint file was seeded by `koni-setup`
during bootstrap and opened retroactively when the docs were standardized.

Scope grew during the sprint and did so deliberately. US-1.1 was the whole
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

## Post-sprint follow-ups

The sprint closed at v0.3.0. Versions 0.3.1 through 0.6.0 were corrections and
hardening carried out after close, each committed with its own decision or lesson
rather than reopening the sprint: the org rename (D5), the gate-phase gap (F-7), the
skills' portability outside Koniverse, the Senti-runtime framing (LESSONS §11), and
the Author Studio correction (LESSONS §12).

Lessons: none new — the final documentation sweep applied §11 (a decision is not
applied until a sweep proves it) and §12 (read the product's UI, not only its
architecture docs). Both were written from the changes that caused this sweep; a
third entry restating them would be filler, and the depth bar exists to prevent that.

## Carry-over

None — every committed story closed.

## Next sprint candidates

- Compile-verify `STARTER_EA_v1.00.mq5` on a Windows host; run the release backtest
  and populate `backtest/`
- Decide whether the repo flips from private to public, and on what trigger
- Consider a second template once a distinct, genuinely different chassis shape
  earns one (a DCA/grid skeleton is the obvious candidate — its restart-recovery
  and margin pre-check story differs materially from the single-position case)
