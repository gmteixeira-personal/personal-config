## 1. The colours

- [x] 1.1 Add a `[colors]` section to `.config/fuzzel/fuzzel.ini` below the existing `terminal=footclient` line, setting all eleven keys to the values in design.md's mapping table; verify against `/etc/xdg/fuzzel/fuzzel.ini` that the eleven are every key that section defines and that none is left commented out
- [x] 1.2 Confirm each value against `.config/swaylock/config` and `.config/waybar/style.css` — `1e1e2e`, `313244` and `cdd6f4` from the lock screen, `6c7086` and `89b4fa` from the bar — so no hex in the file is a value this repository does not already use somewhere
- [x] 1.3 Verify every value ends in `ff`, since fuzzel has no text-shadow setting and cannot pay for transparency the way the bar does
- [x] 1.4 Add the comment above the section naming Catppuccin Mocha and `.config/swaylock/config` as this repository's statement of it, matching what `.config/waybar/style.css` already says
- [x] 1.5 Verify the geometry keys, the `[border]` section and `terminal=footclient` are untouched

## 2. Applying and checking

- [x] 2.1 Open the launcher with `Mod+D` and verify it draws dark, with no restart of the compositor or the session — fuzzel reads its configuration per invocation
- [x] 2.2 Type enough to match an entry and verify the matched substring is blue, the selected row is the lighter fill, and the match stays blue inside the selection
- [x] 2.3 Clear the input and verify the placeholder and the match counter are grey rather than Solarized — the states the resting view does not show
- [x] 2.4 Launch a `Terminal=true` entry from the launcher and verify it still opens in foot, since the terminal requirement is the one this change must not disturb

## 3. Documentation

- [x] 3.1 Correct the sentence in `README.md` that calls `.config/fuzzel/fuzzel.ini` "one line, `terminal=footclient`", and the rebuild procedure's clause calling it "the one launcher setting"; verify no other passage counts the file's contents
- [x] 3.2 Verify `.gitignore` needs no change — `.config/fuzzel/fuzzel.ini` is already allowlisted and tracked

## 4. Close-out

- [x] 4.1 Run `openspec validate darken-the-launcher --strict` and verify it passes
- [x] 4.2 Verify `git status` names only the intended paths, then commit
