## Context

`<leader>e` is bound in `lua/plugins/oil.lua` to `require("oil").toggle_float()`, the one call oil provides that both opens and closes itself. See proposal.md — Why for the motivation.

Oil's public API is `open`, `close`, `open_float`, and `toggle_float`. There is no in-window counterpart to `toggle_float`, so the toggle has to be assembled from `open` and `close` in the mapping's callback. Two details of oil's own behaviour make that assembly short rather than fiddly:

- `oil.open()` runs `:edit oil://<parent>` in the current window, which is exactly the full-window listing this change wants, and is the same path `:Oil` and `nvim <directory>` already take.
- `oil.close()` restores the previous buffer and its saved view. Oil records both in window variables from a `BufLeave` autocmd it installs at setup, so the restore works without this configuration tracking anything itself. When there is no recorded buffer — the editor was started on a directory — `close()` falls back to the previous buffer in the list, or an empty one, so it does not error.

## Goals / Non-Goals

**Goals:**

- Keep `<leader>e` a single-key toggle, opening and dismissing with the same press as it does today.
- Keep the return trip lossless: the buffer, cursor, and scroll the window had before are what come back.
- Keep the mapping's logic small enough to read in one glance, delegating the state handling to oil.

**Non-Goals:**

- Adding a second mapping for the float. The float is being replaced, not moved to another key; it remains reachable with `:Oil --float` for anyone who wants it once.
- Changing the explorer's contents, its columns, its write confirmation, or its netrw takeover.
- Touching the window layout — no splits are created or closed by the toggle.

## Decisions

**Detect the listing by `filetype`, not by buffer name or an oil helper.** The callback needs to know whether the current buffer is already the explorer. `vim.bo.filetype == "oil"` reads as plainly as the condition it stands for and relies on a buffer option oil sets as part of its documented configuration. The alternative, `require("oil.util").is_oil_bufnr(0)`, is a private module: it is the more precise check, but it reaches past the plugin's public surface for a distinction that does not arise here, since nothing else in this configuration sets that filetype. Matching the buffer name against `^oil://` was also considered and rejected — it duplicates knowledge of oil's URL scheme in a place that would not be updated if the scheme ever changed.

**Toggle in the mapping, rather than wrapping `oil.setup` or filing an upstream `toggle`.** The whole toggle is four lines in the callback that already exists, next to the key it belongs to. Anything more indirect would spread one behaviour across two places for no gain.

**Let `oil.close()` decide what to restore.** The obvious alternative is to capture the current buffer in the callback before calling `open()` and switch back to it explicitly. That reimplements what oil already does, and does it worse: it would restore the buffer but not the scroll position, and it would need its own answer for the case where the captured buffer has since been wiped.

## Risks / Trade-offs

- **The buffer behind the explorer is no longer visible while browsing.** → Intended, and the point of the change. Anyone who wants the old view once can open it with `:Oil --float`, which still works and is unaffected by this change.
- **`filetype == "oil"` would also match an oil buffer opened some other way — a split, or `nvim <directory>`.** → Pressing `<leader>e` in such a window dismisses the listing, which is the behaviour the key promises everywhere else. In the `nvim <directory>` case there is no previous buffer, and oil's fallback leaves an empty buffer rather than an error; the spec covers this as its own scenario.
- **`oil.close()` restores a view saved when the window was left, not necessarily the view it had at the moment of opening.** → These are the same moment for this mapping: opening the explorer is what leaves the buffer. The distinction only shows up for callers that switch buffers between the two, which this one does not.
