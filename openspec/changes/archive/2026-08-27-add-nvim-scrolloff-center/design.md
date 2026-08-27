## Context

`.config/nvim/lua/config/options.lua` already sets `vim.opt.scrolloff = 8`, in a file whose convention is one option per line with a trailing comment giving the reason for the value. See proposal.md — Why for the motivation, and specs/nvim-scrolling/spec.md for the behavior being contracted. The only design question is which mechanism produces centering, since Neovim has no dedicated "center the cursor" option.

## Goals / Non-Goals

**Goals:**
- Centering that comes from the existing options file and needs no runtime machinery.
- A comment that explains the value, so the next reader does not mistake `999` for an arbitrary large number.

**Non-Goals:**
- Centering the cursor horizontally, or anything to do with `sidescrolloff`.
- Making `zt` and `zb` keep working; the spec accepts that they no longer hold.
- A per-filetype or per-window opt-out.

## Decisions

**Use `scrolloff = 999` rather than an autocommand.** `scrolloff` is a minimum number of context lines around the cursor; when the value exceeds half the window height Neovim can only satisfy it by keeping the cursor at the middle row, and it clamps at the buffer ends on its own. That gives every requirement in the spec, including the ends-are-exempt one, for free.

Alternatives considered:
- A `CursorMoved` autocommand running `normal! zz`. Rejected: it fires after the redraw rather than before it, so it can visibly jitter, and it fights any plugin that positions the view itself.
- Setting `scrolloff` to a computed half of the window height, refreshed on `WinResized`. Rejected: it is the same behavior as `999` with a resize handler bolted on, since Neovim already clamps the value to what the window can satisfy.

**Keep the value literal at 999 rather than deriving it.** It is the idiomatic Neovim spelling for "always centered" and needs no recomputation when the window is resized.

**Change the existing line, do not add a second one.** A later assignment to the same option would leave two conflicting comments in one file.

## Risks / Trade-offs

- `zt` and `zb` stop parking the cursor at the window edge → accepted and written into the spec; `zz` remains a no-op rather than breaking.
- With `wrap`, `linebreak`, and `breakindent` all on, centering is measured in buffer lines, so a screen with several wrapped lines is only approximately centered → cosmetic, no mitigation needed.
- The smear-cursor plugin animates a larger travel now that the view moves under a stationary cursor → if the animation reads as noisy, tune that plugin, not this option.
- Reverting is restoring one number, so no rollback plan is needed beyond the commit.
