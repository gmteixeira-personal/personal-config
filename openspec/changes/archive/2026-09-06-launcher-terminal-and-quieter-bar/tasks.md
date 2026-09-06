## 1. Give the launcher a terminal

- [x] 1.1 Create `.config/fuzzel/fuzzel.ini` with `terminal=footclient` and a comment stating what breaks without it; verify `cat` reads the file back with the setting present
- [x] 1.2 Add `!/.config/fuzzel/fuzzel.ini` to the wayland-session block of `.gitignore`, with a comment saying which line is tracked and why; verify `git status --short` reports `.config/fuzzel/` as untracked rather than ignored
- [x] 1.3 Verify the terminal command itself works: `footclient nvim` opens a window running Neovim
- [x] 1.4 Verify fuzzel finds and accepts the file: `fuzzel --check-config` exits 0, having read the default `XDG_CONFIG_HOME/fuzzel/fuzzel.ini` path
- [ ] 1.5 Verify the launcher path end to end: press `Mod+D`, choose Neovim, and confirm a foot window opens with Neovim running in it

## 2. Take two modules off the bar

- [x] 2.1 Remove `"cpu"` and `"memory"` from `modules-right` in `.config/waybar/config.jsonc`; verify the array no longer names either
- [x] 2.2 Remove the `"cpu"` and `"memory"` option objects from the same file, keeping the comment above them that still explains `battery`'s format flip; verify no `cpu` or `memory` key remains
- [x] 2.3 Rewrite the comment above `modules-right` so it accounts for all four modules dropped from the packaged list, and says why a load percentage on a bar leads nowhere; verify by reading it back
- [x] 2.4 Remove the `#cpu` and `#memory` selectors from `.config/waybar/style.css`, and correct the comment above them that names them as examples of the stock fills; verify `grep -i 'cpu\|memory' .config/waybar/style.css` reports nothing
- [x] 2.5 Reload the bar and verify it starts clean: `journalctl --user` reports `Using configuration file` and `Including resource file` with no parse error, and the bar no longer shows the two percentages

## 3. Documentation

- [x] 3.1 In `README.md` under *Required*, rewrite the waybar/fuzzel/swaylock entry: fuzzel now has tracked configuration, so the claim that it runs on built-in defaults is removed and replaced with what its one setting does; verify the entry no longer says fuzzel has no tracked configuration
- [x] 3.2 In the same entry, remove the claim that which modules the bar shows is still the system file's decision — untrue since `0349715` — and say instead that the repository names the modules and inherits their options; verify the entry matches `.config/waybar/config.jsonc`
- [x] 3.3 In `README.md` under **Rebuilding the desktop session**, add fuzzel to the list of programs a checkout configures and drop it from the list running on built-in defaults; verify the paragraph names niri, foot, swaylock, waybar and fuzzel
- [x] 3.4 Verify `README.md` makes no other claim that fuzzel is unconfigured: `grep -n -i fuzzel README.md` and read every hit

## 4. Validate, apply and archive

- [x] 4.1 Run `openspec validate --changes launcher-terminal-and-quieter-bar --strict` and verify it passes
- [ ] 4.2 Archive the change and sync the main specs; verify `openspec/specs/application-launcher/spec.md` exists, `openspec/specs/bar-appearance/spec.md` no longer carries the removed requirement, and `openspec/specs/desktop-session-declaration/spec.md` no longer says the launcher has no tracked configuration
- [ ] 4.3 Commit and push; verify `git status` is clean and `git status -sb` reports no divergence from `origin/main`
