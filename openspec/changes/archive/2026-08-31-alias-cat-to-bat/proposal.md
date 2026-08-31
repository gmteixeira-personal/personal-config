## Why

`cat` dumps a file as undifferentiated text. `bat` is now installed on this machine and prints the same file with syntax highlighting, line numbers, and git modification markers in the gutter, and pages it when it does not fit on screen. That is what reading a file at the prompt actually wants, and the reflex that reaches for it is `cat`.

Leaving the improvement behind a second name means never getting it: the hands type `cat`.

## What Changes

- Bind `cat` to `bat` in interactive shells, in both fish and bash, where `bat` is present. This is a deliberate override of an existing command, which the shorthand rules allow only when the intent is exactly that — so the rule that otherwise forbids shadowing is amended to say so in as many words rather than being quietly stepped around.
- Guard on `bat` being installed. Where it is absent, `cat` remains `cat`, silently, with no message and no error — the same shape the `direnv` and `fzf` guards already use.
- Leave `command cat` as the way to reach the real one, which is the shell's own escape hatch and needs nothing added to work.

## Capabilities

### Modified Capabilities

- `shell-aliases`: amends *A shorthand does not shadow an existing command* — its scenario currently states flatly that a command on `PATH` runs its executable and not a shorthand of the same name, which the requirement's own "unless the intent is explicitly to change that command's default behavior" clause already contemplates but never illustrates. The amendment makes the deliberate-override case explicit and says what such an override owes: a guard, and a way back to the original.
- `shell-aliases`: adds a requirement that `cat` reads as highlighted output where `bat` is available.

## Impact

- `.config/fish/conf.d/aliases.fish` — one guarded alias.
- `.bashrc` — the same alias, beside the `cls` one already there, so the two shells agree.
- `README.md` — one entry in the optional-software list, since this is the same kind of absence-tolerated dependency as `direnv` and `fzf`.
- No `.gitignore` change and no new tracked file: `bat`'s own configuration is left at its defaults.
