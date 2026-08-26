## 1. Verify the API before writing against it

- [x] 1.1 Confirm the `kind` values `"replace"`, `"vsplit"`, `"split"` and `"auto"` exist in the neogit version lazy.nvim resolves, and that `require("neogit").open()` accepts `{ kind = ... }` per call
- [x] 1.2 Confirm the `integrations` option keys are still `telescope` and `diffview`, and that leaving them `nil` is what triggers `pcall(require, ...)` auto-detection
- [x] 1.3 Confirm `opts.kind` is the default used by the bare `:Neogit` command

## 2. Add the plugin file

- [x] 2.1 Create `lua/plugins/neogit.lua` returning a spec for `NeogitOrg/neogit` with `dependencies = { "nvim-lua/plenary.nvim" }`
- [x] 2.2 Set `cmd = "Neogit"` and declare no `event`, so nothing loads at startup
- [x] 2.3 Set `opts.kind = "auto"` so the bare command matches `<leader>gg`
- [x] 2.4 Set `opts.integrations = { telescope = true, diffview = false }` explicitly rather than leaving them to auto-detection
- [x] 2.5 Write the file's comments in the style of the neighbouring plugin files: what the file provides at the top, and a comment at each decision that would otherwise read as arbitrary — why `keys` and not an event, why the arrangement is an argument rather than a setting, why the integrations are stated rather than detected, why diffview is absent

## 3. Add the four mappings

- [x] 3.1 `<leader>gg` → `require("neogit").open({ kind = "auto" })`, `desc = "Git status (auto-placed)"`
- [x] 3.2 `<leader>gr` → `kind = "replace"`, with a `desc` naming the arrangement
- [x] 3.3 `<leader>gv` → `kind = "vsplit"`, with a `desc` naming the arrangement
- [x] 3.4 `<leader>gh` → `kind = "split"`, with a `desc` naming the arrangement
- [x] 3.5 Confirm `<leader>g` itself remains unbound and that no existing mapping is shadowed — `:verbose map <leader>g` should show only the eight two-key sequences (four Telescope, four neogit)

## 4. Verify against the spec

- [x] 4.1 Restart Neovim and confirm with `:Lazy` that neogit is not loaded until a mapping is pressed
- [x] 4.2 In a dirty repository, open with each of the four mappings and confirm the placement matches the arrangement the mapping names
- [x] 4.3 Confirm closing the view from `<leader>gr` restores the buffer that window held, and that closing from `<leader>gv` / `<leader>gh` leaves the original window untouched
- [x] 4.4 Stage a file, then part of a file, then unstage — confirm entries move between the unstaged and staged lists in the open view without reopening it
- [x] 4.5 With that file open in another window, confirm gitsigns' sign column follows the stage without a manual refresh; if it lags, add the `NeogitStatusRefreshed` / `NeogitCommitComplete` autocmd calling `gitsigns.refresh()` that design.md describes
- [x] 4.6 Write a commit through the view, and confirm abandoning the message buffer creates no commit and leaves the staged changes staged
- [x] 4.7 Confirm `?` inside the view lists its buffer-local keys, and that those keys have their ordinary meaning again in an editing buffer
- [x] 4.8 Open a branch switch and confirm the branch list is offered through Telescope rather than as a typed name
- [x] 4.9 From a directory that is not a git repository, press a mapping and confirm the user is asked whether to initialize a repository, that the question defaults to declining, and that declining reports the directory is not a git repository with no error trace and no window opened or replaced

## 5. Finish

- [x] 5.1 Pause on `<leader>g` and confirm which-key lists all eight mappings under the Git group with their descriptions
- [x] 5.2 Run `:checkhealth which-key` and confirm no new overlap or conflict is reported
- [x] 5.3 Commit `lua/plugins/neogit.lua` together with the `lazy-lock.json` entry the first sync writes
