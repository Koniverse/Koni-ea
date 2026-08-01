# docs/ — documentation hub

The koni-docs surface for this repo. Everything here is the durable record; the
user-facing guides live at the repo root.

## Looking for something?

| I want to… | Go to |
|---|---|
| Understand where my bot runs | [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md) |
| Build a bot | [templates/mql5/STARTER_EA/README.md](../templates/mql5/STARTER_EA/README.md) |
| Set up my machine | [SETUP.md](SETUP.md) |
| Understand why this repo exists | [BRIEF.md](BRIEF.md) |
| Know where a file goes | [REPO_STRUCTURE.md](../REPO_STRUCTURE.md) |
| Contribute a template or skill | [CONTRIBUTING.md](../CONTRIBUTING.md) |
| Instruct an AI agent working here | [AGENTS.md](../AGENTS.md) |

## Documents

| Doc | What it holds | Mutability |
|---|---|---|
| [RUNNING-ON-SENTI.md](RUNNING-ON-SENTI.md) | Where a bot runs, and why it is not the user's machine | Revised if the platform model changes |
| [BRIEF.md](BRIEF.md) | The problem, the audience, the non-goals | Revised as the product changes |
| [SETUP.md](SETUP.md) | Clone → build → compile → deploy | Revised as steps change |
| [CHANGELOG.md](CHANGELOG.md) | Release history under `[Unreleased]` + versions | **Append-only** |
| [CONTEXT.md](CONTEXT.md) | Decision log — why we chose X over Y | **Append-only** (RULE-7) |
| [LESSONS.md](LESSONS.md) | Mistakes worth not repeating | **Append-only** |
| [sprints/](sprints/) | Epics, stories, and the generated [STATUS.md](sprints/STATUS.md) | Sprint files close and archive |
| [tests/](tests/) | QA surface — strategy, plans, cases, findings | Reports are dated and kept |
| [design/](design/) | Per-story design specs | Per story |

`PRD.md` and `ARCHITECTURE.md` are intentionally absent. This is a content-profile
repo; [REPO_STRUCTURE.md](../REPO_STRUCTURE.md) carries the organizational
conventions an ARCHITECTURE would otherwise hold. Add them via koni-docs templates
if the repo later grows a spec'd product surface.

## Append-only means append-only

`CONTEXT.md`, `LESSONS.md` and `CHANGELOG.md` are never rewritten. A decision that
turned out wrong gets a **new** entry that references the old one by ID — you do
not edit the original. Future readers need to see what was believed at the time,
not a tidied version that hides the reasoning.

## Working the docs

This is a content repo — no `package.json`, so call the CLI directly:

```bash
npx @koniverse/koni-docs status   --docs-path docs/    # regenerate sprints/STATUS.md
npx @koniverse/koni-docs validate --docs-path docs/    # verify every doc reference resolves
```

`sprints/STATUS.md` is **auto-generated**. Do not hand-edit it; edit the stories
and regenerate.

The pre-commit gate (`.koni-harness/`) runs `validate` along with version-phase,
changelog-anchor and secret checks on every commit.
