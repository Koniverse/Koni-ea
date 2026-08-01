#!/usr/bin/env bash
#
# verify.sh — everything this repository can check without a Windows host.
#
# Run it before you open a pull request. CI runs exactly this script, so a green
# run here is a green run there. No arguments, no setup, no network except the
# koni-docs check (skipped automatically when npx is unavailable).
#
#   ./scripts/verify.sh
#
# What it cannot check: whether the MQL5 compiles. MetaEditor is Windows-only.
# See docs/tests/findings.md F-1.

set -uo pipefail
cd "$(dirname "$0")/.."

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; DIM=$'\033[2m'; OFF=$'\033[0m'
[ -t 1 ] || { RED=""; GREEN=""; YELLOW=""; DIM=""; OFF=""; }

fails=0
pass() { printf '%s  ok  %s%s\n' "$GREEN" "$1" "$OFF"; }
fail() { printf '%s FAIL %s%s\n' "$RED" "$1" "$OFF"; fails=$((fails + 1)); }
skip() { printf '%s skip %s — %s%s\n' "$YELLOW" "$1" "$2" "$OFF"; }
detail() { printf '%s       %s%s\n' "$DIM" "$1" "$OFF"; }

# Tracked, reviewable source. Excludes vendored and generated trees.
tracked() { git ls-files "$@" 2>/dev/null; }

echo "verify — $(git rev-parse --short HEAD 2>/dev/null || echo 'no commits yet')"
echo

# ---------------------------------------------------------------- 1. English only
# This repository is English throughout: code, comments, docs, commit messages.
#
# Allowlist, not blocklist. Enumerating forbidden scripts is endless and gets the
# edge cases wrong — an early version flagged `Σ(open·vol)/Σvol` as non-English when
# it is mathematical notation. Instead: declare the non-ASCII characters this repo
# legitimately uses, and flag everything else for a human decision.
#
# Implemented in perl with -CSD (explicit UTF-8 I/O) rather than `grep -P`. The grep
# on PATH is not the same program everywhere — a wrapper, BSD grep, or a non-UTF-8
# locale each give a different answer, so this check silently passed on the author's
# machine while failing in CI. See docs/LESSONS.md §7.
#
# .koni-harness/ is excluded: it is vendored from Koni-Skills by install-gate.sh, is
# overwritten on every reinstall, and is not authored here. Its one Vietnamese
# comment is upstream's to fix.
if command -v perl >/dev/null 2>&1; then
  found=$(tracked '*.md' '*.mq5' '*.mqh' '*.set' '*.yml' '*.yaml' '*.sh' \
    | grep -v '^\.koni-harness/' \
    | while read -r f; do
        perl -CSD -ne '
          # Allowed beyond ASCII: typography, math, arrows, symbols, box drawing,
          # and the status emoji used in docs tables.
          BEGIN { $ok = qr/[
            \x{00A0}\x{00AB}\x{00BB}\x{00B0}\x{00B7}\x{00D7}\x{00F7}
            \x{2010}-\x{2015}\x{2018}\x{2019}\x{201C}\x{201D}\x{2022}\x{2026}\x{2030}
            \x{2039}\x{203A}\x{20AC}\x{00A7}\x{00B1}
            \x{0391}-\x{03C9}
            \x{2190}-\x{21FF}   # arrows
            \x{2200}-\x{22FF}   # mathematical operators
            \x{2300}-\x{23FF}   # miscellaneous technical (includes the clock glyphs)
            \x{2500}-\x{257F}   # box drawing
            \x{2580}-\x{259F}   # block elements
            \x{25A0}-\x{25FF}   # geometric shapes
            \x{2600}-\x{27BF}   # miscellaneous symbols + dingbats (check marks, warning)
            \x{2B00}-\x{2BFF}   # arrows supplement
            \x{1F300}-\x{1FAFF} # emoji
            \x{FE0F}\x{200D}    # variation selector, zero-width joiner
          ]/x }
          if (my @bad = grep { $_ !~ $ok } (/([^\x00-\x7F])/g)) {
            printf "%s:%d: %s\n", $ARGV, $., join(" ", map { sprintf "U+%04X(%s)", ord($_), $_ } @bad);
          }
        ' "$f"
      done)
  if [ -z "$found" ]; then
    pass "English only"
  else
    fail "English only — unexpected non-ASCII in authored files"
    printf '%s\n' "$found" | head -20 | while read -r l; do detail "$l"; done
  fi
else
  fail "English only — perl not found, cannot run the check"
fi

# ------------------------------------------------------- 2. Internal links resolve
# Code is stripped before links are extracted: fenced blocks first, then inline
# spans. Shell snippets in the docs contain text that looks exactly like a markdown
# link and is not one, in both forms — this check flagged its own documentation
# twice, once per form. See docs/LESSONS.md §5.
strip_code() {
  awk '/^[[:space:]]*```/ { inblock = !inblock; next } !inblock' "$1" \
    | sed 's/`[^`]*`//g'
}

broken=""
while read -r f; do
  d=$(dirname "$f")
  while read -r link; do
    [ -z "$link" ] && continue
    case "$link" in http*|mailto:*|'#'*) continue ;; esac
    target="${link%%#*}"
    [ -z "$target" ] && continue
    [ -e "$d/$target" ] || broken="${broken}${f} -> ${link}"$'\n'
  done < <(strip_code "$f" | grep -oE '\]\([^)]+\)' 2>/dev/null | sed 's/^](//;s/)$//')
