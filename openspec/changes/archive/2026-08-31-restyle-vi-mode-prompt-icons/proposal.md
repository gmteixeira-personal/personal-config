## Why

The shell starts in vi key bindings — `conf.d/key-bindings.fish` calls `fish_vi_key_bindings` for every interactive shell — so the command line is always in one of four editing modes, and which one it is in decides what every subsequent keystroke does. The only thing on screen that says which is the prompt character, and today two of its four glyphs are wrong:

| Mode | `fish_bind_mode` | Glyph today |
| --- | --- | --- |
| insert | `insert` | `❯` |
| normal | `default` | `▚` |
| replace | `replace`, `replace_one` | `▶` |
| visual | `visual` | `V` |

`▚` (U+259A, a quadrant block) is on normal mode, which is where the shell sits for most of an editing session; it reads as a rendering artefact rather than as a deliberate marker, and it is the one glyph a user sees most. `V` is a letter dropped into a set of geometric shapes, so visual mode is the odd one out of the four rather than a peer of them.

Neither is a considered choice. `▚` is not tide's default for normal mode — tide ships `❮` — so it arrived by an edit that was never revisited, and `V` is the leftover of tide's letter-based mode badge showing up in the geometric set.

## What Changes

- Move `▚` to visual mode, where a block glyph reads as a selection rather than as damage, and give normal mode `◆`.
- Leave insert (`❯`) and replace (`▶`) alone. They are already correct and already distinct; reassigning them would churn the two glyphs the user is not complaining about.
- The four glyphs then form one family — `❯` `◆` `▶` `▚`, all geometric, none a letter — so the indicator reads as a set of modes rather than as four unrelated marks.
- Write the new assignment through `tide-save-config` into the tracked `conf.d/tide.fish`, not as a bare `set -U`. `fish_variables` is ignored by this repository, so a universal variable alone would fix this machine and leave every clone with `▚` on normal mode.

Not in scope: tide's separate `vi_mode` prompt segment, whose `D`/`I`/`R`/`V` letters are the `tide_vi_mode_icon_*` variables. That segment is in neither `tide_left_prompt_items` nor `tide_right_prompt_items`, so it is never drawn, and its letters are not what the user is seeing. Its variables stay as they are.

## Capabilities

### New Capabilities

- `fish-vi-mode-indicator`: what the prompt shows to say which vi editing mode the command line is in — that each mode is distinguishable, which glyph stands for which mode, that the indicator is the prompt character itself, and that the assignment travels with the repository rather than living in machine-local state.

### Modified Capabilities

<!-- none. `fish-key-bindings` governs which mode the shell starts in and what
     keys do; this change only alters what the prompt draws to report the mode,
     and requires no change to that spec. `fish-startup-files` already places
     prompt configuration in `conf.d/tide.fish`; this change follows that rule
     rather than changing it. -->

## Impact

- `.config/fish/conf.d/tide.fish` — two lines change, `tide_character_vi_icon_default` and `tide_character_vi_icon_visual`. The file is generated, so it is regenerated rather than hand-edited.
- `fish_variables` on this machine — the two universals are set first, because `tide-save-config` dumps universals and would otherwise write the old values straight back. That file stays ignored; it is the input to the dump, not the thing being shipped.
- No other tide setting moves. The committed file is byte-identical to a fresh dump of this machine's universals right now, so regenerating it produces exactly the two intended lines and no incidental drift.
- No vendored file is touched. `functions/_tide_item_character.fish` is the code that reads these variables, and fisher rewrites it on update; the change is entirely in the values it reads.
- No `.gitignore` change. `conf.d/tide.fish` is already tracked.
- No README change. It already documents that `conf.d/tide.fish` carries the prompt configuration and that `tide-save-config` refreshes it.
