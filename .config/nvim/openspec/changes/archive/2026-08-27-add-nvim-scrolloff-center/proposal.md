## Why

The cursor currently drifts to wherever a motion leaves it on screen, so the amount of surrounding code visible changes from one jump to the next and the eye has to re-find the cursor after every move. Keeping the cursor pinned to the middle of the window makes its position on screen constant and gives the same amount of context above and below at all times.

## What Changes

- Raise `scrolloff` in `.config/nvim/lua/config/options.lua` from `8` to `999`, which forces Neovim to keep the cursor vertically centered in every window whenever the buffer is long enough to scroll.
- Restate the option's comment: the setting is no longer "keep 8 lines of context" but "keep the cursor centered".
- No new plugin, no autocommand, no keymap. This is a single-option change.

## Capabilities

### New Capabilities
- `nvim-scrolling`: how Neovim positions the cursor vertically within the window as the buffer scrolls.

### Modified Capabilities

<!-- none -->

## Impact

- `.config/nvim/lua/config/options.lua` — the `scrolloff` line only.
- Behavioral side effects to accept: near the start and end of a buffer the cursor cannot be centered, so it moves normally there; `zt` and `zb` no longer park the cursor at the top or bottom of the window, since the option immediately recenters it.
- No plugin, LSP, or session state is affected.
