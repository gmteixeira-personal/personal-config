## Why

Neovide is installed on this machine and the session has no way to reach it. `cargo install` copies out the binary and nothing else, so the desktop entry, the icon and the default configuration the upstream repository carries never arrive: the launcher has nothing to offer and the editor can only be started by typing its name into a terminal that is already open. This is the gap `file-manager` records for yazi, on the same cause, and it leaves the session with a graphical editor that only the person who installed it knows about.

Reaching it is not enough on its own. Opened beside the terminal running the same editor, Neovide draws visibly different text — a different family at a larger size, rasterized more heavily — and pools the pixels below its last row in one band under the status line. Two windows showing the same buffer should not look like two programs.

## What Changes

- A tracked desktop entry for Neovide, so the launcher offers it and a fresh checkout gets it with no further step.
- A tracked Neovide configuration naming the same font family and point size the terminal uses, and restating the rasterization fontconfig gives the terminal.
- Window padding matching the terminal's, so the two windows frame their grids the same way rather than one of them collecting its leftover pixels in a single band.
- The two ignore-file allowlist entries that let the entry and the configuration be tracked at all.
- Suppression of the two startup errors Neovide's arrival raises in the Neovim message UI. Recorded in the Neovim configuration's own OpenSpec project, not here.

## Capabilities

### New Capabilities

- `gui-text-editor`: which program this session edits text with in its own window, how it is reached, and what its window has to match.

### Modified Capabilities

<!-- None. `application-launcher` states how the launcher treats the entries it is given and is unchanged by another entry existing; `dotfiles-ignore-policy` states the allowlist contract rather than its contents. -->

## Impact

- `.local/share/applications/neovide.desktop` — new, tracked.
- `.config/neovide/config.toml` — new, tracked.
- `.gitignore` — two block 3 allowlist entries.
- `.config/nvim/lua/config/options.lua` — the padding globals, which Neovide exposes nowhere else.
- Reads, and does not change, `.config/foot/foot.ini`: the font line and `pad` there are what this change matches.
