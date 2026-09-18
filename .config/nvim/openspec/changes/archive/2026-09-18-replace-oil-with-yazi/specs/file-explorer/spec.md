## ADDED Requirements

### Requirement: `<leader>e` opens the file explorer in the current window

Pressing `<leader>e` in normal mode SHALL open the file explorer in the current window, replacing the buffer displayed there and filling that window. The explorer SHALL start with the file the window was displaying under the cursor, so that the entry the user was working on is the one already selected. Only the focused window SHALL change: the explorer SHALL NOT be drawn over the rest of the editor, and every other window SHALL keep its size, position, and buffer.

The explorer SHALL take keyboard focus on opening, so that its own keys work without the user entering a mode first. It SHALL NOT be dismissed by `<leader>e`: while it has focus every keystroke belongs to it, so the editor never sees that mapping. Dismissal is covered by the requirement on leaving the explorer.

The mapping SHALL be declared with the explorer's own module, alongside the rest of the explorer's configuration, and SHALL NOT be declared in the general keymaps module.

#### Scenario: Opening the explorer

- **WHEN** the user presses `<leader>e` while editing a file
- **THEN** the current window shows the explorer listing that file's directory
- **AND** the listing occupies the whole window, with no floating border and no part of the previous buffer visible
- **AND** the cursor is on the entry for the file that was being edited

#### Scenario: Opening with no file loaded

- **WHEN** the user presses `<leader>e` from an empty start screen with no file open
- **THEN** the explorer opens on the current working directory
- **AND** no error is raised

#### Scenario: The window layout is left alone

- **WHEN** the user presses `<leader>e` in one of several open windows
- **THEN** only that window's contents change
- **AND** the other windows keep their size, position, and buffers
- **AND** their contents remain visible the whole time the explorer is open

#### Scenario: The explorer is ready for its own keys

- **WHEN** the explorer opens
- **THEN** the next keystroke is delivered to the explorer
- **AND** the user does not have to press anything first to make that so

### Requirement: Leaving the explorer either opens a file or restores the window

Leaving the explorer SHALL always return the window to an ordinary buffer. Where the user left it by choosing one or more files, the window SHALL display the chosen file. Where the user left it without choosing anything, the window SHALL display the buffer it held before the explorer opened, with that buffer's cursor position and scroll position unchanged.

A window that had no previous buffer to return to SHALL be left showing an empty buffer rather than raising an error, and the editor SHALL NOT be left with a terminal buffer displayed or listed.

#### Scenario: Choosing a file

- **WHEN** the user selects a file in the explorer and confirms the choice
- **THEN** the explorer closes
- **AND** the window shows that file

#### Scenario: Leaving without choosing

- **WHEN** the user quits the explorer without selecting a file
- **THEN** the window returns to the buffer it displayed before the explorer was opened
- **AND** that buffer's cursor position and scroll position are unchanged

#### Scenario: Leaving when there is no buffer to return to

- **WHEN** the explorer is displayed in a window that had no previous buffer, such as after starting the editor on a directory
- **AND** the user quits the explorer without selecting a file
- **THEN** the explorer is dismissed
- **AND** an empty buffer is shown
- **AND** no error is raised

#### Scenario: Choosing several files

- **WHEN** the user selects more than one file in the explorer and confirms the choice
- **THEN** the window shows the first of them
- **AND** the rest are opened as buffers, reachable from the buffer list without being displayed

#### Scenario: No terminal buffer is left behind

- **WHEN** the explorer has been opened and left, by either route
- **THEN** no terminal buffer from it remains listed
- **AND** walking the buffer list does not land on one

### Requirement: The explorer runs the user's own file manager, with the user's own configuration

The explorer SHALL be the same file manager program the user runs outside the editor, started so that it reads the user's own configuration. Settings the user has made there — key bindings, theme, and behaviour shared between running instances — SHALL apply inside the editor without being restated in the editor's configuration.

#### Scenario: User key bindings apply

- **WHEN** the user has bound a key in the file manager's own configuration
- **AND** presses it inside the explorer
- **THEN** it does what it does outside the editor

#### Scenario: State shared between instances

- **WHEN** the file manager is configured to share state between its running instances
- **THEN** the instance the editor starts takes part in that sharing on the same terms as any other

### Requirement: A missing file manager is reported, not crashed into

