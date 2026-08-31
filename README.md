# personal-config

My `$HOME`, version-controlled. One config, every environment.

The repository root **is** the home directory. Nothing is tracked unless it is
named explicitly in `.gitignore`, and a security denylist overrides that list
unconditionally. The remote is public — assume everything committed here is
world-readable, because it is.

## Bootstrap a new machine

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

`.config/nvim` used to be its own repository and was absorbed into this one,
which is why it carries a nested `.gitignore`, `.claude/`, and `openspec/` of
its own rather than deferring to the ones at the root.

### Layout and load order

| path | what lives there |
|---|---|
| `init.lua` | three `require` calls and nothing else; load order is the only thing it decides |
| `lua/config/` | `options.lua`, `keymaps.lua`, `lazy.lua` — everything that is not a plugin |
| `lua/plugins/` | one file per plugin, imported automatically |
| `lua/plugins/themes/` | the colorschemes and the switcher that applies them |
| `lazy-lock.json` | the resolved revision of every plugin, tracked |

`init.lua` loads `config.options`, then `config.keymaps`, then `config.lazy`.
The order is load-bearing at the first step: `mapleader` resolves when a mapping
is *defined*, so it has to exist before any plugin spec is evaluated, and a
plugin spec that declares `keys` is evaluated by `config.lazy`.

`lua/plugins/` is imported wholesale — every `.lua` file directly inside it is a
plugin spec, and adding a plugin means adding a file and nothing else.
Subdirectories are not: lazy.nvim descends into one only when it holds an
`init.lua`, so `lua/plugins/themes/` needs its own `{ import = "plugins.themes" }`
line. A subdirectory left unnamed contributes nothing and reports no error,
which is the failure mode that sentence exists to prevent.

### Editor conventions

`lua/config/options.lua` sets only what applies regardless of filetype; a
plugin's own settings live with it in `lua/plugins/`.

Indentation is two columns and never a tab character. Line numbers are relative,
with the absolute number on the cursor line, so a vertical motion count reads
straight off the screen. The sign column is reserved permanently rather than
`auto`, so a git or diagnostic sign cannot shove the buffer sideways as it
appears. Search is case-insensitive until the query contains an upper-case
character, incremental, and stays highlighted after the search is accepted —
`<Esc>` is what dismisses it. The cursor is held at the vertical middle of the
window and the view scrolls under it. Undo is written to disk, so it survives
closing the file. Wrapping is display-only and breaks at word boundaries with
the continuation rows indented to match; the file on disk is untouched. Yank and
delete route through the system clipboard without the register having to be
named.

Under WSL that last one needs a bridge, and the configuration installs one only
where Neovim found no provider of its own — asking the provider rather than
testing for WSL, so a faster tool Neovim already chose is never replaced. The
question is deferred a tick past startup because asking it costs about 60 ms
there.

### Keymaps

`lua/config/keymaps.lua` holds the general mappings; a mapping that invokes a
plugin lives with that plugin. `<Space>` is the leader.

Two families are deliberately unprefixed, because they are used too often to
pay a prefix for. `H` and `L` go to the ends of the line in two steps outward —
first non-blank, then column zero; last non-blank, then past the trailing
whitespace — and they are real motions, so an operator consumes them and a
visual selection extends by them. `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` move focus
between windows.

The rest sit under a prefix. `<M-h>`/`<M-j>`/`<M-k>`/`<M-l>` resize the focused
window toward the direction each letter names. `<leader>w` mirrors the built-in
`<C-w>` window commands without the chord, and adds a maximize toggle that
restores the previous sizes rather than equalizing them. `<leader>b` is the
buffer list. `<leader>q` is the editing session as a whole — quit, write-and-
quit, and restarting the editor process — never one window and never one buffer.
`<C-s>` writes the buffer from any editing mode, and `<M-;>` terminates the line
or the selected lines with a semicolon.

Every deletion and every quit goes through `:confirm`, so a modified buffer
produces a save/discard/cancel dialog rather than an error to work around or a
bang that throws the work away.

### Plugins

lazy.nvim is the manager, and `lua/config/lazy.lua` clones it on first launch
before anything else runs — a fresh machine needs no install step, and a failed
clone aborts loudly rather than falling through into a half-configured session.
`lazy-lock.json` is tracked, so every machine resolves the same revisions rather
than whatever each one happens to fetch first.

**Language support.** `nvim-lspconfig` carries the client — diagnostics display
and the buffer-local mappings — while mason installs the binaries under
`stdpath("data")/mason/`, so nothing lands on the system or on the login shell's
`PATH`. `mason-lspconfig` declares which servers must be present and enables
each installed one; `mason-tool-installer` does the same for the tools that are
not servers. C# is the exception: `roslyn.nvim` starts its own server rather
than going through that path, and `vim-razor` colours the markup half of a
`.razor` buffer, which the server does not.

**Completion and formatting.** `blink.cmp` provides completion, with
`friendly-snippets` as its snippet source. `conform.nvim` is the single
formatting entry point, on write and on demand alike, so a filetype covered by
both an external formatter and a formatting-capable server cannot produce two
different results depending on which route was taken.

**Git.** Three tools at three scales: `gitsigns` marks how the buffer differs
from the index, line by line, and acts on those hunks; `neogit` is the
repository — staging, commits, branches, rebases, stashes, the log; `diffview`
is the whole difference against a revision, a file's history, and the three-way
view of a merge conflict.

**Navigation.** `telescope` fuzzy-finds over files, file contents, buffers, help
and the repository. `flash` reaches any position visible on screen by typing
what is there and pressing the label that appears beside it. `oil` presents a
directory as an ordinary buffer, so renaming a file is editing a line.

**Editing.** `nvim-autopairs` closes delimiters as they are typed;
`nvim-surround` adds, changes and deletes the pair around text already in the
buffer; `mini.move` shifts a selection around as a unit; `vim-visual-multi`
edits at several places at once.

**Interface.** `lualine` replaces the stock status line with the editing mode,
the branch and working-tree summary, unpushed commits, and diagnostic counts.
`noice` moves the command line, its messages, its notifications and the wildmenu
off the last screen row into floating views. `which-key` lists what a
half-typed sequence can still become. `render-markdown` draws markdown as
formatted text rather than as its markup characters, `todo-comments` picks the
`TODO:`/`FIXME:` markers out of the comments around them, `smear-cursor`
animates the cursor between positions, and `mini.icons` is the single icon
provider the rest of them draw from.

**Sessions and themes.** `auto-session` writes the open buffers, the window
layout and every cursor position on exit and restores them on the next bare
launch in the same directory. `themery` is the switcher, and the one file in the
configuration that applies a colorscheme at all — `kanagawa`, `catppuccin`,
`rose-pine` and `tokyonight` are installed as bare installs that set nothing
themselves, with kanagawa wave as the fallback before a theme has been chosen.

### Where the detail lives

This section is an orientation, not a specification. `.config/nvim/openspec/`
is a second OpenSpec workspace, and its `specs/` directory is authoritative for
each capability above — the exact keymaps, the option values, which servers are
declared, what a session records.

Two Neovim capabilities are specified from the root workspace instead of that
one: `openspec/specs/nvim-markdown-rendering/` and
`openspec/specs/nvim-scrolling/`. Check both places before concluding a
behaviour is unspecified.
