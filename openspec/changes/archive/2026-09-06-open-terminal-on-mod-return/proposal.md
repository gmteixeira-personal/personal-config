## Why

The terminal opens on `Mod+T`, which is the chord niri's shipped example configuration suggests and the one this session kept. It is not the chord the hands know. Every tiling compositor this session's habits came from opens a terminal on `Mod+Return` — i3 and sway ship it as the default, and it is the one binding a user of any of them types without looking. Reaching for `Mod+Return` here does nothing at all: no window, no error, no hint that the key is unbound.

`Mod+Return` is free. No binding in `config.kdl` names `Return`, `Enter` or `KP_Enter`, so this takes nothing away from anything.

## What Changes

- `binds` gains `Mod+Return`, spawning `footclient` with the same hotkey-overlay title the existing terminal binding carries.
- `Mod+T` stays. The launcher already answers to two chords — `Mod+D` and `Mod+Space` — so a second way to reach one program is the pattern this configuration already uses rather than an exception to it. Removing `Mod+T` would also break the one chord that currently works, in service of a change whose whole purpose is that a chord which should work does.
- `terminal-emulator` stops describing the terminal binding in the singular. Its requirement is that a terminal binding spawns a client rather than a standalone terminal and that its label names the terminal actually opened; with two bindings that obligation has to attach to each of them, or the second is free to drift to a bare `foot` and a stale label.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `terminal-emulator`: The requirement covering the compositor binding is written for exactly one binding. It becomes a requirement on every binding that opens a terminal, and gains the chord itself — that the terminal is reachable on the convention chord, not only on a letter chord chosen by the packaged example configuration.

## Impact

- `.config/niri/config.kdl` — one binding line in `binds`, beside the existing terminal binding, with a comment recording why two chords open one program.
- Behaviour: `Mod+Return` opens a terminal. Nothing else changes. No existing chord is taken, rebound or removed, and `Mod` is Super, which applications do not see — nothing running inside a terminal loses a key.
- Machines: none beyond this one. The binding is compositor configuration and the WSL machine runs no compositor, so unlike a setting in a shared configuration file there is nothing to keep in step and no second value to choose.
- Reload: niri re-reads `config.kdl` on save, so the binding is live without restarting the session.
