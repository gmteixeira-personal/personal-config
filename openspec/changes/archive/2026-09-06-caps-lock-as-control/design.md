## Context

See `proposal.md` — Why, and its Non-Goals for the layout work this has to leave
room for. Everything below was measured on this machine.

- niri 26.04, libxkbcommon 1.13.1, Xwayland 24.1.13 installed; **Xorg is not**.
  X11 clients are Xwayland clients and take their keymap from niri, so the
  compositor's configuration covers them with nothing written for X11.
- `kbd` 2.9.0, with `loadkeys --parse` able to compile a keymap offline with
  neither root nor a console.
- `/etc/vconsole.conf` is `KEYMAP="us"`; `localectl` reports layout `us`,
  model `pc105`.
- In the shipped console map, `keycode 58 = Caps_Lock` in every column and
  `keycode 88 = F12` with `F24` in the shift column.
- `compat/complete` line 9 is `augment "caps(caps_lock)"`, which brings in
  `interpret Caps_Lock { action = LockMods(modifiers = Lock); }`. Its own
  comment says this exists so `Caps_Lock` can be used off the first level.
- `niri msg keyboard-layouts` reports an indexed list, and per-device keyboard
  configuration does not exist: a `keyboard "usb-0000:00-1"` block is rejected
  with `unexpected argument`.

## Goals / Non-Goals

**Goals:**

- One remap, identical in the graphical session and at the consoles.
- Nothing added to the machine.
- The later layout work edits a line rather than replacing a mechanism.

**Non-Goals:**

- Per-device anything. See the proposal.
- Restating the whole `us` layout. Both halves layer over the stock definition.

## Decisions

### xkb and a console keymap, not `keyd`

`keyd` is the usual answer to "make it work everywhere", and it is the wrong one
here for three separate reasons.

It is a **remapper with no layout engine**. The stated future is `pt-pt` on one
keyboard and `en-us` on another, and pt-PT is dead keys, `ç`, and AltGr levels —
xkb ships that as a maintained layout, and reproducing it in `keyd` config means
hand-writing what already exists, with dead keys as the place it goes wrong.
Whatever mechanism carries the remap, layouts belong in xkb; adding `keyd` means
owning two keyboard mechanisms rather than one.

It is **not packaged for Fedora 44** — neither is `interception-tools` — so it
means a COPR or a source build, against an explicit "no unneeded deps".

It needs a **root daemon reading every input device**, where the alternative
needs no running process at all.

What `keyd` would have bought is per-device *remapping*, which is not wanted:
every keyboard gets this remap.

### `ctrl:nocaps`, the stock option, for the Control half

`+ctrl(nocaps)` is `replace key <CAPS> { [ Control_L ] }` plus a
`modifier_map`, maintained upstream and listed in `evdev.lst` as "Caps Lock as
Ctrl". Hand-writing it into the custom symbols file would be a private copy of
a stock rule for no gain.

### A user rules file that ends by including the system one

The `Shift+F12` half has no stock option, so it needs a symbols file and a name
to reach it by. libxkbcommon 1.13.1 searches `$XDG_CONFIG_HOME/xkb` ahead of
`/usr/share/X11/xkb`, and takes the **first** rules file it finds rather than
merging them — so a user `rules/evdev` that only declared the new option would
silently discard every stock layout and option, `ctrl:nocaps` among them.

It therefore declares the new option first and ends with `! include %S/evdev`,
which is the documented way to layer rather than replace.

### The `F12` override is one group, and that is what makes it layout-proof

`replace key <FK12> { [ F12, Caps_Lock ] }` defines a key with a single group.
When a second layout is added the effective group can exceed that, and xkb
resolves an out-of-range group back into the key's own range — so the same
definition answers in every layout, with no per-group duplication to keep in
step.

Writing `symbols[Group1]` and `symbols[Group2]` explicitly would be the obvious
alternative and is worse: it would need a new stanza for every layout ever
added, and the requirement is that the remap does not depend on the layout.

`F12` stays on the first level, so unshifted `F12` is untouched. The keysym does
the rest: the compat map quoted in Context turns a `Caps_Lock` keysym into
`LockMods(Lock)` wherever it sits, which is exactly the case its comment
describes.

### The console map includes by absolute path

`include "us"` resolves only for a file inside the keymap search path — from
anywhere else it fails with `cannot open include file us`, measured. An absolute
`include "/usr/lib/kbd/keymaps/xkb/us.map.gz"` makes the map self-contained, so
its location stops being load-bearing and the tracked copy is the same file
wherever it is installed.

Verified offline with `loadkeys --parse`: the compiled table has `Control` in
every column of keycode 58, and `F12 Caps_Lock` as the first two columns of
keycode 88 — column two being shift.

### The console half is installed, not tracked in place

`/usr/lib/kbd/keymaps/` and `/etc/vconsole.conf` are outside `$HOME`. The
repository carries the map as a tracked copy and the README names the one step
that installs it and sets `KEYMAP`, which is the shape already used for the
herdr plugin registration.

Until that step runs the remap applies in the graphical session and not at the
consoles. That is worse than either extreme, so the README says it outright
rather than leaving it to be discovered at a console during a repair.

### Verification precedes application

Editing `.config/niri/config.kdl` applies immediately — niri reloads it — so the
xkb half is compiled and inspected with `xkbcli compile-keymap` before the file
is written. That needs `libxkbcommon-utils`, a Fedora package, and it is a
verification tool rather than a runtime dependency: it is not added to the
README's expected-software list and can be removed afterwards.

