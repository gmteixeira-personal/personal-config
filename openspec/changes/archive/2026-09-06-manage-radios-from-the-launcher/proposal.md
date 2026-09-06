## Why

The session can present the state of both its radios and act on neither. `.config/waybar/config.jsonc` carries a `bluetooth` module and a `network` module, placed side by side with a comment saying they belong together "because both report a radio link". Reporting is all they do. The bluetooth module's `on-click` opens `bluetoothctl` in a foot window — a REPL with its own prompt, its own command vocabulary and no completion for a MAC address — and the network module has no `on-click` at all, because the packaged file it inherits from defines none.

Nothing else in the session fills the gap. `blueman` is not installed, there is no GNOME or KDE settings panel, and `nm-applet` is not running. That last absence is the sharper one: NetworkManager asks for a passphrase by calling out to a secret agent on the bus, and with no agent registered there is nothing to ask. Joining a wireless network this session has never seen is not awkward from the bar — it is not possible from the session at all, without dropping to a terminal and typing the passphrase where the shell will keep it.

The launcher is the obvious place for both. It is already the session's one general chooser, it is already themed, and `fuzzel --dmenu` turns it into a menu for any list a script can produce. What was missing was the scripts.

A second gap surfaced while building them, and it is older than this change. Nothing in the session owns `org.freedesktop.Notifications`: there is no `mako`, no `dunst`, and no desktop shell that ships one. Every `notify-send` in the session therefore fails with `GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name is not activatable` and displays nothing. It fails silently in the way that matters — the error goes to a stderr nobody reads, and the caller's exit status is the only trace. Any script that reports through notifications has been reporting into nothing, and a menu that connects to a network has no other way to say that the connection failed: the menu it returns to looks identical whether the action failed or was never attempted.

## What Changes

- Two scripts, `.config/fuzzel/fuzzel-bluetooth` and `.config/fuzzel/fuzzel-wifi`, drive `fuzzel --dmenu` as a menu. Between them they cover the whole of what the session could not do: scan, pair, trust, connect, disconnect, remove and adapter power for Bluetooth; scan, join, disconnect, forget, hidden networks, saved profiles and radio power for wireless, with address details for the active link.
- Selections come back as an index rather than as text. A device or network name may hold a tab, a dash, a colon or a parenthesis, and `nmcli -t` escapes a colon inside a value as `\:`; an index sidesteps all of it, so nothing parses a rendered label to recover a MAC address or an SSID.
- The wireless passphrase never becomes a process argument. The profile is created without a key, and `nmcli connection edit` — an interactive editor, so it reads its commands from standard input — sets the key over a pipe.
- Each menu offers only the verbs the current state allows: a paired device is not offered pairing, an unpaired one is not offered trust, and a network with no saved profile is not offered forgetting.
- `mako` is installed and started by the compositor, so that `org.freedesktop.Notifications` is owned. Its configuration is tracked, drawn in the session's palette, and states where those values came from, as the four files already holding a copy of that palette each do.
- Feedback is split by how much it matters. Progress goes through the notification daemon and is allowed to vanish; a failure is sent at critical urgency, which the daemon is configured not to expire, and falls back to a menu window when no daemon answers at all.
- Both radio modules on the bar open their menu on click, and the network module stops toggling `format-alt`, which the packaged configuration sets.

## Capabilities

### New Capabilities

- `radio-management`: The session had no capability covering what is done with its radios, only `bar-appearance` covering how they are reported. This capability states that both are managed from the launcher, what a menu may offer at a given moment, and the two properties that are easy to lose in a shell script driving a chooser — that a passphrase is never an argument, and that a selection is not recovered by parsing its label.
- `desktop-notifications`: The session had no notification daemon and no specification saying it should have one, which is why its absence went unnoticed for as long as it did. The capability states that the name is owned, that the daemon starts with the session, that its appearance comes from the session's palette, and that a message reporting a failure is not expired on a timer.

### Modified Capabilities

- `bar-appearance`: The specification already requires that a module earns its place by being acted on, and names the bar itself as where the acting happens. The network module was carried in breach of that — a reading with nothing behind it. The capability gains a requirement that a module reporting a radio opens that radio's controls, and that the click does that and nothing else.

## Impact

- `.config/fuzzel/fuzzel-bluetooth`, `.config/fuzzel/fuzzel-wifi` — new, executable, tracked. They live beside the launcher configuration rather than in `.local/bin` because `.gitignore` block 4 ignores `.local/` wholesale and a block 3 entry cannot re-include a file whose parent directory block 4 excludes. Symbolic links in `.local/bin` put them on `PATH` and are not tracked, being derived.
- `.config/mako/config` — new and tracked. The palette count in `.config/fuzzel/fuzzel.ini` goes from four files to five.
- `.config/niri/config.kdl` — one `spawn-at-startup "mako"` line and the comment above it.
- `.config/waybar/config.jsonc` — the bluetooth module's `on-click` retargeted, the network module gaining one, and `"format-alt": null` on the network module. waybar fires both the alternate-format toggle and the click command on the same button, so without the null the label swapped to the interface and address on every open and swapped back on the next.
- `.gitignore` — three block 3 entries, no block 4 change.
- Packages: `mako` installed. Nothing removed.
- Not closed by this change: the two `.desktop` entries and their two icons are on disk and working but untracked. They belong under `.local/share/applications` and `.local/share/icons`, which block 4 excludes for the same reason as `.local/bin` — and unlike the scripts they cannot be moved, since the launcher reads desktop entries from the path the specification defines. Closing it means a decision about the ignore policy, which is `dotfiles-ignore-policy`'s to make and not this change's.
- Known limits, recorded rather than worked around: pairing a device that demands a PIN or a passkey confirmation still needs `bluetoothctl` in a terminal, because answering such a prompt requires a registered agent and a shell script driving a chooser cannot be one. An 802.1X network is refused with a message rather than half-configured, since it needs an identity, a method and often a certificate.
