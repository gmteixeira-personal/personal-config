## Context

See proposal.md — Why. Constraints that shape the approach:

- foot and footclient are installed from the distribution, which already ships `foot-server.service` and `foot-server.socket` as user units. Both are conditioned on `WAYLAND_DISPLAY` and are `WantedBy=graphical-session.target`.
- The compositor was being started as a bare `niri` from an interactive fish on a tty. `niri.service` is `static`, and `graphical-session.target` was inactive.
- The password database names bash as the login shell; fish is used interactively.
- The repository is rooted at `$HOME` and denies by default: a new path is untrackable until an allowlist entry names it. `.config/fish/functions/**` is already allowlisted; the other new paths are not.
- fish 4 compiles its built-in completions into the binary rather than shipping files.

## Goals / Non-Goals

**Goals:**

- Terminal windows that cost a client connection rather than a process start.
- An autostart path that actually fires, rather than one that only appears to be enabled.
- Configuration that behaves the same on a machine whose login shell differs.

**Non-Goals:**

- Changing the login shell. That is a separate decision with its own consequences for non-interactive callers.
- Removing alacritty. It stops being bound to a key; it is not retired, and no requirement asserts its absence.
- Tracking the systemd enablement symlinks. Unit state is machine state, established by enabling the units, not by a tracked file.

## Decisions

**Enable both the socket and the service, not one of them.**
The service is `Requires=` its socket, so enabling the service alone pulls the socket in at start. But the two answer different questions: the service starts the server eagerly with the session, and the socket makes a client that arrives before the server is ready trigger activation rather than fail. Enabling only the socket was the alternative — a lazily started server, no idle process — and it was rejected because the ask was for the server to be running, not merely reachable. Enabling both costs one idle process and removes the ordering question entirely.

**A fish function for the compositor name, not an abbreviation.**
The correct launch is `niri-session`, which imports the environment and starts `niri.service`. Making the bare name do that needs the name intercepted. An abbreviation was the obvious tool and is wrong here: fish expands an abbreviation on the command token regardless of what follows, so `niri msg action ...` would expand to `niri-session msg action ...` and break the IPC and validation subcommands. A function branching on argument count keeps the bare name as the session launcher and passes everything else to `command niri`. It is declared `--wraps niri` so completions still come from the binary.

**Name the shell in foot.ini rather than relying on `$SHELL`.**
foot defaults to `$SHELL`. Under the server that variable comes from systemd's environment, which carries the password-database shell, so the default yields bash windows while the interactive session shows fish — a discrepancy that only appears once the server is what starts the terminal. Naming the binary in the configuration makes the outcome independent of both the login shell and how the server was started. The alternative, `chsh`, would fix it globally but changes what every non-interactive `$SHELL` consumer gets, which is a larger decision than this change.

**Prefer a tool's own generator; hand-write only where nothing else exists.**
`openspec` ships `completion generate fish`, so its completion is generated and will track the tool across upgrades. `waybar` ships only a section-5 page describing its configuration file, and `npx`'s page documents its options in prose with no options section — fish's man-page harvester produces nothing from either, so both are written by hand from `--help` and carry a comment saying why. For `npx` the hand-written form also allows something a harvester could not produce: completing the executables in the nearest `node_modules/.bin`, walking up from the working directory, which is what the command is mostly used for.

**Track only the hand-written completions, and name them individually.**
The ignore file already excludes `.config/fish/completions/` on purpose: tools rewrite their completions there on every reinstall, so a tracked copy goes stale against the tool that owns it. That reasoning holds for the generated `openspec.fish`, which stays untracked. It does not cover the hand-written `waybar.fish` and `npx.fish` — nothing regenerates those, so untracked means lost. They are allowlisted as individual files rather than by re-including the directory, which would silently pull in every tool-installed script and contradict the existing rule. The harvested set in `~/.cache/fish/` — 1550 files from 2527 manual pages — stays untracked on the same reasoning it was excluded for: it describes this machine's installed packages, and one command rebuilds it.

## Risks / Trade-offs

- **The compositor is still started by hand, so the fix depends on the function being loaded.** → The function is autoloaded from `.config/fish/functions/`, which is already tracked and allowlisted. A session started from anything other than an interactive fish — a display manager, a script — bypasses it and reverts to the silent no-autostart behavior. Accepted: the launch path today is interactive fish.
- **Editing foot.ini appears to do nothing.** → Inherent to server mode. Mitigated by stating the rule and the restart command in the file itself, and by a spec scenario asserting it stays there.
- **Restarting the server closes every window it owns.** → Unavoidable; the restart is only needed for configuration edits, so it is a deliberate act rather than a background event.
- **The hand-written completions drift as waybar and npx gain options.** → Bounded: both option sets are small and stable, and each file records that it was derived from `--help`, so the check is a one-line diff against that output.
- **`niri-session` refuses to start when a session is already running.** → It exits with a message rather than damaging the running session, so the failure mode of typing `niri` inside an existing session is benign.
