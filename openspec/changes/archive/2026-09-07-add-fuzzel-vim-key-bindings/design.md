## Context

See proposal.md — Why. fuzzel 1.14 exposes a flat `[key-bindings]` table over a single-line input: one key per action, no modal state, no `hjkl` motions, no counts. `fuzzel(1)` and `fuzzel.ini(5)` mention no vim mode, so the letters exist only as extra bindings on the actions fuzzel already has.

Two properties of that table shape the whole design. Each action takes a **space-separated list** of combinations, and writing one combination replaces the whole default list rather than appending to it. And fuzzel **refuses to start** when a combination appears under two actions — the failure is not a warning at start-up but a launcher that does not open when the key is pressed.

Three of the four letters wanted here were already carrying an action: `Control+k` was `delete-line-forward`, `Control+h` was `delete-prev`, `Control+d` was `delete-next`. Only `Control+l` was free.

## Goals / Non-Goals

**Goals:**

- Bind the four letters without losing any key that worked before.
- Leave the deletion actions in a state a reader can reconstruct from the file alone.
- Fail at edit time, not at press time — the collision has to be caught before the launcher is next opened.

**Non-Goals:**

- A modal editing mode for the launcher. fuzzel has none to enable, and building one out of bindings is not possible in a flat table.
- Touching the compositor's `Mod+h/j/k/l`. Those are a different layer and do not reach a focused launcher.
- Any change to the launcher's other configuration — terminal, match fields, colours are untouched.

## Decisions

**Restate the defaults rather than trusting them.** Every action written here names its full key list, including the packaged keys: `prev=Up Control+p Control+k`, not `prev=Control+k`. The alternative — writing only the new key — is the same number of characters to get wrong and loses the arrows silently, in a way nothing reports and only a hand reaching out of habit discovers. The cost is that the file now pins defaults it did not choose, and a future fuzzel that changes one of them will not pick the change up here. That is the intended trade: a pinned default is visible in the file, a dropped one is not.

**Delete the half-line kills instead of rehoming them.** `delete-line-backward` and `delete-line-forward` are both set to `none`, and `delete-line` — clear the whole input — takes `Control+d`. The alternative considered first was to keep both and move them out of the way, `Control+Shift+d` for the forward kill and `Control+u` left where it was. It was dropped on what the actions are worth in this surface: the query is one short line, so "delete to the end of it" and "delete all of it" differ by a cursor position the user rarely thinks about, and paying two modified keys for that distinction crowds the block for nothing. `Control+w` still covers the narrower correction of one wrong word. This is the only place where a default action is removed rather than moved, and it is a deliberate reduction, not a displacement.

**Keep `Control+Shift+BackSpace` on `delete-line` alongside `Control+d`.** It is fuzzel's own key for that action and costs nothing to leave in the list; dropping it would be the same silent loss the first decision exists to prevent.

**Verify with `fuzzel --check-config`.** It parses the file and exits non-zero on a duplicate binding or an unknown keysym, which are exactly the two ways this change can be wrong. Without it the first evidence of a mistake is the launcher not opening — at which point the launcher is also not available to fix it from.

## Risks / Trade-offs

- **`Control+j` is LF in terminal encodings, and could arrive as `Return`** → fuzzel is a Wayland client reading keysyms from the compositor, not a terminal reading bytes, so `Control+j` and `Return` are distinct events. `--check-config` cannot show this; it is checked by pressing the key in a running launcher and confirming the selection moves rather than the entry launching.
- **The file now pins fuzzel defaults it did not choose** → accepted, per the first decision. The comment block states which keys are restated defaults, so a reader can tell them from the four deliberate additions.
- **Muscle memory for `Control+u` and `Control+k` as line kills** → `Control+d` clears the whole input, which is what the half-line kills were mostly being used to approximate. `Control+w` remains for a single word.
- **A future fuzzel adds a default binding on one of these letters** → it would collide and the launcher would not start. `fuzzel --check-config` after any fuzzel upgrade is the check; the comment block names the keys that were taken over, which is where a reader would look.
