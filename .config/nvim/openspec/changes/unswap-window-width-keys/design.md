## Context

See proposal.md — Why. The mapping being reversed was not accidental: `2026-08-25-rehome-window-commands` decided it deliberately and wrote the argument down in its own design.md. This change overturns that decision, so the reasoning that replaces it has to be recorded somewhere durable, or the pair will drift back.

The mechanical facts that constrain the choice: `:vertical resize +2` grows the focused window whichever side of the layout it sits on, and `:vertical resize -2` shrinks it. Neither key is correct by reference to a window divider, because the command does not act on a divider. The only thing being chosen is which letter reads as "grow".

## Goals / Non-Goals

**Goals:**

- Make the horizontal pair follow the same rule the vertical pair already follows.
- Leave the rule stated in the source, not only in an archived change document.

**Non-Goals:**

- Changing the increment, the modifier, the mode, or which four keys resize.
- Touching `<M-k>`/`<M-j>`, the focus mappings, or the maximize toggle.
- Adding a `<leader>w` resize sequence. The existing comment explains why those are absent and that reasoning is unaffected.

## Decisions

**The letter names the direction the window grows toward.** `<M-k>` grows upward, `<M-j>` shrinks; by the same rule `<M-l>` grows rightward and `<M-h>` shrinks. The rejected alternative is the current pairing, whose argument was that `h` drags the shared edge leftward and so grows the left-hand window. That argument only holds when the focused window is the left one — focus the right-hand window and `h` still grows it, now dragging the edge the other way. It describes a two-window layout with the cursor on a particular side, not the command's actual behaviour, which is why it did not survive contact with real layouts. The new delta spec pins this with a scenario for the right-hand window specifically.

**The rule goes in the comment, not just the spec.** The block comment above the mappings currently explains the modifier choice and the increment but says nothing about direction, which is exactly the gap that let the pairing be argued either way. One sentence there costs nothing and is what a future reader sees first.

## Risks / Trade-offs

- **Muscle memory built on the current pairing breaks.** → Accepted; this is the change, not a side effect. The pair is two keys and the vertical pair already trains the correct instinct.
- **The archived `2026-08-25-rehome-window-commands` design.md still argues for the old direction.** → Archived documents are a record of what was decided then, not current guidance, so it is left as written. The counter-argument lives here and the current rule lives in the spec and the source comment, which are the two places anyone checks.

## Migration Plan

Not applicable — editing the config file and restarting Neovim is the whole deployment. Rollback is reverting the commit.
