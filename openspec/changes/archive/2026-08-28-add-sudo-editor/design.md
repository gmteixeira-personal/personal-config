## Context

See proposal.md — Why. The mechanics that shape the approach, from `sudo(8)` and `sudoers(5)` as installed:

- `sudoedit` picks its editor from `SUDO_EDITOR`, then `VISUAL`, then `EDITOR`, and only then from the `editor` list in sudoers. If none of the three names something that exists and is executable, the sudoers list wins silently — no error, just a different editor.
- `sudoedit` copies each file to a temporary one owned by the invoking user, runs the editor "with the permissions of the invoking user and with the environment unmodified", then copies the result back as root. The editor therefore reads `~/.config/nvim` as a matter of course, and never writes root-owned state into it. This is what makes the whole approach work, and it is why `sudo nvim` is the wrong tool for the job.
- What sudo does *not* document is which `PATH` it searches to turn a bare editor name into a path. The environment it hands the editor is unmodified, but that says nothing about the lookup that precedes the exec, and `secure_path` exists precisely to override `PATH` for sudo's own resolution.
- `.bashrc` already exports `EDITOR=nvim` and `VISUAL=nvim` at lines 44-45, above the non-interactive early return, so scripts and tool runners that spawn `$EDITOR` find it.
- The location of `nvim` is per-machine by design: `/usr/sbin/nvim` here, `$HOME/.local/share/bob/nvim-bin/nvim` where bob installed it, and `.bashrc` already prepends the bob directory to `PATH` when it exists.
- `visudo` is a different problem. It runs as root through `sudo`, where `env_reset` strips `SUDO_EDITOR`, `VISUAL` and `EDITOR` unless sudoers lists them in `env_keep`. `sudoers(5)` describes `env_editor` as a way for a user with visudo rights to run arbitrary commands as root without logging.

## Goals / Non-Goals

**Goals:**

- `sudoedit <file>` opens Neovim with this configuration, on every machine this repository is carried to.
- The editor is named by a path that is correct for the machine, without the machine's layout appearing in the tracked file.
- Silence on a machine with no `nvim`, rather than a variable pointing at nothing.

**Non-Goals:**

- Making `visudo` use Neovim. That needs `env_keep` or `env_editor` in `/etc/sudoers`, which is system configuration this repository does not track, and which sudo's own documentation flags as a privilege-escalation hole.
- Changing `EDITOR` or `VISUAL`.
- Making `sudo nvim` behave better. It is the thing `sudoedit` exists to replace: it runs the editor as root, which drags plugin managers, swap files, shada and LSP servers along with it and leaves root-owned files under `~/.config` and `~/.local` behind.
- Any alias or wrapper around `sudoedit`.
- Configuring which files may be edited. That is sudoers' business.

## Decisions

**Set `SUDO_EDITOR` rather than rely on the existing `EDITOR` and `VISUAL`.** Those two are already `nvim` and `sudoedit` does read them, so on a machine where a bare name resolves, this changes nothing observable. It is still worth setting, for two reasons that are not redundancy: `SUDO_EDITOR` outranks both, so it is immune to anything later in a session setting `VISUAL` for its own purposes; and it is read by `sudoedit` and nothing else, which is what makes the next decision safe. Alternative considered: changing `EDITOR` and `VISUAL` to absolute paths and setting nothing new. Rejected — those are consumed by `git`, `crontab`, `systemctl edit` and everything else that spawns an editor, each of which should keep resolving the name freshly against `PATH`.

**Give it an absolute path, resolved at shell start.** `command -v nvim` is asked once, and its answer is exported. This is the only decision here with real content, and it buys certainty about the lookup: sudo documents the environment it hands the editor, not the search it does to find it, so a bare name leaves the bob-installed case resting on an undocumented detail. It also matches what this configuration already does elsewhere — `DOTNET_ROOT` is exported by testing for `$HOME/.dotnet/dotnet`, the executable, not the directory. Alternative considered: `SUDO_EDITOR=nvim`, matching `EDITOR`. Rejected — cheap to be certain, and the failure mode of being wrong is silent: sudo falls back to the sudoers list and opens `vi`, with nothing said about why.

**Ask `PATH`, do not name the locations.** `command -v` is asked after the `PATH` block has run, so it sees the bob directory when that machine has one and `/usr/bin` when it does not. Alternative considered: a list of candidate paths tested in order with `-x`, mirroring the `DOTNET_ROOT` block. Rejected — that block tests one specific path because it must distinguish a per-user SDK from a system one, a distinction with consequences. Here any `nvim` on `PATH` is the right `nvim`, by definition: it is the one every other program in this shell would get.

**Guard on the resolution succeeding.** No `nvim`, no variable. The alternative — exporting whatever `command -v` returned, empty string included — is worse than not setting it: an empty `SUDO_EDITOR` is set, so it is consulted, and it names nothing. Where it is unset instead, `sudoedit` falls through to `VISUAL` and `EDITOR` and finally the sudoers list, which is the behaviour today.

**Keep it above the non-interactive early return, with `EDITOR` and `VISUAL`.** The three belong together and are read for the same reason. Placing it there also costs a single `command -v` in every non-interactive shell, which is a shell builtin and cheaper than the `-d` tests the `PATH` block above it already does.

**Do not leak the temporary.** The resolved path is held briefly and the holding variable is unset, so no working name survives into the environment of every program the shell runs.

## Risks / Trade-offs

- **The path is frozen at shell start** → a shell open across a bob upgrade that replaces the `nvim` binary in place keeps a valid path; one that moves it does not, and `sudoedit` in that shell falls back to `VISUAL`. Mitigation: none needed. bob's `nvim-bin` is a stable directory by design, and a new shell resolves afresh.
- **A machine where `command -v nvim` finds a wrapper rather than the real binary** → `SUDO_EDITOR` names the wrapper. Correct: it is what the user gets from `nvim` at their own prompt, so it is what they should get here.
- **`sudoedit` still refuses symbolic links and files in user-writable directories** → unchanged by this, and unrelated to it. `/etc/wsl.conf` is neither.
- **The user reaches for `sudo nvim` out of habit** → this change does nothing for that case, and cannot. Out of scope by the Non-Goals above.
- **Rollback** → delete the block; the next shell has no `SUDO_EDITOR`, and `sudoedit` is back to consulting `VISUAL`.
