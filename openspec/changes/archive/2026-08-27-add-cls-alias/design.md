## Context

See proposal.md — Why. `~/.bashrc` is the tracked interactive shell configuration and already carries the stock Debian alias block: `ls`/`grep` colour aliases guarded by `dircolors`, the `ll`/`la`/`l` shorthands, `alert`, and a sourcing hook for an untracked `~/.bash_aliases` that does not exist on this machine. `.bashrc` returns early for non-interactive shells, which is what makes an alias defined there interactive-only without any extra guard.

## Goals / Non-Goals

**Goals:**

- Bind `cls` to `clear` where the existing alias block already lives, so the file keeps one place to look for shorthands.
- Establish the shape a future shorthand follows, since `shell-aliases` is a new capability and this is its first entry.

**Non-Goals:**

- Introducing `~/.bash_aliases`. The hook that sources it stays as the stock file left it; splitting the aliases out is a separate decision and would put the definitions in an untracked file.
- Porting existing shorthands to any other shell. This configuration is bash.
- A general Windows-command compatibility layer (`dir`, `copy`, `type`). Only the one name that is actually being typed is bound.

## Decisions

**Define it as an alias, not a function or a script on `PATH`.**
`clear` takes no arguments in this use, so there is nothing for a function to forward and nothing a script would add. An alias is also the construct that gives the interactive-only behaviour the spec requires for free — bash does not expand aliases in non-interactive shells. A script in `~/.local/bin` would be visible to scripts too, which the spec explicitly rules out; a function would be exported only if deliberately marked, and would still be heavier than the one line it replaces.

**Alias to `clear`, not to a hard-coded escape sequence.**
Writing `printf '\033[2J\033[H'` would bypass terminfo and misbehave on any terminal whose clear sequence differs, and it would not reset the scrollback the way `clear` does. `clear` is already a dependency of the configuration and resolves through terminfo.

**Place it in the `.bashrc` alias block, after the `ll`/`la`/`l` group.**
That block is where a reader already looks for shorthands. Putting it after the stock entries keeps the stock lines contiguous and unmodified, so the local addition is visible as a local addition in a diff against the distribution's file.

**No guard on `clear` existing.**
The other requirements in this configuration guard per-machine paths because those genuinely differ per machine; `clear` ships with ncurses and is present wherever this configuration runs. Guarding it would add a conditional whose false branch is unreachable. If it were somehow absent, `cls` would fail exactly as `clear` would, which is the correct report.

**Alternatives considered:** binding the name in `~/.inputrc` as a readline macro. Rejected — readline binds keys, not command names, so it cannot answer to something typed and entered; it would also fire mid-line and clash with the existing `ctrl-l` binding.

## Risks / Trade-offs

- **`cls` is a real executable on some systems** (a few distributions ship one, and a user-installed tool could claim the name) → the spec's no-shadowing requirement is what catches this; verifying `command -v cls` is empty before adding is a task step, and if it resolves, the alias is not added and the conflict is reported instead.
- **The habit becomes load-bearing in a script** → the alias is interactive-only by construction, so a script using `cls` fails immediately and loudly rather than working on one machine and not another. This is the intended trade-off, and it is written into the spec as a scenario.
- **Alias block grows without structure** → accepted for one line. If the local additions reach a handful, the `~/.bash_aliases` split the stock file already anticipates becomes the answer, tracked as its own change.

## Migration Plan

Adding the alias affects shells started after the change; running shells pick it up on `source ~/.bashrc` or at the next start. Rollback is deleting the line — nothing else in the configuration reads it.
