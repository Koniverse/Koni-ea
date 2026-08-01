# Test strategy — koni-ea

## What this repo is, testing-wise

`koni-ea` ships **markdown and MQL5 source**. It has no application, no build step,
and no runtime of its own. There is no test suite here, and adding one would be
theatre.

That is not the same as having nothing to verify. It means verification is
**structural and documentary** — and that the one thing most worth executing,
compiling and running the MQL5, cannot happen on this repo's development host.

Stating that plainly is the point of this document. A test strategy that invents a
framework nobody runs is worse than one that names where the real gap is.

## Risk posture

Ranked by what actually costs someone money:

| Risk | Severity | Where it is caught |
|---|---|---|
| A partner ships a bot with a chassis bug the template was supposed to prevent | **Critical** — real money | koni-ea-dev pitfall checklist, applied per contribution |
| The template itself contains a chassis bug | **Critical** — multiplied across every copy | Structural self-check + Windows compile + backtest (**gap**) |
| The template does not compile | High — blocks every user at step one | MetaEditor F7 (**gap — Windows-only**) |
| A doc tells a partner to do something wrong | High — propagates silently | Link resolution, doc review, `koni-docs validate` |
| Secrets or proprietary strategy IP leak into a public repo | High — irreversible once public | Credential scan, gate `credential-scan`, CONTRIBUTING bar |
| A broken internal link or stale reference | Medium — erodes trust, cheap to fix | Link-resolution sweep, `koni-docs validate` |
| Skill frontmatter that does not trigger | Medium — the skill silently never loads | koni-qc skill-grading |

The top two are why this repo exists, and neither is fully covered today.

## Priority order

1. **The template's correctness.** It is copied verbatim into every partner bot, so
   a bug here is multiplied. Highest value per hour of verification.
2. **Doc accuracy on anything touching money or safety.** A wrong instruction about
   MagicNumber uniqueness or SL placement is a live-account bug with extra steps.
3. **Public-repo hygiene.** One leaked credential or one proprietary strategy is
   not recoverable by a later commit.
4. **Structural integrity.** Links, IDs, frontmatter — cheap, automatable, and what
   keeps the first three findable.

## What is verified, and how

### Automated, on every commit

The koni-harness gate (`.koni-harness/`) blocks or warns on:

| Check | Phase | Enforces |
|---|---|---|
| `version-phase` | work + release | A VERSION bump has a matching CHANGELOG section |
| `credential-scan` | work + pre-push | No secrets staged |
| `changelog-anchor` | release | `[Unreleased]` anchor present |
| `story-lint` | release | Story frontmatter complete and true |
| `lesson-capture` | release | A non-docs commit records a lesson verdict |
| `koni-docs-validate` | release | Every doc reference resolves |

### Manual, per change

```bash
# every internal markdown link resolves
for f in README.md AGENTS.md CONTRIBUTING.md REPO_STRUCTURE.md docs/*.md; do
  d=$(dirname "$f"); grep -oE '\]\([^)#]+\)' "$f" 2>/dev/null | sed 's/^](//;s/)$//' \
    | grep -v '^http' | while read -r l; do [ -e "$d/$l" ] || echo "BROKEN $f -> $l"; done
done

# template self-consistency
grep -o '#property version *"[0-9.]*"' templates/mql5/*/v*/v*/*.mq5   # matches folder + basenames
grep -c 'IndicatorRelease' templates/mql5/*/v*/v*/*.mq5               # equals handles created
grep -n 'CopyBuffer' templates/mql5/*/v*/v*/*.mq5                     # no bar [0] reads

npx @koniverse/koni-docs validate --docs-path docs/
```

### Per template contribution

The correctness checklist in
[CONTRIBUTING.md](../../CONTRIBUTING.md#correctness-checklist) is the acceptance
gate. Every line is a bug class a green backtest hides, drawn from
[`mql5-pitfalls.md`](../../skills/koni-ea-dev/references/mql5-pitfalls.md). It is
reviewed by hand — there is no static analyzer for MQL5 here.

## Known coverage gaps

Recorded rather than quietly carried. Status tracked in [findings.md](findings.md).

| Gap | Why it exists | What would close it |
|---|---|---|
| **The template has never been compiled** | MetaEditor is Windows-only; dev host is macOS | One MetaEditor F7 on a Windows host |
| **The template has never been run** | Same | Attach to a demo chart; confirm the `[INIT]` Journal line and that filters log as designed |
| **No release backtest** | Depends on the compile | "Every Tick Based on Real Ticks", ≥3 months, report into `backtest/` |
| **No automated link checking** | Manual sweep only | A CI job — deferred until the repo is public and CI is warranted |

The first three are one Windows session. Until then the template is *reviewed*
correct, not *verified* correct, and every document mentioning it says so.

## Where artifacts live

Per the koni-qc test-organization standard — see
[test-organization.md](test-organization.md):

| Artifact | Path |
|---|---|
| Per-epic test plans | `test-plan/EPIC-NN-<slug>.md` |
| Epic-level test cases | `test-cases/EPIC-N.md` |
| Execution reports | `test-reports/EPIC-NN/<MMDDYYYY>/` — created on first run, never pre-made |
| Bug bashes | `bug-bash/sprint-YYYY-WNN.md` |
| One-off analyses | `audits/` |
| Open findings | `findings.md` |

Those directories are empty today because nothing has been executed. They are kept
so the first run has somewhere to land.
