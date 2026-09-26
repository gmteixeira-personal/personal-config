## 1. Configuration

- [x] 1.1 Add `next_workspace = "prefix+u"` and `previous_workspace = "prefix+i"` to the `[keys]` table of `.config/herdr/config.toml`, with a comment saying which way each key moves and that herdr ships both unbound, and verify `herdr config check` reports no diagnostics
- [x] 1.2 Run `herdr server reload-config` and verify it reports `applied` with no diagnostics, and that `herdr workspace list` still lists every workspace the session had before the reload

## 2. Verify the new keys

- [x] 2.1 With two or more workspaces open and the first one active, press the prefix followed by `u` and verify the workspace below it in the sidebar becomes active and nothing is created or closed
- [x] 2.2 Press the prefix followed by `i` and verify the workspace that was active before 2.1 is active again

## 3. Verify nothing else moved

- [x] 3.1 Press the prefix followed by `w` and verify the workspace navigation surface still opens
- [x] 3.2 Confirm with `git diff --no-ext-diff .config/herdr/config.toml` that the only change is the two new keys and their comment, and that no other `[keys]` entry or `[[keys.command]]` block was edited

## 4. Land it

- [x] 4.1 Run `openspec validate --strict add-herdr-workspace-step-keys` and verify it reports no errors
- [x] 4.2 Verify `git status --porcelain` lists `.config/herdr/config.toml` as the only modified path outside `openspec/`, so no machine-local herdr state leaks into the tracked set
