## Why

`shell-aliases` still requires `cat` to print with syntax highlighting, and it has not been true since 2026-09-05. Commit `f583ef9` bound `cat` to `bat` in both shells; commit `b9343e9` reverted that binding as a deliberate decision — "the highlighting was not worth the surprise: cat is expected to print the file and nothing else" — but changed only the two shell files and left the requirement standing. The spec has been describing a behavior the configuration does not have for three months.

Deleting the stale requirement is not enough on its own. The spec said nothing about `cat` before `f583ef9`, and that silence is what let the binding be proposed; deleting the requirement restores exactly that silence and invites the same proposal again. The decision itself is what needs recording.

## What Changes

- Remove the `cat` shows highlighted output requirement from `shell-aliases`. It describes a binding that no longer exists in either shell.
- Add a requirement stating the decision in its place: `cat` and `bat` are separate tools kept under separate names, `cat` SHALL print the file and nothing else, and highlighting is reached by asking for `bat`.
- No shell configuration changes. `.bashrc` and `.config/fish/conf.d/aliases.fish` already match the intended behavior; this change brings the spec to them.

## Capabilities

### New Capabilities

<!-- None. shell-aliases already covers the shorthand names this configuration defines. -->

### Modified Capabilities

- `shell-aliases`: the `cat` shows highlighted output requirement is removed, and a requirement that `cat` stays plain `cat` — with `bat` reached by its own name — takes its place.

## Impact

- `openspec/specs/shell-aliases/spec.md` — one requirement removed, one added.
- No code, no shell startup file, and no installed package is touched. `bat` stays installed at `/usr/bin/bat` and keeps working under its own name.
- The deliberate-override rules in `A shorthand does not shadow an existing command` stay as they are. They were written to justify the `cat` binding, but they read as a general policy for any future override and the escape-hatch clause they refine predates `cat`. Removing them is a separate decision, not part of correcting this drift.
