## 1. Re-derive the inventory

- [x] 1.1 Re-derive each entry in design.md's anchor table from the file named beside it, rather than copying the table. Verify by opening every file in the "What proves it" column and confirming it still asserts the dependency: `.githooks/pre-commit`, `.gitignore`'s allowlist, `.config/fish/conf.d/env.fish`, `aliases.fish`, `direnv.fish`, `tide.fish`, `.config/herdr/equalize-slots/herdr-plugin.toml`, `.claude/statusline-command.sh`, `.claude/hooks/herdr-agent-state.sh`, and `.config/nvim/README.md`
- [x] 1.2 Check the tracked tree for a dependency the table misses: read the remaining tracked non-Neovim files and confirm each either needs nothing beyond what the table names or is already covered. Verify by listing any new entry found, or recording that none was
- [x] 1.3 Confirm the two version floors and add no others. Verify `grep -n 'min_herdr_version' .config/herdr/equalize-slots/herdr-plugin.toml` shows `0.8.0` and that `.config/nvim/README.md` still requires Neovim 0.11 or newer

## 2. Write the section

- [x] 2.1 Add `## Software this configuration expects` to `README.md`, between the end of `## Bootstrap a new machine` and `## Adding a new dotfile`. Verify `grep -n '^## ' README.md` shows it in that position and that no existing heading moved or was renamed
- [x] 2.2 Write the three groups in order — required, optional, carried by the repository — each opening with a sentence saying what the group means. Verify all three group headings are present and that the "carried" group's sentence says installing those separately is unnecessary
- [x] 2.3 Write each entry with what breaks or is lost when it is absent, and where it comes from. Verify by listing every entry and confirming none is only a name, and that no entry carries a package-manager command line
- [x] 2.4 Say outright that direnv's hook and the completion loading fail silently when absent. Verify both entries name the silence, not just the loss
- [x] 2.5 Name `lazygit` as the package that must not be installed, and say the requirement is recorded in `retired-tooling`. Verify `grep -c 'lazygit' README.md` returns at least 1 and that the sentence matches what `openspec/specs/retired-tooling/spec.md` requires
- [x] 2.6 Add the pointer line to `## Bootstrap a new machine` saying its steps need only `git` and the rest is listed below. Verify the line sits in that section and names the new section

## 3. Delegate rather than duplicate

- [x] 3.1 Point the Neovim entries at the `## Neovim` section and `.config/nvim/README.md` instead of restating that configuration's prerequisites. Verify the new section does not repeat the Neovim 0.11 / `git` / Nerd Font requirements table, and that the Nerd Font entry is justified by tide's icons as well
- [x] 3.2 Point the Claude Code entry at `## Claude Code plugins are declarative` and the herdr entry at `## herdr pane equalizing` rather than re-explaining either. Verify both cross-references name the existing section
- [x] 3.3 Verify `~/.cargo/bin` produced no entry: `grep -c 'cargo' README.md` returns 0, per design.md's exclusion

## 4. Verify against the spec

- [x] 4.1 Read the delta at `openspec/changes/document-required-software/specs/dotfiles-repo/spec.md` and check the section against each of the eight added scenarios in turn. Verify every scenario is satisfied and name the text that satisfies it
- [x] 4.2 Check the amended `Bootstrap into a new environment` scenario: verify the bootstrap section now names the software that has to be present, rather than ending at the completed bootstrap
- [x] 4.3 Verify no pre-existing rule broke: `grep -c 'nvim-config' README.md` returns 0, and the Neovim section still opens at `## Neovim` with its five subsections intact
- [x] 4.4 Run `openspec validate document-required-software --strict` and verify it reports the change valid

## 5. Commit

- [x] 5.1 Stage `README.md` and this change's directory by name, and verify `git status --porcelain` shows nothing else staged — this change writes no configuration file
