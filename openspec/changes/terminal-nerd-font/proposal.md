## Why

The README lists **a Nerd Font in the terminal** as required software, and both things that depend on one — the tide prompt's segment icons and Neovim's filetype and status-line glyphs — have been rendering as replacement boxes, because no Nerd Font was installed and `foot.ini` names `Adwaita Mono`, which carries none of the glyphs. The requirement was written down and never satisfied. Neovim is the sharper edge of it: `mini.icons` is this configuration's single icon provider and is loaded eagerly, so the file explorer, the picker and the status line all draw tofu on a machine that is otherwise correctly built.

The entry that records the requirement is also the reason it stayed unsatisfied. It names no font and says the font is *"installed into the terminal emulator, not onto the machine"*, which describes a terminal that ships its own fonts. foot does not; it asks fontconfig, and fontconfig answers from what is installed on the machine. So the one place a rebuild would learn what to do points away from the thing that has to be done, and a reader following it finds nothing to install and no name to install.

Retiring alacritty belongs in the same change rather than a later one. It is a second terminal that the session never opens — `config.kdl` binds nothing to it, no spec names it, the README's software list does not mention it, and its `.config/alacritty/alacritty.toml` is untracked, so nothing in a checkout reproduces it. Left in place it is a terminal that would need the same font setting to stop showing boxes, and would then hold that setting in a file no rebuild restores. Removing it is cheaper than adopting it, and foot already serves the session as a client/server pair.

## What Changes

- JetBrains Mono Nerd Font is installed per-user under `.local/share/fonts/`, from the patched `ryanoasis/nerd-fonts` v3.5.1 release rather than Fedora's `jetbrains-mono-fonts`, which packages the unpatched upstream and carries no Nerd Font glyphs at all.
- Only the 16 `JetBrainsMonoNerdFontMono-*` faces are kept. The base and `Propo` families render the icon glyphs double-width, which breaks cell alignment in a terminal, and the `NL` no-ligature set is unused. Keeping one family of the six drops the installed tree from 233M to 40M.
- `.config/foot/foot.ini` names `JetBrainsMono Nerd Font Mono` in place of `Adwaita Mono`. The size stays 11.
- **BREAKING for the running session**: foot reads its configuration once, when `foot --server` starts. The font does not change in any existing window and does not change in a new one either; the server has to be restarted, which closes every open terminal. `foot.ini` already documents this rule and names the command.
- alacritty is retired: the package is removed, `.config/alacritty/` is deleted, and both the spec and the README record that it must stay absent.
- The README's Nerd Font entry stops describing the font as something the terminal supplies and instead names the family, the release it comes from, where it is installed, and why the distribution package is not a substitute.

## Capabilities

### New Capabilities

- `terminal-font`: Which font the terminal renders with and what that font must contain; that the glyph coverage is a hard requirement of two tracked configurations rather than a preference; which faces are installed and which are deliberately not; and that the requirement is announced in tracked documentation, since the font files themselves fall under the ignore policy's `.local/` denial and no checkout can carry them.

### Modified Capabilities

- `retired-tooling`: Gains a requirement retiring alacritty — package absent, no tracked configuration, no allowlist entry, no leftover directory, and re-adding it a deliberate act. This is the fourth tool recorded there and follows the shape of the three already present.

## Impact

- `.config/foot/foot.ini` — one changed `font=` line and the comment above it, which currently explains a choice of Adwaita Mono that is being reversed.
- `README.md` — the **A Nerd Font in the terminal** entry under *Required* is rewritten; alacritty is added under *Must not be installed*.
- `openspec/specs/retired-tooling/spec.md` — one added requirement.
- `.gitignore` — unchanged. `.config/alacritty/` was never allowlisted, and `.local/` is already denied in block 4, so the font tree is ignored without a new entry. This is worth stating because the change installs 58M into `$HOME` and adds nothing to `git status`.
- Packages: `alacritty-0.17.0-1.fc44` removed, and `libxkbcommon-x11` with it as a then-unused dependency — 8 MiB freed. Nothing installed through the package manager: the font is a per-user unpacked release, like `bob` and `herdr`.
- `.config/alacritty/alacritty.toml` — deleted, and with it a `Shift+Return` binding that sent `ESC CR`. foot has no equivalent binding and does not gain one here. Anything that relied on Shift+Return producing that sequence in alacritty loses it; in foot, Shift+Return sends what it sends today.
- Behaviour a reader should expect to change: after the server restart, every terminal window is JetBrains Mono rather than Adwaita Mono, so the whole session's text metrics shift slightly, and the prompt and Neovim draw icons where they drew boxes.
