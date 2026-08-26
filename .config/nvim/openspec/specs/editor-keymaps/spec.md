## Purpose

Defines the key mappings that hold with no plugin installed — how the cursor reaches the two ends of a line, how windows are focused, resized, split and maximized, how buffers are switched, created and deleted, how a search highlight is dismissed, how a buffer is saved, how a visual selection survives an indent, how a line is terminated with a semicolon, and how the editor is restarted.
## Requirements
### Requirement: `H` and `L` move to the start and end of the line, in two steps outward

`H` SHALL move the cursor towards the start of the current line and `L` towards its end. Each key SHALL have two landing places, ordered from the inner one to the outer one:

- `H`: the first non-blank character, then column zero.
- `L`: the last non-blank character, then the end of the line, past any trailing whitespace.

The landing place SHALL be chosen from where the cursor already is, not from how many times the key has been pressed: when the cursor is on the inner landing place the key SHALL move it to the outer one, and from anywhere else on the line the key SHALL move it to the inner one. No press SHALL be counted and no state SHALL be carried between presses, so the outer landing place is reached the same way whether the cursor got to the inner one by pressing the key, by `^`, or by typing.

Both keys SHALL address the buffer line, not the screen line: on a wrapped line they SHALL move to the ends of the whole line rather than of the visual row.

Neither key SHALL move to the top or bottom of the visible screen, as they did before. That motion SHALL NOT be bound to any other key by this configuration.

#### Scenario: Pressing `H` from the middle of an indented line

- **WHEN** the cursor is in the middle of a line that begins with indentation
- **AND** the user presses `H`
- **THEN** the cursor moves to the first non-blank character of that line
- **AND** the line's text is unchanged

#### Scenario: Pressing `H` again at the first non-blank

- **WHEN** the cursor is on the first non-blank character of an indented line
- **AND** the user presses `H`
- **THEN** the cursor moves to column zero, in front of the indentation

#### Scenario: Reaching column zero without a second press

- **WHEN** the cursor is on the first non-blank character of an indented line, having arrived there by pressing `^` rather than `H`
- **AND** the user presses `H`
- **THEN** the cursor moves to column zero
- **AND** the result is the same as it would be after a first `H` that landed there

#### Scenario: Pressing `L` on a line with trailing whitespace

- **WHEN** the cursor is in the middle of a line that ends in trailing whitespace
- **AND** the user presses `L`
- **THEN** the cursor moves to the last non-blank character of that line
- **AND** pressing `L` again moves it onto the last character of the line, past the trailing whitespace

#### Scenario: A line with no trailing whitespace

- **WHEN** the cursor is in the middle of a line whose last character is not blank
- **AND** the user presses `L`
- **THEN** the cursor moves to that last character
- **AND** pressing `L` again leaves it there

#### Scenario: A line with no indentation

- **WHEN** the cursor is in the middle of a line that starts with a non-blank character
- **AND** the user presses `H`
- **THEN** the cursor moves to column zero
- **AND** pressing `H` again leaves it there

#### Scenario: An empty line

- **WHEN** the cursor is on an empty line and the user presses `H` or `L`
- **THEN** the cursor does not move
- **AND** no error is raised

#### Scenario: The screen motions are gone

- **WHEN** the cursor is anywhere in a buffer longer than the window
- **AND** the user presses `H` or `L`
- **THEN** the cursor stays on the line it was on
- **AND** the view does not scroll

### Requirement: The line-boundary motions work as motions, not only as cursor moves

`H` and `L` SHALL be bound in normal, visual and operator-pending mode, so that they can be given to an operator and can extend a visual selection. In every mode the landing place SHALL be chosen by the same rule, from the cursor position at the moment the key is pressed.

They SHALL NOT be bound in select mode, where typing a printable character replaces the selection.

Where the underlying motion carries behaviour of its own — a following `j` or `k` staying at the end of the line after `L`, or a visual-block `L` selecting to each line's own end — that behaviour SHALL be preserved.

