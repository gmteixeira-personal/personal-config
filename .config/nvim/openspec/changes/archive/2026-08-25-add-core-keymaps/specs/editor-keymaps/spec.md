## Purpose

Defines the key mappings that hold with no plugin installed — how windows are focused, resized, split and maximized, how buffers are switched, how a search highlight is dismissed, how a buffer is saved, how a visual selection survives an indent, and how the editor is restarted.

## ADDED Requirements

### Requirement: Adjacent windows are focused with a single chord

Moving focus between windows SHALL require one chord rather than a prefix followed by a direction. `<C-h>`, `<C-j>`, `<C-k>` and `<C-l>` SHALL move focus to the window left of, below, above and right of the focused one respectively. When there is no window in the requested direction, focus SHALL remain where it is.

#### Scenario: Moving between two side-by-side windows

- **WHEN** two windows are open side by side and the right one is focused
- **AND** the user presses `<C-h>`
- **THEN** the left window becomes focused

#### Scenario: Moving between stacked windows

- **WHEN** two windows are stacked and the upper one is focused
- **AND** the user presses `<C-j>`
- **THEN** the lower window becomes focused

#### Scenario: No window in that direction

- **WHEN** only one window is open and the user presses any of the four
- **THEN** focus does not change
- **AND** no error is raised

### Requirement: The focused window is resized with Alt and a home-row direction key

`<M-k>` and `<M-j>` SHALL increase and decrease the focused window's height. `<M-l>` and `<M-h>` SHALL increase and decrease its width. The four keys SHALL name the same four directions as the focus mappings, so that focusing and resizing differ only by which modifier is held. Each press SHALL change the size by a fixed increment, and holding or repeating the key SHALL continue to resize until the window reaches the limit the surrounding layout allows.

#### Scenario: Growing a window vertically

- **WHEN** two windows are stacked and the user presses `<M-k>` in the upper one
- **THEN** that window becomes taller
- **AND** the other window becomes correspondingly shorter

#### Scenario: Growing a window horizontally

- **WHEN** two windows sit side by side and the user presses `<M-l>` in the left one
- **THEN** that window becomes wider
- **AND** the other becomes correspondingly narrower

#### Scenario: The resize keys do not disturb an existing mapping

- **WHEN** a key that another part of the configuration already binds is pressed
- **THEN** it keeps the meaning that part gave it
- **AND** no resize mapping has replaced it

#### Scenario: Resizing when there is nothing to resize against

- **WHEN** only one window is open and the user presses any resize key
- **THEN** the window continues to fill the tab page
- **AND** no error is raised

### Requirement: `<C-w>\` toggles the focused window between maximized and its previous layout

