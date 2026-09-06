## Context

Two radios, one chooser, and a session with no secret agent and no notification daemon. The constraints that shaped this are mostly about what is absent: no `blueman`, no settings panel, no `nm-applet`, nothing owning `org.freedesktop.Notifications`, and an ignore policy that will not track anything under `.local/`.

## Decisions

### The passphrase does not become an argument

`nmcli device wifi connect "$ssid" password "$pass"` is what every comparable script does, and it puts the passphrase in `argv` for the several seconds a connect takes. `/proc/<pid>/cmdline` is world-readable by default, so on this machine that is every process of this user — a wider audience than the key's resting place, `/etc/NetworkManager/system-connections/`, which is mode 600 and owned by root.

Three alternatives were rejected before the one adopted. `nmcli --ask` reads from the terminal and its own manual page says not to use it in scripts. Writing the keyfile directly needs root. Registering a real secret agent needs a persistent process and a D-Bus interface, which is a different and much larger piece of work.

What is used instead: create the profile with `autoconnect no` and no key, then pipe `set wifi-sec.psk <value>` into `nmcli connection edit`, which is an interactive editor and therefore reads its commands from standard input. Verified on a throwaway profile before it was relied on. The passphrase is still plaintext on two pipes; what it is not is a command line.

`autoconnect` stays off until the key is on the profile, because NetworkManager will otherwise try to activate a profile that has no key the moment it is added. A failed activation deletes the profile, so a mistyped passphrase leaves nothing behind rather than a saved network that fails silently on every later autoconnect.

### Selections come back as an index

`--only-match` with `--index` makes a pick an integer into an array the script already holds. The alternative is emitting `label<separator>identifier` and splitting the reply, which fails on any name containing the separator — and both `bluetoothctl` and `nmcli` produce names that do. `nmcli -t` additionally escapes a colon inside a value as `\:`, so an SSID or profile name has to be read last in `-f` and unescaped; the fields before it cannot contain a colon at all.

Two properties of these tools were found by testing rather than by reading, and both silently produce wrong output:

- `nmcli -g` joins a multi-valued field onto **one** line with ` | ` rather than printing one value per line. Read line by line, two IPv6 addresses arrive as a single value and any filter over them never matches.
- `read` returns non-zero at end of file on a final line with no trailing newline, so the loop body never runs for it. A splitter built on `printf '%s'` therefore drops every single-valued field entirely — which is worse than a visible failure, because the field simply is not there.

### Menus offer only what the state allows

A paired device is not offered pairing; an unpaired one is not offered trust; a network with no profile is not offered forgetting. The alternative is a fixed verb list where some entries return an error when chosen, which teaches the reader that the menu is not to be trusted rather than that the action was wrong.

### Feedback is split by how much it matters

Success does not need a message: the menu is redrawn immediately after, and the new state is on it. Failure does, because an unchanged menu looks the same whether the action failed or was never attempted. So progress goes through `notify-send` and is allowed to vanish, and failure goes at critical urgency — which `mako` is configured never to expire — with a fallback to a menu window when no daemon answers the bus at all. The daemon is detected once at startup rather than per message.

The Bluetooth scan is the one operation long enough to need its own treatment. Run in the foreground it is ten seconds of an empty screen with no way to tell a scan from a hang and no way to stop early. It runs in the background behind a window that dismisses it, and dismissing stops the scan properly — killing `bluetoothctl` is not the same as telling the adapter to stop discovering.

### mako rather than dunst

Measured on this machine: `mako` is one package and 150.5 KiB with no new dependencies; `dunst` is three packages and 513.8 KiB, and links `libX11`, `libXext`, `libXinerama`, `libXrandr` and `libXss` that a Wayland-only session will never call. `dunst` has two things `mako` does not — per-rule scripts and regex rule matching — and nothing here asks for either. Both speak the same bus name, so the choice is reversible without touching the scripts: they ask the bus who owns the name, not which daemon is installed.

### The scripts live in `.config/fuzzel`

`.local/bin` is the conventional home and is unavailable: `.gitignore` block 4 ignores `.local/` wholesale, and git will not re-include a file whose parent directory is excluded, so the block 3 entry the ignore policy prescribes would be inert. Block 4 is not loosened for this — the file's own header forbids it. The scripts therefore live beside the launcher configuration they extend, which block 3 can name, with untracked symbolic links in `.local/bin` putting them on `PATH`.

The two `.desktop` entries and their icons have the same problem and no such escape: the launcher reads desktop entries from `$XDG_DATA_HOME/applications`, and that path is the specification's, not a preference. They are left untracked and the gap is recorded rather than papered over.

## Risks

- A device demanding a PIN or a passkey confirmation cannot be paired from the menu. Answering that prompt requires a registered agent; the failure is reported with a message naming `bluetoothctl` as the way through.
- An 802.1X network is refused rather than half-configured. Guessing at an identity and a method would produce a profile that fails later instead of here.
- The passphrase is plaintext on the pipe between the chooser and `nmcli`. Removing that too means being a secret agent.