#### Scenario: Deleting to the end of the line

- **WHEN** the cursor is in the middle of a line and the user types `dL`
- **THEN** the text from the cursor to the last non-blank character is deleted
- **AND** the deletion is charwise, not linewise

#### Scenario: Selecting back to the first non-blank

- **WHEN** the cursor is in the middle of an indented line and the user types `vH`
- **THEN** the selection extends back to the first non-blank character of that line

#### Scenario: Deleting the indentation

- **WHEN** the cursor is on the first non-blank character of an indented line and the user types `dH`
- **THEN** the indentation in front of the cursor is deleted
- **AND** the rest of the line is left where it is

#### Scenario: Moving down after `L`

- **WHEN** the user presses `L` to land on the end of a long line
- **AND** then presses `j` onto a shorter line
- **THEN** the cursor is at the end of the shorter line, as it would be after `$`

#### Scenario: Replacing a selection in select mode

- **WHEN** a selection is active in select mode and the user types `H`
- **THEN** the selection is replaced by the character `H`
- **AND** the cursor does not move to the start of the line

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

### Requirement: The buffer list is walked with `<leader>b` and a direction

The user SHALL be able to move through the buffer list without naming a buffer: `<leader>bn` and `<leader>bp` SHALL display the next and the previous listed buffer in the current window, and `<leader>bf` and `<leader>bl` SHALL display the first and the last one. Movement SHALL wrap, so the next buffer after the last is the first and the previous buffer before the first is the last.

These mappings SHALL change only which buffer the current window displays. The window layout, the other windows, and the contents of every buffer SHALL be untouched.

#### Scenario: Stepping forward

- **WHEN** three buffers are listed and the second is displayed
- **AND** the user presses `<leader>bn`
- **THEN** the current window displays the third buffer

#### Scenario: Stepping backward

- **WHEN** three buffers are listed and the second is displayed
- **AND** the user presses `<leader>bp`
- **THEN** the current window displays the first buffer

#### Scenario: Wrapping at the end of the list

- **WHEN** the last listed buffer is displayed and the user presses `<leader>bn`
- **THEN** the current window displays the first listed buffer
- **AND** no error is raised

#### Scenario: Wrapping at the start of the list

- **WHEN** the first listed buffer is displayed and the user presses `<leader>bp`
- **THEN** the current window displays the last listed buffer
- **AND** no error is raised

#### Scenario: Jumping to an end of the list

- **WHEN** several buffers are listed and one in the middle is displayed
- **AND** the user presses `<leader>bl`
- **THEN** the current window displays the last listed buffer
- **WHEN** the user then presses `<leader>bf`
- **THEN** the current window displays the first listed buffer

#### Scenario: Only one buffer

- **WHEN** exactly one buffer is listed and the user presses any of the four
- **THEN** that buffer remains displayed
- **AND** no error is raised

#### Scenario: Other windows are left alone

- **WHEN** two windows are open showing different buffers
- **AND** the user presses `<leader>bn` in one of them
- **THEN** only that window's displayed buffer changes
- **AND** the layout is unchanged

### Requirement: `<leader>bc` creates an empty buffer

Pressing `<leader>bc` SHALL open a new, empty, unnamed buffer in the current window, so that text can be written before a filename is chosen. The buffer it replaces SHALL remain loaded and listed, and SHALL be reachable again with `<leader>bb`.

#### Scenario: Creating a buffer to write in

- **WHEN** the user presses `<leader>bc`
- **THEN** the current window displays a new empty buffer with no filename
- **AND** the cursor is in it, ready for input

#### Scenario: The previous buffer survives

- **WHEN** the user presses `<leader>bc` while editing a file
- **AND** then presses `<leader>bb`
- **THEN** that file is displayed again
- **AND** its contents and cursor position are unchanged

