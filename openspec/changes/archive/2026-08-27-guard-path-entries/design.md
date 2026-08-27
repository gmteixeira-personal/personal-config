## Context

See proposal.md — Why. The mechanics that shape the approach:

- `.bashrc` returns early for non-interactive shells. The `PATH` blocks for dotnet and bob's Neovim sit above that return on purpose, so scripts and tool runners that never reach the interactive part still find those tools; the `~/.cargo/bin` and `~/.local/bin` blocks sit below it, where they already were.
- `.profile` sources `.bashrc` when `BASH_VERSION` is set, and then adds `$HOME/bin` and `$HOME/.local/bin` itself. Under a non-bash POSIX login shell it runs alone, so anything it uses must exist without `.bashrc` having been read.
- The file already contained the dedupe idiom twice, written out as a `case` on `":$PATH:"`. It had no existence test anywhere.
- `~/.dotnet` is created by a system-packaged dotnet on first run, for `*.dotnetFirstUseSentinel`, `*.aspNetCertificateSentinel`, `*.toolpath.sentinel` and a `corefx` cache. Its existence says nothing about whether an SDK is installed there.

## Goals / Non-Goals

**Goals:**

- One configuration that composes the right `PATH` on a machine with per-user installs and on a machine with system packages, without either machine editing it.
- Idempotence, so that re-sourcing a startup file during a session is free.

**Non-Goals:**

- Removing any of the named locations. The bob, rustup, nvm and per-user-SDK entries stay declared; they are correct somewhere.
- Detecting a tool by looking for its executable on `PATH`. That is circular here — these blocks are what put it there.
- Making `.profile` and `.bashrc` share code. They must each stand alone.
- Managing `NVM_DIR`. Its two loads are already guarded by `-s` tests on the files they source, and it contributes no `PATH` entry of its own.

## Decisions

**A helper function, not a fourth copy of the `case` block.** With existence and dedupe both required, each entry needs five lines; four entries is twenty lines of near-identical shell in which a typo would be invisible. `prepend_path` states the rule once. Alternative considered: keeping the blocks inline for readability. Rejected — the file already had the idiom twice and had drifted, which is how `~/.local/bin` came to be named in two places.

**Test the directory for `PATH`, but the executable for `DOTNET_ROOT`.** A `PATH` entry is harmless when the directory exists but is empty; the entry simply resolves nothing. `DOTNET_ROOT` is not harmless — it overrides where the runtime is looked for, so naming a directory that holds no runtime is worse than saying nothing. `~/.dotnet` is the concrete case: a system dotnet creates it, so `-d` is a false positive and `-x "$HOME/.dotnet/dotnet"` is the honest test.

**Keep `.profile` self-contained.** It does not call `prepend_path`, even though the function is in scope whenever `.profile` has just sourced `.bashrc` under bash. A POSIX login shell reads `.profile` without ever reading `.bashrc`, and a call to a function that does not exist there would abort the block. Its two stock Debian entries get the `case` dedupe written out instead. Alternative considered: defining the helper in `.profile` too. Rejected — two definitions to keep in step is the problem the helper was meant to remove.

**Prepend `~/.cargo/bin` before `~/.local/bin`, not after.** The old file added `~/.local/bin`, then `~/.cargo/bin`, then `~/.local/bin` again — so the duplicate is what put `~/.local/bin` in front. Dropping the duplicate would have silently reversed the two, and `~/.local/bin` holds the tools that must win. The order of the two calls restores the previous resolution order.

## Risks / Trade-offs

- **A tool installed after the shell started is not found until the file is re-sourced** → the test runs at source time. Accepted: this is how the existing `nvm` and `lesspipe` guards already behave, and a new shell picks it up.
- **A broken install becomes silent** → a directory that has vanished now produces no entry instead of a dead one. Neither reports anything; the difference is that `PATH` stays clean. `command -v` on the missing tool is the diagnosis in both cases.
- **`prepend_path` stays defined in the interactive shell's namespace** → one function name. Unsetting it at the end of the file would also unset it for `.profile`'s use under bash, and the name is specific enough not to collide.
- **Rollback** → restore both files from `bde4d69^`; the next shell has the old `PATH` back.
