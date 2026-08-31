## Why

`README.md` explains how to get the repository into a fresh `$HOME`, how to arm
the commit guard, and how to resolve the collisions that follow. It never says
what has to be on the machine for any of it to do anything. A reader who follows
the bootstrap procedure to the end lands in bash with a tracked `.config/fish/`
nothing reads, `EDITOR=nvim` pointing at a binary that is not there, and a
tracked `herdr` config for a multiplexer that is not installed — with no
document naming what is missing.

The information exists, scattered across the files that need it: `env.fish`
prepends `~/.local/share/bob/nvim-bin` and probes `~/.dotnet/dotnet`,
`direnv.fish` guards its hook behind `type -q direnv`, `herdr-plugin.toml`
invokes `python3`, and `.config/nvim/README.md` names its own three
prerequisites. Reading the configuration to find out what the configuration
needs is backwards, and the parts that fail silently — direnv, the completion
loader — are exactly the ones nobody thinks to check.

## What Changes

- Add a section to `README.md` naming the software the tracked configuration
  needs, in three groups: what must be installed or the configuration does not
  work, what is optional because the configuration is written to tolerate its
  absence, and what the repository already carries so a reader does not go
  installing it.
- Say what breaks for each entry rather than only naming it. "fish" is less
  useful than "without it, everything under `.config/fish/` is inert and the
  machine stays in bash".
- Name each entry's acquisition route — a system package, `bob`, a per-user
  install under `~/.local/bin` — without pinning a distro's package manager
  command. The bootstrap section's paste-ready blocks stay as they are; this
  section is an inventory, not a script.
- Record that `fisher` and `tide` are **not** installs. Both are tracked under
  `.config/fish/functions/`, so cloning the repository provides them, and
  `conf.d/tide.fish` mirrors the prompt configuration into git precisely so that
  no per-machine step is needed. A reader told to "install tide" would be
  following an instruction this repository exists to make unnecessary.
- Name the one package that must be **absent**: `lazygit`, which
  `retired-tooling` already requires not be installed, and which no tracked
  document currently mentions.
- **Not** in this change: installing anything, adding an install script, or
  restating `.config/nvim/README.md`'s own requirements table. The Neovim
  section already condenses that table and keeps doing so.

## Capabilities

### New Capabilities

<!-- none. The documentation requirement belongs beside the bootstrap
     requirement it completes, in the capability that already governs both. -->

### Modified Capabilities

- `dotfiles-repo`: gains a requirement that the tracked documentation names the
  software the configuration depends on, separating what is required from what
  is optional from what the repository carries, and names `lazygit` as the one
  package that must not be present. The existing `Bootstrap into a new
  environment` requirement is amended so its documented-procedure scenario also
  covers naming that software — today it names only obtaining the repository,
  installing the commit guard, and resolving conflicts.

## Impact

- **Modified tracked files**: `README.md`, one new section.
  `openspec/specs/dotfiles-repo/spec.md`, via this change's delta.
- **Read, not modified**: `.config/fish/conf.d/env.fish`, `direnv.fish`,
  `.gitignore`'s allowlist, `.config/herdr/equalize-slots/herdr-plugin.toml`,
  `.claude/statusline-command.sh`, `.bashrc`, and `.config/nvim/README.md` — the
  sources the inventory is drawn from.
- **Not affected**: `.config/nvim/` in its entirety. Its own README states its
  own requirements, and the root README's Neovim section already condenses them;
  the new section points there rather than repeating it.
- **Ongoing**: a change that makes the configuration depend on a new tool, or
  removes the last use of one, updates the inventory in the same change. The
  cost of not doing so is a reader installing something nothing reads, or
  missing something that fails silently.