### Requirement: Buffers are deleted with `<leader>bd`, `<leader>bo` and `<leader>bO`

`<leader>bd` SHALL delete the current buffer. `<leader>bo` SHALL delete every listed buffer except the current one, leaving the current one open. `<leader>bO` SHALL delete every listed buffer including the current one, leaving an empty unnamed buffer.

The set `<leader>bo` and `<leader>bO` act on SHALL be the buffer list — the same set the navigation mappings walk and the buffer picker shows. A buffer that is not listed SHALL NOT be deleted by either mapping, and SHALL be left loaded, so that the scratch and directory buffers plugins keep alive are not swept up by a mapping the user reached for to clear their open files. The number of buffers a bulk deletion reports SHALL therefore be the number the picker was showing.

`<leader>bd` SHALL delete the current buffer whether or not it is listed, since the user is looking at it.

A deleted buffer SHALL be removed from the buffer list, so that it is no longer reached by the navigation mappings or listed by the buffer picker. Any window displaying a buffer that is deleted SHALL close with it; preserving the window layout across a deletion is NOT a goal of these mappings, and the window mappings under `<leader>w` remain the way a layout is managed.

After `<leader>bo`, the buffer that was current SHALL still be displayed, and SHALL be untouched: its contents, its position in the window, its undo history and its buffer-local marks SHALL all survive.

#### Scenario: Deleting the current buffer

- **WHEN** two buffers are listed and the user presses `<leader>bd`
- **THEN** the current buffer is no longer listed
- **AND** the other buffer is displayed

#### Scenario: A deleted buffer leaves the navigation set

- **WHEN** three buffers are listed and the user deletes one with `<leader>bd`
- **AND** then walks the list with `<leader>bn`
- **THEN** only the two remaining buffers are reached

#### Scenario: Deleting a buffer shown in a split

- **WHEN** a buffer is displayed in two windows and the user presses `<leader>bd`
- **THEN** the buffer is deleted
- **AND** the windows that displayed it are closed

#### Scenario: Clearing everything but the current buffer

- **WHEN** five buffers are listed and the user presses `<leader>bo`
- **THEN** only the buffer that was current remains listed
- **AND** it is still displayed in the current window

#### Scenario: Clearing every buffer

- **WHEN** five buffers are listed and the user presses `<leader>bO`
- **THEN** none of the five remains listed
- **AND** the current window displays an empty unnamed buffer

#### Scenario: Deleting the only buffer

- **WHEN** one buffer is listed and the user presses `<leader>bd`
- **THEN** an empty unnamed buffer is displayed
- **AND** the editor does not exit

#### Scenario: Unlisted buffers survive a bulk clear

- **WHEN** two buffers are listed and the editor also holds unlisted buffers a plugin created
- **AND** the user presses `<leader>bO`
- **THEN** the two listed buffers are deleted
- **AND** the unlisted buffers are still loaded
- **AND** the count reported is two

#### Scenario: The surviving buffer is not disturbed

- **WHEN** several buffers are listed, the current one has been edited and saved, and its cursor is partway down the file
- **AND** the user presses `<leader>bo`
- **THEN** the cursor is where it was
- **AND** `u` still undoes the edits made before the clear

#### Scenario: Nothing left to clear

- **WHEN** exactly one buffer is listed and the user presses `<leader>bo`
- **THEN** that buffer remains listed and displayed
- **AND** no error is raised

#### Scenario: Clearing from an unlisted buffer

- **WHEN** the current window displays an unlisted buffer and other buffers are listed
- **AND** the user presses `<leader>bo`
- **THEN** every listed buffer is deleted
- **AND** the unlisted buffer the user is looking at remains displayed

### Requirement: Deleting a buffer with unsaved changes asks first

A mapping that deletes a buffer SHALL NOT discard unsaved changes silently, and SHALL NOT merely fail. When a buffer being deleted has unsaved changes, the user SHALL be asked whether to save them, discard them, or cancel, and the answer SHALL be honoured: saving SHALL write the buffer and then delete it, discarding SHALL delete it without writing, and cancelling SHALL leave the buffer listed and loaded with its changes intact.

