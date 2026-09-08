## 1. Preconditions

- [x] 1.1 Confirm `cls` is not already a real command, by checking that `command -v cls` in bash and `type -q cls; echo $status` in a fish shell started with `fish --no-config` both report it absent. If either resolves, stop and report the conflict instead of binding the name.
- [x] 1.2 Confirm `~/.bashrc` still carries `alias cls='clear'` in its alias block, so the bash half of the requirement needs no edit; verify with `grep -n "alias cls=" ~/.bashrc`.

## 2. Fish binding

- [x] 2.1 Add `alias cls clear` to the `status is-interactive` block in `~/.config/fish/conf.d/aliases.fish`, next to `alias e nvim`, and verify the file still parses with `fish -n ~/.config/fish/conf.d/aliases.fish`.
- [x] 2.2 Verify the binding takes effect in a fresh interactive fish shell: `fish -ic 'type cls'` reports `cls` as a function that runs `clear`.
- [x] 2.3 Verify it stays out of non-interactive fish: `fish -c 'cls'` exits non-zero with an unknown-command error.
- [x] 2.4 Verify `clear` itself is unchanged in both shells: `fish -ic 'type -t clear'` and `FISH_LAUNCHED=1 bash -ic 'type -t clear'` each report the external command, not a function or alias. The `FISH_LAUNCHED=1` is required because `~/.bashrc` ends by `exec fish` for interactive sessions; without it the bash check measures fish.
