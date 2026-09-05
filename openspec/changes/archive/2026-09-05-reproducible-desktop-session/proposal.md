## Why

The repository can rebuild a shell, an editor and a terminal on a fresh machine, but not the desktop session around them. Three gaps opened as the session was assembled: the README's required-software list names none of niri, foot, noctalia, fuzzel, swaylock or xwayland-satellite, though `config.kdl` and `foot.ini` are now tracked; Noctalia's settings — theme, bar widget list, panel placement — live in `~/.local/state/noctalia/settings.toml`, under a tree the ignore policy denylists wholesale; and nothing records the order in which any of it has to be put back.

The result is a repository that looks complete and reproduces a session missing its bar, its launcher, its lock screen and its theme, with no error to say so.

## What Changes

- Noctalia's settings gain a tracked declaration in `.config/noctalia/`, the shell's own configuration layer, so a fresh machine picks them up with no restore step at all.
- The session's software is named in the README's required-software list, each entry saying what breaks without it.
- The README gains a procedure for rebuilding the session, and for refreshing the declaration when the settings are changed through Noctalia's own UI.
- The ignore policy gains an allowlist entry for the new declaration.

No behavior on this machine changes: the declaration is a second copy of settings that already apply here.

## Capabilities

### New Capabilities

- `desktop-session-declaration`: what the repository must record for the graphical session to be rebuilt elsewhere, where a tool's settings are declared when its own state directory is untrackable, and how a declaration that a machine-local layer can shadow is kept honest.

### Modified Capabilities

None. `dotfiles-repo` already requires tracked documentation to name the software the configuration depends on and to describe bootstrapping into a new environment; the README is simply out of compliance with it for the session, which is implementation rather than a requirement change. `dotfiles-ignore-policy` already states that derived state is ignored in favour of its declaration; this change applies that rule rather than altering it.

## Impact

- `.config/noctalia/settings.toml` — new tracked declaration, exported from the running shell's effective configuration.
- `README.md` — session entries under **Required**, and a section on rebuilding the session and refreshing the declaration.
- `.gitignore` — one allowlist entry.
- Not affected: `~/.local/state/noctalia/`, which stays untracked and authoritative on this machine. The declaration is written to be identical to it, not to override it.
