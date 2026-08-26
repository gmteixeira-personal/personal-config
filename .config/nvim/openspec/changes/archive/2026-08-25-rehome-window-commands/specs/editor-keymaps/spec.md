## RENAMED Requirements

- FROM: ### Requirement: `<C-w>\` toggles the focused window between maximized and its previous layout
- TO: ### Requirement: The focused window is toggled between maximized and its previous layout

## MODIFIED Requirements

### Requirement: The focused window is resized with Alt and a home-row direction key

`<M-k>` and `<M-j>` SHALL increase and decrease the focused window's height. `<M-h>` and `<M-l>` SHALL increase and decrease its width. The four keys SHALL name the same four directions as the focus mappings, so that focusing and resizing differ only by which modifier is held. Each press SHALL change the size by a fixed increment, and holding or repeating the key SHALL continue to resize until the window reaches the limit the surrounding layout allows.

#### Scenario: Growing a window vertically

- **WHEN** two windows are stacked and the user presses `<M-k>` in the upper one
- **THEN** that window becomes taller
- **AND** the other window becomes correspondingly shorter

#### Scenario: Growing a window horizontally

- **WHEN** two windows sit side by side and the user presses `<M-h>` in the left one
- **THEN** that window becomes wider
- **AND** the other becomes correspondingly narrower

#### Scenario: Shrinking a window horizontally

- **WHEN** two windows sit side by side and the user presses `<M-l>` in the left one
- **THEN** that window becomes narrower
- **AND** the other becomes correspondingly wider

#### Scenario: The resize keys do not disturb an existing mapping

- **WHEN** a key that another part of the configuration already binds is pressed
- **THEN** it keeps the meaning that part gave it
- **AND** no resize mapping has replaced it

#### Scenario: Resizing when there is nothing to resize against

- **WHEN** only one window is open and the user presses any resize key
- **THEN** the window continues to fill the tab page
- **AND** no error is raised

### Requirement: The focused window is toggled between maximized and its previous layout

The user SHALL be able to enlarge the focused window to fill the tab page, hiding the others without closing them, and to restore every window to the size and position it had before — not merely equalize them — with the same key pressed twice. The toggle SHALL be reachable from both window prefixes by the same two letters: `e` and `\`, so that `<C-w>e`, `<C-w>\`, `<leader>we` and `<leader>w\` all reach it. Each SHALL extend its prefix rather than replacing any key that prefix already carries.

#### Scenario: Maximizing one of several windows

- **WHEN** three windows are open and the user presses the toggle in one of them
- **THEN** that window fills the tab page
- **AND** the other two are still open but not visible
- **AND** the cursor position in the maximized window is unchanged

#### Scenario: Restoring the previous layout

- **WHEN** a window has been maximized and the user presses the toggle again
- **THEN** every window returns to the exact size and position it had before maximizing
- **AND** focus remains in the window that was maximized

#### Scenario: Toggling from either prefix

- **WHEN** a window is maximized with one of the four keys
- **THEN** any of the other three restores the previous layout
- **AND** the four behave identically in every other respect

#### Scenario: A layout changed while maximized

- **WHEN** a window is maximized and a window is opened or closed before the toggle is pressed again
- **THEN** the toggle does not restore a layout that no longer exists
- **AND** no error is raised

#### Scenario: Toggling with a single window open

- **WHEN** only one window is open and the user presses the toggle
- **THEN** the window continues to fill the tab page
- **AND** no error is raised

#### Scenario: Built-in window commands still work

- **WHEN** the user presses any built-in `<C-w>` command such as `<C-w>s` or `<C-w>q`
- **THEN** it behaves exactly as it does without this configuration
- **AND** it is not delayed waiting to see whether `e` or `\` follows

## REMOVED Requirements

### Requirement: Windows are split and closed under a `<leader>s` prefix

**Reason**: Replaced by the `<leader>w` window-command requirement below, which covers the same four operations along with the rest of `<C-w>`'s set and does so on the letters `<C-w>` itself uses. `<leader>s` is left unbound entirely.

**Migration**: `<leader>sv` becomes `<leader>wv`, `<leader>sh` becomes `<leader>ws` (following `<C-w>s`), `<leader>sc` becomes `<leader>wc`, and `<leader>se` becomes `<leader>w=` (following `<C-w>=`; `<leader>we` is the maximize toggle).

## ADDED Requirements

### Requirement: Window commands are available under a `<leader>w` prefix

The window commands the editor provides under `<C-w>` SHALL also be reachable under `<leader>w`, on the same letters, so that window management is discoverable from the `<leader>` menu without a Ctrl chord. The set SHALL cover splitting (`s` horizontally, `v` vertically), opening a new window (`n`), closing (`c` and `q`), closing the others (`o`), non-directional focus (`w` next, `W` previous, `p` last-accessed, `t` top-left, `b` bottom-right), rearranging (`x` exchange, `r` and `R` rotate), equalizing (`=`), and moving the window to a new tab page (`T`).

Two families of `<C-w>` keys SHALL be left to `<C-w>` alone:

- The incremental resizes. Resizing belongs to the Alt mappings, which repeat on a held key; a `<leader>` sequence per increment does not.
- The window moves `H`, `J`, `K` and `L`. Directional focus is unprefixed on Ctrl and so has no lowercase counterpart in this set; an uppercase-only pair would offer the window-dragging half of the pair alone.

Lowercase `h`, `j`, `k` and `l` SHALL NOT be bound under `<leader>w`, since `<C-h>`, `<C-j>`, `<C-k>` and `<C-l>` exist because directional focus is too frequent to prefix at all.

`<leader>w` SHALL NOT be bound to any command of its own, so that pressing it executes nothing and the sequence under it completes on the next key without waiting out a key-sequence timeout. A component that only describes the mappings under a prefix — see `keymap-hints` — MAY attach itself to `<leader>w`, since it runs no command and delays no completion.

Every mapping in the set SHALL carry a description, so that it is listed when the prefix is pending.

#### Scenario: Splitting

- **WHEN** the user presses `<leader>wv`
- **THEN** a second window showing the same buffer opens beside the current one

#### Scenario: Splitting the other way

- **WHEN** the user presses `<leader>ws`
- **THEN** a second window showing the same buffer opens above or below the current one

#### Scenario: Closing a window

- **WHEN** two or more windows are open and the user presses `<leader>wc`
- **THEN** the focused window closes
- **AND** its buffer remains loaded

#### Scenario: Equalizing

- **WHEN** windows are of unequal size and the user presses `<leader>w=`
- **THEN** all windows in the tab page are given equal size

#### Scenario: Rearranging without resizing

- **WHEN** two windows are open and the user presses `<leader>wx`
- **THEN** the two windows exchange places
- **AND** neither changes size

#### Scenario: A command that has no `<leader>s` predecessor

- **WHEN** the user presses `<leader>wo` with three windows open
- **THEN** the other two close
- **AND** the focused one fills the tab page

#### Scenario: The excluded keys are still reachable

- **WHEN** the user presses `<C-w>H` or one of the incremental resize keys
- **THEN** it behaves exactly as the editor defines it
- **AND** no `<leader>w` mapping was needed to reach it

#### Scenario: Directional focus is not duplicated

- **WHEN** the user presses `<leader>w` and pauses
- **THEN** no mapping on lowercase `h`, `j`, `k` or `l` is listed

#### Scenario: No mapping stalls on the window prefix

- **WHEN** the user presses `<leader>w`
- **THEN** no window command is executed and none is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

#### Scenario: `<leader>s` is free

- **WHEN** the user presses `<leader>s`
- **THEN** no split, close, or equalize command runs
