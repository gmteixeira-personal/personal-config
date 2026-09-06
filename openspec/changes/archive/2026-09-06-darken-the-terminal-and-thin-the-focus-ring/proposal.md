## Why

Two surfaces were left at an upstream default, which stops being invisible once everything around it is decided.

**The terminal.** foot's background is `002b36`, Solarized dark base03: a teal-tinted grey lighter than every surface around it, from a palette nothing else uses. The desktop, lock screen, bar and launcher are all Catppuccin Mocha. The comment defending the value records that the foreground was what got fixed then, not that `002b36` was ever weighed against that palette.

**The seam between windows.** Two values decide it, and `window-appearance` set them independently: the ring at niri's default, because at zero gaps nothing competes with it; the gap at zero, because a tiling layout decides every edge. The first fixes the width from what the ring competes with, not from what the width does. The second rules out a gap wide enough to read as space but does not reach zero. Neither is stated in terms of the other, which is why `9c5fe8d` could restore `gaps 8` unnoticed.

## What Changes

- `.config/foot/foot.ini` gains `background=11111b` in its `[colors-dark]` section, next to the existing `foreground=aaaaaa`. The value is Catppuccin Mocha's crust, the palette's darkest entry and the one `.config/swaylock/config` already gives the lock screen: red and green at 17, blue at 27, so a little above black with a small amount of blue in it.
- The result is darker than `002b36` by about 70% of its relative luminance (0.0199 to 0.0060). Base `1e1e2e` was carried first, on the reading that a terminal is an application surface and base is the palette's entry for one; at 0.0140 it is a visible step down but still a tinted grey, and near-black was what was wanted. Crust is the palette entry that lands there.
- The `foreground=aaaaaa` line is unchanged. Contrast against the new background rises from 6.5:1 to 8.1:1, well clear of WCAG AAA for body text rather than falling; the foreground's reason for being `aaaaaa` — matching the Linux virtual console's own default — is unaffected by what sits behind it.
- The comment above the section is corrected. It currently tells a reader the background is deliberately foot's own, which this change makes false. It gains instead the value's palette name, the file this repository's copy of that palette lives in, and the note that base was tried here and was not dark enough, matching what `.config/waybar/style.css` and `.config/fuzzel/fuzzel.ini` already do — the palette is restated in five files in five formats with no shared definition, and it only stays checkable because each file says where its values came from.
- The sixteen palette slots stay unwritten. Nothing here reaches them by index, and the `terminal-colors` spec's reason for leaving them out is untouched by naming a background.
- `.config/niri/config.kdl` sets `focus-ring { width 2 }`, half niri's default of 4. The ring still marks the active window; it stops being wide enough to read as a surface of its own.
- The same file sets `gaps 2`, the ring's width. niri draws the ring outward from the focused window into the gap, so at an equal value it fills exactly the gap belonging to that window: wider and the ring floats inside a band of desktop, narrower — zero included — and it has no space of its own. The seam between two windows is then one constant size, carrying the ring's colour beside the focused window and the declared colour behind windows elsewhere.
- The two values are tied and the file says so. Both are converted from logical to physical pixels by the same rule, which is what keeps them aligned on a fractionally scaled output: on this session's 1.25 output, 2 logical becomes 2.5 physical and rounds to 3, so a column loses 2.4 logical pixels per edge rather than 2. Neither value lands on a whole physical pixel alone; equal, they land on the same one.
- Both niri comments are rewritten. The gap comment currently says only "Set gaps around windows in logical pixels", which is niri's own; the width comment says only how the unit is measured. Each gains the reason for the value this session chose, which is the convention `background-color` in the same block already follows.
- `border { off }` and `active-color "#7fc8ff"` are untouched. The border is a second indicator this session does not use, and no requirement here decides the ring's colour.
- The `terminal-colors` spec's requirement on plain-text rendering loses its "or, where it states nothing, deliberately the terminal's own" allowance for the background and requires the tracked configuration to name it, for the same reason it already requires the foreground to be named.
- The `window-appearance` requirement on the focus indicator drops its instruction to keep the ring at the compositor's default and requires the width to be stated and narrower than that default, on the reasoning above.
- The `window-appearance` requirement on the gap stops requiring zero and requires the gap to equal the focus marker's width, with the two changed together.

