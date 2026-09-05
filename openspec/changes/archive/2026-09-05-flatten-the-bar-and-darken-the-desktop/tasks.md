## 1. Give the bar its appearance

- [x] 1.1 Write `.config/waybar/style.css` setting `window#waybar` to a transparent background with no border and white text, and verify by reading the file back that neither the stock `rgba(43, 48, 59, 0.5)` fill nor the `3px` bottom border survives
- [x] 1.2 Restate the font stack the system stylesheet provided, including both Font Awesome families, and verify `fc-list` reports Font Awesome present so the module glyphs have a face to render in rather than falling back to tofu
- [x] 1.3 Give every module that the bar actually renders a transparent background, white text and horizontal padding, and verify no `background-color` other than `transparent` remains in the file
- [x] 1.4 Replace each state the stock fills reported — battery critical, battery charging, network disconnected, temperature critical, tray needs-attention, muted audio, both power profiles, idle inhibitor activated — with a text colour drawn from the same Catppuccin Mocha values `.config/swaylock/config` uses, and verify the resting white is distinguishable from every one of them
- [x] 1.5 Add a `text-shadow` to labels so the bar survives a surface lighter than its text, and verify it is applied to `label` rather than to individual modules, so a module added later inherits it

## 2. Shrink the bar

- [x] 2.1 Write `.config/waybar/config.jsonc` containing an `include` of `/etc/xdg/waybar/config.jsonc` plus `height` and `spacing`, and verify it contains no `modules-left`, `modules-center` or `modules-right` key of its own
- [x] 2.2 Verify the file parses as JSON once comments are stripped, so a syntax error is caught before waybar is restarted rather than by a missing bar
- [x] 2.3 Set `height` to 24 against the 13-pixel font and `spacing` to 2, and verify the height is under twice the font size as `bar-appearance` requires
- [x] 2.4 Restart waybar and verify its log reports the tracked config, the tracked stylesheet, the included system file, and `height: 24`

## 3. Declare the colour behind windows

- [x] 3.1 Confirm no wallpaper daemon supplies the desktop, by verifying that `swaybg`, `swww` and `wbg` are each absent from the process list, so the compositor is established as the thing that draws it
- [x] 3.2 Add `background-color` to the `layout` block of `.config/niri/config.kdl` with a value one step from the lock screen's `11111b`, and verify it sits with `gaps` rather than in an unrelated block
- [x] 3.3 Run `niri validate` and verify it reports the configuration as valid

## 4. Track the new files

- [x] 4.1 Add `!/.config/waybar/style.css` and `!/.config/waybar/config.jsonc` to the wayland-session block of `.gitignore`'s block 3, and verify `git check-ignore -v` names those allowlist lines for both files rather than a block 1 or block 4 rule
- [x] 4.2 Verify `git status` lists both files as untracked-and-addable rather than ignored, so the allowlist is proven by the tool rather than by reading it

## 5. Say what the checkout now carries

- [x] 5.1 Rewrite the `waybar`/`fuzzel`/`swaylock` entry under **Required** so it names waybar as configured by the checkout for appearance and geometry only, with its module list still the system's, and verify it no longer says waybar has no tracked configuration
- [x] 5.2 Update the opening of **Rebuilding the desktop session** to say the checkout carries configuration for niri, foot, swaylock and waybar, and verify fuzzel is still the only one of the four named as running on its own defaults
- [x] 5.3 Verify the rebuild procedure's install list in step 1 still names every program the compositor spawns at startup, unchanged by this change

## 6. Validate the change

- [x] 6.1 Run `openspec validate flatten-the-bar-and-darken-the-desktop --strict` and verify it passes
- [x] 6.2 Verify the `desktop-session-declaration` delta carries the whole requirement block it modifies, scenarios included, so archiving cannot drop one

## 7. Verify the session

- [x] 7.1 Look at the bar and verify the desktop is visible through it, with no panel fill and no rule along its lower edge
- [x] 7.2 Verify no module carries a coloured block of its own, and that the modules are told apart by spacing
- [x] 7.3 Toggle the idle inhibitor and verify it changes colour on the bar when it is holding the screen awake
- [x] 7.4 Verify the desktop between windows shows the declared colour and is darker than it was
