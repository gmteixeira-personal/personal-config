## Why

One chord locks the session: `Super+Alt+L`. It is the chord niri's own example
configuration suggests rather than one this machine chose, and it is a two-modifier
stretch across the bottom-left corner to a letter on the home row's right half.
`Ctrl+Alt+Escape` is the shape the hands already know from `Ctrl+Alt+Delete`, which
this configuration binds three lines away for `quit`, and it reaches nothing else in
niri — the compositor reserves `Ctrl+Alt+F1..F12` for VT switching, not `Escape`.

The second reason is the one that matters more. Every on-demand lock route this
configuration has is suppressible. An application that takes the keyboard-shortcuts
inhibitor — a remote-desktop client, a software KVM — stops niri from processing any
bind that does not carry `allow-inhibiting=false`, and neither the lock bind nor the
launcher binds that reach the lock entry carry it. While such a client holds the
keyboard, `Super+Alt+L` does nothing, `Mod+D` and `Mod+Space` do nothing, and the
session cannot be locked at all until `Mod+Escape` is found and pressed first to
release the inhibitor. That is precisely the moment locking is wanted: the machine is
in front of someone else's session and about to be walked away from.

## What Changes

- Bind `Ctrl+Alt+Escape` to `spawn "swaylock"` in `.config/niri/config.kdl`, beside
  the existing `Super+Alt+L`, carrying the same `hotkey-overlay-title` so the overlay
  names swaylock for both.
- Add `allow-inhibiting=false` to both lock binds, so a client holding the
  keyboard-shortcuts inhibitor cannot suppress the lock.
- Keep `Super+Alt+L`. Nothing is taken away; an action costs nothing to bind twice,
  and this file already pairs chords this way for the terminal, the launcher and the
  overview.
- Leave the launcher entry, the idle timeout and the sleep hook untouched. They
  already reach the same swaylock through the same tracked configuration.

## Capabilities

### New Capabilities

<!-- None. Screen locking already has a spec. -->

### Modified Capabilities

- `screen-locking`: the on-demand lock requirement currently asks for a compositor
  binding and a launcher entry. It gains a second compositor chord, and gains the
  requirement that the compositor's lock routes survive an active
  keyboard-shortcuts inhibitor.

## Impact

- `.config/niri/config.kdl`, the two lock bind lines in the `binds` block.
- No new package, daemon or privileged process. niri reloads the file on save, so the
  chord is live without a restart or a re-login.
- No other bind changes. `Mod+Escape`, which already carries
  `allow-inhibiting=false`, keeps its job as the general escape hatch; this change
  only stops the lock from depending on it.
