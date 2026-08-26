## MODIFIED Requirements

### Requirement: The editor is left from a `<leader>q` prefix

Leaving the editor SHALL be reachable from the `<leader>` menu rather than only by typing an Ex command. `<leader>qq` SHALL close every window and every tab page, ending the editing session. `<leader>qw` SHALL first write every modified buffer that has a filename, and then close every window and tab page, so that saving and leaving is one sequence rather than a save followed by a separate quit.

Neither mapping SHALL discard unsaved work without asking. When a buffer would be lost, the user SHALL be asked what to do about that buffer — see the requirement on unsaved changes below — and SHALL be able to abandon the quit entirely, leaving the editor exactly as it was, every buffer still loaded and the window layout unchanged.

`<leader>q` SHALL NOT be bound to any command of its own, so that pressing it executes nothing and the sequence under it completes on the next key without waiting out a key-sequence timeout. A component that only describes the mappings under a prefix — see `keymap-hints` — MAY attach itself to `<leader>q`, since it runs no command and delays no completion.

The prefix SHALL be for the editing session as a whole: leaving it, and — per `session-management` — saving, restoring, searching and deleting the sessions that persist it across launches. It SHALL NOT take mappings that act on a single window or a single buffer. Closing a single window remains `<leader>wq` and `<C-w>q`, which are a different sequence and are unaffected, and deleting a single buffer remains `<leader>bd`.

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

### Requirement: `<leader>rc` restarts the editor after confirmation

Pressing `<leader>rc` SHALL restart the editor so that every change to the configuration takes effect, including changes a re-source could not apply. Because a restart tears down and rebuilds the whole editor process, the user SHALL be asked to confirm first, and declining SHALL leave the editor exactly as it was. Unsaved changes SHALL NOT be silently discarded.

The confirmation SHALL NOT tell the user that the session is discarded. Where session management is active, the buffers and window layout are saved on exit and restored on the way back up, so the prompt SHALL describe only what a restart actually costs.

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

#### Scenario: The prompt matches what happens

- **WHEN** the user is shown the restart confirmation
- **THEN** it does not claim that the open buffers and window layout will be lost
