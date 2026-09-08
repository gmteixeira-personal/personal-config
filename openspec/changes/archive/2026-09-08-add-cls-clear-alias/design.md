## Context

See proposal.md — Why. The relevant constraint is that fish offers three mechanisms for a short name, and this configuration already uses all three for different jobs. `~/.config/fish/conf.d/aliases.fish` holds `abbr` entries, which expand at the prompt so history records the real command, and `alias` entries, which define a function so the typed name is what history keeps; its header comment states that division. `~/.config/fish/functions/` holds autoloaded functions such as `cl.fish` and `mkcd.fish`, which take arguments and do more than one thing. The whole `aliases.fish` body sits inside `if status is-interactive`, deliberately guarded there rather than by the directory it lives in.

`~/.bashrc` already carries `alias cls='clear'` in its alias block and needs no change. It also ends by `exec fish` for any interactive session that did not come from fish, so fish is the shell a person actually types at on this machine and bash keeps its prompt only when deliberately dropped into. That is what made the gap invisible for as long as it lasted: the shell holding the binding is the one nobody reaches.

## Goals / Non-Goals

**Goals:**

- Pick the fish mechanism that matches what `cls` is, and put the definition where a reader already looks for shorthands.

**Non-Goals:**

- Reconciling the rest of `shell-aliases` with what the shells actually define. The spec still carries a `cat` shows highlighted output requirement that commit b9343e9 reverted out of both shells; that drift predates this change and is its own decision.
- Porting the `abbr` entries in `aliases.fish` to bash. The requirement this change sharpens is about shorthands this configuration defines going into every shell it configures, and it is written to bind future ones; settling the existing backlog is separate work.

## Decisions

**Use `alias`, not `abbr`.**
The file's own rule is that `abbr` serves a command plus flags, where leaving the expansion in history is the point, and `alias` serves a name that should stay that name. `cls` is a rename of a bare command with no flags to reveal, so an `abbr` would expand to `clear` at the prompt and erase the very name being typed. It would also fight the reflex it exists to serve: the name would vanish under the cursor on the space bar.

**Put it in `conf.d/aliases.fish`, not `functions/cls.fish`.**
An autoloaded function is what `cl` and `mkcd` need because they take arguments and compose several commands. `cls` forwards nothing and does one thing, so a file of its own would add a lookup path for one line. `aliases.fish` is also where the interactive guard already is; a file under `functions/` is autoloaded for scripts too, which would break the interactive-only requirement rather than merely bending it.

**Alias to `clear`, matching bash.**
Same reasoning as the original bash decision: `clear` resolves through terminfo and resets scrollback, which a hard-coded escape sequence does not. Using the same target in both shells is what makes the two bindings one shorthand rather than two lookalikes.

**No guard on `clear` existing.**
`clear` ships with ncurses and is present wherever this configuration runs. This is a plain shorthand, not the deliberate-override case the spec requires a guard for.

## Risks / Trade-offs

- **`alias` in fish defines a function, which is visible to a fish script that runs in the same session** → the definition stays inside the `status is-interactive` guard, which is what keeps it out of non-interactive fish entirely. A fish script started as a separate process never reads `conf.d` in interactive mode and so never sees it.
- **A future `cls` executable on `PATH` would be shadowed in both shells rather than one** → the no-shadowing requirement already covers this, and `command -v cls` being empty is a task step. Shadowing consistently is in any case better than shadowing in one shell only.
