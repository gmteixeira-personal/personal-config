## Context

See proposal.md — Why. The constraint is that `Mod+Escape` was already bound, to
`toggle-keyboard-shortcuts-inhibit`, which is the escape hatch for an application that
takes the keyboard-shortcuts inhibitor. niri answers a chord bound twice with
`duplicate keybind later defined here` and keeps running the last good copy of the
file, so the toggle has to move before the lock can take the chord.

`Ctrl+Alt+Escape`, bound by the previous change, is not a parse or a reload problem:
`niri validate` accepts it, `niri[1404]` logged `loaded config from` 265 ms after the
write, and the chord still produced no `locking session`, no `app-niri-swaylock-*.scope`
and no journal line of any kind. Whatever eats it sits between the keyboard and niri's
bind matching, and nothing available here says what.

## Goals / Non-Goals

**Goals:**

- Put the second lock chord on `Mod+Escape`, confirmed by pressing it.
- Keep the shortcuts-inhibitor escape hatch, on a chord of its own.

**Non-Goals:**

- Finding out what takes `Ctrl+Alt+Escape`. It would need a `libinput debug-events`
  session, and the answer changes nothing: the chord is unusable on this machine
  either way, and a working chord is already in hand.
- Auditing the other binds for the same problem. They are pressed daily; this one was
  new and therefore untested.

## Decisions

**`Mod+Escape` for the lock, `Mod+Shift+Escape` for the toggle — not the reverse.**
The two chords are not equal: one is pressed to lock a machine that is being walked
away from, the other is pressed once when a remote-desktop client misbehaves. The
shorter chord goes to the action taken more often and under more time pressure.
Keeping the toggle on `Escape` with a modifier added also keeps it findable from the
chord it used to be.

**Keep `allow-inhibiting=false` on the toggle.**
It is the escape hatch. A hatch an inhibitor can suppress is not one, which is why
niri's example config sets the property there in the first place.

**Delete the `Ctrl+Alt+Escape` bind rather than leave it in place beside the new one.**
It costs nothing to run and it is not harmless: it appears in the hotkey overlay as a
lock chord, which is exactly the false claim this change is removing. The comment left
behind carries what was observed, so the next reader does not rediscover it as a free
chord.

**Confirm by pressing, and put that in the spec.**
This is what the previous change got wrong. `niri validate` and a reload in the journal
are both necessary and neither is evidence that a chord reaches the compositor, so the
requirement now names the press as the test.

## Risks / Trade-offs

- **`Mod+Escape` is muscle memory for the inhibitor toggle** → it was bound but never
  needed on this machine; no remote-desktop client or software KVM runs here. The
  comment at the toggle records where it went.
- **Pressing `Mod+Escape` under an active inhibitor now locks instead of releasing the
  inhibitor** → `Mod+Shift+Escape` releases it, and it is the chord immediately beside
  it. Locking is also the safer of the two things to do by accident: it costs one
  password.
- **Whatever eats `Ctrl+Alt+Escape` may eat another chord later** → the same test
  applies. A chord is counted as a route once it has been pressed and seen to lock.
