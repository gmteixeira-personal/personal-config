## 1. Configuration

- [x] 1.1 Add `new_tab = "prefix+t"` and `new_workspace = "prefix+c"` to the `[keys]` table of `.config/herdr/config.toml`, with a comment naming the shipped keys they replace, and verify `herdr config check` reports no diagnostics
- [x] 1.2 Run `herdr server reload-config` and verify it applies with no diagnostics and every open pane keeps its running process

## 2. Verify the new keys

- [x] 2.1 Press the prefix followed by `t` and verify a tab is created in the active workspace and takes focus
- [x] 2.2 Press the prefix followed by `c` and verify a workspace is created and becomes active
- [x] 2.3 Press the prefix followed by `shift` and `n` and verify no workspace is created and nothing else happens

## 3. Verify nothing else moved

- [x] 3.1 With two tabs open, press the prefix followed by `n` and by `p` and verify focus moves to the next and previous tab and nothing is created
- [x] 3.2 Press the prefix followed by a bare digit and verify the tab at that position becomes active
- [x] 3.3 Press the prefix followed by `\` and by `e` and verify zoom and equalize still run, and confirm no `[[keys.command]]` block was edited
- [x] 3.4 Close the tabs and workspaces created while verifying, and confirm the session's original workspace and its running agent are intact

## 4. Land it

- [x] 4.1 Run `openspec validate --strict change-herdr-new-tab-and-workspace-keys` and verify it reports no errors
- [x] 4.2 Commit `.config/herdr/config.toml` with the change artifacts and verify `git status` offers nothing else from `.config/herdr/`
