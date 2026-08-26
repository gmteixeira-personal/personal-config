## Context

See proposal.md — Why.

`lua/plugins/telescope.lua` already carries an `opts` function that returns a table with a `defaults.mappings.i` block and nothing else. Everything about the picker's appearance is therefore Telescope's own default: `layout_strategy = "horizontal"`, `layout_config.horizontal.preview_cutoff = 120`, `prompt_position = "bottom"`, `sorting_strategy = "descending"`, widths expressed partly in absolute columns, and a single flat `borderchars` list applied identically to all three windows. That cutoff is the reason the preview comes and goes — below 120 columns Telescope drops the pane entirely rather than rearranging around it.

Two constraints shape the approach. First, the file's header comment records a deliberate decision to keep `telescope-fzf-native` out of the dependency list so that this configuration needs no C toolchain; nothing here may reintroduce a build step. Second, the same file notes that the `opts` function is what causes `require("telescope").setup()` to be called at all — the settings added here land in that same call, so they take effect through the mechanism already in place rather than needing a new one.

## Goals / Non-Goals

**Goals:**

- Express the preview, layout, ordering and border settings once, in `defaults`, so every picker — present and future — inherits them.
- Keep the diff confined to the returned table inside `opts`; the `keys` list is not touched.
- Choose proportions that behave sensibly across the range of window sizes a terminal editor actually sees, from a split pane to a full screen.

**Non-Goals:**

- Per-picker layout overrides. The proposal settles on one global default; a picker that later needs its own shape can get a `pickers.<name>` entry then.
- Changing which pickers exist, or any mapping.
- Theme helpers (`telescope.themes.get_dropdown` / `get_ivy` and friends). They replace the layout wholesale, which is the opposite of inheriting one default, and `get_ivy` in particular pins the picker to the bottom of the screen at full width.
- Preview performance tuning beyond what Telescope does by default.

## Decisions

### `layout_strategy = "flex"` over `horizontal` with a lowered `preview_cutoff`

`flex` picks between the horizontal and vertical layouts at open time based on the window's width, so a narrow window gets the preview stacked with the results instead of alongside them. The alternative — keeping `horizontal` and pushing `preview_cutoff` down to something small — keeps a single arrangement and simply squeezes the preview into an ever-narrower column; at 80 columns that column is too thin to read code in. `flex` is the option that satisfies the spec's "narrowing changes where the preview is, never whether there is one", because the vertical layout it flips to has the full window width for the preview.

`flex.flip_columns` is the threshold at which the flip happens. Telescope's default is 120, which matches the `preview_cutoff` it replaces; keeping that number means the arrangement changes at the same width where the preview used to vanish.

### Percentage sizing with a floor, via `layout_config.width`/`height`

Telescope accepts a number below 1 as a proportion of the editor window, and a `{ padding = n }` or `{ 0.9, min = n }` form for bounds. Percentages of roughly 0.85 wide and 0.85 high leave a visible frame of the underlying buffer — useful orientation — while using most of the window. The `min` floor is what the spec's small-window scenario asks for: below it the picker stops shrinking, so the prompt and a handful of results stay readable even in a small split.

Absolute sizing was the alternative and is what the current defaults partly do; it is what makes the picker look lost on a large monitor and overflow on a small one.

### `prompt_position = "top"` set in both strategies, and `mirror = true` on the vertical one

`prompt_position` is a per-strategy key: `layout_config.horizontal.prompt_position` and `layout_config.vertical.prompt_position` are separate settings, and `flex` reads whichever strategy it flipped to. Setting only one gives a picker whose prompt jumps from top to bottom when the window is resized, which is exactly the confusion the spec's "in both arrangements" clause rules out. Both get it.

The vertical layout draws preview, prompt, results in that order when `prompt_position = "top"` — the prompt ends up sandwiched between the preview and its own results. `mirror = true` reverses that to prompt, results, preview, which is what puts the prompt at the top of the picker in the narrow arrangement too and keeps the prompt-and-results frame contiguous. This is why the spec now says the preview sits *below* the results when stacked; the earlier draft of this change had it above, which was the un-mirrored order.

### `sorting_strategy = "ascending"` follows from the prompt move

Telescope's default is `"descending"`, which places the best match at the *bottom* of the result list — directly above a bottom-positioned prompt. Moving the prompt to the top without changing this leaves the strongest match at the far end of the list from the cursor, which is worse than the arrangement being replaced. `"ascending"` puts the best match on the first row, adjacent to the prompt.

This also aligns `<C-j>`/`<C-k>` with the direction they read as: under `"descending"`, `move_selection_next` walks *up* the screen. Under `"ascending"` "next" is visually downward, which is what the existing "Stepping down the result list" scenario in this capability describes.

### Per-window `borderchars`, one set per arrangement

Telescope resolves `borderchars` through `resolve.win_option`, so it accepts either one flat list applied to all three windows or a table keyed `prompt` / `results` / `preview`. The keyed form is what allows each window to be given a different frame.

The geometry to work with: Telescope places the first result at `prompt.line + prompt.height + 1 + bs`, which with a one-row prompt and a one-cell border is exactly two rows below the prompt text — the prompt's bottom border row and the results' top border row. The side-by-side preview has the same problem one axis over: `preview.col = results.col + results.width + 1 + bs` puts the preview's left border column immediately after the results' right border column. Neither doubled line can be removed; the windows are separate and each reserves its own border.

