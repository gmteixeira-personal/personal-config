## Context

See proposal.md — Why. What constrains the approach:

- `lua/plugins/noice.lua` currently passes **no** `views` table and **no** options to nvim-notify. Both are deliberate and both are recorded in that file: presets over hand-written views, and nvim-notify as a bare dependency because `plugin-management` asks that one file describe one plugin.
- noice's `notify` view has no `timeout` of its own; it delegates to nvim-notify, whose default is 5000 ms.
- noice's defaults route `messages.view`, `messages.view_error`, `messages.view_warn` and every `vim.notify` call to that same `notify` view. One timeout governs all of them.
- `long_message_to_split = true` sends anything too long for the view to the `split` view instead, which is not timed. Shortening the `notify` timeout cannot truncate long output.

## Goals / Non-Goals

**Goals:**

- One setting, in the file that already owns this capability, reversible by deleting a line.
- The `views` table stays a single narrow entry — an exception for a value the spec now fixes, not the start of a hand-written layout.

**Non-Goals:**

- Giving notifications and short messages different lifetimes. Rejected in the proposal; it needs a route and produces two overlays that look identical and behave differently.
- Any other nvim-notify setting — position, animation, render style, maximum width. All stay at their defaults.
- Touching the `split` view, the histories, or the `<leader>n` mappings.

## Decisions

### `views.notify.timeout`, not an `opts` table on nvim-notify

```lua
views = {
  notify = { timeout = 1500 },
},
```

The alternative is `dependencies = { { "rcarriga/nvim-notify", opts = { timeout = 1500 } } }`. Rejected: it converts a bare dependency into a nested spec, which is exactly what `noice.lua` records it is avoiding, and it puts a setting for a view noice owns into the configuration of a plugin noice drives. Setting it on the view keeps every decision about how noice presents things inside noice's own options, and keeps nvim-notify a name in a list.

The cost is a `views` table in a file whose comments say presets are used instead of one. That comment gets amended rather than contradicted: presets remain the layout mechanism, and this is a single duration the spec now fixes, which no preset carries.

### 1500 ms

Under a third of nvim-notify's 5000 ms, and half the three-second ceiling the spec sets. This is below the ~2000 ms usually quoted as the floor for reading an unfamiliar line without rushing, and that is accepted rather than overlooked: almost everything this view carries is recognised rather than read — `"init.lua" 142L, 4021B written`, `3 lines yanked`, a server announcing it has finished indexing. The shape of the message is enough. Anything that has to be read word by word is either long, in which case `long_message_to_split` has already sent it to the untimed split, or recoverable through `<leader>nl` and `<leader>nh`.

The spec states a ceiling rather than this exact number, so the value can move without a spec change. The evidence that it is too low is a specific message the user finds themselves reaching for `<leader>nl` to finish — not a general sense of briskness, which is the point.

## Risks / Trade-offs

- **A message is missed.** Under a third of the window is under a third of the chance to catch something raised while the user was looking elsewhere, and 1500 ms is short enough that this will happen rather than might. → `<leader>nl` shows the last message in full and `<leader>nh` the whole session's; both already exist, and the spec now makes recoverability explicit in the same requirement that shortens the timeout.
- **A multi-line notification cannot be finished in 1500 ms** — a language server reporting a startup failure across three lines, say. → Errors and warnings go to the same view and are equally affected. If this bites, the fix is a route giving `view_error` its own longer timeout, which is a change to make with evidence rather than pre-emptively.
- **The `views` table becomes a place things accumulate.** → It is one entry with a comment saying why it is the only one. A second entry is the point to re-read the presets decision, not to extend the table by reflex.
