# personal-config

My `$HOME`, version-controlled. One config, every environment.

The repository root **is** the home directory. Nothing is tracked unless it is
named explicitly in `.gitignore`, and a security denylist overrides that list
unconditionally. The remote is public — assume everything committed here is
world-readable, because it is.

## Bootstrap a new machine

These three steps need only `git`. What the tracked configuration itself expects
of the machine is listed under **Software this configuration expects**, below —
a finished bootstrap is not yet a working environment.

**1. Get the repository into `$HOME` without clobbering what is already there.**

The home directory of a fresh machine is never empty, so do not clone over it.
Fetch into place and let git tell you what collides:

```sh
cd ~
git init -b main
git remote add origin https://github.com/gmteixeira-personal/personal-config
git fetch origin
git checkout main            # refuses if a tracked file would be overwritten
```

If the checkout refuses, git names the conflicting paths. Move each aside
(`mv .bashrc .bashrc.orig`) and re-run — never `-f`, which discards the
machine's existing file silently.

**2. Activate the commit guard. Do this before staging anything.**

Git clones neither hooks nor repository-local config, so this is manual and it
is the step that matters most:

```sh
git config core.hooksPath .githooks
```

Verify it is live before trusting it:

```sh
git add -f .ghtoken 2>/dev/null; git commit -m test    # must be REJECTED
git reset
```

**3. Set your identity.** It is deliberately not tracked — machines and
accounts differ, and `~/.gitconfig` would carry one machine's answers to every
other. Set it per repository:

```sh
git config user.name  "<name>"
git config user.email "<id>+<user>@users.noreply.github.com"
```

Without this, `git commit` fails with exit 128 before the hook even runs. Use
the GitHub noreply address: commit objects are published even though
`.gitconfig` is not.

## Software this configuration expects

The three bootstrap steps above need only `git`. Everything the tracked
configuration itself reaches for is below, in three groups: what has to be
there, what is tolerated when absent, and what the repository already carries so
you do not go installing it. Each entry says where it comes from, but not with
which package manager — that answer is correct on one machine and wrong on the
next, and this configuration exists to move between them.

### Required

Without these, the tracked configuration does not work.

- **`git`** — the repository *is* `$HOME`, the commit guard in `.githooks/` is a
  git hook, and the prompt's branch segment reads from it. Nothing here starts
  without it. *A system package.*
- **`fish`** — `.config/fish/conf.d/` and `.config/fish/functions/` are the
  largest tracked block there is: the environment, the abbreviations, the key
  bindings, the prompt. Without fish none of it is read and the machine stays in
  bash, which carries a deliberate copy of the environment block and nothing
  else. *A system package.*
- **Neovim 0.11 or newer** — `EDITOR`, `VISUAL`, and `SUDO_EDITOR` all name it,
  `e` is aliased to it, and `.config/nvim/` is tracked in full. Without it every
  one of those resolves to a command that is not there. *Installed through
  `bob`, the version manager: `env.fish` already prepends
  `~/.local/share/bob/nvim-bin` to `PATH`.* That configuration states its own
  prerequisites — see **Neovim** below, and `.config/nvim/README.md`.
- **A Nerd Font in the terminal** — the prompt's segment icons and Neovim's
  filetype and status-line glyphs both come from one. Without it they render as
  replacement boxes; nothing else breaks. *Installed into the terminal
  emulator, not onto the machine.*
- **`bash`** — `.bashrc`, `.profile`, `.inputrc`, and `.bash_logout` are
  tracked, and `.bashrc` keeps its own copy of the environment block rather than
  deferring to fish, because ssh sessions, `sudo -s`, and anything invoking
  `$SHELL` still land in bash. Present on any machine this targets; listed so
  that duplication reads as deliberate.

### Optional

The configuration is written to survive these being absent. What is lost is
named; where nothing at all is printed, that is said outright.

- **`python3`** — the herdr pane equalizer runs `equalize.py` on every pane
  event and stops working entirely without it. The Claude status line also pipes
  through it, but discards the error and drops only its context-percentage
  badge, and the herdr agent-state hook checks for it and exits quietly. So one
  feature breaks and two degrade. *A system package.*
- **`direnv`** — `conf.d/direnv.fish` installs the hook only where `type -q
  direnv` succeeds, so without it project environments are activated by hand,
  which is the behaviour that predates the file. **Absence is silent**: no
  message, no hook, and the `layout venv` in `.config/direnv/direnvrc` simply
  never runs. See **Python virtual environments** below. *A system package, or a
  binary on `PATH`.*
