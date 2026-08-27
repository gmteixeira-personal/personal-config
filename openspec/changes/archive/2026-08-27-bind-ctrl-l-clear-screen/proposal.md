## Why

`Ctrl-L` clears the screen everywhere else and did nothing at this prompt.

Vi editing mode is the cause. Readline keeps two keymaps in vi mode, and only one of them inherits the binding: with the system defaults in place, `clear-screen` is reachable by `\C-l` in the command keymap and bound to no key at all in the insert keymap. A prompt begins in insert mode and stays there for all ordinary typing, so the keystroke that works is the one nobody is in the right mode to use.

The habit is mode-independent — the screen is cleared while typing, not after pressing Escape — so the binding has to be.

## What Changes

- Bind `Ctrl-L` to `clear-screen` in the vi insert keymap, where it was unbound.
- Bind it in the vi command keymap too, so the behaviour is stated by this configuration rather than inherited from a default that happens to agree with it.
- Keep both in `~/.inputrc`, alongside the editing mode and the mode indicator, rather than adding `bind` calls to a shell startup file.

## Capabilities

### Modified Capabilities

- `bash-readline-config`: adds a requirement that the screen can be cleared from the keyboard in either vi mode, which the existing editing-mode and mode-indicator requirements do not cover.

### New Capabilities

<!-- None. -->

## Impact

- `~/.inputrc` gains two keymap selections and two bindings. Nothing existing is removed or re-bound.
- Only readline's own line editing is affected. A full-screen program running under the shell handles `Ctrl-L` itself and is untouched.
- The file now ends with the insert keymap selected, so any binding appended later lands there unless a keymap is named first.
