## Why

A checkout of this repository plus everything under **Software this configuration expects** still leaves a machine with no way into the session. What actually gets this machine from boot to a running niri is greetd, running tuigreet, launching `niri-session` — and none of the three is named anywhere in the repository. The README does not mention them, no specification covers them, and the file that decides it, `/etc/greetd/config.toml`, is root-owned and outside `$HOME`, so the repository cannot carry it even in principle.

That combination is the failure this repository exists to prevent, in its most complete form. Every other piece of the session is either tracked or documented as untracked; the login path is neither. A fresh machine follows the rebuild procedure to the end, reaches step 3, and gets a session only because someone typed `niri-session` into a TTY by hand — which is not what happens on the machine this was written from, where the session starts at boot.

The gap is documentation, not configuration. The machine is already set up correctly and verified so; nothing about how it boots needs to change.

## What Changes

- The rebuild procedure gains a final step covering how the session is entered at boot: the greetd configuration in full, the unit to enable, and the default systemd target it needs.
- greetd and tuigreet are named in the required-software documentation, each with what is lost without it.
- `/etc/greetd/config.toml` is recorded as a path the repository deliberately does not carry, alongside the reason it cannot — it is outside `$HOME`, which is the repository root, so no allowlist entry could ever reach it.
- The documentation states that all three routes into the session — the greeter's `--cmd`, the session entry the greeter's picker lists, and typing `niri` at a prompt — run `niri-session` rather than a bare `niri`, and why all three have to.

**No configuration changes.** greetd is already enabled and active, `/etc/greetd/config.toml` already launches `niri-session`, and the running session already proves the path works: `graphical-session.target` is active and the foot server units started on their own.

## Capabilities

### New Capabilities

- `session-login`: How a booted machine reaches a running graphical session — what presents the login, what it launches, and the requirement that every route into the session goes through the compositor's session launcher rather than its bare binary. Also covers the documentation obligation that falls out of the deciding file living outside the repository root.

### Modified Capabilities

None. `desktop-session-declaration` covers what the session needs once it is running and what a checkout reproduces; this is the step before that, and its distinguishing problem — a configuration file the repository cannot reach at all — is not one that capability has a requirement for. `graphical-session-startup` already requires that starting the compositor by name activates `graphical-session.target`, and this change adds nothing to it: it asserts the same property about the two routes that do not involve typing the name.

## Impact

- `README.md` — a new step in **Rebuilding the desktop session**, two entries under **Required**, and one row in **What is deliberately not tracked**.
- No tracked configuration file changes. No package is installed or removed.
- Machine state: none. This change records what is already there.
- Read against the existing capabilities: `graphical-session-startup` keeps its wrapper requirements untouched, and the `desktop-session-declaration` requirement that another open change (`dark-lock-screen-on-idle`) is already modifying is deliberately left alone here, so the two changes cannot collide over the same requirement block.
