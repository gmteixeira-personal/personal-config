## Context

See `proposal.md` — Why. The constraints that shape the approach, all of them already true of this session:

- The launcher is `fuzzel` 1.14.0, and `fuzzel --dmenu` is the only chooser the session has. There is no dialog toolkit in use, no desktop shell, and no notification-based confirmation mechanism worth building one on.
- Three scripts already establish the shape this change follows: `.config/fuzzel/fuzzel-bluetooth`, `fuzzel-wifi` and `fuzzel-calc`, each with a desktop entry in `.local/share/applications`, an icon in `.local/share/icons/hicolor/scalable/apps`, and a tracked relative symbolic link in `.local/bin`. `.gitignore` blocks 3, 4 and 5 already reach all four directories.
- `loginctl` reports `CanPowerOff` and `CanReboot` as `yes` for this session, so neither verb raises a polkit prompt. This matters because the session registers no polkit authentication agent; a prompt here would stall invisibly.
- `swaylock` 1.8.6 reads `.config/swaylock/config`, and `screen-locking` requires every lock trigger to reach it through that file rather than through per-call arguments.
- `/usr/share/applications` contains no entry named `poweroff.desktop`, `reboot.desktop` or `lock.desktop`, so none of the three new entries shadows a packaged one. XDG name-based overriding is silent when it happens, so this was checked rather than assumed.

## Goals / Non-Goals

**Goals:**

- One confirmation implementation, written once, used by both destructive verbs.
- A confirmation that is safe against the specific failure it exists for: a keystroke arriving before the window is read.
- No new dependency, no new palette copy, no second place where lock screen options are set.

**Non-Goals:**

- Suspend, hibernate and log out. Out of scope in the proposal, and each would need its own decision about confirmation.
- A power control on the bar. `bar-appearance` requires a module to report something; these are verbs, not readings.
- Handling the hardware power key. `niri` holds a `handle-power-key` block inhibitor and decides that question in `.config/niri/config.kdl`; changing it is a compositor decision, not a launcher one.
- Warning about unsaved work in open applications. Nothing on the session bus reports it, and a confirmation that claims to check and cannot is worse than one that does not claim.

## Decisions

### One script taking the verb as an argument, not three scripts

`.config/fuzzel/fuzzel-power` is invoked as `fuzzel-power poweroff`, `fuzzel-power reboot` or `fuzzel-power lock`, and each desktop entry passes one of those.

The alternative — `fuzzel-poweroff`, `fuzzel-reboot`, `fuzzel-lock` as three files, matching the one-script-one-entry shape of the existing three — was rejected because the confirmation would then exist twice. Two copies of a safety mechanism drift: a fix to the cancel-first ordering, or a change to how the menu is worded, lands in one and not the other, and the file that did not get it is the one nobody re-reads because it appears to work. The existing three scripts are one file each because each does a different thing; these two do the same thing to different targets.

Three desktop entries still exist, because the launcher's list is what the user searches and one "Power" entry that opens a second menu would put a menu in front of the confirmation — two choices to reach one action, with the more dangerous one deeper. `lock` shares the script for the sake of one file rather than because it shares behaviour.

### The confirmation is a two-line `fuzzel --dmenu` with cancel first

The menu offers exactly two rows, in this order:

```
Cancel
Shut Down        # or: Restart
```

`--index` returns the 0-based row rather than the label, and `--only-match` rules out a custom entry, both as `fuzzel-wifi`'s `pick` already does. The dangerous row is index 1; anything else — index 0, a dismissal, an empty return, a non-numeric one — falls through to doing nothing. The check is `[[ $choice == 1 ]]`, not `[[ $choice != 0 ]]`: a failure mode that is not enumerated must land on the safe side, and the second form sends an unexpected value to the machine.

Cancel is first because fuzzel starts with the first row selected and there is no option to start with none selected. That ordering is the whole mechanism the "Enter twice does not power the machine off" scenario tests: the Enter that chose `Power Off` in the launcher can still be in flight when the confirmation maps, and it lands on `Cancel`.

The proceeding row says `Shut Down` rather than `Yes` for a related reason. A confirmation met at speed is skimmed rather than read, and `Yes` carries no information without the question above it — fuzzel's prompt is a short string beside an input box, not a paragraph. `Shut Down` states the outcome in the row being selected.

Alternatives considered: a typed-word confirmation (`type POWEROFF to continue`), rejected as disproportionate for a single-user laptop where the cost of a mistake is unsaved work rather than data loss; a countdown with a cancel window, rejected because it leaves the session in a state where the machine is going down and the only way to stop it is a window that may be behind another one.

### `systemctl poweroff` and `systemctl reboot`, called rather than `exec`ed

`systemctl poweroff` asks logind to begin the transition immediately. `shutdown -h +1` and `shutdown -h now` were rejected: the first schedules a transition a minute out and broadcasts a wall message meanwhile, which is a different action from the one the entry names, and the second is a compatibility wrapper around the same logind call with a `wall` message nobody in a single-user graphical session reads.

