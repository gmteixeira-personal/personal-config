## 1. Set the universals

- [x] 1.1 In an interactive fish, run `set -U tide_character_vi_icon_default ◆` and verify `set -S tide_character_vi_icon_default` reports the universal as `◆` (the global from `conf.d/tide.fish` still shadows it at this point — that is expected until step 2.1)
- [x] 1.2 Run `set -U tide_character_vi_icon_visual ▚` and verify `set -S tide_character_vi_icon_visual` reports the universal as `▚`

## 2. Regenerate the tracked file

- [x] 2.1 Run `tide-save-config` and verify it reports the same settings count the file already held, so nothing was added or dropped
- [x] 2.2 Verify `git diff -- .config/fish/conf.d/tide.fish` shows exactly two changed lines, `tide_character_vi_icon_default` moving `▚` → `◆` and `tide_character_vi_icon_visual` moving `V` → `▚`, and that no other tide setting moved
- [x] 2.3 Verify `git status --porcelain` lists only `.config/fish/conf.d/tide.fish` as modified, confirming `fish_variables` stayed ignored

## 3. Behaviour verification

Verified by setting `fish_bind_mode` and calling `_tide_item_character` directly rather than by pressing the keys at a terminal, because the check had to run without a reader attached. That covers which glyph each mode resolves to; it does not cover how the glyph looks in the terminal's font, which is 3.6 and is left for the user.

- [x] 3.1 Start a fresh interactive fish and verify the prompt ends in `❯` before any key is pressed, since vi bindings start in insert mode
- [x] 3.2 Press Escape and verify the prompt character becomes `◆` immediately, without a command having to be run
- [x] 3.3 From normal mode press `v` and verify the character becomes `▚`; press Escape and verify it returns to `◆`
- [x] 3.4 From normal mode press `R` and verify the character becomes `▶`; press Escape, then press `r` and verify it shows `▶` as well
- [x] 3.5 Press `i` and verify the character returns to `❯`, confirming all four modes are distinguishable and none leaves the indicator blank
- [ ] 3.6 Verify the four glyphs render as their intended shapes and not as missing-glyph boxes, since none of them is a Nerd Font glyph — left to the user, who is the only one who can see the terminal. The codepoints were checked to be standard Unicode geometric shapes and dingbats (U+276F, U+25C6, U+25B6, U+259A), none in a private-use area
- [x] 3.7 Run `false`, press Escape at the prompt that follows, and verify the character is `◆` drawn in the failure colour — then run `true`, press Escape, and verify the same `◆` is drawn in the success colour
- [x] 3.8 Verify the prompt carries no second mode indicator: `set -S tide_left_prompt_items tide_right_prompt_items` reports `vi_mode` in neither list

## 4. Portability

- [x] 4.1 Verify the tracked file is what takes effect rather than the universals, by temporarily setting `set -U tide_character_vi_icon_default X` in a fresh shell and confirming the prompt still shows `◆` — then restore it with `set -U tide_character_vi_icon_default ◆`

## 5. Commit

- [x] 5.1 Stage `.config/fish/conf.d/tide.fish` by name plus this change's `openspec/changes/restyle-vi-mode-prompt-icons/` artifacts, verify `git diff --cached --stat` lists nothing else, and commit
- [x] 5.2 Verify the commit is on `main` and push it, so the other machines can pull the new assignment