This SHALL hold for `<leader>bd`, `<leader>bo` and `<leader>bO` alike, and SHALL apply to each modified buffer the mapping would delete.

#### Scenario: Saving when asked

- **WHEN** the current buffer has unsaved changes and the user presses `<leader>bd`
- **AND** answers that the changes should be saved
- **THEN** the buffer is written to disk
- **AND** it is then deleted

#### Scenario: Discarding when asked

- **WHEN** the current buffer has unsaved changes and the user presses `<leader>bd`
- **AND** answers that the changes should be discarded
- **THEN** the buffer is deleted
- **AND** the file on disk is unchanged

#### Scenario: Cancelling

- **WHEN** the current buffer has unsaved changes and the user presses `<leader>bd`
- **AND** cancels
- **THEN** the buffer is still listed and still displayed
- **AND** its unsaved changes are intact

#### Scenario: A modified buffer among many

- **WHEN** several buffers are listed and one of them has unsaved changes
- **AND** the user presses `<leader>bo`
- **THEN** the user is asked about that buffer
- **AND** the unmodified buffers are deleted without a prompt

#### Scenario: Nothing is lost without an answer

- **WHEN** any of the three deleting mappings would delete a modified buffer
- **THEN** that buffer is not deleted until the user has answered

### Requirement: The editor is left from a `<leader>q` prefix

Leaving the editor SHALL be reachable from the `<leader>` menu rather than only by typing an Ex command. `<leader>qq` SHALL close every window and every tab page, ending the editing session. `<leader>qw` SHALL first write every modified buffer that has a filename, and then close every window and tab page, so that saving and leaving is one sequence rather than a save followed by a separate quit.

Neither mapping SHALL discard unsaved work without asking. When a buffer would be lost, the user SHALL be asked what to do about that buffer — see the requirement on unsaved changes below — and SHALL be able to abandon the quit entirely, leaving the editor exactly as it was, every buffer still loaded and the window layout unchanged.

`<leader>q` SHALL NOT be bound to any command of its own, so that pressing it executes nothing and the sequence under it completes on the next key without waiting out a key-sequence timeout. A component that only describes the mappings under a prefix — see `keymap-hints` — MAY attach itself to `<leader>q`, since it runs no command and delays no completion.

The prefix SHALL be for the editing session as a whole: leaving it, restarting it, and — per `session-management` — saving, restoring, searching and deleting the sessions that persist it across launches. It SHALL NOT take mappings that act on a single window or a single buffer. Closing a single window remains `<leader>wq` and `<C-w>q`, which are a different sequence and are unaffected, and deleting a single buffer remains `<leader>bd`.

Adding the session mappings SHALL NOT change what `<leader>qq` and `<leader>qw` do, and SHALL NOT put a session mapping on a key that shadows either of them.

#### Scenario: Quitting with nothing to save

- **WHEN** no buffer has unsaved changes and the user presses `<leader>qq`
- **THEN** every window and tab page closes
- **AND** the editing session ends

#### Scenario: Quitting with several windows and tab pages open

- **WHEN** two tab pages are open, one of them split into three windows
- **AND** the user presses `<leader>qq` with nothing unsaved
- **THEN** all of them close
- **AND** no window is left behind for the user to quit separately

#### Scenario: Saving and quitting in one sequence

- **WHEN** two buffers have unsaved changes, both with filenames
- **AND** the user presses `<leader>qw`
- **THEN** both buffers are written to their files
- **AND** the editing session ends
- **AND** no prompt is shown, since nothing would be lost

#### Scenario: Saving and quitting writes only what changed

- **WHEN** one buffer of several has unsaved changes and the user presses `<leader>qw`
- **THEN** that buffer is written
- **AND** the files behind the unmodified buffers are left as they are

