## 1. Confirm the ground truth before writing

- [x] 1.1 Re-read `.config/nvim/init.lua`, `lua/config/options.lua`, and `lua/config/lazy.lua`, and confirm the load order and the two `import` lines the section will state; verify by quoting the actual `require` order and the `plugins` / `plugins.themes` imports rather than the ones assumed here
- [x] 1.2 List `.config/nvim/lua/plugins/*.lua` and `.config/nvim/lua/plugins/themes/*.lua` and assign every file to exactly one purpose group; verify no file is left ungrouped and no group names a file that does not exist
- [x] 1.3 List `.config/nvim/openspec/specs/` and `openspec/specs/nvim-*`, and confirm both workspaces still hold Neovim specs; verify the counts and paths the section will cite

## 2. Rewrite the README's Neovim section

- [x] 2.1 Remove the `https://github.com/gmteixeira-personal/nvim-config` URL and the sentence claiming the history remains there; verify `grep -n 'nvim-config' README.md` returns nothing
- [x] 2.2 Keep a single sentence recording that `.config/nvim` was absorbed from its own repository, as the explanation for its nested `.gitignore`, `.claude/`, and `openspec/`; verify the sentence names those three subtrees and claims no recovery path
- [x] 2.3 Write the layout paragraph and its path table — `init.lua`, `lua/config/`, `lua/plugins/`, `lua/plugins/themes/`, `lazy-lock.json` — stating the `require` order and why `mapleader` forces it, and that `lua/plugins/themes/` needs its own import line because lazy.nvim descends into a subdirectory only when it holds an `init.lua`; verify each row's path exists in the tracked tree
- [x] 2.4 Write the plugin-manager paragraph: lazy.nvim, bootstrapped by `lua/config/lazy.lua` on first launch so a fresh machine needs no manual install, with `lazy-lock.json` tracked so every machine resolves the same revisions; verify the claim against `lua/config/lazy.lua` and the tracked lock file
- [x] 2.5 Write the editor-conventions paragraph covering only what applies regardless of filetype — two-column indentation with no tab character, relative numbers with an absolute cursor line, a permanently reserved sign column, smart-case search, a centred cursor, persistent undo, display-only wrapping, the system clipboard on the unnamed register, and the WSL clipboard bridge installed only where Neovim found no provider; verify each against `lua/config/options.lua`
- [x] 2.6 Write the keymap paragraph by prefix family — unprefixed `H`/`L` line boundaries and `<C-hjkl>` window focus, `<M-hjkl>` resize, `<leader>w` windows, `<leader>b` buffers, `<leader>q` session and quit, `<C-s>` save, `<M-;>` line termination — naming no individual mapping beyond those anchors; verify each family exists in `lua/config/keymaps.lua`
- [x] 2.7 Write the plugin groups as prose, one short paragraph per group, each saying what the group is for and naming its plugins: language servers and tool installation, completion, formatting, git, navigation and search, editing, interface, sessions, and themes; verify every file from task 1.2 appears in exactly one paragraph
- [x] 2.8 Add the delegation sentence naming `.config/nvim/openspec/specs/` as the authoritative per-capability detail, and note that `openspec/specs/nvim-markdown-rendering/` and `openspec/specs/nvim-scrolling/` live in the root workspace instead; verify both paths resolve

## 3. Verify the section against the spec

- [x] 3.1 Check the rewritten section against each scenario in `specs/dotfiles-repo/spec.md`; verify all four hold — no `nvim-config` match, every listed element of the description present, detail delegated rather than restated, and no plugin named that the configuration does not load
- [x] 3.2 Confirm no scenario from a `.config/nvim/openspec/specs/` spec has been copied into the README; verify by spot-checking the keymap and options paragraphs against `editor-keymaps` and `editor-options` for restated WHEN/THEN content
- [x] 3.3 Confirm every other README section is byte-identical; verify with `git diff README.md` showing changes confined to the `## Neovim` section
- [x] 3.4 Run `openspec validate document-nvim-config-in-readme --strict` and verify it reports no errors
