## 1. Return the compositor to the separate components

- [x] 1.1 Replace `spawn-at-startup "noctalia" "-d"` with `spawn-at-startup "waybar"` in `.config/niri/config.kdl`
- [x] 1.2 Point `Mod+D` back at `spawn "fuzzel"` and `Super+Alt+L` back at `spawn "swaylock"`, updating both `hotkey-overlay-title` values to name the program that now runs
- [x] 1.3 Delete the `Mod+Alt+V` clipboard binding, and the trailing `include "noctalia.kdl"` line
- [x] 1.4 Verify `Mod+T` is untouched and still spawns `footclient`
- [x] 1.5 Run `niri validate` and verify it reports the configuration as valid

## 2. Return foot to its own colours

- [x] 2.1 Delete the `include=~/.config/foot/themes/noctalia` line from `.config/foot/foot.ini`
- [x] 2.2 Verify the rest of the file is unchanged — the server-mode notes, `shell=/usr/bin/fish`, the font and padding, the scrollback, cursor and mouse blocks, and the `[csd]` block from `2026-09-05-seamless-window-appearance`

## 3. Untrack the declaration

- [x] 3.1 `git rm .config/noctalia/settings.toml`
- [x] 3.2 Delete the noctalia allowlist block from `.gitignore`, leaving the wayland-session block above it intact
- [x] 3.3 Verify `git check-ignore -v .config/noctalia/settings.toml` reports a deny-by-default rule rather than an allowlist exception

## 4. Remove what it wrote

- [x] 4.1 Archive every path to be removed outside the repository first, so the palette is recoverable if it is ever wanted deliberately
- [x] 4.2 Delete `.config/niri/noctalia.kdl` and `.config/foot/themes/`
- [x] 4.3 Delete `.config/gtk-3.0/` and `.config/gtk-4.0/`, both of which contained only its `gtk.css` import and the imported palette
- [x] 4.4 Delete `.config/kdeglobals`
- [x] 4.5 Delete `.config/kitty/` and `.config/btop/`, whose only contents were themes it wrote for programs not installed here
- [x] 4.6 Delete `.config/noctalia/` and `.local/state/noctalia/`
- [x] 4.7 Verify `git grep -l -i noctalia -- ':!openspec/changes'` returns no match, and that no file remains on the machine outside the archive

## 5. Update the documentation

- [x] 5.1 Replace the noctalia entry under **Required** with waybar, fuzzel and swaylock, stating that none of the three has tracked configuration because none has any
- [x] 5.2 Delete the superseded-components note under **Optional**, now that those components are the live ones
- [x] 5.3 Rewrite the opening of **Rebuilding the desktop session** and its step 1 to name the session as it now is
- [x] 5.4 Delete the **The shell's settings, and how they drift** section
- [x] 5.5 Delete the `.local/state/noctalia/` row from the not-tracked table

## 6. Record the retirement

- [x] 6.1 Write the `desktop-shell` delta as `REMOVED Requirements`, giving each of the six requirements a reason and a migration, and stating plainly that the clipboard one has no replacement
- [x] 6.2 Add the noctalia requirement to the `retired-tooling` delta, covering the files it wrote into other programs' directories as well as its own paths
- [x] 6.3 Restate the `desktop-session-declaration` required-software requirement, and remove and re-add its rebuild-procedure requirement so the shell-settings scenario goes on the record rather than being dropped by a MODIFIED block; leave the three conditional requirements about untrackable state directories standing
- [x] 6.4 Run `openspec validate 2026-09-05-retire-noctalia --strict` and verify it passes

## 7. Verify the session

- [ ] 7.1 Restart the session with `niri-session` and verify waybar draws a bar, `Mod+D` opens fuzzel, `Super+Alt+L` locks with swaylock, and `Mod+Alt+V` does nothing
- [ ] 7.2 In that session, verify no noctalia process is running and that GTK and Qt applications fall back to their system default themes without error
- [ ] 7.3 Verify foot opens with its built-in colours and that `Mod+T` still attaches to the server
