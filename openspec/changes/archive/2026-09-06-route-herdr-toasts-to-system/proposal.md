## Why

herdr's toast delivery is set to `herdr`, which draws the toast inside the herdr window. That is the one place the message is not needed: an agent notification exists to reach someone who has looked away, and a toast painted inside herdr is visible only to someone already looking at herdr. On another workspace, behind a browser, or with the terminal minimised, an agent that went blocked reports it to nobody.

The session gained a notification daemon since that value was chosen. `mako` now owns `org.freedesktop.Notifications`, and `desktop-notifications` fixes what it does with what it receives — the session's palette, criticals that wait to be dismissed, ordinary notifications that expire. Routing herdr's toasts to the OS service puts them on that path instead of a private one, and they arrive drawn like every other surface in the session.

The comment above the setting has also gone stale. It explains the `terminal` and `herdr` values, names neither of the two the setting can now hold, and gives WSL as the reason for the choice on a machine running Fedora and niri.

## What Changes

- Set `[ui.toast] delivery` to `system` in the tracked herdr configuration, so herdr hands its notifications to whatever owns the notification bus name on the machine. On this machine that is mako.
- Rewrite the comment above the setting. It states what `system` means, that the daemon on this machine is mako and that `desktop-notifications` is where its behaviour is fixed, and why the in-app value it replaces was the wrong one — not merely which values exist.
- Keep the tracked configuration free of any platform test. herdr offers no include directive, no local override file and no per-host block; `HERDR_CONFIG_PATH` swaps the whole file or nothing. One value therefore has to serve every machine, and `system` is the value that can: it names an intent — *the machine's notification service* — rather than a mechanism, and each machine answers it with whatever it has.
- Require a machine with no notification service of its own to supply `notify-send` rather than have the configuration branch. Under WSL that means a shim on `PATH` — `wsl-notify-send`, or a script calling `powershell.exe` — installed on that machine, outside this repository. This is the shape the dotfiles already use for tools that exist on one machine and not another: `.bashrc` asks whether `direnv` is present rather than which OS it is on, and `.config/nvim` asks Neovim whether it found a clipboard provider rather than testing for WSL.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `herdr-config`: adds requirements fixing where herdr's agent notifications are delivered — the OS notification service rather than an in-app toast — that the tracked setting carries no platform test and that a machine without a notification service supplies one, and that the setting survives a restore and a configuration reload like every other setting in that file.

## Impact

- `.config/herdr/config.toml` — one value in `[ui.toast]`, and the comment above it. The change is already present in the working tree, uncommitted, with the stale comment still attached.
- `openspec/specs/herdr-config/spec.md` — has no toast or delivery requirement today, so these are added, not modified.
- Depends on `org.freedesktop.Notifications` having an owner. On this machine `desktop-notifications` already requires that and mako already satisfies it; `libnotify-0.8.8` and `/usr/bin/notify-send` are installed.
- Applied with `herdr server reload-config`; open sessions survive.
- Accepted risk: on a machine where nothing owns the bus name and no shim is installed, `system` delivers nothing and says nothing. That is the silent discard `desktop-notifications` describes, and it is worse than an in-app toast on that machine — a notification that never appears is indistinguishable from one that was never sent. The requirement that such a machine supply `notify-send` is what keeps this from being a regression there; it is a step to perform on the WSL machine, not something this repository can assert on its own.
- Not affected: notification sound, which `[ui.sound]` governs separately and this change leaves enabled. Nothing about which events herdr considers worth a notification changes — only where the notification is drawn.