`loginctl poweroff` and a raw `busctl call org.freedesktop.login1` reach the same manager; `systemctl` is chosen for being the form a reader recognises and the form the failure would be diagnosed in.

`exec systemctl poweroff` was the first form written here, on the grounds that no shell frame should be left waiting behind a process about to be killed by the shutdown it requested. It was replaced during implementation because `exec` replaces the shell, and a replaced shell has nothing left to report a refused request with. The frame that survives instead costs one sleeping bash for the length of a shutdown that kills it anyway, which is a smaller price than a failure nobody sees.

Nothing is waited for either way. The transition belongs to logind once the request is made and does not depend on the script outliving it, which is also why no `--no-block` is needed: pid 1 carries it out regardless.

Failure is possible in principle (a refused request, a name not on the bus) and the script reports it the way the rest of `.config/fuzzel/` does: `notify-send` at critical urgency, which `.config/mako/config` is set not to expire, falling back to a fuzzel window when no daemon owns the name. It is a genuinely rare path — `CanPowerOff` is `yes` and the local session is active — but a silent one otherwise, since the launcher has already closed by then.

### `lock` runs `swaylock` with no arguments and no confirmation

`swaylock` bare, exactly as `Super+Alt+L` spawns it, so the screen's appearance keeps coming from `.config/swaylock/config` and this change adds no fourth call site with its own options. `screen-locking`'s "One configuration serves every trigger" is a requirement about drift, and drift is what passing a flag here would start.

No confirmation, because an accidental lock is undone by the password the user was about to type and a prompt in front of it would cost more than the mistake. This is the asymmetry the change turns on and it is stated in both specs rather than only in the script.

`swaylock` is not forked to the background: without `-f` it holds the screen for its own lifetime, which is what a spawned launcher entry wants. Its exit status is checked for the same reason the power verbs' is — a lock that fails to start is the one silent failure here that matters, because the user walks away from a session they believe is locked. `-f` exists for `swayidle`, which needs the process to daemonize so its own `timeout` bookkeeping continues, and that is why `.config/niri/config.kdl` passes it there and not on the binding.

### Three icons, named for the verb rather than for the script

`fuzzel-poweroff.svg`, `fuzzel-reboot.svg` and `fuzzel-lock.svg`, recoloured from Adwaita's `system-shutdown-symbolic`, `system-reboot-symbolic` and `system-lock-screen-symbolic` to `#cdd6f4` — the launcher's `text` colour, the same substitution `fuzzel-wifi.svg` and `fuzzel-bluetooth.svg` already record. Adwaita's originals are `#2e3436` on this session's `#1e1e2e` background: present, correct, invisible.

The existing icons are named after their script; these are named after their entry, because one script now serves three. The `fuzzel-` prefix is kept so the set stays greppable and so nothing collides with a themed icon name.

### `.gitignore` placement

The script goes in block 3 beside the other three `.config/fuzzel/` entries; the entries, icons and the `.local/bin/fuzzel-power` link go in block 5 beside their counterparts. No block 4 pattern pair is added — all four directories are already reached, which is the whole reason block 4 was written the way it was.

The symbolic link is tracked rather than derived, with a relative target, for the reason `.gitignore` already gives for the other three: a desktop entry cannot say `$HOME`, so it names the script by bare command name, and a tracked file naming this machine's home directory is what the ignore policy exists to keep out.

## Risks / Trade-offs

- **A user learns to hit Enter twice out of habit, and the confirmation stops confirming anything.** → Not mitigable by ordering, and worth naming rather than pretending otherwise. The mitigation available is that the second Enter lands on `Cancel`, so the habit that forms is the harmless one: two Enters is a cancel, and powering off takes a deliberate Down.
- **`Shut Down` and `Restart` sit in the same fuzzy-matched list as every application, so a short query can surface them unintentionally.** → This is the risk the confirmation exists for and it is accepted, not removed. Keywords are chosen to make the entries findable without making them promiscuous: no single-letter and no generic term like `system` or `exit`.
- **The confirmation is only as good as fuzzel's initial selection.** → If a future fuzzel changed which row starts selected, the safety property would silently invert. `--index` makes this checkable — the test in the tasks is to press Enter twice and confirm the machine is still running — but nothing in the configuration pins it.
- **A held-open application blocks or delays the transition and the user sees nothing, because the launcher has closed.** → Out of the script's hands once logind has the request; this is systemd's stop-job handling and a machine-level timeout setting outside `$HOME`. Recorded rather than worked around.
- **One script, three entries, means a broken script breaks locking too.** → Locking keeps its independent route: `Super+Alt+L` spawns `swaylock` directly and does not go through this script, which is why the binding is left alone rather than retargeted at `fuzzel-power lock`.
