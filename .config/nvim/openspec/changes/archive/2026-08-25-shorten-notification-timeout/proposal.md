## Why

A notification and a short message both sit on screen for five seconds — nvim-notify's default, which noice inherits because `lua/plugins/noice.lua` deliberately passes it no options. Five seconds is long for the messages this configuration actually raises: a write confirmation, a `yanked 3 lines`, a language server reporting it has finished indexing. They are read in a glance and then occupy a corner of the editor for four seconds more, and while several are outstanding the stack grows tall enough to cover buffer text the user is working in.

## What Changes

- The `notify` view's dismissal timeout drops from nvim-notify's default 5000 ms to **1500 ms**.
- This is one setting on noice's `notify` view, in the existing `lua/plugins/noice.lua`. nvim-notify stays a bare dependency with no options table of its own, as `plugin-management` and this file's own reasoning require.
- Because noice routes short editor messages *and* `vim.notify` notifications through that one view, both shorten together. This is deliberate: they are the same transient overlay to the user, and giving them different lifetimes would need a route splitting them and would read as a bug rather than a decision.
- Nothing else changes. Long messages still open a scrollable split with no timeout, errors are still routed and still recorded, both histories still hold everything, and `<leader>nd` still dismisses early.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `message-ui`: the two requirements that say a short message and a notification each disappear "after a period" gain a stated one — long enough to read a one-line message, and bounded so that transient output does not hold the screen. The dismissal behaviour itself is unchanged; only its duration becomes contractual.

## Impact

- Modified: `lua/plugins/noice.lua` (one `views` entry and its comment), `openspec/specs/message-ui/spec.md`.
- No new plugins, no `lazy-lock.json` change, no startup cost.
- Reversible in one line: deleting the entry returns both to nvim-notify's 5000 ms.
- A message the user was mid-way through reading now vanishes sooner. `<leader>nl` (last message) and `<leader>nh` (history) are what recover it, and both already exist.
