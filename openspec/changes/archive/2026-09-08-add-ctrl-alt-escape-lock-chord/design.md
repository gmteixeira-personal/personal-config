## Context

See proposal.md — Why. The constraints are in `.config/niri/config.kdl`.

`Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }`
sits under the "Suggested binds for running programs" comment, in the group that
already pairs two chords per action: `Mod+Return` and `Mod+T` open the terminal,
`Mod+D` and `Mod+Space` open fuzzel. That comment states the rule the pairing follows
— a chord costs nothing to bind twice, and removing one is a silent failure, because
an unbound chord opens no window and logs nothing.

niri binds are inhibitable by default. An application that takes the
keyboard-shortcuts inhibitor stops the compositor from processing every bind that does
not set `allow-inhibiting=false`. This file uses the property exactly once today, on
`Mod+Escape { toggle-keyboard-shortcuts-inhibit; }`, with a comment noting it can be
applied to other binds as well.

A bind is a duplicate-key error, not a shadow: niri answers `duplicate keybind later
defined here` and keeps running the last good copy of the file, so a chord bound twice
by accident fails silently at load. `Ctrl+Alt+Escape` is unbound in this file, and
niri reserves `Ctrl+Alt+F1..F12` for VT switching, not `Escape`. The nearby
`Ctrl+Alt+Delete { quit; }` is the only other `Ctrl+Alt` chord.

## Goals / Non-Goals

**Goals:**

- Put the lock on a chord the hands already know, without giving up the one that works.
- Make the compositor's lock routes unsuppressible by a running application.

**Non-Goals:**

- Making the launcher reachable under an inhibitor. `Mod+D` and `Mod+Space` stay
  inhibitable; the launcher is the discoverable route, not the one needed while a
  remote-desktop client holds the keyboard, and the point of this change is that
  locking no longer depends on it.
- Auditing the rest of the binds for `allow-inhibiting`. Media keys, screenshots and
  window movement are exactly what an inhibitor is entitled to take.
- Changing what locking runs. Both chords spawn the same `swaylock` reading
  `~/.config/swaylock/config`, as the idle daemon and the sleep hook already do.

## Decisions

**`Ctrl+Alt+Escape`, not a `Mod` chord.**
Every other bind in this file is `Mod`-prefixed, and a `Mod` chord would be the
consistent choice — but consistency is not what a second lock chord is for. The first
chord already exists; a second one earns its place only by being reachable when the
first is not remembered. `Ctrl+Alt+Escape` borrows the `Ctrl+Alt+Delete` shape that
means "interrupt this machine" on every desktop the hands have used before this one,
and it is typed with the left hand alone. It is also, unlike a `Mod` chord, still
distinct in a nested niri session, where `Mod` becomes `Alt`.

**Keep `Super+Alt+L`.**
The alternative is moving the lock rather than adding to it. This file's own rule is
that taking a working chord away buys nothing, and the spec's `Super+Alt+L` appears in
the rationale of the on-demand requirement as the chord that has to be known in
advance. Two chords, one action, kept adjacent so the pair cannot drift apart
unnoticed.

**`allow-inhibiting=false` on both lock binds, not on the new one only.**
Setting it on the new chord alone would produce two lock chords that behave
differently, and the difference would show up only under an inhibitor — the case
nobody tests. The spec requires every lock chord to reach the same lock, so they get
the same property.

**Leave `Mod+Escape` as it is.**
It stays the general escape hatch for the remaining inhibitable binds. This change
removes the lock's dependency on it; it does not remove its job.

**Same `hotkey-overlay-title` on both.**
The overlay lists binds by their title. Two entries reading `Lock the Screen:
swaylock` say correctly that either chord does the one thing; a second title, or a
`null` that hides the new chord, would leave the overlay describing the file
inaccurately.

## Risks / Trade-offs

- **`Ctrl+Alt+Escape` is force-quit-a-window on KDE and some GNOME setups** → not
  bound to anything in niri, and this configuration is the only thing that binds
  chords on this machine. A person arriving from KDE gets a lock instead of an
  `xkill` cursor; the lock is dismissed by a password, so the cost of the surprise is
  one password.
- **`Ctrl+Alt+Delete` three lines below quits the session, with a confirmation
  dialog** → the two chords differ by a key at the opposite end of the keyboard, and
  the destructive one is the one that confirms. No new risk beyond what
  `Ctrl+Alt+Delete` already carries.
- **A remote-desktop client can no longer forward `Ctrl+Alt+Escape` or
  `Super+Alt+L` to the far machine** → that is the requirement, not a side effect. If
  a far machine ever needs one of those chords, `Mod+Escape` releases the inhibitor
  for everything else and the remaining binds still forward.
- **A typo in the new line takes the whole file down to its last good copy, silently**
  → `niri validate` is run before the file is saved into place, and the tasks check
  the chord actually locks rather than assuming the reload happened.
