## ADDED Requirements

### Requirement: `<C-d>` deletes buffers from the buffer picker

While the buffer picker's prompt has focus, `<C-d>` SHALL delete the buffer the picker names, without leaving the picker.

Which buffers it acts on SHALL follow the picker's own marks: if one or more entries are marked, `<C-d>` SHALL act on every marked entry and on nothing else; if no entry is marked, it SHALL act on the single entry currently selected.

Deleting a buffer SHALL be the same operation the editor's own buffer deletion performs — the buffer is unloaded and removed from the buffer list, and any window displaying it is dealt with as that operation dictates. If the buffer being deleted is the one displayed in the window the picker was opened from, that window SHALL be left displaying some other valid buffer rather than the deleted one, and SHALL NOT be closed.

This binding SHALL apply to the buffer picker alone. In every other picker in this capability, `<C-d>` SHALL retain its existing meaning of scrolling the preview pane.

#### Scenario: Deleting the selected buffer

- **WHEN** the buffer picker is open with no entry marked and a buffer with no unsaved changes selected
- **AND** the user presses `<C-d>`
- **THEN** that buffer is unloaded and no longer appears in the buffer list

#### Scenario: Deleting a marked set

- **WHEN** the user has marked three entries in the buffer picker and presses `<C-d>`
- **THEN** all three buffers are deleted
- **AND** no unmarked buffer is deleted, including the one the selection happens to rest on

#### Scenario: Deleting the buffer the picker was opened from

- **WHEN** the user opens the buffer picker and deletes the buffer that was displayed in the window it was opened from
- **THEN** that window displays another valid buffer
- **AND** the window is not closed and no error is raised

#### Scenario: The preview scroll is untouched elsewhere

- **WHEN** the user opens the file picker, the content search, the help picker, or any git picker and presses `<C-d>`
- **THEN** the preview pane scrolls down
- **AND** nothing is deleted

### Requirement: The picker stays open and current across a delete

A delete SHALL NOT dismiss the buffer picker. The deleted entries SHALL be removed from the result list so that the list continues to show what is actually open, the prompt SHALL keep focus with the typed query unchanged, and a further `<C-d>` SHALL act on whatever is selected after the list has been updated.

Marks SHALL be cleared once the marked set has been dealt with, so that a subsequent `<C-d>` does not re-act on entries that are gone.

#### Scenario: Deleting several buffers in a row

- **WHEN** the user presses `<C-d>` on a selected buffer with no marks set
- **THEN** the picker remains open with the deleted entry gone from the list
- **AND** pressing `<C-d>` again deletes the entry now selected

#### Scenario: The query survives a delete

- **WHEN** the user has typed a query that narrows the buffer list and deletes one of the matches
- **THEN** the prompt still holds that query and still has focus
- **AND** the remaining matches are still listed

#### Scenario: Marks do not outlive the delete

- **WHEN** the user marks two entries, presses `<C-d>`, and both are deleted
- **THEN** no entry in the refreshed list is marked

### Requirement: Unsaved changes raise a save / discard / cancel prompt

A `<C-d>` on a buffer with unsaved changes SHALL NOT delete it silently, discard its changes without asking, or fail without telling the user why. It SHALL instead raise a prompt that names the buffer and offers three answers:

- **Save** — the buffer is written and then deleted.
- **Discard** — the buffer is deleted and its unsaved changes are lost.
- **Cancel** — the buffer is neither written nor deleted.

The prompt SHALL be raised once per modified buffer. A buffer with no unsaved changes SHALL raise no prompt at all.

Where a buffer cannot be written — it has no filename, or the write fails — the user SHALL be told, and that buffer SHALL be left open with its changes intact rather than deleted.

#### Scenario: Saving before the delete

- **WHEN** the user presses `<C-d>` on a buffer with unsaved changes and answers Save
- **THEN** the buffer's changes are written to its file
- **AND** the buffer is then deleted and drops out of the list

#### Scenario: Discarding the changes

- **WHEN** the user presses `<C-d>` on a buffer with unsaved changes and answers Discard
- **THEN** the buffer is deleted without being written
- **AND** it drops out of the list

#### Scenario: Cancelling the delete

- **WHEN** the user presses `<C-d>` on a buffer with unsaved changes and answers Cancel
- **THEN** the buffer is not deleted and its unsaved changes are intact
- **AND** it is still listed in the picker, which is still open and usable

#### Scenario: Only modified buffers prompt

- **WHEN** the user marks three buffers, one of which has unsaved changes, and presses `<C-d>`
- **THEN** exactly one prompt is raised, naming the modified buffer
- **AND** the two unmodified buffers are deleted without any prompt

#### Scenario: Cancelling one of a marked set

- **WHEN** the user marks three buffers, two of which have unsaved changes, and answers Discard to the first prompt and Cancel to the second
- **THEN** the buffer Cancel was answered for is still open and still listed
- **AND** the other two buffers are deleted

#### Scenario: Cancelling every prompt deletes nothing

- **WHEN** every buffer in the set the user is deleting has unsaved changes and the user answers Cancel to each prompt
- **THEN** no buffer is deleted
- **AND** the picker is unchanged and still open

#### Scenario: Saving a buffer that has no file to save to

- **WHEN** the user answers Save for a modified buffer that has never been given a filename
- **THEN** the user is told it cannot be written
- **AND** the buffer is left open with its changes intact, and no error trace is shown