- **`fzf` 0.74 or newer** — `conf.d/fzf.fish` sources `fzf --fish`, which is
  where Ctrl+T (pick a file into the line), Ctrl+R (pick a command out of
  history), Alt+C (change directory) and Shift+Tab (run the current token's
  completions through the picker) come from; `.bashrc` does the same with
  `fzf --bash` for the sessions that stay bash. The version floor is where the
  `--fish` and `--bash` flags arrive. **Absence is silent**: no message, and
  those four keys keep whatever fish and readline already gave them. *A system
  package.*
- **`herdr` 0.8.0 or newer** — the multiplexer that `.config/herdr/config.toml`
  configures: the prefix and keybindings, the theme, the agent panes, and the
  pane-equalizer plugin, whose `min_herdr_version` is where that floor comes
  from. Without it the whole tracked config is inert. See **herdr pane
  equalizing** below. *A per-user install.*
- **Claude Code** — `.claude/` carries the settings, the `/git:*` and `/opsx:*`
  command suites, the skills, the hooks, and the status line. Without it those
  files are just text. Its plugins are declared rather than vendored — see
  **Claude Code plugins are declarative** below. *A per-user install.*
- **The `openspec` CLI** — drives `openspec/`, where every change here is
  proposed, implemented, and archived. Without it the specs stay perfectly
  readable and the workflow around them does not run. *A per-user install
  landing in `~/.local/bin`, which `env.fish` already has on `PATH`.*
- **`gh`** — `.config/gh/config.yml` sets HTTPS as the git protocol and `co` as
  an alias for `pr checkout`. Without it nothing else changes. *A system
  package.*
- **A .NET SDK** — for C# in Neovim and nothing else; every other language works
  without it. `env.fish` points `DOTNET_ROOT` at `~/.dotnet` when a per-user
  install is there, testing for the binary rather than the directory, because a
  system-packaged `dotnet` creates that directory itself. *A per-user install
  under `~/.dotnet`, or a system package.*
- **`bash-completion`** — deliberately not needed. `.bashrc` loads every script
  in `~/.local/share/bash-completion/completions/` itself, precisely because
  that loader is missing on machines that have the directory. **Absence is
  silent, and by design.**

### Carried by the repository

Cloning gives you these. Installing them separately is unnecessary.

- **`fisher`**, the fish plugin manager — `.config/fish/functions/fisher.fish`
  is tracked.
- **`tide`**, the prompt — its functions are tracked under
  `.config/fish/functions/`, and `conf.d/tide.fish` mirrors the prompt
  configuration into globals so that git carries it while `fish_variables`
  itself stays ignored. After running `tide configure`, run `tide-save-config`
  to refresh that file.

### Must not be installed

- **`lazygit`** — retired, and required to stay that way:
  `openspec/specs/retired-tooling/spec.md` wants the package absent, no
  configuration tracked, and no state or cache directory left behind. The git
  workflow it served is covered by the Neovim git plugins and the `/git:*`
  commands. Bringing it back is a deliberate change that supersedes that
  requirement, not merely a reinstall.

## Adding a new dotfile

Two steps, in this order:

1. Add an allowlist entry to **block 3** of `.gitignore`. Directories need
   `/**` — `!/dir/` re-includes only the directory, not the files in it.
2. `git add <path>` **by name**. Never `git add -A`, `git add .`, or `-u`.

## When a file refuses to stage

```sh
git check-ignore -v <path>
```

It prints the exact file, line number, and pattern responsible. Fix by adding a
narrow block 3 exception for that one path — **never** by loosening block 4.
Block 4 is the denylist, and the commit guard enforces the same patterns.

## How `.gitignore` is organized

Git applies **last match wins**, so the four blocks each override the one above:

| block | role |
|---|---|
| 1 | `*` — ignore everything, including every non-dot entry at the root |
| 2 | `!*/` — keep directories traversable, then re-ignore non-dot root dirs |
| 3 | allowlist — the only tracked paths |
| 4 | denylist — secrets, credentials, derived state, bulk trees |

Block 2 is load-bearing: git will not re-include a file whose parent directory
is excluded, so without it every nested allowlist entry is silently inert.
Block 4 sits last so no allowlist entry can ever re-expose a secret, and it
re-ignores the large trees so `git status` prunes instead of walking ~12 GB.

## Claude Code plugins are declarative

`.claude/settings.json` carries `extraKnownMarketplaces` and `enabledPlugins`.
`.claude/plugins/` — the cloned marketplaces and caches — is ignored: it is
derived state, and its `installLocation` fields are absolute paths that are
wrong on any other machine.

