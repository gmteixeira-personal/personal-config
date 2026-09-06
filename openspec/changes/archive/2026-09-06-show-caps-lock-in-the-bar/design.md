## Context

See proposal.md — Why. What constrains the approach is that nothing in the session can be made to *announce* the lock; it can only be observed.

The Caps Lock key is Control (`ctrl:nocaps`) and the lock is on `Shift+F12` through this repository's own XKB option. XKB resolves that inside the keymap, so the compositor never runs a binding for it — and a compositor binding on `Shift+F12` would consume the key and stop the lock from happening at all. niri's IPC does not carry lock state either: its event stream reports workspaces, windows, keyboard layouts and the overview, and nothing else.

That leaves two places the state is readable: the evdev device that reports `EV_LED`, and the LED class under `/sys/class/leds`.

## Goals / Non-Goals

**Goals:**

- The lock is visible while it is on, and the bar is unchanged while it is off.
- The indicator costs no group membership, no package and no udev rule.
- The reason the direct source was declined survives in the file, so the module is not later "simplified" onto it.

**Non-Goals:**

- Num Lock and Scroll Lock. Neither has a key on this keyboard worth reporting, and each additional lock is another permanent widget.
- A transient on-screen display. That was the alternative considered when this was first discussed; an indicator was chosen because a lock is a state, and a state reads better as something visible for as long as it holds than as a popup that can be missed.
- Reporting the lock anywhere but the bar.

## Decisions

### Read the LED under `/sys/class/leds`, not `/dev/input`

waybar ships `keyboard-state`, which does exactly this module and reads `/dev/input` through libevdev. That needs the user in the `input` group, and the group is not scoped to waybar: it grants every process the user runs the ability to read every keystroke on every input device, permanently. That is the whole keyboard, granted to draw one word.

`/sys/class/leds/*::capslock/brightness` reports the same lock, is world-readable, and follows the state whichever way it was set. The cost is that it must be polled rather than waited on.

Alternatives considered:

- **`keyboard-state` plus the `input` group.** Two lines of configuration and no script. Rejected on the grant, which is also what the new spec requirement now forbids.
- **A udev rule granting only this user only the capslock LED.** Narrower than the group, but it is a privileged file outside the repository — the same objection that ruled out an hwdb entry for the `Fn+F4` key, and here it buys nothing, because the LED is already world-readable.
- **`libinput debug-events` parsed by a script.** Still `/dev/input`, so still the group.

### Poll, but wake without forking

The LED attribute is unlikely to wake `poll(2)`: a sysfs attribute only does so where the driver calls `sysfs_notify()`, and that was not verified for the LED class. Polling at 100 ms is what makes the indicator appear with the keypress rather than after it.

A `sleep` in the loop would fork a process ten times a second for the length of the session. Reading with a timeout from a file descriptor opened read-write on a pipe that never delivers waits exactly as well and forks once, at startup. Measured at zero CPU ticks over three seconds.

### One line per change, not one line per poll

waybar's continuous `exec` redraws on each line it reads. Printing every poll would redraw the bar ten times a second to say nothing changed. The script holds the last value and prints only on a transition, so the bar does work only when the lock actually moves.

This is also why the module carries no `interval`: an interval would re-run the script from the start every tick and discard the process already watching. `restart-interval` is kept for the one case where the script exits, which is a machine with no capslock LED at all.

### Right of the workspaces, left of the layout

The user asked for it beside the workspaces, and it belongs there for the reason the layout indicator does: `niri/window` is variable width, so anything after it moves whenever the focused window changes.

Between the two, Caps Lock goes first — hard against the fixed-width workspaces. It is the one module here that appears and disappears, so placing it inboard of the layout indicator means the thing that changes width sits between two things that do not, rather than shifting the layout indicator's position every time the lock is used.

### Mauve, being the accent the bar does not already spend

The stylesheet's state colours are Catppuccin Mocha, and red, peach and yellow all already mean a reading has gone wrong. A lock that is on is not a fault. Mauve is unused in the file, and it has to be unmistakable against the layout indicator's warm yellow two modules over — the other thing on this bar that says the keyboard is in a mode.

## Risks / Trade-offs

- **A 100 ms timer for the life of the session** → no forking and no measurable CPU; the alternative costs a permanent keylogging-capable grant, which is the larger price.
- **The first `*::capslock` LED node answers for the machine.** Several keyboards each publish one → they all track the one lock, so any of them is correct; a keyboard attached later publishes its own node and the existing one keeps reporting.
- **A reader who finds `keyboard-state` in waybar's documentation will see a simpler module doing the same job** → the declined source and its cost are recorded in the module's own comment and in the script's header, and the spec now carries the rule rather than leaving it as a preference.
- **The indicator is absent while the lock is off, so a broken script looks exactly like a lock that is off** → the failure surfaces the first time the lock is used, which is the moment the module exists for.
