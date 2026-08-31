## 1. Precondition

- [x] 1.1 Verify `.config/nvim/README.md` exists and that `add-readme` has been archived in the Neovim workspace: `ls .config/nvim/README.md` succeeds and `ls -d .config/nvim/openspec/changes/add-readme` fails. If either does not hold, stop — every task below reads that file

## 2. Rewrite the section

- [x] 2.1 Read `.config/nvim/README.md` in full and list the subjects it covers, so the condensation is decided against the whole document rather than against the root section's existing headings. Verify the list names, at minimum, the layout and load order, how a fresh machine acquires plugins, the editor-wide conventions, the keymaps, and the plugins
- [x] 2.2 Rewrite `README.md` between `## Neovim` and the heading that follows the section, as a condensation of that README rather than an edit of the existing text. Keep the section's current depth and its five subsections. Verify the section still opens at `## Neovim` and that `Layout and load order`, `Editor conventions`, `Keymaps`, `Plugins`, and `Where the detail lives` are all present
- [x] 2.3 Check every claim the rewritten section makes against `.config/nvim/README.md` and remove any the source does not support. Verify by listing each claim and the line of the source that carries it, and that the list has no entry with no source
- [x] 2.4 Where the previous text said something the source does not, record it rather than keeping it — those are gaps in `.config/nvim/README.md` to raise against that workspace's `documentation` capability. Verify the record is either empty or written down for the user, and that nothing in it survived into the section

## 3. Name the source and the copy-out

- [x] 3.1 In "Where the detail lives", name `.config/nvim/README.md` as the document the section condenses and say the fuller description is there, alongside the existing sentence naming `.config/nvim/openspec/` as authoritative for per-capability behaviour. Verify `grep -c '.config/nvim/README.md' README.md` returns at least 1 and that the sentence naming `.config/nvim/openspec/` is still present
- [x] 3.2 In the section's opening paragraph, state that the contents of `.config/nvim/` can be copied into another machine's `~/.config/nvim` to get the same editor configuration without the rest of this repository. Verify the sentence sits in the paragraph about the directory being self-contained, and that it names `~/.config/nvim` as the destination
- [x] 3.3 Verify the section still names no second location as specifying a Neovim capability: `grep -n 'openspec/specs' README.md` shows `.config/nvim/openspec/` and no other specs path within the Neovim section

## 4. Verify against the spec

- [x] 4.1 Read the delta at `openspec/changes/derive-nvim-readme-section/specs/dotfiles-repo/spec.md` and check the rewritten section against each of its eight scenarios in turn. Verify every scenario is satisfied and name the text that satisfies it
- [x] 4.2 Verify the pre-existing rules still hold: `grep -c 'nvim-config' README.md` returns 0, and the section still identifies the entrypoint and load order, names the plugin manager and the no-manual-step install, states the filetype-independent conventions, describes the keymap families by prefix, and lists the plugins grouped by purpose
- [x] 4.3 Run `openspec validate derive-nvim-readme-section --strict` and verify it reports the change valid

## 5. Commit

- [x] 5.1 Stage `README.md` and this change's directory by name, and verify `git status --porcelain` shows nothing staged under `.config/nvim/` — this change writes nothing there
