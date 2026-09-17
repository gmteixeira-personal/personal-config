## Context

See `proposal.md` — Why. Two mechanisms shape the approach and neither is ours to change.

**Target resolution.** roslyn.nvim's workspace resolution walks upward from the buffer for `.sln`, `.slnx` and `.slnf` files, keeps those that name the buffer's own `.csproj`, and then branches on the count. One survivor is the workspace. None falls back to the project directory. More than one consults a `choose_target` hook, and if that hook is absent or returns nothing the decision is `ambiguous`: `root_dir` calls back with `nil`, no workspace is set, and the user is told to run `:Roslyn target`. The hook is the plugin's only supported way to answer the question ahead of time; there is no marker file or precedence order it reads instead.

**Load order.** lazy.nvim loads a plugin in two steps — `packadd`, which sources the plugin's `plugin/` directory, and then `config`, which applies `opts`. roslyn.nvim's `plugin/roslyn.lua` calls `vim.lsp.enable("roslyn")`, and on Neovim 0.12 that applies to buffers that already exist as well as registering the `FileType` autocommand for later ones. Under `ft = { "cs", "razor" }` both steps run inside the `FileType` event of the first C# buffer, in that order, so that buffer is resolved before `opts` has been applied.

The two compose badly: the hook exists, but under `ft` it is installed one step too late to answer for the buffer that triggered the load.

## Goals / Non-Goals

**Goals:**

- Resolve the target by rule, in every session, without a per-session command.
- Have the rule hold for the first C# or Razor buffer of a session, not only for later ones.
- Keep the roslyn process itself out of sessions that open no C# or Razor file.

**Non-Goals:**

- Choosing between the `Crm.Client` and `Crm.Server` halves per buffer. The widest solution serves both, and a per-buffer split would reintroduce exactly the boundary this change exists to cross.
- A general precedence rule for any repository with several solutions. The rule here names one file; anywhere else it matches nothing and the plugin's own prompt stands.
- Touching any other server's workspace determination. `scope-tailwind-server-to-projects` covers that ground and its `root_dir` override is untouched.

## Decisions

**Choose the widest solution, by name, in `choose_target`.**

`Crm.slnx` names every project both halves do, so selecting it costs nothing the halves would have saved and buys navigation across them. Returning `nil` for anything else is deliberate: the rule is a statement about this one repository, and a rule that silently picked a solution in an unfamiliar repository would hide the very ambiguity the plugin is right to report.

Matching on basename rather than on project count was the alternative considered. Counting projects would generalise — the widest candidate would be found anywhere without naming it — but it makes every resolution parse every candidate solution from disk, and it would silently pick a target in repositories where the plugin currently asks. The named rule is narrower and says what it means. `./ycrm gen` regenerates these files and they are not committed, so if that generator ever renames its output the rule stops matching and the prompt returns — a visible failure, not a wrong answer.

**Load the plugin at startup rather than on filetype.**

`lazy = false` is the only ordering under our control that puts `opts` ahead of the first buffer's resolution. The alternatives do not survive contact with the two mechanisms above:

- Calling `require("roslyn.config").setup(...)` from `init` fails — `init` runs before lazy.nvim adds the plugin to the runtimepath, so the module cannot be required.
- Overriding `root_dir` ourselves through `vim.lsp.config("roslyn", ...)` would replace the plugin's own resolution, and with it the `remember`/`consume` handshake that passes the chosen solution to `on_init`. The server would be rooted but never told which solution to open.
- Leaving `ft` and accepting the duplicate is not available: two clients per buffer is a violation of `language-servers`, not a cosmetic wart, and the rootless one answers requests.

The cost is one small Lua file sourced in every session. It is not the cost `ft` was avoiding — that comment named the server as the expensive part, and the server is unaffected: `vim.lsp.enable` only registers, and the process still starts on the first `cs` or `razor` buffer. The `ft` was buying nothing it claimed to buy.

## Risks / Trade-offs

- **The generated solutions are not committed, so a clone without them resolves nothing.** → Unchanged by this design: without solution files the plugin already falls back to the buffer's `.csproj` as a project root, which is the existing behaviour for a project outside a solution. `./ycrm gen` restores the solution-wide workspace.
- **A future third solution that also names every project would make "widest" ambiguous again.** → The rule matches one exact basename, so a new file does not change which target is chosen. It would only matter if `Crm.slnx` itself were split, which is a rename the rule reports by prompting.
- **Startup work grows by one plugin.** → Bounded and measurable: it is a `vim.lsp.enable` call and a table merge. If startup time ever becomes the concern, the fix is upstream ordering, not re-adding `ft`, which would restore the duplicate client.
- **The first C# buffer of a session still waits on Roslyn loading the whole solution before `gd` answers.** → Not addressed here and not a regression; it is the same wait `:Roslyn target` imposed, minus the command. `language-servers` already requires that progress be reported while it runs, so the wait is visible.
