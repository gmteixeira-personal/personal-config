## 1. Picker layout and preview defaults

- [x] 1.1 In `lua/plugins/telescope.lua`, inside the table returned by `opts`, add `layout_strategy = "flex"` to `defaults` alongside the existing `mappings` block.
- [x] 1.2 Add `defaults.layout_config` with a `flex.flip_columns` threshold of 120, so the arrangement flips at the width where the preview previously disappeared.
- [x] 1.3 Give `layout_config` a `width` and a `height` expressed as a proportion of the editor window, each with a `min` floor so the picker stays readable in a small window.
- [x] 1.4 Add a `layout_config.horizontal` entry setting `preview_width` as a proportion, so the side-by-side arrangement gives the preview a usable column.
- [x] 1.5 Add a `layout_config.vertical` entry setting `preview_height` as a proportion, so the stacked arrangement is sized deliberately rather than left at the stock proportion.
- [x] 1.6 Set `defaults.preview` explicitly rather than relying on the upstream default, matching the reasoning already recorded in this file for binding `<Esc>` explicitly.

## 2. Prompt position and result ordering

- [x] 2.1 Set `prompt_position = "top"` in both the `layout_config.horizontal` and the `layout_config.vertical` entry, since `flex` reads the key from whichever strategy it flipped to.
- [x] 2.2 Set `mirror = true` on the `layout_config.vertical` entry, so the stacked arrangement orders itself prompt, results, preview rather than putting the preview above the prompt.
- [x] 2.3 Set `defaults.sorting_strategy = "ascending"`, so the strongest match is the first row under the prompt rather than the last row of the list.

## 3. Merged prompt and results frame

- [x] 3.1 Replace the implicit flat `borderchars` default with a `defaults.borderchars` table keyed `prompt`, `results` and `preview`, which is the form `resolve.win_option` accepts.
- [x] 3.2 Give the `prompt` entry a blank bottom edge with vertical side pieces for its bottom corners, so its frame is left open downwards.
- [x] 3.3 Give the `results` entry a drawn top edge with tee pieces at its top corners, so it closes the shape the prompt left open and the outer verticals line up into one frame.
- [x] 3.4 Give the `preview` entry a fully closed frame, since it stays a distinct region rather than part of the prompt-and-results control.

## 5. Join the preview into the same frame

- [x] 5.1 Define two `borderchars` sets in the `opts` function, one per arrangement, since the edge that must be blanked when the preview is stacked under the results is the edge that closes the frame when it sits beside them.
- [x] 5.2 In the stacked set, blank the `results` bottom edge and give the `preview` a drawn top edge with tees, so the single frame runs from the prompt through to the bottom of the preview.
- [x] 5.3 In the side-by-side set, keep the prompt and results right border as the sole divider — `┬` at the prompt's top-right, `┴` at the results' bottom-right — and blank the `preview` left edge, using `─` for its two left corners so the outer lines run through.
- [x] 5.4 Name the flip width as one local and use it for both `flex.flip_columns` and the glyph-set choice, so the two cannot disagree about which arrangement is in play.
- [x] 5.5 Seed `defaults.borderchars` with the set matching the current width, and register a `VimResized` autocommand that writes the matching set back to `require("telescope.config").values.borderchars`, which is what the next picker reads when it is built.
- [x] 5.6 Set `preview_cutoff = 0` on both the `horizontal` and the `vertical` entry, so neither strategy drops the preview on its own and leaves the joined border meeting nothing.
- [x] 5.7 Comment the two sets with why the glyphs differ per arrangement, and the autocommand with why writing back to Telescope's config is enough.

## 4. Documentation in the config

- [x] 4.1 Extend the file's header comment to record why `flex` was chosen over lowering `preview_cutoff` — that a narrow window gets the preview moved, not removed.
- [x] 4.2 Comment the `layout_config` block with what the proportions and the `min` floor are for, in the style of the comments already in this file.
- [x] 4.3 Note next to `preview` that it is set explicitly to pin the behaviour the spec now requires, not because the default differs today.
- [x] 4.4 Note next to `sorting_strategy` that it follows from the prompt move — `"descending"` would leave the best match at the far end of the list from the prompt, and would make `move_selection_next` walk up the screen.
- [x] 4.5 Note next to `borderchars` that the two rows between the prompt and the first result are each window's own border row and cannot be removed, so the compact look comes from making them read as one frame.