## Capabilities

### New Capabilities

<!-- None. Both surfaces already have a spec; this change tightens one requirement in each. -->

### Modified Capabilities

- `terminal-colors`: The requirement "Plain text renders at an intensity this configuration chooses" currently lets the background be either a stated value or, if nothing states one, the terminal's own. That permission is what left the terminal on Solarized. The requirement is tightened so the background is named by the tracked configuration and comes from the session's palette, with its source recorded — the same obligation the spec already places on how every other colour here is chosen.
- `window-appearance`: Two requirements change, because they decide one thing between them. "A focus indicator survives the removal of gaps and borders" currently fixes the ring at the compositor's default and gives a reason — that at zero gaps it no longer competes with a gap — which decides the width from the wrong comparison; it is changed to demand the width be stated rather than inherited, and be narrow enough that the marker reads as a division rather than a surface. "Tiled windows meet without a gap" currently requires zero, which its own reasoning does not reach; it is changed to require the gap to equal the marker's width, and the two values to move together. The obligation that the marker exist and be the only thing drawn between windows is unchanged.

## Impact

- `.config/foot/foot.ini` — one added `background` line under `[colors-dark]`, and the rewrite of the comment sentence that called the background deliberately foot's own. The `[main]`, `[scrollback]`, `[cursor]`, `[mouse]` and `[csd]` sections, the font, and the `foreground` line are untouched.
- `.config/niri/config.kdl` — `gaps 2` and `focus-ring { width 2 }` in the `layout` block, with the comment above each rewritten to give the reason for the value and to say that each depends on the other. `background-color`, the `border` block, `preset-column-widths`, `default-column-width`, every binding and every other block are untouched.
- `openspec/specs/terminal-colors/spec.md` — one modified requirement. The palette-slot, bold-weight, colour-depth, generator-absence and section-heading requirements are unchanged.
- `openspec/specs/window-appearance/spec.md` — two modified requirements, the gap and the focus marker. The client-decoration requirements, the restart-dependency requirement and the declared-background requirement are unchanged.
- `.gitignore` — no change. `.config/foot/foot.ini` is allowlisted at line 79, `.config/niri/config.kdl` is already tracked.
- `README.md` — no change. Its foot entry says the file configures the terminal and does not describe the terminal's colours, and its niri entry does not describe the layout's dimensions, so nothing in it becomes untrue.
- Packages: none installed or removed.
- Behaviour a reader should expect to change: the background colour of new terminal windows, the width of the ring around the active window, and the space between tiled windows narrowing from 8 logical pixels to 2. Nothing else.
- **The terminal change is not visible until the foot server is restarted.** In server mode `foot.ini` is read once, when `foot --server` starts; windows opened afterwards inherit that reading and do not re-read the file, so `systemctl --user restart foot-server.service` is part of applying this, and opening another `footclient` is not. That restart closes every terminal window currently open, since each is a client of the server being replaced; waiting for the next login applies the value just as well and closes nothing. That rule is already stated at the top of the file and required by the `terminal-emulator` spec.
- **The niri change applies on config reload and needs no restart.** niri watches its configuration file and reloads it in place; the gaps and the ring redraw as soon as the file is saved. This is the opposite of the terminal's behaviour, in the same change, which is worth knowing before concluding that one half did not take.
- `.config/herdr/config.toml` is untouched. herdr carries its own `[theme]` (`gruvbox`) for the chrome it draws inside the window; whatever it paints today it paints unchanged, and this change only affects the cells herdr leaves to the terminal.
