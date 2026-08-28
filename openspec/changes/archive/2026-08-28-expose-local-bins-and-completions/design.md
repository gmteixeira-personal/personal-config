## Context

See proposal.md — Why. The mechanics that shape the approach:

- `.bashrc` returns early for non-interactive shells, roughly a third of the way down. Everything above the return is environment the machine needs whoever is asking; everything below it is for a person at a prompt. The `~/.dotnet` and bob `nvim-bin` entries were already placed above it on purpose, each with a comment saying so.
- Plain `bash -c` never reads `.bashrc` at all, so this only matters for the shells that do read it non-interactively: a login shell running a command, which reaches `.bashrc` through `.profile`; a remote command over `ssh`, for which bash sources `.bashrc` deliberately; and anything pointing `BASH_ENV` at it.
- `.profile` adds `$HOME/bin` and `$HOME/.local/bin` itself, with its own written-out dedupe. It does not add `~/.cargo/bin`. Its blocks run after it has sourced `.bashrc`, so under bash they find the entries already present and add nothing.
- This machine has `/usr/share/bash-completion/completions` but no `/usr/share/bash-completion/bash_completion` and no `/etc/bash_completion`. The `bash-completion` loader — the thing that finds a completion script by command name on first Tab — is not installed, so nothing would discover `~/.local/share/bash-completion/completions` on its own.
- The completion block came from `openspec completion install bash`, which delimits what it wrote with `# OPENSPEC:START` / `# OPENSPEC:END` markers and rewrites between them on a later install.

## Goals / Non-Goals

**Goals:**

- One `PATH` for every shell that reads the configuration, whatever its interactivity.
- Completions that survive being carried to a machine with a different home directory.

**Non-Goals:**

- Giving `~/.cargo/bin` to a non-bash POSIX login shell. That would mean a fourth written-out block in `.profile`; the tools there are wanted by bash and by tool runners, both of which read `.bashrc`.
- Installing `bash-completion`. The eager loop is a smaller dependency than the package, and it is what makes the current machine work.
- Reorganising the rest of `.bashrc` around the early return. Only the two entries that were on the wrong side of it move.

## Decisions

**Move the two calls above the early return rather than duplicating them below it.** The alternative — leaving them where they were and adding a second pair above — would work, because `prepend_path` is idempotent, but it puts the same fact in two places in a file whose last bug was exactly that: `~/.local/bin` named twice, in two blocks that had drifted apart. One call site each.

**Keep `~/.cargo/bin` prepended before `~/.local/bin`.** Prepending reverses order, so the call that runs first ends up second in `PATH`. The existing order puts `~/.local/bin` in front, which is what `claude` and `openspec` need; moving the pair as a pair preserves it. Verified rather than assumed: the resulting `PATH` starts `~/.local/bin:~/.cargo/bin`, as it did before.

**Leave the completion block below the early return.** The `PATH` entries move because a script needs the tool; completions are only meaningful to someone pressing Tab. Sourcing them in a non-interactive shell would buy nothing and cost a file read per completion script on every hook invocation.

**Rewrite the installer's literal path to `$HOME`, and accept that a reinstall may undo it.** `openspec completion install bash` rewrites between its markers, so the literal path can come back. Alternative considered: leaving it alone and treating the block as vendor-owned. Rejected — `.bashrc` is tracked, so a reinstall that reverts the edit shows up as a diff in the working tree rather than passing unnoticed, and the cost of restoring it is one edit. The portability of the tracked file is worth more than avoiding that.

**Load the completion scripts eagerly rather than adding the `bash-completion` loader.** The loader is the general answer and does this lazily, which is better; it is also a package this machine does not have and this repository cannot install on the machines it is carried to. The loop is a handful of lines that work with or without the loader present. Where the loader does exist it will define the same functions on demand, and defining them twice is not a conflict.

**No ordering fix is needed against the loader.** The block sits well above the `/usr/share/bash-completion/bash_completion` block later in the file, so the completion scripts are sourced before the loader's helpers exist. That is fine: the generated script tests `declare -F _init_completion` when a completion runs, not when it is sourced, and by then the loader has been read.

## Risks / Trade-offs

- **A later `openspec completion install bash` rewrites the literal path back** → the file is tracked, so it appears as a diff; re-apply the `$HOME` form. Noted here so the next person seeing that diff knows it is a regression and not a stray edit.
- **Eager sourcing costs a file read per completion script at every interactive shell start** → one 28 KB file today. If the directory ever grows enough to be noticeable, installing `bash-completion` and deleting the block is the fix.
- **Every file dropped into that directory is now sourced, by whatever installed it** → it is the standard per-user completion directory, so that is its purpose; the `[ -f "$f" ]` test keeps a subdirectory from being sourced.
- **A tool installed after a shell started is still not on that shell's `PATH`** → unchanged from before; `prepend_path` tests at source time and a new shell picks it up.
- **Rollback** → restore `.bashrc` from the commit before this change; the next shell has the old behaviour back.
