## 1. The notification daemon

- [x] 1.1 Confirm the gap before filling it: `gdbus call --session --dest org.freedesktop.DBus --method org.freedesktop.DBus.NameHasOwner org.freedesktop.Notifications` returns `(false,)` and the name is not in `ListActivatableNames`
- [x] 1.2 Compare `mako` and `dunst` on this machine's repositories — package count, installed size, and which X11 libraries each links — and record the comparison in design.md
- [x] 1.3 Install `mako`
- [x] 1.4 Write `.config/mako/config` with the Catppuccin Mocha values the launcher, the bar, the lock screen and the compositor already restate, and a comment naming where they came from
- [x] 1.5 Match the corner radius to the launcher's rather than the bar's, and pair the point size with the bar's pixel size rather than matching the two numbers
- [x] 1.6 Give `[urgency=critical]` a red border and `default-timeout=0`
- [x] 1.7 Add `spawn-at-startup "mako"` to `.config/niri/config.kdl` with a comment naming what fails without it, and verify with `niri validate`
- [x] 1.8 Update `.config/fuzzel/fuzzel.ini`'s count of the files restating the palette from four to five
- [x] 1.9 Verify the name is owned afterwards and both a normal and a critical notification display

## 2. The Bluetooth menu

- [x] 2.1 Write `.config/fuzzel/fuzzel-bluetooth` driving `fuzzel --dmenu --index --only-match`
- [x] 2.2 Build the device list from `bluetoothctl devices` with `Connected`, `Paired` and `Trusted` as three filtered calls rather than one `info` call per device, and mark each row with the state it is in
- [x] 2.3 Offer per device only the verbs its current state allows — connect against disconnect, trust against untrust, pair only when unpaired — and confirm before removing
- [x] 2.4 Run the scan in the background behind a dismissible window, and stop discovery on early dismissal rather than only killing the process
- [x] 2.5 Trust a freshly paired device without asking, since pairing it is the statement that it is wanted
- [x] 2.6 Report a pairing failure with the reason a PIN device cannot be handled here

## 3. The Wi-Fi menu

- [x] 3.1 Write `.config/fuzzel/fuzzel-wifi` to the same shape
- [x] 3.2 Read the access point list with the SSID last in `-f` and unescape `\:`, since only the SSID can contain a colon
- [x] 3.3 Sort the in-use row first and by signal descending after it, so that a duplicated SSID keeps its connected row rather than its strongest one, then deduplicate by SSID
- [x] 3.4 Map access points to saved profiles by reading each profile's `802-11-wireless.ssid`, not by assuming the profile name equals the SSID
- [x] 3.5 Verify on a throwaway profile that `nmcli connection edit` accepts its commands on a pipe and stores the key, then delete the profile and confirm the live connection was undisturbed
- [x] 3.6 Join a secured network by creating the profile with `autoconnect no`, setting the key over that pipe, enabling autoconnect, then activating — and delete the profile if activation fails
- [x] 3.7 Refuse an 802.1X network with a message rather than building a profile that cannot work
- [x] 3.8 Cover hidden networks, saved profiles out of range, and the radio power toggle
- [x] 3.9 Show the active link's address on its row, and both address families with labelled fields behind Info
- [x] 3.10 Widen the Info menu for a labelled IPv6 address, which is 46 characters on its own

## 4. Feedback

- [x] 4.1 Detect the notification daemon once at startup rather than per message
- [x] 4.2 Send progress through `notify-send` and let it vanish; send failures at critical urgency
- [x] 4.3 Fall back to a menu window for failures when no daemon answers, so a failure is never silent
- [x] 4.4 Verify a redrawn menu carries the new state, so success needs no message of its own

## 5. The bar

- [x] 5.1 Point the bluetooth module's `on-click` at the Bluetooth menu, and update the comment that described the interface it replaces
- [x] 5.2 Give the network module the same click
- [x] 5.3 Set `"format-alt": null` on the network module, since waybar fires the alternate-format toggle and the click command on the same button and the label would otherwise swap on every open
- [x] 5.4 Reload the bar with SIGUSR2 on the compositor-spawned process and verify one process survives, so the configuration is known to parse

## 6. Tracking

- [x] 6.1 Place both scripts under `.config/fuzzel` rather than `.local/bin`, and record why in the ignore file's own comment
- [x] 6.2 Add the three block 3 entries and verify with `git check-ignore -v` that each file is now trackable
- [x] 6.3 Verify block 4 is unchanged
- [x] 6.4 Record the untracked `.desktop` entries and icons as an open gap rather than force-adding them

## 7. Close-out

- [x] 7.1 Exercise both scripts against the real adapter and NetworkManager with a stubbed chooser, covering menu construction, index mapping, deduplication, sort order and navigation
- [x] 7.2 Verify `git status` names only the intended paths, then commit
- [x] 7.3 Run `openspec validate manage-radios-from-the-launcher --strict` and verify it passes