The explorer depends on an external program that this configuration does not install. Where that program is not on `PATH`, pressing `<leader>e` SHALL report that it is missing, naming it, and SHALL leave the window untouched. It SHALL NOT open a window, replace a buffer, or surface the failure as a job or terminal error.

#### Scenario: The program is absent

- **WHEN** the external file manager is not installed
- **AND** the user presses `<leader>e`
- **THEN** a message names the missing program
- **AND** the current window still shows the buffer it showed before
- **AND** no terminal buffer is created

## MODIFIED Requirements

### Requirement: The explorer displays icons

Each entry in the listing SHALL be shown with an icon distinguishing files from directories and indicating a file's type. The icons SHALL come from the file manager's own theme rather than from the editor's icon provider, so that the listing looks the same inside the editor as outside it.

#### Scenario: Entries are iconified

- **WHEN** the explorer lists a directory containing both files and subdirectories
- **THEN** each file shows a filetype-appropriate icon and each subdirectory shows a directory icon

#### Scenario: The listing matches the standalone program

- **WHEN** the same directory is viewed in the explorer and in the file manager run from a terminal
- **THEN** the icons and their colours are the same in both

### Requirement: The explorer replaces the built-in directory browser

Opening a directory path SHALL show the explorer rather than Neovim's built-in netrw browser, so that directory browsing behaves the same however it is reached. The directory buffer netrw would otherwise have taken over SHALL NOT be left behind once the explorer has opened.

#### Scenario: Opening a directory from the shell

- **WHEN** the user runs `nvim <directory>`
- **THEN** the explorer's listing for that directory is shown, not netrw

#### Scenario: Opening a directory from within the editor

- **WHEN** the user edits a path that is a directory from inside the editor
- **THEN** the explorer opens on it, not netrw

#### Scenario: No directory buffer is left listed

- **WHEN** the editor has been started on a directory
- **THEN** no buffer named for that directory remains listed

## REMOVED Requirements

### Requirement: `<leader>e` toggles the file explorer in the current window

**Reason**: The explorer becomes a terminal user interface with its own key handling, and a program that owns the keyboard cannot be closed by a key the editor is watching for. `<leader>e` is `<Space>e`; to close on it, the editor would have to intercept `<Space>` inside the explorer and hold it for `timeoutlen` before passing it on, which would degrade the explorer's own use of `<Space>` for selecting entries. The toggle is therefore withdrawn rather than reimplemented badly.

**Migration**: `<leader>e` still opens the explorer, and its opening behaviour is unchanged — same window, same full-window listing, same untouched layout — under the requirement "`<leader>e` opens the file explorer in the current window". Closing is now the file manager's own `q`, which restores the previous buffer with its cursor and scroll position intact, exactly as the second press of `<leader>e` used to. That is specified by "Leaving the explorer either opens a file or restores the window", which also covers the case the old requirement had no answer for: leaving by choosing a file.

### Requirement: The directory listing is an editable buffer

**Reason**: The listing stops being a buffer at all. The explorer is a terminal user interface that draws its own listing and applies file operations directly, so there is no text to edit and no write to confirm. This is the deliberate trade in this change: editing a directory as text is given up in exchange for preview, filtering, and the file manager the user already runs everywhere else.

**Migration**: The operations the editable buffer provided are still available, as the file manager's own keys, applied when pressed rather than on a write. Creating is `a`, renaming is `r`, deleting is `d`, and moving is a yank with `y` followed by `p` in the destination — which no longer requires the source and the destination to be on screen together. Renaming many entries at once, the case the editable buffer was best at, remains available as the file manager's bulk rename: select the entries, press `r`, and their names open in `$EDITOR` as text to edit and write. Because operations are no longer staged, there is no longer a point at which unwritten edits leave the filesystem untouched; the guard against a mistaken delete is the confirmation on the delete key and the trash it goes to, covered below.

### Requirement: Deleting an entry removes it permanently

**Reason**: The requirement exists to make a deletion's irreversibility explicit rather than inherited from a default. The new explorer's default is the opposite — a delete goes to the trash, and a separate key deletes permanently — and rebinding it would make the file manager behave differently inside the editor than outside it, which is the thing this change is trying to stop. The requirement is withdrawn rather than enforced, and it is the weaker guarantee that is given up: a deletion made here is now recoverable.

**Migration**: `d` moves the entry to the system trash, from which it can be restored. `D` deletes permanently, with no trash and no undo. Both keys prompt for confirmation before acting. Neither is rebound by this configuration, so both behave exactly as they do when the file manager is run from a terminal.
