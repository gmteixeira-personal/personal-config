## Context

See proposal.md — Why. Constraints that shape the approach:

- The session runs niri 26.04, started from an interactive fish. `spawn-at-startup` is how it launches session programs; there is no per-component systemd unit involved.
- `noctalia` 5.0.1 and `cliphist` 0.7.0 are both packaged by Fedora 44, so neither needs a COPR or a git checkout. Noctalia ships a single `/usr/bin/noctalia` with no separate Quickshell dependency.
- The bindings being replaced — `Mod+D`, `Super+Alt+L` — already exist and already have hotkey-overlay titles naming the program they launch.
- `.config/niri/config.kdl` is now tracked, so this change is a reviewable diff rather than an untracked machine edit.

## Goals / Non-Goals

**Goals:**

- Clipboard entries that survive the window that copied them.
- One shell to configure instead of four components with four configuration formats.
- A change that reverts by restoring lines, not by reinstalling software.

**Non-Goals:**

- Removing waybar, fuzzel or swaylock. They are superseded, not retired, and no requirement asserts their absence.
- Theming or widget layout. Noctalia's own setup wizard owns that, and it is per-machine taste rather than tracked configuration.
- Moving the terminal binding. `Mod+T` continues to open footclient.

## Decisions

**Address the running shell over IPC rather than spawning per binding.**
Noctalia exposes `noctalia msg` against a socket at `$XDG_RUNTIME_DIR/noctalia-$WAYLAND_DISPLAY.sock`. The bindings therefore send `panel-toggle launcher`, `panel-toggle clipboard` and `session lock` to the running instance. Spawning a fresh process per binding was the alternative and is wrong for a shell that is already running: a second process would neither see the clipboard history nor share the bar's state, and would pay startup cost on every press.

**Discover the command surface from the binary, not from documentation.**
The published documentation URL returns HTTP 410, and the clipboard documentation that is reachable describes a *plugin* — the separate Clipper plugin — rather than the panel built into 5.0.1. The panel ids and command names used here were taken from `noctalia msg --help` and from the symbols in the shipped binary. That is also how the cliphist question below was settled.

**No external clipboard history daemon.**
`cliphist` was installed on the assumption, taken from that plugin documentation, that Noctalia's clipboard panel was a frontend over it. The shipped binary contains `ClipboardService`, `ClipboardPanel` and `ClipboardPollSource`, references cliphist zero times, and shells out to neither `wl-copy` nor `wl-paste`. The history is native. cliphist stays installed but unused, and the spec records that rather than leaving a future reader to assume it is load-bearing.

**Move the new binding, not the compositor's.**
`Mod+V` was the obvious key for a clipboard panel and is already niri's `toggle-window-floating`; `Mod+Shift+V` is `switch-focus-between-floating-and-tiling`. niri does not merely warn about a duplicate — it refuses to load the configuration at all, so the collision took down the whole file until it was resolved. The clipboard panel moved to the free `Mod+Alt+V`, keeping the paste mnemonic. Displacing a compositor binding to win the shorter key was rejected: window management is used far more often than clipboard history, and a shell should not take keys from the compositor hosting it.

**Keep the replaced components installed.**
Only the startup entry and three bindings changed. waybar had no configuration at all — no `.config/waybar/` exists, so it was running on built-in defaults — and fuzzel and swaylock remain launchable by name, so reverting restores lines and nothing else. This is what makes the change cheap to abandon, and it is why `retired-tooling` is not modified: nothing here is retired.

## Risks / Trade-offs

- **One shell is now a single point of failure for bar, launcher, lock and clipboard.** → The four components it replaced are all still installed, so recovery is restoring three lines in a validated configuration file rather than a reinstall.
- **The lock screen is now provided by a program whose lock path is untested here.** → `session lock` was confirmed present in the IPC surface, but locking was not exercised, since testing it means locking the running session. Worth exercising deliberately before relying on it.
- **Noctalia's own settings live outside this repository.** → Its wizard writes per-machine theme and widget state. Nothing tracked depends on it, so a machine without it gets defaults rather than a broken shell.
- **cliphist sits installed and unused.** → Recorded in the spec and the proposal so it reads as deliberate. It can be removed at any time without touching the shell.
