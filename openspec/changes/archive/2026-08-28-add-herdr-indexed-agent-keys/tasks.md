## 1. Add the binding

- [x] 1.1 In `.config/herdr/config.toml`, add `focus_agent = "prefix+shift+1..9"` to the existing `[keys]` table directly under `prefix = "ctrl+f"` and above the `[[keys.command]]` blocks, so it stays inside `[keys]` rather than landing in a command table, verifying with `grep -n -A3 '^\[keys\]' .config/herdr/config.toml` that the line sits under the `[keys]` header
- [x] 1.2 Run `herdr config check` and verify it reports `config: ok` with no `invalid keybinding` line for `keys.focus_agent`
- [x] 1.3 Run `herdr server reload-config` and verify it reports the reload applied with empty diagnostics, then confirm with `herdr status server` that the server is still running

## 2. Verify the agent keys

- [x] 2.1 With at least two agents in the panel, press the prefix then `shift+1` and verify the pane running the first listed agent takes focus, including switching workspace or tab if that agent lives elsewhere
- [x] 2.2 Press the prefix then `shift+2` and verify focus moves to the second listed agent
- [x] 2.3 Press the prefix then `shift` and a digit higher than the number of agents listed, and verify focus does not move and no error toast appears
- [x] 2.4 Note the panel order, wait for an agent's state to change under `agent_panel_sort = "priority"`, and verify the digits address the new order — confirming the documented behaviour rather than treating the shift as a fault
- [x] 2.5 If the chord did not reach herdr in 2.1, rebind to `focus_agent = "prefix+alt+1..9"` and, failing that, `"prefix+ctrl+1..9"`, re-running `herdr config check` and `herdr server reload-config` after each and repeating 2.1 through 2.4 before continuing

## 3. Verify nothing else moved

- [x] 3.1 Press the prefix then a bare digit and verify it still switches tab, and that the focused agent did not change as a side effect
- [x] 3.2 Open the workspace list from the prefix, press a digit, and verify it still switches workspace exactly as before
- [x] 3.3 Press the prefix followed by each of `z`, `\`, `e`, and `=` and verify the zoom and equalize keys still do what they did, confirming the new `[keys]` line did not disturb the `[[keys.command]]` blocks below it

## 4. Land it

- [x] 4.1 Verify `git diff -- .config/herdr/config.toml` shows one added line and no change to the prefix or to any `[[keys.command]]` block
- [x] 4.2 Run `openspec validate add-herdr-indexed-agent-keys --strict` and verify it passes
