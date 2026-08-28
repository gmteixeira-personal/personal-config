## Why

Two tools now live in per-user directories: `openspec` and `claude` in `~/.local/bin`, `herdr` and `bob` in `~/.cargo/bin`. Both of those `PATH` entries sat below `.bashrc`'s non-interactive early return, so only an interactive shell ever reached them. A shell that reads `.bashrc` without being interactive — a login shell running a command, `ssh host command`, a hook or tool runner that sources the file — returned before either line and got neither directory.

That is the shell this repository is driven from. `openspec` is the CLI behind every change in `openspec/`, and it was not on `PATH` for anything that ran non-interactively. The two entries above the return, `~/.dotnet` and bob's `nvim-bin`, were deliberately placed there for exactly this reason; `~/.cargo/bin` and `~/.local/bin` were left below it only because that is where they happened to be when the entries were first guarded.

Separately, installing `openspec`'s bash completions wrote a block into `.bashrc` that names `/home/gmteixeira/...` as a literal absolute path. This repository is one configuration carried to every environment, and every other location in these files is written relative to `$HOME`. On a machine where the home directory has a different name the block's existence test fails and completions silently never load.

## What Changes

- Move `prepend_path "$HOME/.cargo/bin"` and `prepend_path "$HOME/.local/bin"` above `.bashrc`'s non-interactive early return, keeping their order so `~/.local/bin` stays ahead of `~/.cargo/bin` in `PATH`.
- Keep the completion-loading block the `openspec` installer wrote, and rewrite the home directory it names from the literal `/home/gmteixeira` to `$HOME`.
- Leave the block below the early return: completions are meaningful only to an interactive shell.

## Capabilities

### New Capabilities

- `shell-completions`: how completion scripts installed into the per-user completion directory are loaded, on a machine that has that directory but not the `bash-completion` loader that would otherwise find them.

### Modified Capabilities

- `shell-environment`: `PATH` entries for per-machine tool locations must be reached by every shell that reads the configuration, not only by interactive ones.

## Impact

- `.bashrc` only. No tool is installed, removed, or relocated.
- Non-interactive shells that read `.bashrc` gain `~/.local/bin` and `~/.cargo/bin`, and so resolve `openspec`, `claude`, `herdr` and `bob`. Interactive shells are unchanged — the same entries, in the same order, added earlier in the file.
- A machine whose home directory is not `/home/gmteixeira` gains working completions where it previously had none.
- `.profile` is untouched, so a non-bash POSIX login shell still gets `~/.local/bin` from `.profile`'s own block and still has no `~/.cargo/bin` entry. That gap predates this change and is left alone.
