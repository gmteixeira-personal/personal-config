## 1. Configuration

- [x] 1.1 Add `close_pane = "prefix+q"`, `close_tab = "prefix+shift+q"`, `close_workspace = "prefix+d"`, and `detach = "prefix+shift+d"` to the `[keys]` table of `.config/herdr/config.toml`, with a comment naming the shipped keys they replace, and verify `herdr config check` reports no diagnostics
- [x] 1.2 Run `herdr server reload-config` and verify it applies with no diagnostics and every open pane keeps its running process

## 2. Verify the new keys

- [x] 2.1 Split a pane, press the prefix followed by `q` in the new pane, and verify it closes, the survivors take its space, and the session does not detach
- [x] 2.2 Create a disposable tab, press the prefix followed by `shift` and `q`, and verify the tab and its panes close and another tab becomes active
- [x] 2.3 On a disposable workspace, press the prefix followed by `d`, decline the confirmation, and verify the workspace and its panes are intact
- [x] 2.4 Press the prefix followed by `d` again, accept the confirmation, and verify the workspace closes and another becomes active
- [x] 2.5 Press the prefix followed by `shift` and `d` and verify the session detaches to the shell rather than closing a workspace

## 3. Verify nothing else moved

- [x] 3.1 Reattach the session and verify its workspaces, tabs, panes, and the processes in them are as they were
- [x] 3.2 Press the prefix followed by `x` and by `shift` and `x` in a disposable pane and tab and verify neither closes anything
- [x] 3.3 Press the prefix followed by `n`, by `p`, and by a bare digit and verify focus moves between tabs as before
- [x] 3.4 Press the prefix followed by `\` and by `e` and verify zoom and equalize still run, and confirm no `[[keys.command]]` block was edited

## 4. Land it

- [x] 4.1 Run `openspec validate --strict change-herdr-close-and-detach-keys` and verify it reports no errors
- [x] 4.2 Commit `.config/herdr/config.toml` with the change artifacts and verify `git status` offers nothing else from `.config/herdr/`
