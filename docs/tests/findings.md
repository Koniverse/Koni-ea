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

### F-7 — Five gate checks are configured but never fire

| | |
|---|---|
| **Severity** | Medium |
| **Opened** | 2026-08-02 (v0.3.6) |
| **Area** | `.koni-harness/`, git hooks |
| **Owner** | partly upstream — `Koniverse/Koni-Skills` |

`install-gate.sh` writes a pre-commit hook hardcoded to `--phase work-commit`:

```
sh "$(git rev-parse --show-toplevel)/.koni-harness/gate-runner.sh" --phase work-commit || exit 1
```

Nothing in the repository ever invokes `--phase release-commit`. Every check assigned
to that phase in `gates.conf` therefore **never runs automatically**: `story-lint`,
`changelog-anchor`, `lesson-capture`, `design-first`, and `koni-docs-validate`.

**How it went unnoticed**: they were run by hand before every commit during setup, so
they appeared to work. A contributor who does not know to run them manually gets none
of them — which is precisely the population a gate exists to protect. The failure is
silent in the direction that always hides: it passes.

**Partly closed in v0.3.6**:
- `story-lint` and `changelog-anchor` moved into
  [`scripts/verify.sh`](../../scripts/verify.sh), so CI runs them on every push and
  pull request. Both are stateless — they read files, not the staged diff.
- `koni-docs-validate` was already covered there.
- The local `.git/hooks/pre-commit` now invokes both phases.

**Still open**: `lesson-capture` and `design-first` inspect `git diff --cached`, which
is empty in CI and meaningless outside a commit. They only work in a git hook — and
hooks are not committed, so the fix above protects this machine and nobody else's.

**To close**: `install-gate.sh` upstream in `Koni-Skills` should write a hook that
runs both phases, or move the release-phase checks to `work-commit`. Until then, a
fresh clone here has no `lesson-capture` or `design-first` enforcement even after
running `install-gate.sh`.

---

### F-5 — A vendored gate file carries a Vietnamese comment into this English repo

| | |
|---|---|
| **Severity** | Low |
| **Opened** | 2026-08-02 (v0.3.2) |
| **Area** | `.koni-harness/checks/design-first.sh` |
| **Owner** | upstream — `Koniverse/Koni-Skills` |

Line 4 of the vendored gate file contains a Vietnamese quotation:
`# discovered by /design-review is REWORK ("...")`. The file is tracked here, so a
public English repository ships one non-English line.

**Why it is open rather than fixed**: the file is vendored by
`install-gate.sh` from `Koni-Skills` (`skills/koni-harness/scripts/checks/design-first.sh`)
and is **overwritten on every gate reinstall**. Editing the copy here would be undone
by the next `install-gate.sh` run and would make the two diverge in the meantime.
`Koni-Skills` is a separate repository with its own language policy, and changing
that policy is not this repo's call.

The English check in `scripts/verify.sh` excludes `.koni-harness/` for exactly this
reason — flagging it produces a failure no contributor here can act on.

**To close**: translate the quotation upstream in `Koni-Skills`, keeping the original
Vietnamese in parentheses so the provenance of the quote survives. Then re-run
`install-gate.sh` here and drop the exclusion from `verify.sh`.

---

## Closed

### F-6 — Private vulnerability reporting was unavailable on a private repository

| | |
|---|---|
| **Severity** | Medium — blocked the documented security channel |
| **Opened** | 2026-08-02 (v0.3.4) |
| **Closed** | 2026-08-02 (v0.3.5) |
| **Area** | repository settings |

[SECURITY.md](../../SECURITY.md) and [CODE_OF_CONDUCT.md](../../CODE_OF_CONDUCT.md)
routed all private reports to `/security/advisories/new`, which returned **404**.

**Cause**: private vulnerability reporting is a **public-repository feature**. The
repository was private, so there was nothing to enable — the API returned `404` on
`PUT .../private-vulnerability-reporting` rather than an error explaining why.

**Closed by**: publishing the repository, then enabling the feature.

```
gh repo edit Koniverse/Koni-ea --visibility public
gh api -X PUT repos/Koniverse/Koni-ea/private-vulnerability-reporting   # 204
gh api repos/Koniverse/Koni-ea/private-vulnerability-reporting          # {"enabled":true}
```

**Evidence**: an unauthenticated request to the advisory form now returns `302` to
`login?return_to=.../security/advisories/new` and resolves `200` — sign-in, not
absence. `/security`, `/security/policy`, `/discussions`, `/issues` and the three
community-health files all return `200`.

**Pre-publication sweep** (the one-way door): 100 tracked files, all text; no binaries
or archives; no credentials, personal paths, or personal email addresses in tracked
content — the only `password` matches are the instructions telling reporters *not* to
paste one. The gitleaks history scan passed in CI on `f98eacc`.

---

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
