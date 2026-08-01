# What this changes

<!-- One or two sentences. What is different after this merges? -->

Closes #

## Why

<!-- The problem this solves. If it is a template change, name the failure mode it
     prevents. -->

## Type of change

- [ ] New template
- [ ] Change to an existing template (**this means a new version — see below**)
- [ ] New skill, or a change to a skill
- [ ] Documentation
- [ ] Repository tooling

## Checklist — everything

- [ ] Written in **English** — code, comments, docs, and this description
- [ ] `VERSION` bumped and a `docs/CHANGELOG.md` entry added **in the same commit**
- [ ] No credentials, account numbers, or broker logins in any file, including `.set`
      files and commented-out lines
- [ ] No compiled binaries (`.ex5` / `.ex4`)
- [ ] No third-party or proprietary strategy logic I do not own
- [ ] No performance or profitability claims

## Checklist — template changes only

Delete this section if you did not touch `templates/`.

A change to a released template is a **new version**, not an edit in place. Create
`v<X.YY+1>/` with all four artifacts; do not modify `v1.00/`.

- [ ] New version directory created; the old version is untouched
- [ ] `#property version`, the folder name, and all three basenames state the same `X.YY`
- [ ] `.set` file and the input table in the `.md` agree
- [ ] Signals read **closed** bars only (`[1]`, `[2]`), never the forming bar `[0]`
- [ ] Orders go through `CTrade`, never raw `OrderSend`
- [ ] Both the boolean **and** `ResultRetcode()` checked after every trade call
- [ ] Every indicator handle checked against `INVALID_HANDLE` and released in `OnDeinit`
- [ ] `ArraySetAsSeries(buf, true)` before every `CopyBuffer`, return value checked
- [ ] Prices normalized to `_Digits`; lots snapped to `SYMBOL_VOLUME_STEP`, rounded **down**
- [ ] SL/TP clamped to `SYMBOL_TRADE_STOPS_LEVEL`
- [ ] Margin is **pre**-checked, never post-checked
- [ ] Positions filtered by symbol **and** magic in every query
- [ ] State survives a restart
- [ ] Compiles with zero errors **and** zero warnings

The reasoning behind each line is in
[`mql5-pitfalls.md`](https://github.com/Koniverse/koni-ea/blob/main/skills/koni-ea-dev/references/mql5-pitfalls.md).

## Verification

<!-- What did you actually run? Name the host — MetaEditor is Windows-only, and an
     unverified compile reported as verified is worse than an admitted gap. -->

- [ ] Compiled in MetaEditor (state your OS and MT5 build)
- [ ] Backtested "Every Tick Based on Real Ticks", 3+ months
- [ ] Forward-tested on a demo account for at least one trading week
- [ ] Not verified — I could not run the above, and I am saying so rather than implying otherwise