To add a plugin: declare the marketplace and enable the plugin in
`settings.json`, and commit that. Never commit `.claude/plugins/`.

**On a fresh machine, expect to install once.** The declaration is read, but
the CLI does not clone marketplaces from it — tested against an isolated
`CLAUDE_CONFIG_DIR` seeded with only the committed `settings.json`,
`claude plugin marketplace list` reported `No marketplaces configured`. If
plugins are missing after the first session, materialize them:

```sh
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

The declaration still does the useful work: it records which marketplaces and
plugins belong on every machine, so this is a two-line fix rather than an
archaeology exercise.

Two keys are deliberately absent from the tracked `settings.json`:

- `autoMode` — user-scope and machine-specific. It names a trusted repository,
  its branch policy, and its layout, so it has no place on a public remote. The
  pre-commit guard rejects any staged `settings.json` that carries it.
- Anything else describing one machine. `settings.local.json` does **not** help
  here: it is scoped to `$HOME`-as-a-project and is ignored when Claude Code
  runs from anywhere else.

## herdr pane equalizing

`.config/herdr/equalize-slots/` is a local herdr plugin, written for this
repository and tracked with it. It keeps a tab's panes evenly sized: equal-width
columns first, then equal-height rows inside each column. A column that holds
stacked panes still counts as one column, which is the part every off-the-shelf
equalizer gets differently — they weight by pane count, so a column holding
three panes ends up three times as wide as its neighbours.

herdr registers local plugins per machine, so a fresh checkout needs one
command before the keybindings do anything:

```sh
herdr plugin link ~/.config/herdr/equalize-slots
herdr server reload-config
```

| key | effect |
|---|---|
| `prefix+plus` | turn automatic equalizing on or off; resizes nothing by itself |
| `prefix+e`, `prefix+=` | equalize the focused tab once, in either mode |

`prefix+plus` runs `.config/herdr/herdr-equalize-toggle`, which rewrites `mode`
in the plugin's config directory. The plugin re-reads that file on every event,
so the switch is live — no reload, no plugin disable. The selected mode is
per-machine and deliberately not tracked, and neither is anything else herdr
writes for a plugin: `plugins.json` records absolute paths and an install
timestamp, and `.plugins.lock` is an empty lock file, not a manifest.

## Python virtual environments

`.config/direnv/direnvrc` defines `layout venv`. Entering a project puts its
`.venv` on `PATH`, leaving it takes it back off, and a subdirectory counts as
inside — identically in bash and fish, from one declaration per project. The
helper names the two values the environment contributes rather than sourcing the
`activate` script the project ships, so no project-supplied code runs in either
shell.

direnv is a machine-level dependency, installed once:

```sh
sudo pacman -S direnv
```

Without it both shell hooks are inert — no error, no activation — and virtual
environments are activated by hand, exactly as they were before.

Per project, once:

```sh
echo 'layout venv' > .envrc
direnv allow
```

The approval is per machine and deliberately not tracked: it records what
someone approved *here*, and carrying it to a clone would grant, on that
machine, a trust nobody there gave. Editing `.envrc` revokes it, so the edit is
approved on its own terms.

## What is deliberately not tracked

| path | why |
|---|---|
| `.gitconfig` | per-machine identity and credential helpers |
| `.ssh/` | private keys |
| `.config/gh/hosts.yml` | OAuth token |
| `.claude/.credentials.json`, `.claude.json` | credentials and session state |
| `.claude/plugins/` | derived from the declaration above |
| `.config/herdr/plugins/`, `.config/herdr/plugins.json` | herdr's own plugin registry and config: absolute paths, install timestamps, live mode |
| `.bash_history`, `.psql_history`, `.viminfo` | history can contain anything |
| `.config/openspec/config.json` | telemetry state; a published `anonymousId` is not anonymous |
| `.cache/`, `.local/`, `.npm/`, `.nuget/`, `.cargo/`, `.dotnet/`, `.nvm/`, `.vscode-server/` | bulk, machine-local |

## Neovim

`.config/nvim/` is a self-contained Neovim configuration: Lua throughout,
`lazy.nvim` as the plugin manager, one file per plugin, a leader key of
`<Space>`, and its own OpenSpec workspace alongside them. Copying its contents
into another machine's `~/.config/nvim` gives that machine the same editor
configuration, with nothing else from this repository needed.

It provisions itself from there. The first launch clones the plugin manager,
installs about thirty plugins, and installs the language servers and formatters
those plugins need; there is no install script and no bootstrap command, and a
failed clone prints the error and exits rather than falling through into a
half-configured session. What it does not install is Neovim 0.11 or newer,
`git`, and a Nerd Font, which must already be on the machine — plus a .NET SDK
for C# alone.

### Layout and load order

| path | what lives there |
|---|---|
| `init.lua` | three `require` calls and nothing else; load order is the only thing it decides |
| `lua/config/` | `options.lua`, `keymaps.lua`, `lazy.lua` — everything that is not a plugin |
| `lua/plugins/` | one file per plugin, imported wholesale |
| `lua/plugins/themes/` | the colorschemes and the switcher that applies them |
| `lazy-lock.json` | the resolved revision of every plugin, tracked |
| `openspec/` | the specifications |

`init.lua` loads `config.options`, then `config.keymaps`, then `config.lazy`.
The order is load-bearing at the first step: `mapleader` resolves when a mapping
is *defined*, so it has to exist before any plugin spec is evaluated, and a
plugin spec that declares `keys` is evaluated by `config.lazy`. The other two
steps are ordered for readability rather than by necessity.

The split between the two general modules and the plugin files is a rule, not a
habit: a setting that would still make sense with every plugin removed belongs
in `lua/config/`, and everything a plugin needs — its options *and* the keymaps
that invoke it — belongs in that plugin's own file, so deleting that file
removes both together.

`lua/plugins/` is imported wholesale, so adding a plugin means adding one file
and restarting — no registration list, no edit to `init.lua`, no edit to any
other plugin file. Subdirectories are the exception: `lazy.nvim` descends into
one only when it holds an `init.lua`, so `lua/plugins/themes/` needs its own
`{ import = "plugins.themes" }` line. A subdirectory left unnamed contributes
nothing and reports no error, which is the failure mode that rule exists to
prevent.

### Editor conventions

These apply to every buffer regardless of filetype; a plugin's own settings live
with the plugin.

Indentation is two columns and never a tab character. Line numbers are relative,
with the absolute number on the cursor line, so a vertical motion count reads
straight off the screen. The sign column is reserved permanently rather than
sized automatically, so a git or diagnostic sign appearing cannot shove the
buffer sideways under the cursor. Search is case-insensitive until the query
contains an upper-case character, matches move under the query as it is typed,
and they stay highlighted after the search is accepted — `<Esc>` is what
dismisses them. Wrapping is display-only and breaks at word boundaries with
continuation rows indented to match; the file on disk is never modified. The
cursor is held at the vertical middle of the window and the view scrolls under
it, so the context above and below is the same however the cursor arrived. Undo
is written to disk and survives closing the file. Sessions record the layout —
window sizes and positions, folds, tabs, per-window options — and not the global
option values. New splits open right and below. Yank and delete route through
the system clipboard without the register having to be named.

Under WSL that last one needs a bridge, and the configuration installs one only
where Neovim found no provider of its own — asking the provider rather than
testing for WSL, so a faster tool Neovim already chose is never replaced. The
question is deferred a tick past startup because asking it costs about 60 ms
there.

Two of these override a Neovim default in a way that can read as a malfunction.
`scrolloff` is 999, so the cursor does not move down the screen as you scroll
and the text moves instead. `hlsearch` stays on after a search completes,
because highlights persisting is the point — they show a term's spread through
the file.

### Keymaps

`<Space>` is the leader and `\` is the local leader. A bare `<Space>` is bound
to nothing, so it never moves the cursor while a mapping is pending, and every
prefix is a prefix *only* — never a mapping in its own right — so pressing one
never waits out `timeoutlen` before showing what can follow. `which-key` lists
the continuations while a sequence is pending, and `<leader>?` lists the
mappings that belong to the current buffer alone.

Four mappings take over keys Vim already uses, unprefixed because they are
wanted constantly. `H` and `L` reach the ends of the line in two steps outward —
first non-blank, then column zero; last non-blank, then past the trailing
whitespace — and they are real motions, so an operator consumes them and a
visual selection extends by them; what they displace is given up rather than
rehomed. `<Esc>` clears the search highlight, and `<C-s>` writes the buffer from
any editing mode.

The rest sit under a prefix:

| prefix | what it covers |
|---|---|
| `<leader>w` | the built-in `<C-w>` window commands without the chord, plus a maximize toggle that restores the previous sizes rather than equalizing them |
| `<leader>b` | the buffer list — moving between buffers, and deleting this one, the others, or all |
| `<leader>q` | the editing session as a whole: quit, write-and-quit, restarting the process, and the saved sessions |
| `<leader>f` | finding file contents, buffers, help tags, symbols and colorschemes; files themselves are `<leader><leader>` |
| `<leader>g`, `<leader>h` | the repository and, per buffer and only inside a git repository, this file's hunks |
| `<leader>c` | what a language server offers: rename, code action, format |
| `<leader>m` | multiple cursors, moved off the plugin's own `\` because that is the local leader here |
| `<leader>n` | the messages and notifications noice captures |
| `<leader>t` | the `TODO:`/`FIXME:` markers found across the project |

`<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` move focus between windows, and
`<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` resize the focused one; the same four `<M->`
keys move the selection in visual mode, which does not collide because the modes
differ. `s`, `f`, `t` and `/` are labelled jumps, `gd`/`gi`/`K` and `]d`/`[d`
attach to a buffer when a language server does, `]c`/`[c` step through git
hunks, and `<M-;>` terminates the line or the selected lines with a semicolon.

Every deletion and every quit goes through `:confirm`, so a modified buffer
produces a save/discard/cancel dialog rather than an error to work around or a
bang that throws the work away.

### Plugins

Thirty-one plugin files, grouped by the job each does. `lazy-lock.json` is
tracked, so every machine resolves the same revisions rather than whatever each
one happens to fetch first.

**Language support.** `nvim-lspconfig` carries the client — diagnostics display,
the buffer-local mappings and the server configurations — while mason installs
the binaries under `stdpath("data")/mason/`, so nothing lands on the system or
on the login shell's `PATH`. `mason-lspconfig` declares which servers must be
present and enables each installed one; `mason-tool-installer` does the same for
the tools that are not servers. C# is the exception: `roslyn.nvim` starts its
own server rather than going through that path, and `vim-razor` colours the
markup half of a `.razor` buffer, which the server does not.

**Completion and formatting.** `blink.cmp` provides completion, with
`friendly-snippets` as its snippet source. `conform.nvim` is the single
formatting entry point, on write and on demand alike, so a filetype covered by
both an external formatter and a formatting-capable server cannot produce two
different results depending on which route the buffer took.

**Git.** Three tools at three scales: `gitsigns` marks how the buffer differs
from the index, line by line, and stages, resets, previews and blames those
hunks; `neogit` is the repository — staging, commits, branches, fetch, pull,
push, rebases, stashes, the log; `diffview` is a whole difference — every file
that differs against a revision, a file's history, and the three-way view a
merge conflict is resolved in.

**Navigation.** `telescope` fuzzy-finds over files, file contents, buffers, help
tags, symbols and the repository. `flash` reaches any position visible on screen
by typing what is there and pressing the label that appears beside it. `oil`
presents a directory as an ordinary buffer, so renaming a file is editing a line
— and a delete there is a real delete, not a move to trash.

**Editing.** `nvim-autopairs` closes delimiters as they are typed;
`nvim-surround` adds, changes and deletes the pair around text already in the
buffer; `mini.move` shifts a selection around as a unit; `vim-visual-multi`
edits at several places at once.

**Interface.** `lualine` is the status line: editing mode, file and modified
state, branch and working-tree summary, unpushed commits, diagnostic counts,
cursor position, macro recording. `noice` moves the command line, messages,
notifications and the wildmenu off the last screen row into floating views, so a
long message is scrolled rather than acknowledged with `Press ENTER`.
`which-key` lists what a half-typed sequence can still become.
`render-markdown` draws markdown as formatted text rather than as its markup
characters, reverting the cursor's own line to raw source so the document stays
editable in place. `todo-comments` picks the `TODO:`/`FIXME:` markers out of the
comments around them, `smear-cursor` animates the cursor between positions so a
large jump is traceable, and `mini.icons` is the single icon provider every
other plugin draws from.

**Sessions and themes.** `auto-session` writes the open buffers, the window
layout and every cursor position on exit and restores them on the next bare
launch in the same directory. `themery` is the switcher, and the only file in
the configuration that applies a colorscheme at all — `kanagawa`, `catppuccin`,
`rose-pine` and `tokyonight` are installed as bare installs that set nothing
themselves, with kanagawa wave as the fallback before a theme has been chosen.

### Where the detail lives

This section is a condensation of `.config/nvim/README.md`, which is the fuller
description of the configuration and the document to change first. Where the two
disagree, that one is right.

Neither is the specification. `.config/nvim/` holds a second OpenSpec workspace,
and `.config/nvim/openspec/specs/` is authoritative for each capability above —
the exact mappings and their modes, every option value and why it holds, which
servers are declared, what a session records.