The failure modes if it were skipped are mild — an unrecognised option is
ignored and a keymap that fails to compile leaves niri on the previous one — but
"mild" is not "checked", and the claim being made is about which keysym arrives
at which level in which group.

### A new `~/.config/xkb` is invisible to an already-running compositor

Found while applying this, and kept because it is not obvious from either side.

libxkbcommon adds `$XDG_CONFIG_HOME/xkb` to a context's include path only when
that directory exists at context creation; a missing directory is skipped and
never reconsidered. niri creates its context once, at startup. So a session that
started before the directory existed cannot see the user rules however many
times the config is reloaded, and reports
`Unrecognized RMLVO option "custom:capslock_shift_f12" was ignored`.

Confirmed rather than inferred: pointing `XDG_CONFIG_HOME` at a directory with
no `xkb` child reproduces that exact message from `xkbcli`, and the real config
home compiles clean.

This is an artefact of adding the directory to a live session, not a property of
the design. A fresh checkout creates it during bootstrap, before any graphical
session starts. It is recorded in the README because the symptom — an option
silently ignored while the file on disk is correct — reads like a broken
configuration rather than a stale context.

### The compositor binds the layout switch, not an xkb `grp:` option

Both can do it, and the config's own note says why not both: a chord bound in
each switches twice and lands back where it started.

The compositor's bind wins on two counts. It keeps layout policy with the other
keybindings instead of on the same `options` line as the remap, where two
unrelated subjects would share a string. And the compositor knows the state:
`niri msg keyboard-layouts` reports the list and marks the active one, which a
`grp:` option leaves invisible to everything outside xkb — including anything
that might later want to display it.

Two `grp:` options that would otherwise be the obvious choices are unavailable
regardless. `grp:caps_toggle` and `grp:caps_switch` both want the Caps Lock key,
which is Control now.

### `Mod+Alt+Space`, chosen over `Mod+K` and every other K chord

K was asked for first and is the busiest letter in the file: `Mod+K` is
`focus-window-up`, `Mod+Ctrl+K` is `move-window-up`, `Mod+Shift+K` is
`focus-monitor-up`, `Mod+Shift+Ctrl+K` moves a window to the monitor above.
Each is the vim half of a set whose arrow twin still works, so any of them could
have been taken at the cost of a hole in an otherwise complete H/J/K/L row.
Leaving the four sets intact was preferred.

The accepted trade-off: `Mod+Alt+Space` is the launcher's `Mod+Space` with one
modifier added, so a slipped Alt on the way to the launcher changes the keyboard
layout instead of opening it. That is a quiet failure — the next thing typed
comes out in the other layout with nothing having announced the change. It is
chosen deliberately over a key that is harder to reach, and
`niri msg keyboard-layouts` is what tells you which layout you are in when it
happens.

### EurKEY as `eu`, not as the `xmodmap` file its page distributes

EurKEY is shipped by xkeyboard-config as the layout `eu`, so it is selected by
name like any other and works under Wayland with no X and no `xmodmap`. The
project's page offers an `xmodmap` file because it predates the layout being
upstreamed; using it would mean an X-only mechanism to configure a session that
runs no X server.

It brings its own AltGr wiring — `symbols/eu` line 70 is
`include "level3(ralt_switch)"` — so no `lv3:` option is needed alongside it.
Verified: `ä` is AltGr+a, reported as keycode 38 `AC01`, level 3,
`[ Mod5 LevelThree ]`.

The shipped layout is **not byte-identical** to the page's current release, and
the file says so in its own header: it follows EurKEY 1.2 with two deliberate
maintainer changes. `<AE11>` carries `[minus, underscore, endash, emdash]` where
1.3 has ✓ and ✗, and `<AC03>` carries `[d, D, eth, ETH]`, added to stay
consistent with having þ. The AltGr letter layer, which is what EurKEY exists
for, is the same. Recorded because "the same keymap" is the reason for choosing
it and the difference is small but real.

### `eu` is first, on a pt-PT keyboard

The physical keyboard is Portuguese, so `eu` first means the legends do not
match what the keys do at login — `eu` is US-positioned, so the key marked `ç`
types `;`. That is the stated preference rather than an oversight, and reversing
it is a one-word edit to `"pt,eu"`.

## Risks / Trade-offs

- **A `kbd` package update replaces the stock `us` map the console map includes
  by absolute path** → The path is the one the package itself installs, so an
  update replaces the file rather than removing it. A path change across
  releases would surface as a boot-time `loadkeys` failure naming the file.
- **Someone adds a second layout later and the `F12` override does not follow**
  → The mechanism is chosen for this and the spec requires it; the check is one
  `xkbcli compile-keymap --layout us,pt` away.
- **`Shift+F12` collides with an application's own binding** → Nothing in the
  tracked configuration binds it, which the tasks verify. An application that
  grabs it would shadow the lock in that window only.
- **The console step is never run on some machine** → The remap is then
  graphical-only there. Named in the README as the cost of skipping it.
- **A slipped Alt while reaching for the launcher switches layout silently** →
  Accepted, with its reasoning above. The recovery is the same key again, and
  `niri msg keyboard-layouts` says which layout is live.
- **The consoles keep `us` whatever the graphical session is switched to** →
  The console keymap is one file with no switching, and the kernel has one
  keymap for every keyboard. A console is `us` always. Recorded rather than
  fixed, because it cannot be fixed.
