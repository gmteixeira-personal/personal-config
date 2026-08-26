## ADDED Requirements

### Requirement: The editor is left from a `<leader>q` prefix

Leaving the editor SHALL be reachable from the `<leader>` menu rather than only by typing an Ex command. `<leader>qq` SHALL close every window and every tab page, ending the editing session. `<leader>qw` SHALL first write every modified buffer that has a filename, and then close every window and tab page, so that saving and leaving is one sequence rather than a save followed by a separate quit.

Neither mapping SHALL discard unsaved work without asking. When a buffer would be lost, the user SHALL be asked what to do about that buffer — see the requirement on unsaved changes below — and SHALL be able to abandon the quit entirely, leaving the editor exactly as it was, every buffer still loaded and the window layout unchanged.

`<leader>q` SHALL NOT be bound to any command of its own, so that pressing it executes nothing and the sequence under it completes on the next key without waiting out a key-sequence timeout. A component that only describes the mappings under a prefix — see `keymap-hints` — MAY attach itself to `<leader>q`, since it runs no command and delays no completion.

The prefix SHALL be for leaving the editor only. Closing a single window remains `<leader>wq` and `<C-w>q`, which are a different sequence and are unaffected.

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
- **AND** the mappings that can continue the sequence are listed

#### Scenario: Closing one window is a different sequence

- **WHEN** two windows are open and the user presses `<leader>wq`
- **THEN** that window closes
- **AND** the editing session continues in the remaining window

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
