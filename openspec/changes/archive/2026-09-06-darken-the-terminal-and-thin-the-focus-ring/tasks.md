## 1. Set the background

- [x] 1.1 Add `background=11111b` to the `[colors-dark]` section of `.config/foot/foot.ini`, beside the existing `foreground=aaaaaa`; verify by `grep -n 'background=' .config/foot/foot.ini` returning exactly one line inside that section
- [x] 1.2 Replace the comment sentence "The background is left at foot's own on purpose -- only the foreground was too bright" with one naming the value's palette (Catppuccin Mocha, crust), the tracked file this repository's copy of that palette lives in (`.config/swaylock/config`) and the fact that base `1e1e2e` was tried here and was not dark enough, matching how `.config/waybar/style.css` and `.config/fuzzel/fuzzel.ini` cite theirs; verify by reading the section back and finding no remaining claim that the background is foot's own
- [x] 1.3 Confirm nothing else in the file changed — no palette slot written, no `[colors-light]` section added, `foreground=aaaaaa` intact — with `git diff .config/foot/foot.ini`

## 2. Applying and checking

- [x] 2.1 Run `foot --check-config` and verify it reports the configuration valid with no deprecated setting or section
- [x] 2.2 Start a standalone `foot` — not a client, so it reads the tracked file fresh rather than inheriting the running server's reading — and ask it for its own colours with an OSC 11 and OSC 10 query; verify it answers `rgb:1111/1111/1b1b` for the background and `rgb:aaaa/aaaa/aaaa` for the foreground, and that its stderr carries no deprecation notice
- [x] 2.3 Verify the listing's colours cannot have moved: they come from `LS_COLORS`, which `.config/vivid/themes/starlight.yml` and the fish startup files produce, and `git status` shows none of those files touched by this change
- [x] 2.4 Restart the server with `systemctl --user restart foot-server.service`, then open a terminal with `Mod+T` and verify the background is the near-black Mocha crust and the prompt is the first line. Left for the operator: the restart closes every open foot window at once, this change was made from inside one, and the standalone start above already proves what the restarted server will read. Waiting for the next login applies the value just as well

## 3. Thin the focus ring and restore the gap

- [x] 3.1 Set `focus-ring { width 2 }` in the `layout` block of `.config/niri/config.kdl`, half niri's default of 4, and replace the comment above it — currently only niri's own note on how the unit is measured — with one giving the reason for the value: at zero gaps the ring is the entire seam between two tiled windows, only the focused window draws one, and 4 reads as a band where 2 reads as a line
- [x] 3.2 Set `gaps 2` in the same block — the ring's width, so the ring fills exactly the gap belonging to the focused window — and rewrite the comment above it to give that reason and to name the value it depends on; verify by `grep -n '^    gaps' .config/niri/config.kdl` returning one line
- [x] 3.3 Confirm nothing else in the file changed — `background-color "#181825"` intact, `border` still `off`, `active-color "#7fc8ff"` untouched, no binding altered — with `git diff .config/niri/config.kdl`
- [x] 3.4 Run `niri validate -c .config/niri/config.kdl` and verify it reports the configuration valid
- [x] 3.5 Verify the compositor applied it without a restart: niri watches the file and reloads a valid edit in place. Tile two windows, confirm they meet with no gap, and confirm the marker on the focused one reads as a line rather than a band

## 4. Documentation

- [x] 4.1 Verify `README.md` needs no change — its foot entry says the file configures the terminal and does not describe the terminal's colours, its one mention of a `[colors]` section is fuzzel's, and its niri entry does not describe the layout's dimensions
- [x] 4.2 Verify `.gitignore` needs no change — `.config/foot/foot.ini` is already allowlisted at line 79 and `.config/niri/config.kdl` is already tracked

## 5. Close-out

- [x] 5.1 Run `openspec validate darken-the-terminal-and-thin-the-focus-ring --strict` and verify it passes
- [x] 5.2 Verify `git status` names only `.config/foot/foot.ini`, `.config/niri/config.kdl` and the change's own files among the paths this change would stage, then commit

<!-- The `terminal-colors` and `window-appearance` deltas are applied to the main specs by `openspec archive`; they are not tasks here. -->
