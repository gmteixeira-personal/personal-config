## Context

See proposal.md — Why.

Facts verified against fish 4.8.1 on this machine rather than assumed:

- fish reads every `conf.d/*.fish` in filename order, then `config.fish`. It does this for interactive and non-interactive shells alike — confirmed by ordering probes, which reported the snippets first and `config.fish` last in both.
- `fish_user_key_bindings` is called after all configuration has been read, so the function may be defined in a `conf.d/` snippet and still take effect. Confirmed: a snippet that called `fish_vi_key_bindings` and defined `fish_user_key_bindings` produced `$fish_key_bindings` of `fish_vi_key_bindings` and the expected `bind -M insert` entry.
- `exit` inside a `conf.d/` snippet stops that snippet only; it does not end the shell. Confirmed by running a non-interactive `fish -c` against a snippet guarded that way and seeing the command still run.
- `abbr` and `alias` invoked from a `conf.d/` snippet leave working shorthands. Confirmed with `abbr --query` and `functions -q` in a fresh interactive shell.
- The repository's ignore file already carries `!/.config/fish/conf.d/**`, so a new snippet is trackable the moment it is written. `functions/` has no such entry: it is ignored today.

The existing `conf.d/env.fish` is the model this change follows — one topic, no interactivity guard because the environment is wanted by every shell, and a comment recording why `~/.bashrc` keeps its own copy.

## Goals / Non-Goals

**Goals:**

- Land the split without changing a single observable shell behaviour, so that the whole change can be judged by comparing two shells.
- Leave each file readable on its own: what it configures, and why it is guarded the way it is.

**Non-Goals:**

- Reworking any of the settings being moved. The `bind` sequences, the abbreviation set and the two functions move as they are, save for the un-nesting the split forces.
- Touching `conf.d/env.fish`, `~/.bashrc`, or the bash side of the configuration.
- A `fish_prompt`, `fish_greeting`, or any other setting not present today.

## Decisions

### Four files, split by kind, with no ordering prefixes

`conf.d/env.fish` stays; `conf.d/key-bindings.fish` takes the vi mode and `fish_user_key_bindings`; `conf.d/aliases.fish` takes the abbreviations and `alias e nvim`; `functions/mkcd.fish` and `functions/cl.fish` take one function each.

Numeric prefixes (`10-env.fish`, `20-keys.fish`) were considered and rejected. They would rename the existing `env.fish` for no gain, and they encode an order the spec deliberately forbids anything from depending on. Where a real dependency appears, the requirement is to put both halves in one file, not to sequence two.

Alternative considered: a single `conf.d/interactive.fish` holding everything that is not environment. Rejected because it recreates `config.fish` under another name — the same catch-all, one directory down.

### Shorthands go together, in a file named for the capability that governs them

`abbr` and `alias` are both command shorthands, and `shell-aliases` already covers both as one subject. Splitting them by fish's two mechanisms would put one requirement's subject in two files and force a maintainer to know which mechanism was used before knowing where to look.

### `mkcd` and `cl` go to `functions/`, not to a `conf.d/` snippet

`functions/<name>.fish` is fish's autoload path: the function is read when the name is first used, so it costs a startup that never calls it nothing, and the file name is the function name, which is the cheapest possible index. Defining them in a snippet instead would work but would define both in every interactive shell to serve the sessions that use neither.

The cost is a new `.gitignore` entry, since `functions/` is ignored today. That entry is `!/.config/fish/functions/**`, matching the shape of the `conf.d/**` line beside it.

### Each interactive file guards itself with `status is-interactive`

`conf.d/key-bindings.fish` and `conf.d/aliases.fish` each open with their own interactivity test. This is what the spec requires, and it is also what makes the change a fix rather than a move: today the shorthands are interactive-only by accident of living inside a function that only interactive shells call.

The guard is written as an `if status is-interactive` block wrapping the file's body rather than as an early `exit`. Both work — `exit` in a snippet was confirmed not to end the shell — but the block form matches `~/.bashrc`'s existing guard and does not rest on a reader knowing that `exit` means something narrower here than it does everywhere else.

The two `functions/` files need no guard: an autoloaded function is not read until something calls it, and nothing in a non-interactive shell does.

### `config.fish` is deleted rather than emptied

fish starts without it. An empty file left behind is an invitation to put the next setting there, which is how the current state arose. Its `.gitignore` allowlist line goes with it, otherwise the ignore file names a path that cannot exist.

## Risks / Trade-offs

- **The un-nesting could change when the shorthands are defined, and something might depend on the current timing** → Nothing can: the only consumer is a person at a prompt, and both the old and new arrangements have the shorthands in place before the first prompt is drawn. The verification is a side-by-side comparison of `abbr --list`, `alias`, `functions`, and `bind` between a shell started before and after.
- **A `conf.d/` snippet that errors is easy to miss, because fish reports it and carries on** → The verification step opens a fresh interactive shell and checks that it starts clean, rather than only checking that the settings arrived.
- **`functions/` becomes trackable, and fish or a tool may later write into it** → Only `mkcd.fish` and `cl.fish` are added; anything else appearing there shows up as untracked and is a deliberate decision at that point. This is the same exposure `conf.d/**` already carries, which is why `completions/` was left ignored.
- **Deleting `config.fish` is visible on every machine carrying this repository** → It is a tracked file, so the deletion propagates with the snippets that replace it; there is no window where a machine has neither.
