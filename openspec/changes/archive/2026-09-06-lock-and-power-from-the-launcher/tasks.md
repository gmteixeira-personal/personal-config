## 1. The script

- [x] 1.1 Write `.config/fuzzel/fuzzel-power`, taking the verb as `$1` and rejecting anything but `poweroff`, `reboot` and `lock` with a usage message on stderr and a non-zero exit; verify each of the three names is accepted and `fuzzel-power suspend` is refused
- [x] 1.2 Write the confirmation as a two-row `fuzzel --dmenu --index --only-match` menu with `Cancel` first and the verb-named row second, reusing the shape of `fuzzel-wifi`'s `pick`; verify the returned value is `0` for the first row and `1` for the second
- [x] 1.3 Proceed only on exactly `1`, so that a dismissal, an empty return and any non-numeric value all fall through to doing nothing; verify by dismissing the menu with Escape and confirming the machine keeps running
- [x] 1.4 Reach the transition with `systemctl poweroff` and `systemctl reboot`, and `lock` with `swaylock` and no arguments — called rather than `exec`ed, since `exec` leaves nothing behind to report a refused request with
- [x] 1.5 Report a refused or failed request through `notify-send` at critical urgency, matching what `fuzzel-wifi` and `fuzzel-bluetooth` do for their own failures; verify the message displays by pointing the call at a verb systemd will refuse
- [x] 1.6 Head the file with a comment covering what the other three in this directory cover: why the confirmation is a fuzzel menu, why `Cancel` is first, why `lock` is not confirmed, and why `systemctl poweroff` rather than `shutdown`
- [x] 1.7 `chmod +x` the script and create `.local/bin/fuzzel-power` as a relative symbolic link to it; verify `command -v fuzzel-power` resolves in a fresh shell

## 2. The launcher entries

- [x] 2.1 Draw `fuzzel-poweroff.svg`, `fuzzel-reboot.svg` and `fuzzel-lock.svg` into `.local/share/icons/hicolor/scalable/apps/`, recoloured from Adwaita's `system-shutdown-symbolic`, `system-reboot-symbolic` and `system-lock-screen-symbolic` to `#cdd6f4` on the same 16px grid as the existing three
- [x] 2.2 Write `.local/share/applications/poweroff.desktop`, `reboot.desktop` and `lock.desktop`, each `Terminal=false`, each naming its icon and calling `fuzzel-power` with its verb
- [x] 2.3 Give each entry keywords that cover the synonyms — `shutdown`, `halt`, `power off` for the first; `restart`, `reboot` for the second; `screensaver`, `lock screen` for the third — without generic terms like `system` or `exit`; verify each entry is reachable by typing a prefix of each of its keywords into the launcher
- [x] 2.4 Confirm no packaged entry in `/usr/share/applications` shares any of the three filenames, since a same-named entry in `.local` shadows it silently
- [x] 2.6 Add `fields=filename,name,generic,keywords` to `.config/fuzzel/fuzzel.ini` with a comment naming what the default omits, since fuzzel's default `filename,name,generic` reads an entry's `Keywords=` line and ignores it; verify against `man 5 fuzzel.ini`
- [x] 2.7 Verify the keywords now match, both on a new entry and on one of the three that were already carrying dead keywords — `arithmetic` for the calculator, `ssid` for Wi-Fi
- [x] 2.5 Verify all three appear in the launcher with their icons drawn rather than as blanks or as the missing-image glyph

## 3. Tracking

- [x] 3.1 Add `!/.config/fuzzel/fuzzel-power` to `.gitignore` block 3 beside the other three, with the comment extended to name it
- [x] 3.2 Add the three desktop entries, the three icons and `!/.local/bin/fuzzel-power` to block 5, beside their counterparts and under the comments that already explain why each kind of file is there
- [x] 3.3 Verify no block 4 pattern pair is needed, and that `git status --porcelain` lists exactly the eight new files and nothing else from `.local/`
- [x] 3.4 Verify no tracked file added by this change contains an absolute path naming this machine's home directory

## 4. Verification

- [x] 4.1 Press Enter twice in a row from the launcher on `Shut Down` and confirm the machine is still running — the cancel-first ordering is the safety property and this is the test of it
- [x] 4.2 Dismiss the confirmation with Escape and confirm nothing is pending: `systemctl list-jobs` is empty of a shutdown job and `systemctl status systemd-shutdownd` reports nothing scheduled
- [x] 4.3 Choose the lock entry and confirm the screen locks with no confirmation shown, and that the screen presented is the same one `Super+Alt+L` presents
- [x] 4.4 Confirm neither power verb raises a polkit prompt, by checking `loginctl show-session` reports the session active and running the reboot verb through to the transition — the session half is verified (`Active=yes`, `State=active`, `CanPowerOff` and `CanReboot` both `yes`); the transition half is 4.5
- [x] 4.5 Reboot the machine from the entry and confirm it comes back, then power it off from the entry and confirm it powers off rather than restarting
- [x] 4.6 Confirm `Super+Alt+L` still spawns `swaylock` directly and does not go through the script, so a broken script cannot take locking with it
