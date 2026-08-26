## Purpose

Lets the user reach any file, any line of text, any open buffer, or any help topic in the project by typing part of its name rather than by remembering and navigating a path.
## Requirements
### Requirement: `<leader><leader>` searches for files by name

Pressing `<leader><leader>` in normal mode SHALL open an interactive picker over the files in the current working directory. Typing SHALL narrow the list by fuzzy-matching the query against file paths, updating on every keystroke. Selecting an entry SHALL open that file in the current window.

The mapping SHALL be `<leader><leader>` exactly, and `<leader>f` SHALL NOT be bound as a mapping in its own right, so that no `<leader>f`-prefixed mapping waits on a key-sequence timeout.

#### Scenario: Finding a file by a fragment of its name

- **WHEN** the user presses `<leader><leader>` and types a fragment of a filename
- **THEN** the list narrows to files whose paths fuzzy-match that fragment
- **AND** the list updates as each further character is typed

#### Scenario: Opening a match

- **WHEN** the user selects an entry in the file picker
- **THEN** that file opens in the window the picker was invoked from
- **AND** the picker closes

#### Scenario: Dismissing without choosing

- **WHEN** the user cancels the picker without selecting an entry
- **THEN** the picker closes
- **AND** the buffer and cursor position are exactly as they were before it opened

#### Scenario: No mapping stalls on the find prefix

- **WHEN** the user presses `<leader>f`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of a `<leader>f`-prefixed sequence

### Requirement: `<leader>fg` searches file contents

Pressing `<leader>fg` SHALL open an interactive picker that searches the *text* of files under the current working directory. Results SHALL identify the file and line of each match, and selecting one SHALL open that file with the cursor on the matching line.

#### Scenario: Searching for a string across the project

- **WHEN** the user presses `<leader>fg` and types a search string
- **THEN** matching lines from across the project are listed with their file and line number
- **AND** the results update as the query changes

#### Scenario: Jumping to a match

- **WHEN** the user selects a result from the content search
- **THEN** the containing file opens
- **AND** the cursor is placed on the matched line

#### Scenario: Query with no matches

- **WHEN** the query matches nothing
- **THEN** the picker shows an empty result list
- **AND** no error is raised

### Requirement: `<leader>fb` lists open buffers

Pressing `<leader>fb` SHALL open a picker over the currently open buffers. Selecting one SHALL switch to it.

The same picker SHALL also be reachable as `<leader>,`, a two-key sequence beside the `<leader><leader>` that opens the file picker, since switching buffers is at least as frequent as opening a file. The two keys SHALL open the same picker and differ in nothing else, and the prefixed form SHALL remain, so the picker is still listed with the rest of `<leader>f`.

#### Scenario: Switching buffers

- **WHEN** two or more buffers are open
- **AND** the user presses `<leader>fb` and selects one
- **THEN** the current window displays that buffer

#### Scenario: Switching buffers from the unprefixed key

- **WHEN** two or more buffers are open
- **AND** the user presses `<leader>,` and selects one
- **THEN** the current window displays that buffer
- **AND** the picker was identical to the one `<leader>fb` opens

### Requirement: `<leader>fh` searches help

Pressing `<leader>fh` SHALL open a picker over the editor's help tags. Selecting a tag SHALL open the help document at that tag.

#### Scenario: Opening a help topic

- **WHEN** the user presses `<leader>fh` and selects a help tag
- **THEN** the help window opens positioned at that tag

### Requirement: `<leader>g` opens pickers over git

The user SHALL be able to fuzzy-find over the state of the repository containing the current working directory, from a two-key sequence beginning `<leader>g`, covering:

- **Tracked files** — the files git knows about, as distinct from every file on disk, so that ignored and untracked files are excluded.
- **Working-tree status** — the files that differ from the index or the last commit, with selection opening the file.
- **Commit log** — the repository's commits, with selection showing that commit's diff.
- **Branches** — the repository's branches, with selection checking one out.

`<leader>g` SHALL NOT itself be bound as a mapping, so that no sequence under it waits out a key-sequence timeout. These mappings SHALL be declared in the fuzzy finder's own plugin file.

#### Scenario: Finding a tracked file

- **WHEN** the working directory is a git repository containing both tracked and ignored files
- **AND** the user opens the tracked-files picker and types a fragment
- **THEN** the list narrows to tracked files matching that fragment
- **AND** no ignored or untracked file appears in the list

#### Scenario: Reviewing what has changed

- **WHEN** several files differ from the index
- **AND** the user opens the status picker
- **THEN** those files are listed
- **AND** selecting one opens it in the window the picker was invoked from

