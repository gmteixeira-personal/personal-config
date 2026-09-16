## 1. Reach the editor from the launcher

- [x] 1.1 Write `.local/share/applications/neovide.desktop` with `Terminal=false`, `TryExec=neovide`, a bare `Exec`, `Icon=nvim`, `StartupWMClass` matching the Wayland app id, and task keywords; verify with `desktop-file-validate`, which must report no error
- [x] 1.2 Add the block 3 allowlist entry for that path to `.gitignore`; verify with `git check-ignore -v` that the path is no longer ignored and `git status` lists it
- [x] 1.3 Confirm the entry actually launches through the desktop-entry path rather than only from a shell, using `gio launch` on it

## 2. Make the window match the terminal

- [x] 2.1 Read `.config/foot/foot.ini` for the font family, point size and `pad`, and `fc-match -v` for this machine's hinting and antialiasing; record the four values that have to be restated
- [x] 2.2 Write `.config/neovide/config.toml` with `normal`, `size`, `hinting` and `edging` set from 2.1, each commented with the file it restates; verify Neovide starts clean and the grid is unchanged, so the rasterization keys changed rasterization and not metrics
- [x] 2.3 Add the block 3 allowlist entry for `.config/neovide/config.toml`; verify with `git check-ignore -v`
- [x] 2.4 Establish whether Neovide reads padding from `config.toml` by setting a `[padding]` table and re-measuring the grid; verify the grid does not change, which is what makes the next task necessary rather than optional
- [x] 2.5 Add the four `vim.g.neovide_padding_*` globals to `.config/nvim/lua/config/options.lua` behind an `if vim.g.neovide` guard, commented on both ends with why the setting is not in `config.toml`; verify the file still loads with `loadfile`

## 3. Verify the two windows agree

- [x] 3.1 Open Neovide and foot in the same window size and compare the reported grid; verify the row counts match and record the remaining column difference with its cause
- [x] 3.2 Confirm nothing else regressed: Neovide starts with no error on stderr, and the desktop entry still validates
