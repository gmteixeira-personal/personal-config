## Why

Telescope currently runs on its stock layout. On a horizontal layout the preview pane is dropped whenever the editor is narrower than Telescope's `preview_cutoff`, and the picker window is sized from Telescope's own defaults rather than from the editor's dimensions. The result is that the preview — the whole point of picking a file or a grep hit by eye rather than by name — is present or absent depending on how wide the terminal happens to be, and the picker never uses the space a large window offers.

The stock arrangement also puts the prompt underneath the result list and draws the prompt and the results as two separately framed boxes. Typing therefore happens at the bottom of the picker while the eye is reading from the top, and the two panes read as two windows that happen to be adjacent rather than as one control.

## What Changes

- Enable the preview pane explicitly as a global default, so every picker in this configuration shows one rather than inheriting whatever the upstream default happens to be.
- Switch the layout strategy to `flex`, so the picker presents the preview beside the results on a wide editor and below them on a narrow one, instead of hiding the preview when space runs short.
- Size the picker as a percentage of the editor window, with a minimum floor, so it grows and shrinks with the Neovim window rather than sitting at a fixed size.
- Move the prompt above the result list, in both arrangements, and order results best-first from the top so the strongest match sits directly under the cursor rather than at the far end of the list.
- Draw the prompt, the result list and the preview as one continuous frame rather than separately bordered boxes, so the picker reads as a single compact control with a single drawn line between one area and the next, in both arrangements.
- Keep every existing mapping (`<leader><leader>`, the `<leader>f` and `<leader>g` pickers, `<Esc>`, `<C-j>`/`<C-k>`) exactly as it is; this change touches only presentation.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fuzzy-finder`: adds requirements for a preview pane on every picker, for the picker window being laid out and sized relative to the editor window rather than at a fixed size, and for the prompt sitting above a best-first result list within a single frame.

## Impact

- `lua/plugins/telescope.lua` — the `defaults` table inside the existing `opts` function gains `layout_strategy`, `layout_config` (including `prompt_position`, the vertical `mirror`, and a zeroed `preview_cutoff` on both strategies), `sorting_strategy`, `borderchars`, and an explicit `preview` setting. The `opts` function itself gains the two border-glyph sets and a `VimResized` autocommand that keeps the active set matched to the arrangement. The `mappings` block and the whole `keys` list are unaffected.
- No new plugin dependency. `flex`, percentage layout sizing, and per-window `borderchars` are built into `telescope.nvim`; `telescope-fzf-native` stays deliberately absent, per the note at the top of the file.
- Previewing a grep hit with syntax highlighting uses `nvim-treesitter` where a parser is installed and falls back to Neovim's own highlighting otherwise; neither is a new requirement.