#### Scenario: Browsing the log

- **WHEN** the user opens the commit picker and selects a commit
- **THEN** that commit's changes are displayed

#### Scenario: Switching branch

- **WHEN** the repository has more than one branch
- **AND** the user opens the branch picker and selects one
- **THEN** that branch is checked out

#### Scenario: Outside a git repository

- **WHEN** the working directory is not inside a git repository
- **AND** the user opens any of these pickers
- **THEN** the user is told the directory is not a git repository
- **AND** no error trace is shown and the editor remains usable

#### Scenario: No mapping stalls on the git prefix

- **WHEN** the user presses `<leader>g`
- **THEN** nothing is executed and no action is deferred pending a timeout
- **AND** the editor waits for the next key of the sequence

### Requirement: `<Esc>` closes an open picker

Pressing `<Esc>` while a picker's prompt has focus SHALL close the picker immediately and return to the buffer it was invoked from, rather than leaving the picker open in its own normal mode. The buffer, cursor position and window layout SHALL be exactly as they were before the picker opened.

#### Scenario: Dismissing a picker mid-query

- **WHEN** a picker is open and the user has typed part of a query
- **AND** the user presses `<Esc>`
- **THEN** the picker closes
- **AND** the buffer and cursor position are exactly as they were before it opened

#### Scenario: One press is enough

- **WHEN** a picker is open with its prompt focused and the user presses `<Esc>` once
- **THEN** the picker is closed
- **AND** no second key is needed to leave it

#### Scenario: Every picker behaves the same way

- **WHEN** any of this capability's pickers is open
- **THEN** `<Esc>` closes it
- **AND** the behaviour does not differ between pickers

### Requirement: `<C-j>` and `<C-k>` move through picker results

While a picker's prompt has focus, `<C-j>` SHALL move the selection to the next result and `<C-k>` to the previous one, without leaving the prompt or interrupting the query being typed. The keys SHALL work alongside, not instead of, whatever result-navigation keys the picker already provides.

These mappings SHALL apply only within a picker prompt. In every other buffer `<C-j>` and `<C-k>` SHALL retain the window-navigation behaviour specified by `editor-keymaps`.

#### Scenario: Stepping down the result list

- **WHEN** a picker is open with several results and the first is selected
- **AND** the user presses `<C-j>`
- **THEN** the second result becomes selected
- **AND** the prompt still has focus and the typed query is unchanged

#### Scenario: Stepping back up

- **WHEN** a result below the first is selected and the user presses `<C-k>`
- **THEN** the previous result becomes selected

#### Scenario: Navigating then refining the query

- **WHEN** the user has moved the selection with `<C-j>` and then types another character
- **THEN** the query is extended by that character
- **AND** the result list narrows accordingly

#### Scenario: Opening the navigated-to result

- **WHEN** the user has moved the selection with `<C-j>` or `<C-k>` and accepts the selection
- **THEN** the result that was selected is the one opened

#### Scenario: Window navigation is unaffected outside a picker

- **WHEN** no picker is open and the user presses `<C-j>` in a normal buffer
- **THEN** focus moves to the window below, per `editor-keymaps`

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

### Requirement: Picker mappings are declared with the finder

Every mapping in this capability SHALL be declared in the fuzzy finder's own plugin file and SHALL NOT appear in the general keymaps module, per the ownership rule in `config-structure`.

#### Scenario: Locating a picker mapping

- **WHEN** a contributor looks for where `<leader><leader>` is defined
- **THEN** it is declared in the fuzzy finder's plugin file under `lua/plugins/`
- **AND** it is absent from `lua/config/keymaps.lua`

### Requirement: Every picker shows a preview of the selected result

While a picker is open, a preview pane SHALL display the content behind the currently selected result, and SHALL follow the selection as it moves. The pane SHALL be present for every picker in this capability, not only for the file and content searches.

What the pane shows depends on what the result is: for a result that names a file, it SHALL be that file's content; for a result that names a file and a line, the content SHALL be positioned on that line with the match distinguishable from its surroundings; for a result that names a commit or a branch, it SHALL be the diff or log for that revision.

A result the editor cannot usefully render — a binary file, or one large enough that reading it would stall the picker — SHALL leave the pane showing a short explanation rather than raw bytes, an error, or a hang.

#### Scenario: Preview follows the selection

- **WHEN** a picker is open with several results and the user moves the selection to a different result
- **THEN** the preview pane updates to show the newly selected result
- **AND** the prompt keeps focus and the typed query is unchanged

