# The per-version EA document

Every released version ships a `<ALGO>_v<X.YY>.md` beside its source (see
[`versioning.md`](versioning.md#folder--file-layout)). It is the human record of
what the version does, what its inputs mean, and how it was tested.

**Write it in English.** An earlier revision of this standard preferred Vietnamese,
on the reasoning that the document is operational rather than code. That held while
the standard lived in a private repo read by one team. It stopped holding when the
standard shipped publicly: a partner in Jakarta or Warsaw who installs this skill
gets an EA document they cannot read, written to a rule they never saw. A team
working in one language may of course keep a translation alongside the English
original — but the shipped artifact is English.

**Contents**: [Required sections](#required-sections) · [Style](#style)

## Required sections

In order:

1. **Identity** — `# <EA> v<X.YY> — Algorithm Document`, then bold metadata:
   `File`, `Version`, `Language: MQL5`, `Updated: YYYY-MM-DD`.
2. **Strategy overview** — 1–2 paragraphs: the strategy type (breakout / grid /
   trend / time-based) and the money-management method (fixed lot / DCA / martingale).
3. **Version improvements** — for any version above `v1.00`: a change table
   (*Change / Detail*) versus the previous version. This is how a reader tracks
   what a minor bump actually changed.
4. **Input parameters** — a table of every `Inp…`, **grouped by section**, columns
   *Input | Default | Type | Description*. The `.set` defaults and this table must agree.
5. **Algorithm detail** — the entry/exit flow (ASCII or mermaid), the explicit
   **tick-vs-bar** trigger, the SL/TP formulas, and a warning if the SL is not
   hard-coded.
6. **Technical description** *(optional)* — structs, enums, global arrays, the
   `OnTick` order of operations.
7. **Recommended config** *(optional)* — a concrete setup (e.g. XAUUSD M15); state
   the **timezone in UTC**.
8. **Risk & backtest notes** *(optional)* — the backtest mode used (see
   [`backtest-and-release.md`](backtest-and-release.md#release-backtest-mode)) and a
   `> [!WARNING]` block for repaint / blow-up risks.

## Style

Keep code identifiers in backticks; keep the numbered headings even when an optional
section is empty (so a reader knows nothing was omitted by accident). The document
describes the version *as released* — when a new version is cut, it gets its own
doc; the old one is not edited.
