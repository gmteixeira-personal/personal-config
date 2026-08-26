## ADDED Requirements

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
