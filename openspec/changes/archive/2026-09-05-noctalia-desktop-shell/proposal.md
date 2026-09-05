## Why

The niri session was assembled from separate parts: waybar for the bar, fuzzel for the launcher, swaylock for the lock screen, and nothing at all for clipboard history. The missing piece was the one that prompted this — the Wayland clipboard is owned by the source client, so copied text dies when the window that copied it closes, and no component on the machine outlived that.

Noctalia is a single shell covering all four, with a native clipboard service rather than a wrapper over an external history daemon. It carries a dedicated niri backend, so this is a supported target rather than generic Wayland compatibility.

## What Changes

- Noctalia becomes the session's shell, started with the session in place of waybar.
- The launcher and lock-screen bindings address Noctalia over its IPC socket instead of spawning fuzzel and swaylock.
- A new binding opens Noctalia's clipboard history panel, giving the session clipboard entries that outlive the window that copied them.
- **BREAKING** for muscle memory only: `Mod+D` and `Super+Alt+L` now reach a different program. The keys and their meanings are unchanged.

Not a removal: waybar, fuzzel and swaylock stay installed. waybar had no configuration of its own to preserve — it ran on built-in defaults. Only what the session starts and what the bindings name has changed, so reverting is a matter of restoring three lines.

## Capabilities

### New Capabilities

- `desktop-shell`: which program provides the session's bar, launcher, lock screen and clipboard history; how its bindings address it; and what must remain true of the components it replaced.

### Modified Capabilities

None. `terminal-emulator` keeps its own binding and `graphical-session-startup` is unaffected — the shell is spawned by the compositor, not by a systemd unit.

## Impact

- `.config/niri/config.kdl` — the startup line and three bindings.
- Packages installed: `noctalia` 5.0.1 from the Fedora repository. `cliphist` 0.7.0 was installed alongside it on the assumption that Noctalia's clipboard panel was a frontend over it; the shipped binary carries its own `ClipboardService` and references cliphist nowhere, so that package is unused and this change records it as such rather than leaving it to be rediscovered.
- Machine state: waybar is no longer started with the session. It had no configuration file, so nothing but the startup entry was involved.
- Not affected: the `Mod+T` terminal binding, and the systemd units that start the foot server.