So "no gap" is achieved by making the doubled line read as a continuation of one frame: one side of each junction is blanked and the other side carries a tee, so a single drawn line divides the areas. Blanking *both* facing edges was the alternative and is worse — it turns two border rows into two blank rows, which is more visual space than the default, not less.

Which side gets blanked depends on how the windows are butted together, so there is one set of glyphs per arrangement:

- **Stacked (vertical).** Every window above blanks its bottom edge and takes vertical side pieces for its bottom corners; the window below closes the shape with a drawn top edge and tees at its top corners. Applied to prompt→results and again to results→preview, that is one continuous frame from the prompt down to the bottom of the preview.
- **Side by side (horizontal).** The prompt and the results keep their right border as the single divider column — the prompt's top-right corner becomes `┬` and the results' bottom-right corner `┴`, so the outer top and bottom lines run through the junction. The preview blanks its own left edge and uses `─` for its two left corners, continuing those lines across the column where its border would have been.

The earlier draft of this change joined only the prompt to the results and left the preview fully framed. That left the doubled line intact between the results and the preview — a visible gap in the stacked arrangement, and a doubled divider column in the side-by-side one — which is the thing this decision now removes.

### Re-picking the glyph set on `VimResized`

`borderchars` is a plain table read out of Telescope's config when a picker is constructed, and a picker is constructed on every open — so the set in `config.values.borderchars` at open time is the set that picker gets. It is not, however, re-evaluated by Telescope itself, and `flex` decides its arrangement later, inside the layout strategy, from `vim.o.columns`.

The `opts` function therefore seeds `borderchars` with the set matching the width at load time, and registers a `VimResized` autocommand that writes the matching set back to `require("telescope.config").values.borderchars`. Both the autocommand and `flex` compare against the same `flip_columns` local, so they cannot disagree about which arrangement is in play.

The alternatives were worse. A single static set cannot be right in both arrangements — the edge that must be blanked in one is the edge that closes the frame in the other. Passing `borderchars` per picker call would work, since `pickers.new` prefers `opts.borderchars`, but it means threading a helper through all ten entries of the `keys` list, which this change set out not to touch. Overriding `create_layout` globally would also work but requires reimplementing Telescope's whole layout builder, which is local to `pickers.lua`.

### `preview_cutoff = 0` on both strategies

Each strategy drops the preview pane on its own when the window falls under its `preview_cutoff` — 120 columns for `horizontal`, 40 lines for `vertical`. Both are zeroed here for two reasons. The spec requires that narrowing move the preview rather than remove it, so `flip_columns` should be the only thing reacting to a small window. And the joined border glyphs assume all three windows are on screen: with the preview gone, the results' `┴` or blank bottom edge has nothing to meet.

The one case left is a picker with no previewer at all, where Telescope creates no preview window regardless of the cutoff. Every builtin bound in this file has one, so this is a latent edge rather than a live defect.

### Preview stated explicitly rather than left to the default

`preview` defaults to enabled upstream, so setting it changes nothing today. It is set anyway because the spec now requires a preview: an explicit `preview = { ... }` line is the thing a future reader greps for, and it pins the behaviour against an upstream default flipping. This mirrors the reasoning already recorded in the file for binding `<Esc>` explicitly instead of relying on Telescope's default.

### Both layouts get their own `layout_config` entry

`layout_config` is keyed per strategy: `horizontal.preview_width` and `vertical.preview_height` are separate settings, as are the two `prompt_position` keys above, and `flex` consults whichever it flipped to. Setting only one leaves the other arrangement on stock proportions, which is how a configuration ends up looking correct on a wide screen and wrong on a narrow one. Both get an entry.

### Preview truncation left at Telescope's defaults

The spec's unrenderable-result scenario is already Telescope's behaviour: its `buffer_previewer_maker` checks for binary content and a file-size ceiling and puts a message in the pane. No custom previewer is needed, and writing one would be a larger change than this proposal covers.

## Risks / Trade-offs

- **A larger picker hides more of the buffer behind it.** → The percentages stop short of full-window and the picker is dismissed with a single `<Esc>`, which this capability already guarantees.
- **The merged frame depends on the border glyphs matching between the windows.** → All three lists of a set are written together in the same table, and both sets sit side by side; a mismatch shows immediately on the first picker opened.
- **The glyph set is chosen from `vim.o.columns` outside Telescope, so it could drift from what `flex` picks.** → Both read the same `flip_columns` local, and the autocommand fires on the only event that changes the answer. A terminal resize that Neovim does not report as `VimResized` would leave one picker with the previous set — visually wrong for one open, corrected on the next.
- **The joined border assumes a border is drawn at all.** → It is, by default; a later switch to borderless windows would make the `borderchars` table dead weight rather than wrong, and the merged look would come for free.
- **The preview opens files, so a picker over a directory of very large files does more work than before.** → Telescope's file-size ceiling and its debounced preview loading already bound this; the pickers here are scoped to a project tree, not to arbitrary paths.
- **`flex` makes the picker's shape depend on terminal width, so it looks different in different windows.** → That is the requested behaviour, and the flip threshold is a single number to move if the chosen one feels wrong in practice.
- **Syntax highlighting in the preview depends on a Treesitter parser being installed for the filetype.** → Where none is, Telescope falls back to Neovim's built-in highlighting; the pane is never blank because of it.

## Migration Plan

Not applicable — an options change inside a plugin spec. It takes effect on the next Neovim start, and reverting is deleting the added lines.
