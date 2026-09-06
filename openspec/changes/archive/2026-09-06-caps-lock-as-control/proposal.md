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
- The `xkb` block carries **two layouts**, `eu` and `pt`, with `eu` first and so
  active at login, and `Mod+Alt+Space` switches between them. `eu` is EurKEY,
  shipped by xkeyboard-config as a first-class layout — a US layout carrying
  Western European letters and symbols on the AltGr levels. The project's own
  page distributes an `xmodmap` file, which is not wanted and not needed: that
  predates the layout being upstreamed, and nothing here touches X.
  The physical keyboard is pt-PT, which is what `pt` is for; `eu` is the default
  deliberately.
- `Mod+Space` becomes a second binding for the launcher, alongside the existing
  `Mod+D`. Unrelated to the remap and named here rather than left as a silent
  passenger: it is the same file, the same sitting, and the key it takes is the
  one the layout switch would otherwise have had.

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

- `.config/niri/config.kdl` — the `xkb` block, currently all comments, and the
  binds section, where two commented-out `switch-layout` examples are replaced
  by one real bind and the launcher gains a second key.
- `.config/xkb/symbols/custom`, `.config/xkb/rules/evdev` — new.
- A tracked console keymap, and `.gitignore` allow entries for all three.
- `README.md` — the install step for the console half.
- **No new package.** libxkbcommon 1.13.1, `kbd` 2.9.0 and Xwayland 24.1.13 are
  all installed. `keyd` was considered and rejected: it is unpackaged for Fedora
  44, needs a root daemon reading every input device, and is a key remapper with
  no layout engine — see the design.

## Non-Goals

Layout following the keyboard **automatically** — the right one selected because
of which keyboard is attached — is wanted and is still not built here. Switching
by hand is; choosing for you is not.

niri has no per-device keyboard configuration, which was verified rather than
assumed: a `keyboard "usb-0000:00-1"` block is rejected with
`unexpected argument`. So that work will be a hotplug trigger calling
`niri msg action switch-layout` over the layout list this change creates, and it
is a mechanism of its own rather than a setting.

Two consequences are designed for now rather than discovered later:

- niri keeps **one** active layout for the whole session, not one per device. A
  keypress switches every attached keyboard at once, and a hotplug trigger would
  write that same single piece of state — so the two can disagree, and whichever
  acted last wins. Nothing here can make the state per-device; only the choosing
  can be automated.
- The remap SHALL NOT depend on which layout is active, because every keyboard
  gets the remap while only some get a given layout. That requirement now has a
  real second layout to be tested against rather than a hypothetical one. The
  kernel console has one keymap for all keyboards regardless, so per-device
  layout can never reach the virtual consoles by any mechanism.