#### Scenario: The prefix runs nothing on its own

- **WHEN** the user presses `<leader>q` and pauses
- **THEN** the editor has not quit
- **AND** the mappings that can continue the sequence are listed, both the quit ones and the session ones

#### Scenario: Closing one window is a different sequence

- **WHEN** two windows are open and the user presses `<leader>wq`
- **THEN** that window closes
- **AND** the editing session continues in the remaining window

#### Scenario: The quit mappings are unchanged by the session mappings

- **WHEN** the session mappings have been added under the same prefix
- **THEN** `<leader>qq` and `<leader>qw` behave exactly as they did before
- **AND** neither of them is shadowed by a session mapping

### Requirement: A quit that would lose unsaved changes is confirmed

When `<leader>qq` or `<leader>qw` would end the session while a buffer holds changes that would be lost, the user SHALL be prompted for that buffer rather than the quit failing with an error or discarding the buffer. The prompt SHALL offer saving the buffer, discarding it, and cancelling.

For `<leader>qq`, which writes nothing, that is every modified buffer. For `<leader>qw`, which has already written what it could, that is every buffer whose changes it could not write — one with no filename, one that is read-only, one whose write failed.

Cancelling SHALL abandon the quit: the editor SHALL remain open with every buffer still loaded and the window layout unchanged. A prompt SHALL be shown once per buffer that needs one, so that a session with several such buffers is not lost to a single keystroke.

#### Scenario: Quitting with a modified buffer

- **WHEN** a file has been edited and not saved and the user presses `<leader>qq`
- **THEN** a prompt offers to save, discard, or cancel
- **AND** the editor has not quit while the prompt is open

#### Scenario: Saving and quitting with a buffer that cannot be written

- **WHEN** text has been typed into a new unnamed buffer and the user presses `<leader>qw`
- **THEN** the other modified buffers are written
- **AND** a prompt is shown for the unnamed one rather than an error reporting it has no filename

#### Scenario: Cancelling the quit

- **WHEN** the prompt is shown and the user cancels
- **THEN** the editor remains open
- **AND** every buffer is still loaded with its changes intact
- **AND** the window layout is unchanged

#### Scenario: Discarding at the prompt

- **WHEN** the prompt is shown and the user chooses to discard
- **THEN** the editing session ends
- **AND** that buffer's changes are not written

#### Scenario: Saving at the prompt

- **WHEN** the prompt is shown for a modified buffer that has a filename and the user chooses to save
- **THEN** that buffer is written to its file
- **AND** the session ends once no other buffer needs a decision

#### Scenario: Several buffers need a decision

- **WHEN** two modified buffers exist and the user presses `<leader>qq`
- **THEN** a prompt is shown for each of them in turn
- **AND** a decision made for one does not decide the other

#### Scenario: The quit never discards silently

- **WHEN** any buffer holds changes that would be lost
- **THEN** neither `<leader>qq` nor `<leader>qw` ends the session without a prompt for it

### Requirement: `<leader>qc` restarts the editor after confirmation

Pressing `<leader>qc` SHALL restart the editor so that every change to the configuration takes effect, including changes a re-source could not apply. Because a restart tears down and rebuilds the whole editor process, the user SHALL be asked to confirm first, and declining SHALL leave the editor exactly as it was. Unsaved changes SHALL NOT be silently discarded.

The confirmation SHALL NOT tell the user that the session is discarded. Where session management is active, the buffers and window layout are saved on exit and restored on the way back up, so the prompt SHALL describe only what a restart actually costs.

#### Scenario: Confirming a restart

- **WHEN** the user presses `<leader>qc` and confirms
- **THEN** the editor restarts
- **AND** the configuration is loaded afresh, including edits to files that were already loaded

#### Scenario: Declining a restart

- **WHEN** the user presses `<leader>qc` and declines
- **THEN** the editor does not restart
- **AND** all buffers, windows and cursor positions are unchanged

