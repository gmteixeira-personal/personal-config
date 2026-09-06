## Why

Caps Lock sits on the home row under the left little finger, the best key on the
board, and toggles a mode almost nobody wants. Control sits in the bottom corner
and is pressed constantly — by readline in vi mode, by fish's key bindings, by
herdr's prefix, by every terminal program. Swapping them is the oldest keyboard
ergonomics fix there is.

Caps Lock itself is still wanted occasionally, so it moves rather than
disappearing: onto `Shift+F12`, a chord nothing here binds.

The remap has to hold wherever a key is read on this machine — the niri session,
the X11 clients that run under Xwayland inside it, and the virtual consoles on
tty1 through tty6. A remap that stops at the compositor is a remap that fails on
the one occasion the graphical session is broken and the console is where the
repair happens.

## What Changes

- `.config/niri/config.kdl` gains an `xkb` block naming the layout explicitly
  and the `ctrl:nocaps` option, which makes the Caps Lock key a Control.
- A new `.config/xkb/symbols/custom` puts `Caps_Lock` on the second level of
  `F12`, reached with Shift. `compat/complete` already carries
  `interpret Caps_Lock { action = LockMods(modifiers = Lock); }`, so a
  `Caps_Lock` keysym away from the first level locks the modifier with no
  further work.
- A new `.config/xkb/rules/evdev` registers that as an option name, ending with
  `! include %S/evdev` so the stock rules still apply. libxkbcommon 1.13.1 reads
  `$XDG_CONFIG_HOME/xkb` ahead of the system tree.
- A tracked console keymap makes the same two changes for the virtual consoles:
  `keycode 58 = Control` and `shift keycode 88 = Caps_Lock`, over an
  `include "us"`. It is installed by a documented step, since `/etc` is outside
  `$HOME` and cannot be tracked here.
- `README.md` records that step and what is lost without it.

## Capabilities

### New Capabilities

- `keyboard-mapping`: what the physical keys do before any application sees
  them — which key carries which modifier, where a displaced function goes, and
  how far down the stack the answer holds. Named for the whole subject rather
  than for this one remap, because the layout work described below lands here
  too.

### Modified Capabilities

None.

## Impact

- `.config/niri/config.kdl` — the `xkb` block, currently all comments.
- `.config/xkb/symbols/custom`, `.config/xkb/rules/evdev` — new.
- A tracked console keymap, and `.gitignore` allow entries for all three.
- `README.md` — the install step for the console half.
- **No new package.** libxkbcommon 1.13.1, `kbd` 2.9.0 and Xwayland 24.1.13 are
  all installed. `keyd` was considered and rejected: it is unpackaged for Fedora
  44, needs a root daemon reading every input device, and is a key remapper with
  no layout engine — see the design.

## Non-Goals

Layout following the keyboard — `pt-pt` on one, `en-us` on another — is wanted
and is deliberately not built here. It is a separate mechanism: niri has no
per-device keyboard configuration, which was verified rather than assumed
(`keyboard "usb-0000:00-1"` is rejected with `unexpected argument`), so it will
be a hotplug trigger calling `niri msg action switch-layout` over an xkb layout
list.

Two consequences are designed for now rather than discovered later:

- The layout list will live in the same `xkb` block this change creates, so the
  later work edits one line rather than introducing a mechanism.
- The remap SHALL NOT depend on which layout is active, because every keyboard
  gets the remap while only some get a given layout. The kernel console has one
  keymap for all keyboards regardless, so per-device layout can never reach the
  virtual consoles by any mechanism.
