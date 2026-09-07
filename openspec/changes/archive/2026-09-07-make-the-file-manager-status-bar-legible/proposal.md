## Why

The file manager's status bar is drawn in colours nobody chose. Its mode badge and its position badge state a background and no foreground, so their text falls through to the terminal's default foreground — measured on screen, `#aaaaaa` on `#24acd4`, a contrast ratio of **1.14:1** where 4.5:1 is the threshold for readable text. The badges are legible only at the anti-aliased edges of their glyphs. The pale chips beside them are the same fault in the other direction: `#24acd4` on `#e6e6e6`, **2.12:1**.

Neither half is a mistake on its own. The program's shipped theme names palette slots and leaves those two foregrounds unset; the terminal's configuration deliberately leaves the sixteen slots at the terminal's own defaults, on the recorded reasoning that only a program choosing its own colours can reach them. The file manager is exactly such a program, and it is the first one in this session to make the gap visible.

Repainting the terminal's slots does not fix it. With the foreground unset the text stays `#aaaaaa` whatever the background becomes — measured against this session's own palette, 1.10:1 on its blue and 1.23:1 on its sapphire. The foreground has to be stated where the program reads it.

## What Changes

- The file manager gains its own theme file, which is the first configuration it has had. Until now it ran entirely on its shipped defaults.
- The two badges that stated no foreground are given one, taking them from 1.14:1 to 2.65:1.
- The pale chips are given a dark background from the session's palette instead of the terminal's near-white slot, taking them from 2.12:1 to 4.75:1.
- Values are stated in 24-bit rather than by palette-slot name wherever they are chosen here, so they do not depend on slots this session leaves at the terminal's defaults.
- The row under the cursor is deliberately not touched. It is already the best-contrasted thing in the window at 7.08:1, and the program offers no key for it in any case.

## Capabilities

### New Capabilities
<!-- None. `file-manager` already covers which program browses files and how it is reached; what it looks like doing so belongs with it, the way `application-launcher` carries both the launcher's behaviour and its palette. -->

### Modified Capabilities
- `file-manager`: adds that the file manager's status bar states its own foregrounds rather than inheriting the terminal's, and that its colours are traceable rather than left to slots nothing chose.

## Impact

- `~/.config/yazi/theme.toml` — a new file, tracked in this repository.
- `.gitignore` — one allowlist entry, since the policy is deny-by-default.
- No change to `.config/foot/foot.ini`. The sixteen palette slots stay where they are; this change does not need them moved and repainting them would not have fixed the fault.
- Takes effect when the file manager next starts. It reads its theme once, at startup.
