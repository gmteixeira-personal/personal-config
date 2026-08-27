## Why

The window-width resize keys are inverted against the direction their letters name: `<M-h>` grows the focused window and `<M-l>` shrinks it. That pairing came from `2026-08-25-rehome-window-commands`, which argued `h` reads as "grow" because it drags the shared edge toward the left window. In daily use the intuition does not hold — the height pair `<M-k>`/`<M-j>` grows toward the letter's own direction, and the width pair reads as the odd one out every time it is pressed.

## What Changes

- `<M-l>` grows the focused window's width (`:vertical resize +2`); `<M-h>` shrinks it (`:vertical resize -2`). This is the reverse of today's mapping.
- The `editor-keymaps` requirement and its two horizontal scenarios are restated so the spec describes the new direction rather than the old one.
- The comment above the resize block in `lua/config/keymaps.lua` gains a line stating the direction rule — every key grows the focused window toward the direction its letter names. The comment records no direction rationale today, which is how the pair drifted the other way once already.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `editor-keymaps`: the requirement covering Alt-plus-direction resizing changes which of `<M-h>` and `<M-l>` grows and which shrinks the focused window's width.

## Impact

- `lua/config/keymaps.lua` — the two `<M-h>`/`<M-l>` mappings and the comment above them.
- `openspec/specs/editor-keymaps/spec.md` — via the delta spec in this change.
- Muscle memory: anyone used to the current pairing must relearn it. That is the point of the change, not a side effect.
- No plugin, no other keymap, and no vertical-resize behaviour is touched. `<M-k>`/`<M-j>` keep their current meaning.