#### Scenario: Previewing a content-search hit

- **WHEN** the user runs the content search and a result is selected
- **THEN** the preview shows that file positioned on the matching line
- **AND** the matched text is distinguishable from the surrounding lines

#### Scenario: Previewing a revision

- **WHEN** the user opens the commit picker and selects a commit
- **THEN** the preview shows that commit's changes without the picker being dismissed

#### Scenario: Previewing something unrenderable

- **WHEN** the selected result is a binary file or one too large to read into the preview
- **THEN** the pane reports that rather than showing its bytes
- **AND** no error is raised and the picker stays usable

#### Scenario: Preview is not tied to one picker

- **WHEN** any picker in this capability is opened
- **THEN** it has a preview pane
- **AND** the pane behaves the same way across pickers

### Requirement: The picker is sized and laid out from the editor window

The picker window SHALL take its size from the dimensions of the Neovim window at the moment it opens, as a proportion of them rather than as a fixed number of rows and columns, so that it grows with a large window and shrinks with a small one. A lower bound SHALL keep the picker usable when the editor window is small enough that the proportion alone would leave the prompt or the result list too cramped to read.

The arrangement of the three areas — prompt, result list, preview — SHALL adapt to the shape of the editor window: where there is width enough for both, the preview SHALL sit beside the result list; where there is not, it SHALL sit below the result list instead, stacked vertically. Narrowing the editor SHALL change where the preview is, never whether there is one.

Resizing the Neovim window while no picker is open SHALL be reflected the next time a picker opens.

#### Scenario: A wide editor window

- **WHEN** the Neovim window is wide enough for a side-by-side arrangement and the user opens a picker
- **THEN** the preview pane sits beside the result list
- **AND** the picker occupies a proportion of the editor window rather than a fixed size

#### Scenario: A narrow editor window

- **WHEN** the Neovim window is too narrow for a side-by-side arrangement and the user opens a picker
- **THEN** the preview pane sits below the result list rather than beside it
- **AND** the preview is still shown

#### Scenario: Resizing between pickers

- **WHEN** the user closes a picker, resizes the Neovim window, and opens a picker again
- **THEN** the new picker is sized to the resized window

#### Scenario: A small editor window

- **WHEN** the Neovim window is small enough that a proportional size alone would leave the picker unusably cramped
- **THEN** the picker is no smaller than its lower bound
- **AND** the prompt and at least several results remain readable

#### Scenario: Layout does not change what the mappings do

- **WHEN** a picker is open in either arrangement
- **THEN** `<Esc>`, `<C-j>` and `<C-k>` behave exactly as this capability already specifies
- **AND** which arrangement is in use makes no difference to them

### Requirement: The prompt sits above a best-first result list in one frame

The prompt SHALL be positioned above the result list, not below it, so that the text being typed and the results it produces read in that order from the top of the picker downwards. This SHALL hold in both arrangements: the prompt is above the results whether the preview is beside them or stacked under them.

Results SHALL be ordered with the strongest match at the top of the list, immediately under the prompt, and progressively weaker matches below it — so that the entry the user is most likely to want is the one adjacent to what they are typing, and is the entry selected when the picker opens.

The prompt, the result list and the preview SHALL be drawn as one continuous frame rather than as separately framed boxes, so that no doubled border or blank run separates what is typed from the results beneath it, or the results from the preview, and the three read as a single control. A single drawn line SHALL divide one area from the next, whichever arrangement is in use.

#### Scenario: Typing at the top

- **WHEN** the user opens any picker in this capability
- **THEN** the prompt is at the top of the picker, above the result list
- **AND** results appear beneath it as the query is typed

#### Scenario: The best match is adjacent to the prompt

- **WHEN** the user types a query that matches several entries
- **THEN** the strongest match is the first row of the result list, directly under the prompt
- **AND** it is the entry that is selected

#### Scenario: Moving down the list moves down the screen

- **WHEN** the strongest match is selected and the user presses `<C-j>`
- **THEN** the selection moves to the next-strongest match
- **AND** that entry is the one visually below the previous selection

#### Scenario: Prompt, results and preview read as one control

- **WHEN** a picker is open
- **THEN** the prompt, the result list and the preview are enclosed in a single continuous frame
- **AND** a single drawn line divides each area from the next, with no doubled border or blank run between them

#### Scenario: The same in the stacked arrangement

- **WHEN** the editor window is narrow enough for the stacked arrangement
- **THEN** the prompt is still above the result list, in the same continuous frame
- **AND** the preview sits below both, divided from the results by a single drawn line

