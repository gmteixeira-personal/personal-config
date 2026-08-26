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
Claude Code fetches and installs from that declaration on a new machine, so
`.claude/plugins/` — the cloned marketplaces and caches — is ignored. Its
`installLocation` fields are absolute paths that are wrong anywhere else.

To add a plugin: declare the marketplace and enable the plugin in
`settings.json`, and commit that. Never commit `.claude/plugins/`.

Two keys are deliberately absent from the tracked `settings.json`:

- `autoMode` — user-scope and machine-specific. It names a trusted repository,
  its branch policy, and its layout, so it has no place on a public remote. The
  pre-commit guard rejects any staged `settings.json` that carries it.
- Anything else describing one machine. `settings.local.json` does **not** help
  here: it is scoped to `$HOME`-as-a-project and is ignored when Claude Code
  runs from anywhere else.

## What is deliberately not tracked

| path | why |
|---|---|
| `.gitconfig` | per-machine identity and credential helpers |
| `.ssh/` | private keys |
| `.config/gh/hosts.yml` | OAuth token |
| `.claude/.credentials.json`, `.claude.json` | credentials and session state |
| `.claude/plugins/` | derived from the declaration above |
| `.bash_history`, `.psql_history`, `.viminfo` | history can contain anything |
| `.config/openspec/config.json` | telemetry state; a published `anonymousId` is not anonymous |
| `.cache/`, `.local/`, `.npm/`, `.nuget/`, `.cargo/`, `.dotnet/`, `.nvm/`, `.vscode-server/` | bulk, machine-local |

## Neovim

`.config/nvim` used to be its own repository and was absorbed into this one.
Its independent history remains at
`https://github.com/gmteixeira-personal/nvim-config`.
