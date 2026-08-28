## 1. Confirm the chord is deliverable

- [x] 1.1 With herdr still on `ctrl+f`, verify the terminal sends something for `ctrl+space` — run `cat -v` in a pane, press `ctrl+space`, and confirm it prints `^@` rather than nothing; if nothing arrives, stop, leave the prefix at `ctrl+f`, and report that the terminal does not deliver the chord
- [x] 1.2 Confirm no tracked configuration claims the chord: `grep -rn 'C-@\|C-space\|ctrl+space' .inputrc .bashrc .config/herdr/config.toml` returns nothing

## 2. Rebind the prefix

- [x] 2.1 In `.config/herdr/config.toml`, change the `prefix` line in `[keys]` from `ctrl+f` to `ctrl+space`, verifying with `grep -n -A3 '^\[keys\]' .config/herdr/config.toml` that the new value sits under the `[keys]` header and `focus_agent` below it is untouched
- [x] 2.2 Confirm no `[[keys.command]]` block was edited: `git diff .config/herdr/config.toml` shows exactly one changed line

## 3. Apply and verify in the running server

- [x] 3.1 Ask herdr to reload its configuration and verify open sessions survive the reload
- [x] 3.2 Press `ctrl+space` followed by `\` in a tab with more than one pane and verify zoom toggles
- [x] 3.3 Press `ctrl+space` followed by `e` and verify the panes equalize
- [x] 3.4 Press `ctrl+space` followed by `shift` and a digit naming an agent in the panel and verify that agent's pane takes focus
- [x] 3.5 Press `ctrl+f` and `ctrl+b` each followed by a prefixed action's key and verify neither runs it
- [x] 3.6 Press `ctrl+f` in a pane running a program that binds it and verify the program receives it rather than herdr consuming it

## 4. Close out

- [x] 4.1 Run `openspec validate change-herdr-prefix-to-ctrl-space --strict` and resolve anything it reports
- [x] 4.2 Commit the configuration change with the change's artifacts