done < <(tracked '*.md')
if [ -z "$broken" ]; then
  pass "internal links resolve"
else
  fail "internal links — broken references"
  printf '%s' "$broken" | while read -r l; do [ -n "$l" ] && detail "$l"; done
fi

# ------------------------------------------------------------- 3. No binaries
bins=$(tracked '*.ex5' '*.ex4' '*.dll' '*.zip')
if [ -z "$bins" ]; then
  pass "no compiled binaries committed"
else
  fail "binaries committed — ship source, let consumers compile"
  printf '%s\n' "$bins" | while read -r f; do detail "$f"; done
fi

# ------------------------------------------------------- 4. Template consistency
# Every EA states one version in three places: #property, the folder, the basename.
tmpl_fail=0
while read -r mq5; do
  [ -z "$mq5" ] && continue
  base=$(basename "$mq5" .mq5)                       # STARTER_EA_v1.00
  file_ver="${base##*_v}"                            # 1.00
  dir_ver=$(basename "$(dirname "$mq5")")            # v1.00
  prop_ver=$(grep -oE '#property[[:space:]]+version[[:space:]]+"[0-9.]+"' "$mq5" \
             | grep -oE '[0-9]+\.[0-9]+' | head -1)

  [ "v$file_ver" = "$dir_ver" ] || { detail "$mq5: basename v$file_ver != folder $dir_ver"; tmpl_fail=1; }
  [ "$prop_ver" = "$file_ver" ] || { detail "$mq5: #property $prop_ver != basename $file_ver"; tmpl_fail=1; }

  # A created handle that is never released survives a recompile and leaks.
  created=$(grep -cE '=[[:space:]]*i(MA|ATR|RSI|Custom|MACD|Stochastic|Bands|CCI|ADX)\(' "$mq5")
  released=$(grep -c 'IndicatorRelease' "$mq5")
  [ "$created" -eq "$released" ] || { detail "$mq5: $created handles created, $released released"; tmpl_fail=1; }

  # The forming bar repaints. Reading it is the single most expensive MQL5 mistake.
  if grep -nE 'CopyBuffer\([^,]+,[^,]+,[[:space:]]*0[[:space:]]*,' "$mq5" >/dev/null; then
    detail "$mq5: CopyBuffer reads bar [0] — the forming bar repaints"; tmpl_fail=1
  fi

  # The three sibling artifacts must exist for the version to be releasable.
  for ext in set md; do
    [ -f "${mq5%.mq5}.$ext" ] || { detail "$mq5: missing sibling .$ext"; tmpl_fail=1; }
  done
done < <(tracked 'templates/**/*.mq5')
[ "$tmpl_fail" -eq 0 ] && pass "template self-consistency" || fail "template self-consistency"

# ------------------------------------------------------------ 5. Version/changelog
ver=$(tr -d '[:space:]' < VERSION 2>/dev/null)
if [ -z "$ver" ]; then
  fail "VERSION is missing or empty"
elif ! printf '%s' "$ver" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  fail "VERSION '$ver' is not bare semver (no leading v)"
elif ! grep -q '\[Unreleased\]' docs/CHANGELOG.md 2>/dev/null; then
  fail "docs/CHANGELOG.md is missing the [Unreleased] anchor"
elif ! grep -qF "[$ver]" docs/CHANGELOG.md 2>/dev/null; then
  fail "docs/CHANGELOG.md has no [$ver] section"
else
  pass "VERSION $ver has a CHANGELOG section"
fi

# ------------------------------------------------------- 6. release-phase gate checks
# The koni-harness pre-commit hook is hardcoded to `--phase work-commit`, so every
# check configured for `release-commit` in .koni-harness/gates.conf never fires on its
# own. Two of them are stateless — they read files, not the staged diff — so they run
# here, where CI executes them on every push and pull request.
#
# lesson-capture and design-first are NOT here: both inspect `git diff --cached`, which
# is empty in CI and meaningless outside a commit. They need the git hook. See F-7.
for chk in story-lint changelog-anchor; do
  script=".koni-harness/checks/$chk.sh"
  if [ ! -x "$script" ] && [ ! -f "$script" ]; then
    skip "$chk" "gate not installed"
    continue
  fi
  if out=$(sh "$script" 2>&1); then
    pass "$chk"
  else
    fail "$chk"
    printf '%s\n' "$out" | head -10 | while read -r l; do detail "$l"; done
  fi
done

# ------------------------------------------------------------------ 7. koni-docs
if command -v npx >/dev/null 2>&1; then
  if out=$(npx --yes @koniverse/koni-docs validate --docs-path docs/ 2>&1); then
    pass "koni-docs validate"
  else
    fail "koni-docs validate"
    printf '%s\n' "$out" | tail -20 | while read -r l; do detail "$l"; done
  fi
else
  skip "koni-docs validate" "npx not available"
fi

echo
if [ "$fails" -eq 0 ]; then
  printf '%sall checks passed%s\n' "$GREEN" "$OFF"
  echo "note: the MQL5 compile is NOT checked here — MetaEditor is Windows-only (docs/tests/findings.md F-1)"
  exit 0
fi
printf '%s%d check(s) failed%s\n' "$RED" "$fails" "$OFF"
exit 1
