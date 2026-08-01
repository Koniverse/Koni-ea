# REPO_STRUCTURE.md — koni-ea

File-organization conventions. Content-profile repos lean on this document instead
of `docs/ARCHITECTURE.md`. If you are adding a skill or a template and are unsure
where it goes, the answer is here.

## Top-level map

```
koni-ea/
├── skills/                     # OWNED — the agent skills this repo publishes
│   ├── koni-ea-dev/            #   the MQL5 programming standard
│   │   ├── SKILL.md            #   navigational body + frontmatter
│   │   └── references/         #   deep material, loaded on demand
│   └── koni-ea-ops/            #   release lifecycle standard
├── templates/                  # OWNED — the starter kits partners copy
│   ├── README.md               #   template index
│   └── mql5/
│       └── STARTER_EA/         #   <ALGO> in UPPER_SNAKE_CASE
│           ├── README.md       #   how to use this template
│           └── v1/v1.00/       #   v<major>/v<X.YY>
│               ├── STARTER_EA_v1.00.mq5
│               ├── STARTER_EA_v1.00.set
│               ├── STARTER_EA_v1.00.md
│               └── backtest/
├── docs/                       # koni-docs surface — see docs/README.md
├── scripts/verify.sh           # every check CI runs; run it before a PR
├── .github/                    # issue + PR templates, CODEOWNERS, CI workflow
├── .claude/skills/             # CONSUMED — toolchain for Claude Code (symlinks)
├── .agents/skills/             # CONSUMED — toolchain for Codex/Cursor/Gemini/Copilot
├── .koni-harness/              # vendored commit/release gate
├── _bmad/                      # BMAD framework (installer-managed)
├── AGENTS.md                   # single source of truth for AI instructions
├── CLAUDE.md                   # thin pointer + Koni-Docs Integration block
├── CONTRIBUTING.md             # contribution rules + correctness checklist
├── CODE_OF_CONDUCT.md          # Contributor Covenant 2.1 + trading-specific standards
├── SECURITY.md                 # private disclosure + the threat model for this repo
├── SUPPORT.md                  # where to ask, and what is out of scope
├── LICENSE                     # MIT
├── REPO_STRUCTURE.md           # this file
├── VERSION                     # bare semver, no `v` prefix
├── .editorconfig               # MetaEditor uses 3-space + CRLF; general files use 2-space + LF
└── skills-lock.json            # lockfile for externally-sourced skills
```

## Language

**English, everywhere.** Source, comments, documentation, issues, pull requests,
commit messages. `./scripts/verify.sh` fails on non-English text in tracked files
and CI runs the same script, so this is enforced rather than requested. See
[CONTEXT D4](docs/CONTEXT.md) for why the one prior exception was removed.

## Owned vs consumed — the distinction that matters

Two kinds of directory hold skills here, and confusing them is the most likely
mistake in this repo:

| | `skills/` | `.claude/skills/` · `.agents/skills/` |
|---|---|---|
| **Role** | The product this repo ships | Tools this repo consumes |
| **Contents** | Real directories, authored here | Symlinks + installer output |
| **In git?** | Yes | **No — gitignored** |
| **Edit them?** | Yes — this is the work | **Never** — changes are lost or leak into another repo |
| **Who reads them** | Partners, via `npx skills add` | Agents working *in* this repo |

A symlink under `.claude/skills/koni-docs` resolves into a shared `Koni-Skills`
checkout. Editing through it silently modifies a different repository.

The consumed dirs are gitignored deliberately. They hold ~500 vendored BMAD skill
files — this repo's dev tooling, not its product. Committing them would republish
third-party content under our LICENSE and bury the ~20 files that matter. Restore
them per [docs/SETUP.md §6](docs/SETUP.md#6-setting-up-to-contribute); nothing
about *using* the templates requires them.

## Adding a template

Templates are grouped by **platform**, then by algorithm, then by version.

```
templates/<platform>/<ALGO>/
├── README.md                    # required — how to use it, what to replace
└── v<major>/v<X.YY>/
    ├── <ALGO>_v<X.YY>.mq5       # source
    ├── <ALGO>_v<X.YY>.set       # default preset
    ├── <ALGO>_v<X.YY>.md        # per-version doc (English, per koni-ea-ops)
    └── backtest/                # exported MT5 HTML report
```

Rules:

- **`<ALGO>` is `UPPER_SNAKE_CASE`** (`STARTER_EA`, `EMA_CROSS`). Every basename
  repeats the full version, and `#property version` inside the `.mq5` states the
  same `X.YY`. A file claiming one version while sitting in another's directory is
  the first sign the archive has drifted.
- **Note the double nesting**: the major dir `v1/` contains minor dirs `v1.00/`,
  `v1.01/`. You never edit a released version in place — a fix is a new minor.
- **Every template needs a `README.md`.** A template a partner cannot run unaided
  is not a deliverable.
- **Never commit build output or secrets.** `.ex5` / `.ex4` / `.env` are
  gitignored; ship source plus a `.set`, and let the consumer compile.
- **MQL5 templates follow the `koni-ea-dev` standard** and must pass the
  correctness checklist in [CONTRIBUTING.md](CONTRIBUTING.md#correctness-checklist).
- Reusable `.mqh` modules shared across templates go in
  `templates/mql5/_shared/` rather than being copy-pasted per template.

### Why only `mql5/`

Senti's upload path accepts a compiled `.ex5` plus its `.set`, so MQL5 is the one
language with a working route from editor to live deployment. Other runtimes get a
directory when Senti opens a path for them — an empty directory promising a
template that does not exist is worse than no directory.

## Adding a skill

1. Create `skills/<name>/SKILL.md` (or `npx skills init koni-<name>`).
2. Frontmatter needs `name` and a `description` written as **trigger conditions** —
   when should an agent reach for this? Not a summary of what it contains. Follow
   the phrasing of `koni-ea-dev` and `koni-ea-ops`.
3. Keep `SKILL.md` **navigational**. Deep material goes in `references/<topic>.md`
   and is loaded on demand — a body that must be read in full on every invocation
   is too long.
4. Naming: `koni-<domain>` for skills this ecosystem owns; a plain `<domain>` name
   only for something vendored from upstream.

## Where documentation goes

| Content | Location |
|---|---|
| Where a bot actually runs (Senti, not the user's MT5) | `docs/RUNNING-ON-SENTI.md` |
| Why a structural decision was made | `docs/CONTEXT.md` (append-only) |
| A mistake worth not repeating | `docs/LESSONS.md` |
| Release history | `docs/CHANGELOG.md` under `[Unreleased]` |
| Sprint / epic / story tracking | `docs/sprints/` |
| Test plans, cases, findings | `docs/tests/` (koni-qc standard) |
| How to use one skill or template | that skill's / template's own README |
| Rules for AI agents working here | `AGENTS.md` |
