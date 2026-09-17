## 1. Target selection

- [x] 1.1 Add a `choose_target` function to the roslyn.nvim `opts` in `lua/plugins/roslyn.lua` that returns the candidate whose basename is `Crm.slnx`, and `nil` otherwise; verify by resolving a `.cs` buffer under `~/repos/yCRM` and confirming the decision is `kind = "solution"` with `target` ending in `Crm.slnx`
- [x] 1.2 Confirm the `broad_search = false` default and the reasoning recorded beside it are left intact

## 2. Load order

- [x] 2.1 Replace `ft = { "cs", "razor" }` with `lazy = false` in the same spec, recording why the ordering matters; verify by opening a `.cs` file under `~/repos/yCRM` and confirming exactly one `roslyn` client is attached with `root_dir` set to the repository root
- [x] 2.2 Confirm no `Multiple potential target files found` notification is emitted during that session

## 3. Verification

- [x] 3.1 Verify go-to-definition crosses a project boundary: request `textDocument/definition` on `ServedAudience` in `src/Crm.Server/Configuration/CrmBearerAuthentication.cs` and confirm the result resolves into `src/Crm.Server.Kernel/`
- [x] 3.2 Verify `gd` is bound to the language-server definition handler in that buffer rather than to its built-in text-search meaning
- [x] 3.3 Verify a Razor buffer in the same repository is served by the same single client, so the one-instance-per-technology requirement still holds
- [x] 3.4 Verify no server starts in a session that opens only a Lua file, confirming the laziness requirement survives the eager plugin load
- [x] 3.5 Confirm `stylua --check lua/plugins/roslyn.lua` passes and `openspec validate --strict` accepts the change
