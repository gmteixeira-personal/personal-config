## Why

`Ctrl+Alt+Escape` was bound to swaylock and does not lock this machine. The bind
parsed, `niri validate` passed, the running compositor logged the reload, and
pressing the chord produced nothing at all — no spawn, no `locking session` line, no
swaylock scope in the journal. Something ahead of niri takes that chord, so the bind
is a lock route that exists only in the file.

`Mod+Escape` is the chord wanted instead: shorter, one modifier, and confirmed to lock
on this machine. It was not free — `toggle-keyboard-shortcuts-inhibit` held it — and a
chord bound twice does not shadow, it makes niri reject the file and carry on with the
last good copy, silently. So taking it means moving the toggle.

The failure also says something the spec does not: a chord that never reaches the
compositor is indistinguishable, in the configuration, from one that works. Nothing in
the file or in `niri validate` can tell the two apart, and the previous change shipped
one of each.

## What Changes

- Bind `Mod+Escape` to `spawn "swaylock"` in `.config/niri/config.kdl`, with
  `allow-inhibiting=false` and the same `hotkey-overlay-title` as `Super+Alt+L`.
- Remove the `Ctrl+Alt+Escape` lock bind, leaving a comment that records what was
  observed, so the chord is not proposed again as an obvious free one.
- Move `toggle-keyboard-shortcuts-inhibit` from `Mod+Escape` to `Mod+Shift+Escape`,
  keeping its `allow-inhibiting=false`.
- Keep `Super+Alt+L`, unchanged.
- Update `README.md`, which names the session's lock chords.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `screen-locking`: the on-demand requirement counts a compositor chord as a lock
  route only once the chord has been confirmed to lock the machine it is configured
  on. A chord the compositor never receives is not a route.

## Impact

- `.config/niri/config.kdl`: the two lock binds and the shortcuts-inhibitor toggle.
- `README.md`: the sentence naming the lock chords.
- `Mod+Escape` no longer toggles the shortcuts inhibitor. Anything reaching for it
  under a remote-desktop client or a software KVM now presses `Mod+Shift+Escape`.
- No new package, daemon or privileged process; niri reloads the file on save.
