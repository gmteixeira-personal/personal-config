## Why

herdr's closing keys are spread across four keys with no pattern between them:
a pane closes on `prefix+x`, a tab on `prefix+shift+x`, a workspace on
`prefix+shift+d`, and `q` — the letter every other program uses for quit — sits
on `detach`, which is rare.

Two letters take all four, paired by size: `q` closes a pane and `shift+q` the
tab holding it, `d` closes a workspace and `shift+d` leaves the session
altogether. The bare letter is always the smaller object, so the shift is what
widens the blast radius.

## What Changes

- Bind `close_pane` to `prefix+q`, its shipped `prefix+x` becoming unbound.
- Bind `close_tab` to `prefix+shift+q`, its shipped `prefix+shift+x` becoming
  unbound.
- Bind `close_workspace` to `prefix+d`, taking the chord `prefix+shift+d` had.
  `ui.confirm_close` stays at its default, so closing a workspace still asks
  first.
- Bind `detach` to `prefix+shift+d`, vacating `prefix+q`, which `close_pane`
  takes above.
- Declare all four in `[keys]` in the tracked `.config/herdr/config.toml`, so
  they reach every machine rather than being set per install.
- `prefix+x` and `prefix+shift+x` are both left free rather than filled.
- `prefix+w d` was asked for and is not possible: herdr binds one chord after the
  prefix and rejects a two-key sequence — `close_workspace = "prefix+w d"` is
  reported as an invalid keybinding and disabled. `prefix+w` opens the workspace
  picker, whose in-overlay keys are movement only, so there is no closing action
  there for a second key to reach.
- **BREAKING** for muscle memory only: `prefix+q` closes a pane rather than
  detaching, and `prefix+shift+d` detaches rather than closing a workspace. The
  first reflex destroys a pane and the process in it; the second is harmless but
  drops you to the shell when you meant to close something.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `herdr-config`: adds requirements that `prefix+q` closes the focused pane,
  `prefix+shift+q` closes the active tab, `prefix+d` closes the active workspace
  behind a confirmation, and `prefix+shift+d` detaches, and that moving between
  tabs is unchanged.

## Impact

- `.config/herdr/config.toml` — four new keys in the existing `[keys]` table.
- `prefix+q` becomes destructive where it used to be safe. A detach reflex fired
  at the wrong moment now closes the focused pane and whatever it was running;
  herdr asks for confirmation before closing a workspace, but not before closing
  a pane or a tab.
- `prefix+d` is a bare letter next to `prefix+e` and `prefix+=`, which equalize
  panes. A mistyped equalize now offers to close the workspace; the confirmation
  is what stands between that and losing it.
- `prefix+x` and `prefix+shift+x` stop closing anything and do nothing until
  something is bound to them.
- Applies to a running server through `herdr server reload-config`; no restart
  and no session loss.
- No change to `.gitignore` or `README.md`: the file is already tracked, and four
  key values need no setup on a fresh machine.
