# MagicNumber & the registry

> **Read this first if you are not on the Koniverse team.** The sections below
> describe the *Koniverse* implementation, which uses a Notion table as the assigning
> authority. You almost certainly do not have that table, and the rules are written as
> though you do — "never hand-pick a magic" is unfollowable advice if nothing else
> issues one.
>
> **The portable contract is in [Running your own registry](#running-your-own-registry)
> at the end of this file.** Read that section instead; it states what a MagicNumber
> must satisfy and how to keep a registry of your own. Everything the Notion workflow
> exists to guarantee, it guarantees — the specific tool is not the standard.

**Notion is the source of truth** for MagicNumbers (and the instance rows, where
tracked — D9 scoped the old live-instance *registry* role out of the yaml itself).
`algorithms/registry.yaml` is its **git-tracked mirror** — still maintained as the
version-controlled record of magic-per-version, but note its *live-instance-registry*
role was formally retired (D9 in the source archive's own decision log — a
Koniverse-internal repository, cited for provenance and not fetchable; it superseded the earlier
"registry.yaml as source of truth" decision). What survives and stays in scope is the
**MagicNumber-via-Notion workflow** and the git mirror; the old automation around it
(Grafana, a `sync_registry` job) is gone, so the checks below are manual.

**Contents**: [MagicNumber rules](#magicnumber-rules) · [The registry mirror shape](#the-registry-mirror-shape) ·
[Instances](#instances) · [The collision audit](#the-collision-audit) ·
[Running your own registry](#running-your-own-registry)

## MagicNumber rules

- **Notion assigns it — never hand-pick one.** A new row in the Notion algorithm
  table generates the magic; an in-development EA carries `magic: null` until Notion
  assigns it at deploy.
- The EA's `InpMagicNumber` **default**, its `.set`, and the registry mirror all
  state the **same** number Notion issued — the code, the params file, and the
  mirror agree.
- **One magic per running instance; never reuse.** MT5 does not enforce uniqueness,
  so two instances on the same magic silently merge in every position/deal query and
  in reporting. (The programming side of this hazard — filtering positions by magic
  in EA code — is in the **koni-ea-dev** skill.)
- **Never treat `registry.yaml` as authoritative, and never edit a magic or
  instance-state there first.** It is a mirror only: read from Notion, write to
  Notion, then mirror to the yaml. If the yaml drifts ahead of Notion, a deploy
  driven off the stale mirror runs a magic or version Notion never issued — silently
  colliding with an instance Notion *does* track (the exact merge hazard above). On
  any disagreement, Notion wins and the yaml is corrected — never the reverse.

## The registry mirror shape

`registry.yaml` is a **map keyed by the `UPPER_SNAKE` algo code** (not a list). Each
entry lists its `versions[]`, whose `version:` string mirrors whatever granularity
Notion tracks — often major-only (`v1`, `v8`) but minor-level strings also appear
(`v2.1`, `v1.00`). Match the string Notion/the mirror actually uses; do not assume
major-only. The `instances[]` list mirrors the live deployments Notion tracks.

```yaml
algorithms:
  MY_ALGO:                           # UPPER_SNAKE algo code is the key
    name: "My Algo"                  # human-readable name (a field, not the key)
    category: "Trend Following"
    type: mql5
    description: "…"
    versions:
      - version: "v1"
        status: deprecated           # active | deprecated | in_development
        magic: 41                     # Notion-assigned (a small integer); never hand-edited
      - version: "v2"
        status: active
        magic: 58
    instances:                       # illustrative — mirrors what Notion tracks per live deploy
      - magic: 58
        version: "v2"
        symbol: XAUUSD
        timeframe: H1
        account_id: null
        bot_name: null
        status: active
```

(The values above are illustrative — real magics are the small integers Notion
issues, not a placeholder like `123456`, and an EA with no live deploy has
`instances: []`.)

## Instances

An `instances[]` entry mirrors a *live deployment* row Notion tracks: which magic is
running which version, on which symbol/timeframe, under which account. Notion is
authoritative (D9 retired the yaml's own live-instance-registry role); the mirror
just records the rows for git history, it does not own them. When an instance is
stopped or replaced, update its `status` rather than deleting the row — the history
is the audit trail.

## The collision audit

Automated collision detection (the retired monitoring/sync stack) is **no longer
available**, so audit by hand before deploying — confirm no two EAs in the tree ship
the same magic default:

```bash
grep -rh "MagicNumber=" algorithms/mql5/ | sort | uniq -c | sort -rn
```

Any count `> 1` on a real magic (not a `0`/placeholder) is a collision waiting to
merge two instances — resolve it against Notion before the second one goes live.

---

## Running your own registry

For anyone outside the Koniverse team. Notion is *an* assigning authority, not *the*
requirement. Strip it away and four rules remain — these are the standard:

1. **Every running instance has its own MagicNumber, and it is `> 0`.** MT5 does not
   enforce uniqueness. Two instances sharing a magic silently merge in every
   position and deal query, so each one manages the other's trades and every report
   is wrong. Nothing warns you.
2. **A number, once used, is never reused** — not even after the instance is retired.
   Closed deals keep the magic in history; reusing it corrupts the reporting of both.
3. **One authority issues numbers, and it is not a person's memory.** Any durable,
   append-only record works: a committed `registry.yaml`, a spreadsheet, a database
   table, an issue in your tracker. What matters is that a *single* place decides,
   and that asking it is easier than guessing.
4. **The number agrees in three places** — the EA's `InpMagicNumber` default, its
   `.set` file, and the registry entry. A disagreement means a deploy runs a magic
   the registry never issued, which is exactly the collision in rule 1.

A minimal registry that satisfies all four, committed to git:

```yaml
# registry.yaml — one entry per algorithm, one row per running instance
MY_STRATEGY:
  next_magic: 990003        # bump on issue; never decrement, never reuse a retired value
  instances:
    - magic: 990001
      version: v1.00
      symbol: EURUSD
      timeframe: M15
      account: "demo-1234"  # an identifier, never credentials
      status: live
    - magic: 990002
      version: v1.00
      symbol: XAUUSD
      timeframe: M15
      account: "demo-1234"
      status: retired       # kept on purpose — 990002 is now permanently spent
```

Issuing a number is then: read `next_magic`, use it, increment it, commit. The commit
is the audit trail, and `git log` answers "who took 990002 and when".

**The collision audit** ([above](#the-collision-audit)) applies unchanged — it reads
the EAs and the terminal, not Notion. Run it whatever your registry is.

**Do not hand-pick a number per deploy.** That is the rule the Notion workflow exists
to enforce, and it holds without Notion: picking ad hoc is how two instances end up on
the same magic, and the failure is silent until the numbers stop adding up.
