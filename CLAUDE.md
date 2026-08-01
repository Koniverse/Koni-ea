# CLAUDE.md — koni-ea

This project uses **[AGENTS.md](AGENTS.md)** as the single source of truth
for all AI instructions — project purpose, repo structure, conventions, skill
catalog, documentation map, and commit discipline. On any conflict between
this file and AGENTS.md, AGENTS.md wins.

This file holds only the Claude-Code activation surface for the `koni-docs`
skill (Koni-Docs Integration config + Active Context pointer).

## Koni-Docs Integration

koni-docs:
  plugins: []                        # none in v0.1
  docs_path: docs/                   # where docs live
  active_sprint: sprint-2026-W31     # seeded at bootstrap; open it for real via koni-docs
  version_file: VERSION              # path to semver file

> **CLI**: this is a *content* repo — no `package.json`, so there are no
> `agile:*` npm aliases. Call the koni-docs CLI directly
> (`koni-docs status --docs-path docs/`) with `@koniverse/koni-docs` installed
> globally, or via `npx @koniverse/koni-docs <subcommand>`.

## Active Context

> **Moved to `.active-context.md`** — see [`.active-context.example.md`](./.active-context.example.md)
> for the template and the gitignored-on-purpose rationale. The auto-update block
> (sprint / active stories / decisions / lessons) and the per-developer block
> (GitHub login, git name/email, current branch, workspace path) both live there.
>
> When you start working in this repo, copy the example to `.active-context.md`
> and fill in your local-developer details. Koni-docs T1-T7 triggers update the
> sprint block inside `.active-context.md`, not here.
