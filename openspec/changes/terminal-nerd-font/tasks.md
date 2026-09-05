## 1. Font install

- [x] 1.1 Delete every face under `.local/share/fonts/JetBrainsMonoNerdFont/` except `JetBrainsMonoNerdFontMono-*.ttf`; verify `ls` reports 16 files and `du -sh` reports 40M
- [x] 1.2 Rebuild the font cache with `fc-cache -f ~/.local/share/fonts`; verify `fc-list : family | grep -i jetbrains` reports only the `JetBrainsMono Nerd Font Mono` family and none of the base, `Propo` or `NL` families
- [x] 1.3 Verify glyph coverage: `fc-match "JetBrainsMono Nerd Font Mono:charset=e0b0"` and the same for `charset=f011c` both resolve to a `JetBrainsMonoNerdFontMono-*.ttf` file
- [x] 1.4 Verify the install is invisible to git: `git status --porcelain` reports nothing under `.local/`, and `git check-ignore -v .local/share/fonts/JetBrainsMonoNerdFont` names the block 4 `.local/` rule

## 2. Retire alacritty

- [x] 2.1 Remove the package with `dnf remove alacritty`; verify `rpm -q alacritty` reports it not installed and `command -v alacritty` finds nothing on `PATH`
- [x] 2.2 Delete `.config/alacritty/`; verify that directory, `.local/share/alacritty/`, `.local/state/alacritty/` and `.cache/alacritty/` are all absent
- [x] 2.3 Verify no allowlist entry names it: `git check-ignore -v .config/alacritty/alacritty.toml` reports the block 1 `*` deny-by-default rule, not an exception
- [x] 2.4 Verify `.config/niri/config.kdl` has no `spawn-at-startup` entry and no binding naming alacritty

## 3. Configuration and documentation

- [x] 3.1 In `.config/foot/foot.ini`, replace `font=Adwaita Mono:size=11` with `font=JetBrainsMono Nerd Font Mono:size=11` and rewrite the comment above it, which currently justifies the Adwaita Mono choice being reversed; verify by reading the file back
- [x] 3.2 Rewrite the **A Nerd Font in the terminal** entry under *Required* in `README.md`: name `JetBrainsMono Nerd Font Mono`, the `ryanoasis/nerd-fonts` v3.5.1 release it comes from, that it installs into `.local/share/fonts/`, that Fedora's `jetbrains-mono-fonts` is the unpatched upstream and not a substitute, and what renders as boxes without it. Verify the entry no longer claims the font is supplied by the terminal emulator
- [x] 3.3 Add an alacritty entry under *Must not be installed* in `README.md`, naming foot as what serves the session instead and pointing at `openspec/specs/retired-tooling/spec.md`; verify it reads consistently with the lazygit entry beside it
- [x] 3.4 Run `openspec validate terminal-nerd-font --strict` and verify it passes

## 4. Commit and apply

- [ ] 4.1 Commit the tracked changes — `.config/foot/foot.ini`, `README.md`, and the change directory — before anything disruptive runs; verify `git status` is clean afterwards for those paths
- [ ] 4.2 Restart the terminal server with `systemctl --user restart foot-server.service`. **This closes every open terminal window, including the one running this work.** Verify `systemctl --user is-active foot-server.service` reports active from a new window
- [ ] 4.3 In a new terminal window, verify the prompt's tide segment icons render as icons rather than replacement boxes
- [ ] 4.4 In that window, open Neovim and verify the file explorer and status line draw `mini.icons` glyphs rather than boxes
