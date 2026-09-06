## Context

See `proposal.md` — Why. The constraints:

- The home directory *is* the repository, so every interactive shell starts
  inside it. There is no "sometimes in the repo" case to handle.
- `git config --get core.hooksPath` prints nothing and exits non-zero when the
  key is absent, which is the state that was found here.
- The guard's other half is the hook file. `.githooks/pre-commit` is tracked, so
  a clone has it, but git does not preserve the executable bit through every
  route into a working tree and a non-executable hook is skipped in silence.
- `conf.d/colors.fish` now sets `fish_color_error`, and files in `conf.d` are
  read in name order, so `colors.fish` is read before `commit-guard.fish`.

## Goals / Non-Goals

**Goals:**

- The failure announces itself, at the place the person actually is.
- Nothing at all in the correct case.

**Non-Goals:**

- Activating the guard automatically. A shell startup file that silently writes
  repository configuration is a worse thing to own than the problem it fixes:
  it would mask the same failure on a machine where the write did not work, and
  it would run on every clone of every kind, including ones where the operator
  meant something else.
- Covering bash. See the last decision below.

## Decisions

### An interactive fish startup check, in its own `conf.d` file

The alternatives were the fish greeting, which fires once per interactive shell
and would work, and a Claude Code `SessionStart` hook, which fires where most
commits are actually authored.

`conf.d/greeting.fish` is about one variable and says so; folding an unrelated
security check into it would make the file two subjects. The Claude hook covers
less: a commit typed at a bare prompt would not be checked, and that is the case
the guard exists for. A file of its own follows the rule `greeting.fish` states
in its own comment — the startup-file layout names four categories, and a
setting of a new kind gets a file.

### Judged on whether the guard would run, not on the config key

Two conditions, reported identically: `core.hooksPath` equals `.githooks`, and
`.githooks/pre-commit` is executable. Checking only the key would have caught
this incident and would miss a clone whose hook lost its mode bit, which fails
the same way and is harder to notice.

Comparing the value to `.githooks` rather than accepting any non-empty value is
deliberate: a hooks path pointing somewhere else is not this guard.

### Cost is one `git` invocation, and it is conditional

`test -e $HOME/.git` is a fish builtin and costs nothing; only if it passes does
`git config` run, at roughly 2 ms. On a machine where the home directory is not
a repository — the tracked files copied rather than cloned — the check does not
run at all and says nothing, because there is no repository to guard.

The value is read with a quoted `"$(...)"` substitution rather than a bare
`(...)`: a bare one expands to zero arguments when git prints nothing, and
`test` then sees two arguments instead of three and errors. That is precisely
the unset case this file exists to catch, so getting it wrong would have made
the check fail exactly when it was needed.

### Reported through `fish_color_error`

Not a hardcoded colour: the variable is what the rest of the shell uses for
errors, and `conf.d/colors.fish` gives it a 24-bit value earlier in the same
directory pass.

### fish only

`.bashrc` ends by `exec fish` for interactive sessions, so an interactive bash
becomes fish and gets the check. The paths that stay bash are non-interactive —
`bash -c`, hooks, tool runners — where a warning has no reader, and the
`FISH_LAUNCHED` case, which is a bash deliberately started from a fish that has
already reported.

Duplicating the check into `.bashrc` would put a second copy of a security rule
in a second language for no additional coverage.

## Risks / Trade-offs

- **The check itself is a tracked file that a fresh clone reads before the
  guard is on, so the first shell after step 1 of the bootstrap warns** → That
  is the intended behaviour, and it arrives one step before the README asks for
  the command anyway.
- **Someone sets `core.hooksPath` to a different directory on purpose** →
  reported as inactive, because from this repository's point of view it is. The
  message names what it expected.
- **A warning that is always present becomes invisible** → It is absent in the
  working case by construction, which is the only defence that works.
