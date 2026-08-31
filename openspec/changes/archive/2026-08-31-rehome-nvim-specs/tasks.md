## 1. Move the specs into the Neovim workspace

- [x] 1.1 Write `.config/nvim/openspec/specs/scrolling/spec.md` from `openspec/specs/nvim-scrolling/spec.md`, changing only the `# ... Specification` heading to `scrolling`. Verify with `diff <(tail -n +2 openspec/specs/nvim-scrolling/spec.md) <(tail -n +2 .config/nvim/openspec/specs/scrolling/spec.md)` that nothing but the heading differs
- [x] 1.2 Write `.config/nvim/openspec/specs/markdown-rendering/spec.md` the same way from `openspec/specs/nvim-markdown-rendering/spec.md`, and verify with the same `diff` that only the heading differs
- [x] 1.3 Leave `openspec/specs/nvim-scrolling/` and `openspec/specs/nvim-markdown-rendering/` in place — the archive step retires them. Verify both still exist and that `openspec list --specs` from `~` still lists them
- [x] 1.4 Verify both new specs are valid in their new workspace: `openspec validate --specs --strict` run from `~/.config/nvim` reports `scrolling` and `markdown-rendering` valid

## 2. Resolve the contradiction in `editor-options`

- [x] 2.1 Remove the requirement `Context is kept above and below the cursor` and its two scenarios from `.config/nvim/openspec/specs/editor-options/spec.md`. Verify `grep -c "eight lines" .config/nvim/openspec/specs/editor-options/spec.md` returns 0 and that `git diff` shows no other requirement touched
- [x] 2.2 Verify the reconciled specs describe the configuration as it is: `grep -n scrolloff .config/nvim/lua/config/options.lua` shows `999`, and `scrolling` is the only capability in that workspace stating where the cursor sits vertically

## 3. Move the planning history

- [x] 3.1 `git mv openspec/changes/archive/2026-08-27-add-nvim-scrolloff-center .config/nvim/openspec/changes/archive/` and the same for `2026-08-31-add-markdown-rendering`. Verify `git status --porcelain` reports both as renames (`R`) with no content change
- [x] 3.2 Verify the moved archives are unaltered — their delta directories are still named `specs/nvim-scrolling/` and `specs/nvim-markdown-rendering/` — and that `openspec validate --archived` run from `~/.config/nvim` reports their tasks complete

## 4. Documentation

- [x] 4.1 Delete the closing paragraph of "Where the detail lives" in `README.md` — the one naming `openspec/specs/nvim-markdown-rendering/` and `openspec/specs/nvim-scrolling/` — leaving the sentence that names `.config/nvim/openspec/` as authoritative. Verify `grep -c "nvim-scrolling\|nvim-markdown-rendering" README.md` returns 0 and that the section still names `.config/nvim/openspec/`
- [x] 4.2 Verify the section's remaining claims still hold against the relocated specs: the editor-conventions paragraph states the cursor is held at the vertical middle of the window, and the plugin list states `render-markdown` draws markdown as formatted text — both now specified in `.config/nvim/openspec/specs/`, and neither needing an edit

## 5. Prepare the retirement

- [x] 5.1 Add `retire_capabilities: true` to `openspec/changes/rehome-nvim-specs/.openspec.yaml`, beside its existing `schema:` key. Verify with `openspec validate rehome-nvim-specs --strict` that the change is still reported valid

## 6. Commit and archive

- [x] 6.1 Stage the two new Neovim specs, the edited `editor-options` spec, the edited `README.md`, the moved archives, and this change's directory, then verify `git status --porcelain` shows nothing staged from `lua/`, `init.lua`, or `lazy-lock.json`
- [x] 6.2 After committing, run `/opsx:archive rehome-nvim-specs` and verify it reports `Retiring` for both home spec files and that `openspec/specs/nvim-scrolling/` and `openspec/specs/nvim-markdown-rendering/` are gone
- [x] 6.3 Verify the end state: `openspec list --specs` from `~` names no Neovim capability, and the same command from `~/.config/nvim` lists 30, including `scrolling` and `markdown-rendering`