Pressing `<C-w>\` while the tab page holds more than one window SHALL enlarge the focused window to fill the tab page, hiding the others without closing them. Pressing it again SHALL restore every window to the size and position it had before, not merely equalize them. The mapping SHALL extend the built-in window-command prefix rather than replacing any of its existing keys.

#### Scenario: Maximizing one of several windows

- **WHEN** three windows are open and the user presses `<C-w>\` in one of them
- **THEN** that window fills the tab page
- **AND** the other two are still open but not visible
- **AND** the cursor position in the maximized window is unchanged

#### Scenario: Restoring the previous layout

- **WHEN** a window has been maximized with `<C-w>\` and the user presses `<C-w>\` again
- **THEN** every window returns to the exact size and position it had before maximizing
- **AND** focus remains in the window that was maximized

#### Scenario: A layout changed while maximized

- **WHEN** a window is maximized and a window is opened or closed before the toggle is pressed again
- **THEN** the toggle does not restore a layout that no longer exists
- **AND** no error is raised

#### Scenario: Toggling with a single window open

- **WHEN** only one window is open and the user presses `<C-w>\`
- **THEN** the window continues to fill the tab page
- **AND** no error is raised

#### Scenario: Built-in window commands still work

- **WHEN** the user presses any built-in `<C-w>` command such as `<C-w>s` or `<C-w>q`
- **THEN** it behaves exactly as it does without this configuration
- **AND** it is not delayed waiting to see whether `\` follows

### Requirement: Windows are split and closed under a `<leader>s` prefix

The user SHALL be able to split the current window vertically, split it horizontally, close the focused window, and equalize all window sizes, each from a two-key sequence beginning `<leader>s`. `<leader>s` SHALL NOT itself be bound as a mapping, so that no sequence under it waits out a key-sequence timeout.

#### Scenario: Splitting vertically

- **WHEN** the user invokes the vertical split mapping
- **THEN** a second window showing the same buffer opens beside the current one

#### Scenario: Splitting horizontally

- **WHEN** the user invokes the horizontal split mapping
- **THEN** a second window showing the same buffer opens above or below the current one

#### Scenario: Closing a window

- **WHEN** two or more windows are open and the user invokes the close mapping
- **THEN** the focused window closes
- **AND** its buffer remains loaded

#### Scenario: Equalizing

- **WHEN** windows are of unequal size and the user invokes the equalize mapping
- **THEN** all windows in the tab page are given equal size

#### Scenario: No mapping stalls on the split prefix

- **WHEN** the user presses `<leader>s`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

### Requirement: `<Esc>` dismisses the search highlight

Pressing `<Esc>` in normal mode SHALL clear the highlighting left by the last search, leaving the search pattern and the search history intact so that `n` and `N` continue to work. When there is no highlight to clear, the key SHALL do nothing observable.

#### Scenario: Clearing after a search

- **WHEN** the user has searched for a term and its occurrences are highlighted
- **AND** the user presses `<Esc>` in normal mode
- **THEN** the highlighting is removed from every occurrence
- **AND** the cursor does not move

#### Scenario: The search itself survives

- **WHEN** the user has dismissed the highlight with `<Esc>`
- **AND** then presses `n`
- **THEN** the cursor moves to the next occurrence of the same search term
- **AND** the occurrences are highlighted again

#### Scenario: Nothing to clear

- **WHEN** no search has been performed and the user presses `<Esc>` in normal mode
- **THEN** nothing happens
- **AND** no error is raised

#### Scenario: Escape still leaves other modes

- **WHEN** the user presses `<Esc>` in insert, visual or command-line mode
- **THEN** that mode is left exactly as it would be without this mapping

### Requirement: Indenting a visual selection keeps it selected

Shifting a visual selection left with `<` or right with `>` SHALL leave the same lines selected afterwards, so that the shift can be repeated without re-selecting. The amount shifted SHALL be one indentation level per press, as configured for the buffer.

#### Scenario: Indenting repeatedly

- **WHEN** the user selects three lines in visual mode and presses `>`
- **THEN** those three lines are indented one level
- **AND** the same three lines remain selected

#### Scenario: Outdenting repeatedly

- **WHEN** a visual selection is active and the user presses `<` twice
- **THEN** the selected lines are outdented two levels in total
- **AND** the selection is still active

#### Scenario: A count still applies

- **WHEN** the user prefixes the shift with a count
- **THEN** the selection is shifted by that many levels
- **AND** it remains selected

### Requirement: `<C-s>` writes the current buffer from any editing mode

Pressing `<C-s>` SHALL write the current buffer to disk. It SHALL work from normal, insert and visual mode, and from insert or visual mode SHALL return the editor to normal mode after writing. A buffer with no changes SHALL not be rewritten needlessly, and a buffer that cannot be written SHALL report why.

#### Scenario: Saving from normal mode

- **WHEN** the user has modified a file-backed buffer and presses `<C-s>` in normal mode
- **THEN** the buffer is written to disk
- **AND** the buffer is no longer marked as modified

#### Scenario: Saving from insert mode

- **WHEN** the user is typing in insert mode and presses `<C-s>`
- **THEN** the buffer is written
- **AND** the editor is left in normal mode

#### Scenario: Saving a buffer with no filename

- **WHEN** the buffer has no associated file and the user presses `<C-s>`
- **THEN** the user is told the buffer has no name
- **AND** nothing is written
- **AND** the editor does not remain in a broken state

### Requirement: `<leader>bb` switches to the previous buffer

Pressing `<leader>bb` SHALL display the alternate buffer — the one most recently edited in the current window before the present one — in the current window. Pressing it again SHALL return to the buffer it was invoked from, so the pair of buffers can be alternated between.

#### Scenario: Alternating between two buffers

- **WHEN** the user has edited buffer A and then opened buffer B in the same window
- **AND** presses `<leader>bb`
- **THEN** buffer A is displayed
- **WHEN** the user presses `<leader>bb` again
- **THEN** buffer B is displayed

#### Scenario: No alternate buffer

- **WHEN** only one buffer has ever been opened in the window and the user presses `<leader>bb`
- **THEN** the current buffer remains displayed
- **AND** the user is told there is no alternate buffer rather than the editor failing silently

### Requirement: `<leader>rc` restarts the editor after confirmation

Pressing `<leader>rc` SHALL restart the editor so that every change to the configuration takes effect, including changes a re-source could not apply. Because a restart discards the session, the user SHALL be asked to confirm first, and declining SHALL leave the editor exactly as it was. Unsaved changes SHALL NOT be silently discarded.

#### Scenario: Confirming a restart

- **WHEN** the user presses `<leader>rc` and confirms
- **THEN** the editor restarts
- **AND** the configuration is loaded afresh, including edits to files that were already loaded

#### Scenario: Declining a restart

- **WHEN** the user presses `<leader>rc` and declines
- **THEN** the editor does not restart
- **AND** all buffers, windows and cursor positions are unchanged

#### Scenario: Unsaved work is not lost

- **WHEN** a buffer has unsaved changes and the user confirms a restart
- **THEN** the restart does not discard those changes without the user being told
- **AND** the user is given the chance to save or abandon them deliberately

### Requirement: General keymaps stay independent of plugins

Every mapping in this capability SHALL be declared in `lua/config/keymaps.lua` and SHALL work with every plugin removed. No mapping here may call a function provided by a plugin, and no mapping that invokes a plugin may be added to this module, per the ownership rule in `config-structure`.

#### Scenario: The general keymaps module loads with no plugins

- **WHEN** `lua/config/keymaps.lua` is loaded with no plugins installed
- **THEN** it loads without error
- **AND** every mapping it declares is functional

#### Scenario: Locating a general mapping

- **WHEN** a contributor looks for where window navigation is defined
- **THEN** it is declared in `lua/config/keymaps.lua`
- **AND** it is absent from every file under `lua/plugins/`
