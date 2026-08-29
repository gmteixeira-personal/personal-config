## 1. Configuration

- [x] 1.1 Add `prompt_new_tab_name = false` to the `[ui]` section of `.config/herdr/config.toml`, with a comment saying the name is a rename away, and verify `herdr config check` reports no diagnostics
- [x] 1.2 Confirm `prompt_new_workspace_name` is left unset so workspace creation keeps its prompt, and verify by reading the file back

## 2. Verification in a running herdr

- [x] 2.1 Reload herdr's configuration and verify open sessions survive it
- [x] 2.2 Press the prefix followed by `t` and verify a tab is created and focused with no name prompt, and that the tab row shows a non-empty name for it
- [x] 2.3 Rename that tab and verify the tab row shows the new name
- [x] 2.4 Press the prefix followed by `c` and verify the workspace name prompt still appears

## 3. Tracking

- [x] 3.1 Verify `git status` shows the edited `.config/herdr/config.toml` as the only change from herdr's directory
