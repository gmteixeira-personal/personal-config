#!/usr/bin/env bash
input=$(cat | tr -d '\n')

# --- width helpers -----------------------------------------------------------
# Claude Code captures stdout instead of attaching a terminal, so tput cols is
# useless here; COLUMNS/LINES are exported by Claude Code before the script runs.
strip_ansi() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g'; }

visible_len() {
  local stripped
  stripped=$(strip_ansi "$1")
  printf '%s' "${#stripped}"
}

# Shorten a plain (escape-free) string to at most $2 chars, eliding the middle.
truncate_middle() {
  local s=$1 max=$2 keep h t
  if [ "${#s}" -le "$max" ]; then printf '%s' "$s"; return; fi
  if [ "$max" -le 1 ]; then printf '%s' '…'; return; fi
  keep=$((max - 1))
  h=$(((keep + 1) / 2))
  t=$((keep - h))
  if [ "$t" -gt 0 ]; then
    printf '%s…%s' "${s:0:h}" "${s:${#s}-t}"
  else
    printf '%s…' "${s:0:h}"
  fi
}

# --- payload -----------------------------------------------------------------
# Parsed as JSON rather than by regex: context_window carries a nested
# current_usage object, so a brace-scoped match stops short of the field, and
# rate_limits has a "used_percentage" of its own that a bare match would win.
meta=$(printf '%s' "$input" | python3 -c '
import json, sys

def dig(d, *keys):
    for k in keys:
        if not isinstance(d, dict):
            return ""
        d = d.get(k)
        if d is None:
            return ""
    return d

try:
    j = json.load(sys.stdin)
except Exception:
    j = {}
if not isinstance(j, dict):
    j = {}
ws = j.get("workspace") if isinstance(j.get("workspace"), dict) else {}
wt = j.get("worktree") if isinstance(j.get("worktree"), dict) else {}
vals = [
    ws.get("current_dir") or j.get("current_dir") or j.get("cwd") or "",
    dig(j, "model", "display_name"),
    dig(j, "effort", "level"),
    "1" if j.get("fast_mode") is True else "",
    dig(j, "context_window", "used_percentage"),
    wt.get("name") or ws.get("git_worktree") or "",
    wt.get("branch") or "",
]
print("\n".join(str(v).replace("\n", " ") for v in vals))
' 2>/dev/null)

p_cwd=""; p_model=""; p_effort=""; p_fast=""; p_ctx=""; p_wt=""; p_wtbranch=""
if [ -n "$meta" ]; then
  {
    IFS= read -r p_cwd
    IFS= read -r p_model
    IFS= read -r p_effort
    IFS= read -r p_fast
    IFS= read -r p_ctx
    IFS= read -r p_wt
    IFS= read -r p_wtbranch
  } <<< "$meta"
fi

# Regex fallbacks for when python3 is unavailable.
cwd="$p_cwd"
[ -z "$cwd" ] && cwd=$(printf '%s' "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$cwd" ] && cwd=$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$cwd" ] && cwd="$PWD"

model="$p_model"
[ -z "$model" ] && model=$(printf '%s' "$input" | grep -o '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
effort="$p_effort"
[ -z "$effort" ] && effort=$(printf '%s' "$input" | grep -o '"effort"[[:space:]]*:[[:space:]]*{[^}]*}' | grep -o '"level"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fast="$p_fast"
[ -z "$fast" ] && fast=$(printf '%s' "$input" | grep -o '"fast_mode"[[:space:]]*:[[:space:]]*true')

# --- location ----------------------------------------------------------------
dir=$(basename "$cwd")
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
[ -z "$branch" ] && branch="$p_wtbranch"

# A linked worktree has its own git dir but shares the main checkout's common
# git dir; that common dir's parent is the parent repository.
repo=""
gitdir=$(git -C "$cwd" --no-optional-locks rev-parse --path-format=absolute --git-dir 2>/dev/null)
common=$(git -C "$cwd" --no-optional-locks rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
if [ -n "$gitdir" ] && [ -n "$common" ] && [ "$gitdir" != "$common" ]; then
  repo=$(basename "$(dirname "$common")")
  [ "$repo" = "/" ] || [ "$repo" = "." ] && repo=""
fi

location="$dir"
[ -n "$repo" ] && location="$repo/$dir"
[ -n "$branch" ] && location="$location:$branch"

# --- caveman badge -----------------------------------------------------------
# Mirror plugin's statusline logic, always render (even when off).
FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$FLAG" ] && [ ! -L "$FLAG" ]; then
  mode=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
  case "$mode" in
    off|lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress) ;;
    *) mode="" ;;
  esac
else
  mode="off"
fi
[ -z "$mode" ] && mode="off"
suffix=$(printf '%s' "$mode" | tr '[:lower:]' '[:upper:]')
cave=$(printf '\033[38;5;172m[%s]\033[0m' "$suffix")

# --- git pending state -------------------------------------------------------
git_state=""
if [ -n "$branch" ]; then
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  untracked=0
  unstaged=0
  staged=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    x=${line:0:1}
    y=${line:1:1}
    if [ "$x" = "?" ] && [ "$y" = "?" ]; then
      untracked=$((untracked+1))
    else
      [ "$x" != " " ] && [ "$x" != "?" ] && staged=$((staged+1))
      [ "$y" != " " ] && [ "$y" != "?" ] && unstaged=$((unstaged+1))
    fi
  done <<< "$porcelain"

  ahead=0
  upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" --no-optional-locks rev-list --count '@{u}..HEAD' 2>/dev/null)
    [ -z "$ahead" ] && ahead=0
  fi

  parts=""
  [ "$untracked" -gt 0 ] && parts="${parts} +${untracked}"
  [ "$unstaged" -gt 0 ] && parts="${parts} ●${unstaged}"
  [ "$staged" -gt 0 ] && parts="${parts} ◆${staged}"
  [ "$ahead" -gt 0 ] && parts="${parts} ↑${ahead}"
  if [ -n "$parts" ]; then
    git_state=$(printf '\033[38;5;214m[%s]\033[0m' "${parts# }")
  else
    git_state=$(printf '\033[38;5;35m[clean]\033[0m')
  fi
fi

# --- model badge -------------------------------------------------------------
badge=""
if [ -n "$model" ] || [ -n "$effort" ]; then
  text="${model%% *}"
  [ -n "$fast" ] && text="${text}⚡"
  [ -n "$effort" ] && text="${text:+$text:}${effort}"
  badge=$(printf '\033[38;5;110m[%s]\033[0m' "$text")
fi

# --- context window badge ----------------------------------------------------
ctx_badge=""
if [ -n "$p_ctx" ]; then
  ctx_int=$(awk -v p="$p_ctx" 'BEGIN{printf "%.0f", p}')
  ctx_color=$(awk -v p="$ctx_int" 'BEGIN{ if (p>=85) print 196; else if (p>=50) print 220; else print 35; }')
  ctx_badge=$(printf '\033[38;5;%sm%s%%\033[0m' "$ctx_color" "$ctx_int")
fi

# --- render ------------------------------------------------------------------
# One line when it fits the terminal, two lines when it does not.
badges=""
for part in "$git_state" "$cave" "$badge" "$ctx_badge"; do
  [ -n "$part" ] && badges="${badges:+$badges }$part"
done

cols="$COLUMNS"
case "$cols" in
  ''|*[!0-9]*) cols=80 ;;
esac
[ "$cols" -lt 20 ] && cols=80

one_line="${location}${badges:+ $badges}"
if [ "$(visible_len "$one_line")" -le "$cols" ]; then
  printf '%s\n' "$one_line"
else
  printf '%s\n' "$(truncate_middle "$location" "$cols")"
  [ -n "$badges" ] && printf '%s\n' "$badges"
fi
