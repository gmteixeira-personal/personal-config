#!/usr/bin/env bash
input=$(cat | tr -d '\n')
cwd=$(printf '%s' "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$cwd" ] && cwd=$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$cwd" ] && cwd="$PWD"
dir=$(basename "$cwd")
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

# Caveman badge — mirror plugin's statusline logic, always render (even when off).
FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
cave=""
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
cave=$(printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$suffix")

# Git pending state
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

# Model and effort, from the payload Claude Code hands the status line on stdin.
model=$(printf '%s' "$input" | grep -o '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
effort=$(printf '%s' "$input" | grep -o '"effort"[[:space:]]*:[[:space:]]*{[^}]*}' | grep -o '"level"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fast=$(printf '%s' "$input" | grep -o '"fast_mode"[[:space:]]*:[[:space:]]*true')

badge=""
if [ -n "$model" ] || [ -n "$effort" ]; then
  text="$model"
  [ -n "$fast" ] && text="${text}⚡"
  [ -n "$effort" ] && text="${text:+$text · }effort:${effort}"
  badge=$(printf '\033[38;5;110m[%s]\033[0m' "$text")
fi

# Context window used %, from context_window.used_percentage.
# Parsed as JSON rather than by regex: context_window carries a nested
# current_usage object, so a brace-scoped match stops short of the field, and
# rate_limits has a "used_percentage" of its own that a bare match would win.
ctx_pct=$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    v = json.load(sys.stdin).get("context_window", {}).get("used_percentage")
    print("" if v is None else v)
except Exception:
    print("")
' 2>/dev/null)

ctx_badge=""
if [ -n "$ctx_pct" ]; then
  ctx_int=$(awk -v p="$ctx_pct" 'BEGIN{printf "%.0f", p}')
  ctx_color=$(awk -v p="$ctx_int" 'BEGIN{ if (p>=85) print 196; else if (p>=50) print 220; else print 35; }')
  ctx_badge=$(printf '\033[38;5;%sm%s%%\033[0m' "$ctx_color" "$ctx_int")
fi

if [ -n "$branch" ]; then
  printf "%s on %s %s %s %s %s" "$dir" "$branch" "$git_state" "$cave" "$badge" "$ctx_badge"
else
  printf "%s %s %s %s" "$dir" "$cave" "$badge" "$ctx_badge"
fi
