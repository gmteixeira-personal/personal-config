## Why

The launcher is the surface opened most often, and it is the only one in this session where the hands have to leave the home row. The compositor navigates with `Mod+h/j/k/l`, the shell starts in vi mode, and the terminal multiplexer moves between panes on the same four letters — then the launcher, reached dozens of times a day, answers only to the arrow keys and to the emacs pair `Control+p`/`Control+n`. fuzzel has no modal mode to turn on, so the letters have to be bound one action at a time.

The obstacle is that three of the four keys are already taken by fuzzel's defaults, and fuzzel refuses to start when a combination is bound twice. Adding the bindings without deciding where the displaced actions go turns the launcher from awkward into absent.

## What Changes

- The result list gains `Control+k` and `Control+j` for previous and next entry, alongside the existing `Up`/`Down` and `Control+p`/`Control+n`.
- The input cursor gains `Control+h` and `Control+l` for left and right, alongside the existing `Left`/`Right` and `Control+b`/`Control+f`.
- `Control+h` therefore stops deleting the previous character; that action keeps `BackSpace`.
- The two half-line kills are removed rather than rehomed. `delete-line-backward` (`Control+u`) and `delete-line-forward` (`Control+k`) are both set to `none`.
- `Control+d` is bound to `delete-line`, which clears the whole input. It keeps its packaged key `Control+Shift+BackSpace` as well, and stops deleting the next character; that action keeps `Delete` and `KP_Delete`.
- The launcher's tracked configuration records why each displaced default moved, so the block can be read without a diff against fuzzel's defaults.

No behaviour outside the launcher changes. Nothing here collides with the compositor: its `h/j/k/l` bindings are all `Mod`-prefixed, and its only two non-`Mod` bindings are `Ctrl+Print` and `Ctrl+Alt+Delete`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `application-launcher`: gains requirements for how the launcher is navigated and edited from the keyboard — that the vim letters move the selection and the cursor, that the keys they displace are accounted for rather than left to collide, that the packaged keys keep working, and that the configuration explains the reassignments.

## Impact

- `.config/fuzzel/fuzzel.ini` — a new `[key-bindings]` section with its comment block. This is the only file changed.
- No effect on `.config/niri/config.kdl`, which owns the `Mod`-prefixed uses of the same letters.
- Verified with `fuzzel --check-config`, which is what catches a duplicate binding or a misspelled keysym before the launcher fails to open.
