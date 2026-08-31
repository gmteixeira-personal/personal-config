## Context

See `proposal.md` — Why. What shapes the approach is that every dependency is
already asserted somewhere in the tracked files, so the section is a collation
rather than a fresh judgement, and the collation has to be anchored to those
assertions or it becomes a second hand-maintained list free to drift.

`README.md` currently runs: intro, `## Bootstrap a new machine` (three numbered
steps), `## Adding a new dotfile`, `## When a file refuses to stage`,
`## How .gitignore is organized`, `## Claude Code plugins are declarative`,
`## herdr pane equalizing`, `## Python virtual environments`,
`## What is deliberately not tracked`, `## Neovim`.

Three of those sections already carry a piece of what this change collects:
`Claude Code plugins are declarative` explains that plugins are declared in
`.claude/settings.json` and cloned into an ignored directory, `herdr pane
equalizing` describes the plugin that invokes `python3`, and `Neovim` condenses
`.config/nvim/README.md`, which states that configuration's own three
prerequisites. The new section has to point at those rather than restate them.

## Goals / Non-Goals

**Goals:**

- A reader who has finished the bootstrap procedure can tell, from one place,
  what the machine still needs.
- Each entry is traceable to the tracked file that proves the dependency, so
  the list can be re-derived rather than remembered.
- The silent failures — direnv's guarded hook, the absent completion loader —
  are visible as such.

**Non-Goals:**

- Installing anything, or adding an install script. The repository has
  deliberately had no bootstrap script since it was set up, and this change does
  not introduce the first one.
- Pinning version floors the tracked files do not assert. Only two exist:
  `herdr-plugin.toml` declares `min_herdr_version = "0.8.0"`, and
  `.config/nvim/README.md` requires Neovim 0.11 or newer.
- Restating `.config/nvim/README.md`. The Neovim section already condenses it
  under a rule that says so.
- Any mechanism that checks the inventory against the configuration. As with the
  Neovim section, the rule is prose and enforcement is human.

## Decisions

### Three groups, not one table

Required, optional, and carried by the repository. A single table with a
required/optional column was considered and rejected: the third group is not a
weaker kind of dependency but a different claim entirely — "do not install this,
you already have it" — and burying that in a column reads as "optional", which
is the opposite of what it means.

The groups are prose lists rather than a table because each entry has to say
what breaks, and a consequence does not fit a table cell. `## What is
deliberately not tracked` uses a two-column table for exactly the case where the
second column *is* one short clause; this is not that case.

### Placed after the bootstrap section, with a pointer from it

The tension: prerequisites conventionally come first, but the bootstrap
procedure's three steps need only `git`, and hoisting a fifteen-entry inventory
above them puts the least urgent content first on the page.

Resolved by leaving the bootstrap section where it is and adding one line to it
saying `git` is all its steps need and the rest is listed below. The new
`## Software this configuration expects` section then follows it, before
`## Adding a new dotfile`. A reader going top to bottom hits the procedure they
came for, then the inventory, in the order they will act on them.

### Every entry is anchored to a tracked file

The inventory is derived, and the derivation is recorded here so the apply step
does not invent entries:

| Entry | Group | What proves it |
|---|---|---|
| `git` | required | the bootstrap section, `.githooks/pre-commit` |
| `fish` | required | `.gitignore` allowlist for `.config/fish/conf.d/**` and `functions/**` |
| Neovim, via `bob` | required | `env.fish` prepends `~/.local/share/bob/nvim-bin`; `EDITOR`, `VISUAL`, `SUDO_EDITOR`; `alias e nvim` |
| a Nerd Font | required | tide's icon variables in `conf.d/tide.fish`; `.config/nvim/README.md` |
| `bash` | required | `.bashrc`, `.profile`, `.inputrc`, `.bash_logout`; `env.fish` says bash keeps its own copy of the env block for ssh, `sudo -s`, and anything running `$SHELL` |
| `python3` | optional | `herdr-plugin.toml` invokes it for every action and event; `.claude/statusline-command.sh` pipes through it; `.claude/hooks/herdr-agent-state.sh` guards on it |
| `direnv` | optional | `direnv.fish` guards on `type -q direnv`; `.config/direnv/direnvrc` |
| `herdr` 0.8.0+ | optional | `.config/herdr/config.toml`, the equalize plugin, `.claude/hooks/herdr-agent-state.sh` |
| Claude Code | optional | `.claude/settings.json`, `commands/**`, `skills/**`, `hooks/**`, `statusline-command.sh` |
| the `openspec` CLI | optional | `openspec/` is tracked; the `/opsx:*` commands drive it |
| `gh` | optional | `.config/gh/config.yml` |
| a .NET SDK | optional | `env.fish` probes `~/.dotnet/dotnet`; `.config/nvim/README.md` scopes it to C# |
| `bash-completion` | optional | `shell-completions` requires loading not to depend on it |
| `fisher` | carried | `.config/fish/functions/fisher.fish` |
| `tide` | carried | `functions/tide.fish`, `tide-save-config.fish`, `_tide_*`, `functions/tide/**`, and `conf.d/tide.fish` mirroring the config that `fish_variables` would otherwise hold |
| `lazygit` | must be absent | `retired-tooling` |

`~/.cargo/bin` is deliberately **not** an entry. `env.fish` prepends it, but
nothing tracked here requires a Rust toolchain; the prepend is a no-op on a
machine without one, and listing it would put a dependency in the reader's head
that does not exist.

### `python3` is optional, on the evidence

Three tracked things call it, and re-deriving them at apply time overturned the
first reading of this entry. `.claude/hooks/herdr-agent-state.sh` guards on it
outright (`command -v python3 >/dev/null 2>&1 || exit 0`). The Claude status
line pipes through it with stderr discarded and the result tested before use, so
a machine without it loses the context-percentage badge and renders the rest of
the line unchanged. Only `herdr-plugin.toml` breaks — every action and event
command is `["python3", "equalize.py", …]` with no guard — and that is the pane
equalizer belonging to `herdr`, which is itself optional.

So nothing in the *required* group needs it, and the two things that use it
either guard or degrade. It goes in *optional*, with the pane equalizer named as
the one feature that actually stops working.

### Consequences are stated, and silence is called out

`direnv.fish` is written so a machine without direnv sees nothing at all, and
`shell-completions` requires loading to work without the `bash-completion`
loader. Both are correct, and both mean absence produces no message. Each such
entry says so, because "nothing happened" is the hardest failure to attribute.

### Acquisition route, not a command line

Each entry names where it comes from — a system package, `bob` for Neovim, a
per-user install landing in `~/.local/bin` — and stops there. The bootstrap
section's paste-ready blocks are correct because `git` behaves the same
everywhere; a package-manager line is correct for one distribution and wrong on
the next machine, and this repository's stated purpose is to move between them.

## Risks / Trade-offs

- **The inventory is a hand-maintained list that can drift from the
  configuration** — the same failure the Neovim section was just rewritten to
  end. → Reduced by anchoring every entry to the tracked file that asserts the
  dependency, so it can be re-derived, and by the spec scenario requiring a
  change that adds or removes a dependency to update the inventory in the same
  change. Not eliminated: enforcement is prose, by choice.
- **Naming optional software may read as a recommendation to install it.** →
  The group's own sentence says the configuration tolerates absence, and each
  entry says what is lost rather than what is gained.
- **`herdr`, the `openspec` CLI, and Claude Code are not distribution packages,
  and their acquisition routes are the least stable part of the list.** → Named
  as what they are rather than as a command, so a stale route costs a search
  rather than a failed paste.
- **The `bash` entry is close to noise on any machine this targets.** → Kept,
  because `env.fish` explains at length why bash carries a duplicate of the
  environment block, and a reader who skips bash entirely will not understand
  why that duplication exists.

## Migration Plan

1. The section is added to `README.md`; nothing else changes.
2. The `dotfiles-repo` delta is synced when the change is archived.
3. Rollback is `git revert` of the single commit. No tracked configuration file
   is touched, so no shell, editor, or multiplexer behaviour depends on it.
