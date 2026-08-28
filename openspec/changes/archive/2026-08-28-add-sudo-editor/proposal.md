## Why

`sudoedit /etc/wsl.conf` should open Neovim with this configuration, and nothing in the tracked files says so. The shell exports `EDITOR` and `VISUAL`, both `nvim`, and sudoedit does consult them — but only third and second in its order of preference, behind `SUDO_EDITOR`, and behind whatever else on a given machine happens to have set `VISUAL` first. The one variable that is read by sudoedit and by nothing else is the one variable this configuration never sets.

Naming it also lets the answer be a path rather than a name. `EDITOR` and `VISUAL` are consumed by dozens of programs and are right to stay as the bare word `nvim`; `SUDO_EDITOR` is consumed by one, so it can carry the absolute path of the `nvim` this shell actually resolved — `/usr/sbin/nvim` on this machine, `~/.local/share/bob/nvim-bin/nvim` on a machine where bob installed it. sudo documents that it runs the editor with the invoking user's environment unmodified, but it does not document which `PATH` it searches to find that editor in the first place. An absolute path makes the question moot.

## What Changes

- Export `SUDO_EDITOR` from `.bashrc`, alongside the existing `EDITOR` and `VISUAL`, carrying the absolute path of the `nvim` on this machine.
- Resolve that path at shell start from `PATH`, so a bob install and a system package both work without the file naming either.
- Leave the variable unset when no `nvim` is resolvable, so sudoedit falls back to `VISUAL`, `EDITOR`, and finally the `editor` list in sudoers, exactly as it does today.
- Leave `EDITOR` and `VISUAL` unchanged.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `shell-environment`: adds a requirement covering which editor the shell nominates for privileged file editing. The existing requirements cover `PATH` assembly, tool roots, and colour depth, and say nothing about editor selection.

## Impact

- `.bashrc` gains one guarded export in the block that already sets `EDITOR` and `VISUAL`.
- `sudoedit` opens Neovim, running as the invoking user, so it reads `~/.config/nvim` — plugins, keymaps, and all — with no root-owned state written into the config directory.
- No file under `/etc` is touched. `visudo` is unaffected: it runs as root through `sudo`, where `env_reset` strips these variables unless sudoers lists them in `env_keep`, and that is a change to system configuration this repository does not track.
- Machines with no `nvim` behave exactly as before.
- Rollback is deleting the block.
