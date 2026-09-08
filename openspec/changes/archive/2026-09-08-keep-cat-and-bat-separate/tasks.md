## 1. Confirm the code already matches

- [x] 1.1 Confirm `cat` is bound in neither startup file: `grep -rn "alias cat\|abbr cat" ~/.bashrc ~/.config/fish/conf.d/` returns nothing.
- [x] 1.2 Confirm `cat` resolves to the executable in both shells: `fish -ic 'type -t cat'` and `FISH_LAUNCHED=1 bash -ic 'type -t cat'` each report `file`. The `FISH_LAUNCHED=1` is required because `~/.bashrc` ends by `exec fish` for interactive sessions.
- [x] 1.3 Confirm `bat` is still available under its own name: `command -v bat` resolves and `bat --version` reports a version.

## 2. Spec

- [x] 2.1 Sync the delta into `openspec/specs/shell-aliases/spec.md`: the `cat` shows highlighted output requirement is gone, and `cat` and `bat` stay separate names is present with its three scenarios. Verify with `grep -n "^### Requirement:" openspec/specs/shell-aliases/spec.md`.
- [x] 2.2 Verify the requirements this change does not touch survive the sync intact: `An alias is an interactive convenience only`, `A shorthand does not shadow an existing command` (including its deliberate-override paragraph and both override scenarios), and `` `cls` clears the screen ``.
- [x] 2.3 Verify the spec still validates: `openspec validate shell-aliases --type spec --strict` reports it valid.
