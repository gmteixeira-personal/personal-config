## Why

`gd` does nothing useful in any C# file under `~/repos/yCRM`. The cursor stays where it is, or lands on the next textual occurrence of the word in the same buffer, and a symbol defined in another project is never found.

No server is attached. `./ycrm gen` writes three solution files into that repository's root — `Crm.slnx` and the `Crm.Client.slnx` / `Crm.Server.slnx` halves — and every project named by a half is also named by the whole. Any `.cs` file therefore resolves to two candidate solutions, and roslyn.nvim declines to guess: it reports `Multiple potential target files found. Use ":Roslyn target" to select a target.`, returns no workspace root, and starts nothing. With no server there is no attach, so the `gd` mapping — which is established only when a server attaches — is never bound, and the key keeps its built-in text-search meaning. The same is true of hover, diagnostics and every other language-server feature in that repository.

Fixing the selection then exposed a second fault behind it. The plugin is loaded on the `cs` and `razor` filetypes, and lazy.nvim sources a plugin's `plugin/` directory before it applies that plugin's options. roslyn.nvim's `plugin/roslyn.lua` registers the server, and registration on Neovim 0.12 also applies to buffers that already exist — so the first C# buffer of a session was resolved with the new selection rule not yet in effect. It went ambiguous exactly as before, attached a rootless client, and a second, correctly rooted client then attached beside it. Two servers for one technology in one buffer, which `language-servers` already forbids.

## What Changes

- Give roslyn.nvim a target-selection rule that picks the widest solution — the one naming every project the others do — when a buffer resolves to several candidates.
- Load roslyn.nvim at startup rather than on the `cs` and `razor` filetypes, so its configuration is in effect before any C# or Razor buffer is resolved. The server process is unaffected and still starts only when such a buffer is opened.
- Leave selection unresolved, and the plugin's own prompt intact, for a repository where no candidate matches the rule.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `language-servers`: adds a requirement that a buffer resolving to several candidate workspaces is given one rather than none; amends the per-filetype attachment requirement to say that laziness is a property of the server process, not of the configuration that selects its workspace, which must be in effect before the first buffer of that filetype is resolved.

## Impact

- `lua/plugins/roslyn.lua` gains a `choose_target` function in its `opts` and trades `ft = { "cs", "razor" }` for `lazy = false`.
- C# and Razor buffers in `~/repos/yCRM` get a server rooted at `Crm.slnx`, so `gd`, hover, diagnostics and references work there, across project boundaries — a client file can reach the server contract it calls.
- One extra Lua file is sourced at startup, in every session including those that never open a C# file. The roslyn process itself is not started by it and its cost is unchanged.
- A C# repository whose solutions are named differently is unaffected: the rule matches nothing there, and `:Roslyn target` still prompts as it does today.
- No other server is touched. The rule is passed to roslyn.nvim alone and names no other configuration.
