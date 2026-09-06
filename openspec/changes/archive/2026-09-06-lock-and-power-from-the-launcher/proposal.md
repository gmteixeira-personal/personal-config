## Why

The session can be locked and it can be powered off, and neither is reachable from the surface the session opens most. Locking has exactly one trigger a hand can reach — `Super+Alt+L` in `.config/niri/config.kdl` — and that chord has to be known before it can be used; the hotkey overlay that lists it is itself behind a chord. Powering off has none at all. There is no shell menu, no power button on the bar, and `niri` holds a `handle-power-key` block inhibitor, so the hardware key belongs to the compositor and does nothing with it. Shutting this machine down means opening a terminal and typing `systemctl poweroff`, and restarting it means the same with a different verb.

The launcher already answers this for every other task of this size. `fuzzel-bluetooth`, `fuzzel-wifi` and `fuzzel-calc` each established the same shape: a script drives `fuzzel --dmenu`, a desktop entry makes it findable by typing a few letters of its name, an icon and a tracked symbolic link finish it. Three verbs are missing from that set, and two of them are the ones that end the session.

Those two are also the reason this is not simply three more entries. A launcher is a fuzzy matcher over every desktop entry on the machine: `sh` matches `Shut Down`, and a mistyped search followed by Enter is one keystroke away from discarding whatever is unsaved in every open window. The radio menus could afford a wrong pick because a wrong pick there is undone by picking again. Powering off is not undone. The confirmation is what makes the entry safe enough to exist beside `Shotwell` in the same list, and it belongs in fuzzel rather than in a dialog toolkit the session does not install.

## What Changes

- One script, `.config/fuzzel/fuzzel-power`, carries all three verbs and is invoked with the verb as its argument: `fuzzel-power poweroff`, `fuzzel-power reboot`, `fuzzel-power lock`. One file rather than three keeps the confirmation menu written once, so the two destructive verbs cannot drift apart in wording or in behaviour.
- Three desktop entries — `poweroff.desktop`, `reboot.desktop` and `lock.desktop` — put the verbs in the launcher under the names a hand would type for them, each with keywords covering the words this session's user might reach for instead (`shutdown`, `halt`, `restart`, `screensaver`).
- `.config/fuzzel/fuzzel.ini` gains `fields=filename,name,generic,keywords`, because the launcher's default field list does not include keywords. Discovered while implementing this change: every entry this repository ships already carries a `Keywords=` line, and not one of them has ever matched anything.
- `poweroff` and `reboot` open a confirmation menu in fuzzel before acting. The menu's default selection is the one that does nothing, so Enter pressed twice in succession cancels rather than commits, and the confirming entry names the verb rather than saying "Yes".
- `lock` does not confirm. It runs `swaylock` directly, because a lock screen dismissed by the password that was going to be typed anyway costs nothing to trigger by accident, and a confirmation on it would be a prompt in front of the one action that is meant to be instant.
- Shutdown and reboot go through `systemctl poweroff` and `systemctl reboot` — the logind request, made and acted on immediately. Not `shutdown -h`, which schedules the transition for a minute out, broadcasts a wall message and leaves the machine running until then.
- Locking reaches `swaylock` with no arguments, as the compositor binding already does, so the appearance stays the tracked `.config/swaylock/config` and this change adds no fourth place where lock screen options could be set.
- Three icons, recoloured from Adwaita's symbolic set to the launcher's text colour, exactly as the existing three were.
- `.gitignore` gains the script, the three entries, the three icons and the symbolic link, in the blocks those file types already have.

## Capabilities

### New Capabilities

- `session-power-control`: The session has no capability covering how it is powered off or restarted. `screen-locking` covers the screen and `graphical-session-startup` covers coming up; nothing covers going down, which is why the only route to it is a terminal. This capability states that both verbs are reachable from the launcher, that each is confirmed before it acts and that the confirmation defaults to refusing, that the transition is requested immediately rather than scheduled, and that dismissing the confirmation leaves the machine exactly as it was.

### Modified Capabilities

- `application-launcher`: The capability already covers what the launcher does with the entries it presents and what it looks like doing it. It gains a requirement that a query is matched against an entry's keywords and that the matched field list is stated in tracked configuration rather than inherited — the same shape as its existing requirement about the terminal command, and for the same reason: a default that cannot do the job here fails silently and leaves the entry looking correct.
- `screen-locking`: The capability already requires that the session locks on demand and names a compositor binding as how. It gains a requirement that on-demand locking is also reachable from the launcher, and that this second route reaches the same swaylock through the same tracked configuration — which is the property the existing "One configuration serves every trigger" scenario exists to protect, now with one more trigger to hold it against.

## Impact

- `.config/fuzzel/fuzzel-power` — new, executable, tracked. It lives beside the launcher configuration rather than in `.local/bin` for the reason the other three do: `.gitignore` block 4 ignores `.local/` wholesale, and a block 3 entry cannot re-include a file whose parent directory block 4 excludes.
- `.local/share/applications/poweroff.desktop`, `reboot.desktop`, `lock.desktop` — new and tracked, alongside the three entries already there.
- `.local/share/icons/hicolor/scalable/apps/fuzzel-poweroff.svg`, `fuzzel-reboot.svg`, `fuzzel-lock.svg` — new and tracked, recoloured from `system-shutdown-symbolic`, `system-reboot-symbolic` and `system-lock-screen-symbolic`.
- `.local/bin/fuzzel-power` — a tracked relative symbolic link, matching the three already tracked for the same reason: a desktop entry cannot say `$HOME`, so the entries name the script by bare command name and something has to put that name on `PATH`.
- `.gitignore` — one block 3 entry, seven block 5 entries. No new block 4 pattern pair: all four directories these files land in are already reached.
- `.config/fuzzel/fuzzel.ini` — one `fields` line and the comment above it. This is the only file in the change that alters behaviour outside it: every packaged entry's keywords become searchable too, so some queries return more than they did.
- `.config/niri/config.kdl` — unchanged. `Super+Alt+L` keeps working and keeps spawning `swaylock` directly; the launcher entry is a second route to it, not a replacement.
- Packages: none. `systemctl`, `swaylock` and `fuzzel` are all already present, and `loginctl` reports `CanPowerOff` and `CanReboot` as `yes` for this session, so neither verb raises a polkit password prompt there would be nothing to answer.
- Not in scope: suspend, hibernate, log out, and a power button on the bar. Each is a defensible addition and none is what is missing today — the machine is suspended by closing the lid, and the session is ended by powering the machine off.
