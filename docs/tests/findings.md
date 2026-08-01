# Open QA findings

Open findings and known coverage gaps. A gap recorded here is a gap the repo owns;
a gap not recorded here is a gap nobody knows about.

Close a finding by moving it to **Closed** with the evidence, not by deleting it.

---

## Open

### F-1 — `STARTER_EA_v1.00.mq5` has never been compiled

| | |
|---|---|
| **Severity** | High |
| **Opened** | 2026-08-02 (v0.2.0) |
| **Area** | `templates/mql5/STARTER_EA/v1/v1.00/` |
| **Owner** | unassigned |

The template was written to the koni-ea-dev standard and structurally self-checked
(version identity holds, 3 indicator handles created and 3 released, no `CopyBuffer`
reads bar `[0]`). It has **not** been through MetaEditor.

**Why it is open**: MetaEditor is Windows-only; the work was done on macOS. There is
no cross-platform MQL5 compiler.

**Impact**: A syntax, type, or scope error would block every partner at step one of
the 6-step loop. The structural checks cannot catch those.

**To close**: MetaEditor F7 on a Windows host. Zero errors **and** zero warnings.
Record the result in `test-reports/EPIC-01/<MMDDYYYY>/report-manual.md`.

**Mitigation until then**: `AGENTS.md`, [LESSONS §2](../LESSONS.md), and
[STRATEGY.md](STRATEGY.md) all state that the compile is unverified, so no reader
should assume otherwise.

---

### F-2 — `STARTER_EA_v1.00.mq5` has never been run on a terminal

| | |
|---|---|
| **Severity** | High |
| **Opened** | 2026-08-02 (v0.2.0) |
| **Area** | `templates/mql5/STARTER_EA/v1/v1.00/` |
| **Owner** | unassigned |
| **Blocked by** | F-1 |

No runtime behaviour has been observed. Specifically unverified: the `[INIT]`
startup line appears in the Journal; input validation rejects a bad
`InpMagicNumber`; the operational filters log and block as designed; the equity
breaker latches and survives a restart; `OnDeinit` releases handles without error.

**To close**: attach to a demo chart, exercise each guard, confirm the Journal
output. Record in the same report as F-1.

---

### F-3 — No release backtest for `STARTER_EA v1.00`

| | |
|---|---|
| **Severity** | Medium |
| **Opened** | 2026-08-02 (v0.2.0) |
| **Area** | `templates/mql5/STARTER_EA/v1/v1.00/backtest/` |
| **Owner** | unassigned |
| **Blocked by** | F-1 |

`backtest/` is empty. Per koni-ea-ops, a released version ships an exported MT5 HTML
report from "Every Tick Based on Real Ticks", ≥3 months.

**Nuance**: for this template the backtest proves the chassis *runs*, not that the
strategy *works* — the placeholder signal has no edge by design, and the docs say so
in four places. The report should be framed as a mechanical smoke test, and must not
be presented as performance.

**To close**: run the backtest, export the HTML into `backtest/`, and state in the
per-version doc that it is a mechanical check rather than a performance claim.

---

## Closed

### F-4 — No automated link checking

| | |
|---|---|
| **Severity** | Low |
| **Opened** | 2026-08-02 (v0.2.0) |
| **Closed** | 2026-08-02 (v0.3.0) |
| **Area** | repo-wide |

Internal markdown links were checked only by a manual shell sweep, so nothing
prevented a future commit from breaking one. `koni-docs validate` covers references
in the koni-docs ID graph but not arbitrary relative links in `README.md`,
`AGENTS.md`, or the template READMEs — which is where most of this repo's links
live.

**Closed by**: [`scripts/verify.sh`](../../scripts/verify.sh) and
[`.github/workflows/verify.yml`](../../.github/workflows/verify.yml)
([US-1.4](../sprints/stories/US-1.4-open-source-standard.md)). CI runs the same
script a contributor runs locally, on every push and pull request.

**Evidence**: the check found two real defects on its first run — `sed` snippets
inside fenced code blocks being parsed as markdown links. Fixed by stripping fences
before extraction, which is now covered by the same check.

**Coverage beyond links**: the script also verifies English-only text, template
version identity, indicator-handle create/release parity, closed-bar reads, absence
of committed binaries, and the VERSION/CHANGELOG pairing.