#### Scenario: Unsaved work is not lost

- **WHEN** a buffer has unsaved changes and the user confirms a restart
- **THEN** the restart does not discard those changes without the user being told
- **AND** the user is given the chance to save or abandon them deliberately

#### Scenario: The prompt matches what happens

- **WHEN** the user is shown the restart confirmation
- **THEN** it does not claim that the open buffers and window layout will be lost

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

### Requirement: `<M-;>` terminates the current line with a semicolon and moves the cursor after it

Pressing `<M-;>` in insert mode SHALL place a `;` at the end of the current line and move the cursor to immediately after that `;`, with the editor still in insert mode. The semicolon SHALL be placed after the line's last non-blank character, so trailing whitespace does not end up before it. When the line already ends in a semicolon, no second one SHALL be inserted, and the cursor SHALL still be left immediately after the existing one. The mapping SHALL NOT raise an error on any line, including an empty one.

The key SHALL be an Alt chord rather than a Ctrl one, so that it reaches the editor from any terminal: Ctrl combined with `;` has no representation in the legacy terminal key encoding and is not delivered at all by the terminals this configuration is used from.

The mapping SHALL be declared in `lua/config/keymaps.lua` and SHALL call no plugin.

#### Scenario: Terminating a statement from mid-line

- **WHEN** the cursor is inside a line being typed in insert mode and the user presses `<M-;>`
- **THEN** a `;` is appended to that line
- **AND** the cursor sits immediately after that `;`
- **AND** the editor is still in insert mode
- **AND** what the user types next continues after the semicolon

#### Scenario: The line already ends in a semicolon

- **WHEN** the current line's last non-blank character is `;` and the user presses `<M-;>`
- **THEN** the line is unchanged
- **AND** no second semicolon is added
- **AND** the cursor sits immediately after the existing `;`

#### Scenario: Trailing whitespace

- **WHEN** the current line ends in one or more spaces and the user presses `<M-;>`
- **THEN** the `;` is placed after the last non-blank character
- **AND** it is not separated from the code by the trailing whitespace
- **AND** the cursor sits immediately after the `;`, before the remaining whitespace

#### Scenario: A blank line

- **WHEN** the current line is empty or contains only whitespace and the user presses `<M-;>`
- **THEN** a `;` is placed at the end of the line, leaving any indentation intact
- **AND** the cursor sits immediately after it
- **AND** no error is raised

### Requirement: `<M-;>` terminates every line a visual selection touches

Pressing `<M-;>` in visual mode SHALL place a `;` at the end of every line the selection touches, by the same placement rule as the insert-mode mapping, and SHALL then leave visual mode. Lines the selection covers only partially SHALL be terminated in full, so the result does not depend on which columns were highlighted. Lines that are empty or hold only whitespace SHALL be left untouched. The cursor SHALL be left immediately after the semicolon on the last line that was terminated.

#### Scenario: Terminating a block of statements

- **WHEN** the user selects three consecutive statement lines and presses `<M-;>`
- **THEN** each of the three lines ends in `;`
- **AND** visual mode is left
- **AND** the cursor sits immediately after the semicolon on the third line

#### Scenario: A partial selection still terminates whole lines

- **WHEN** the selection starts mid-way through one line and ends mid-way through another
- **AND** the user presses `<M-;>`
- **THEN** both lines are terminated at their own ends
- **AND** no semicolon is placed at the selection boundaries

#### Scenario: Blank lines inside the selection

- **WHEN** the selection spans lines with one or more blank lines among them
- **AND** the user presses `<M-;>`
- **THEN** the blank lines are unchanged
- **AND** the non-blank lines are each terminated

#### Scenario: Lines already terminated

- **WHEN** some lines in the selection already end in `;`
- **AND** the user presses `<M-;>`
- **THEN** those lines are unchanged
- **AND** no line gains a second semicolon
