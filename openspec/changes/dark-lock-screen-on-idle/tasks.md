## 1. Give the lock screen its appearance

- [x] 1.1 Write `.config/swaylock/config` with `color=11111b` and `scaling=solid_color` for the background, `indicator-radius=110`, `indicator-thickness=6`, `line-uses-inside` and `separator-color=00000000` for the ring, and `font=Adwaita Sans` at size 20; verify it parses by running `swaylock -C .config/swaylock/config` with `WAYLAND_DISPLAY` pointed at a name no compositor is serving, and confirming it reaches `Unable to connect to the compositor` rather than a usage dump
- [x] 1.2 Confirm the parse check actually proves something, by appending a bogus line to a copy and verifying that copy fails with `swaylock: unrecognized option` before any compositor connection is attempted
- [x] 1.3 Give each state named in `screen-locking` its own colour — at rest, key accepted, backspace, verifying, rejected, cleared, and Caps Lock on the ring via `indicator-caps-lock` — and verify by reading the file back that no two of those seven states share a value
- [x] 1.4 Add `ignore-empty-password` and `show-failed-attempts`, and verify both appear in the file as bare options with no `=`
- [x] 1.5 Add `!/.config/swaylock/config` to the wayland-session block of `.gitignore`'s block 3, and verify `git check-ignore -v .config/swaylock/config` names that allowlist line rather than a block 1 or block 4 rule

## 2. Lock the session on idle and before sleep

- [x] 2.1 Add `spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock -f" "before-sleep" "swaylock -f"` to `.config/niri/config.kdl` beside the existing waybar startup entry, and verify the timeout reads `300` rather than a value in minutes
- [x] 2.2 Run `niri validate` and verify it reports the configuration as valid
- [x] 2.3 Verify the `Super+Alt+L` binding at `.config/niri/config.kdl:367` is untouched — still `spawn "swaylock"` with its `hotkey-overlay-title` naming swaylock — so the on-demand path and the idle path differ only by `-f`

## 3. Say what the session now needs and what the checkout now carries

- [x] 3.1 Rewrite the `waybar`/`fuzzel`/`swaylock` entry under **Required** so it names swaylock as configured by the checkout and waybar and fuzzel as running on their defaults, and verify it no longer claims that none of the three has a tracked configuration
- [x] 3.2 Add a **Required** entry for `swayidle` stating what is lost without it — the session locks only on `Super+Alt+L`, with no idle timeout and no lock before sleep — and verify it says the failure is a degradation rather than a broken session
- [x] 3.3 Update the opening of **Rebuilding the desktop session** to say the checkout carries configuration for niri, foot and swaylock, and verify it no longer says the checkout carries niri and foot only
- [x] 3.4 Add swayidle to the install list in step 1 of the rebuild procedure, and verify every program the compositor spawns at startup appears there

## 4. Validate the change

- [x] 4.1 Run `openspec validate dark-lock-screen-on-idle --strict` and verify it passes
- [x] 4.2 Verify the `desktop-session-declaration` delta carries the whole requirement block it modifies, scenarios included, so archiving cannot drop one

## 5. Verify the session

- [ ] 5.1 Restart the session with `niri-session` and verify `pgrep -a swayidle` shows exactly one process carrying the `timeout 300` arguments
- [ ] 5.2 Press `Super+Alt+L` and verify the screen that appears is dark rather than light grey, with a single large ring and no segment separators
- [ ] 5.3 Leave the session untouched for five minutes and verify it locks on its own, presenting the same screen as 5.2
- [ ] 5.4 Type a character, then a backspace, then submit a wrong password, and verify the ring reports each of those three states differently and that the failed-attempt count is shown
- [ ] 5.5 Press Enter on an empty field and verify the failed-attempt count does not increase
- [ ] 5.6 Enable Caps Lock at the lock screen and verify the ring itself changes colour rather than only the text
- [ ] 5.7 Suspend the machine and resume it, and verify it comes back to a lock screen
