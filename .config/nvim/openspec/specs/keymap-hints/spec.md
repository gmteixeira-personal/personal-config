## Purpose

Shows the user what a half-typed key sequence can still become. While a mapping is pending, the keys that continue it are listed with the descriptions their mappings already carry, so a prefix can be explored instead of remembered, and so a mapping is discovered by pressing keys rather than by reading the configuration.
## Requirements
### Requirement: A pending key sequence is answered with the keys that continue it

When the keys typed so far form the prefix of one or more mappings and the user pauses, the editor SHALL display every key that can continue the sequence, each next to the description of what completing it does. The list SHALL cover all modes the pending sequence is valid in, and SHALL be drawn from the mappings that actually exist at that moment, so a mapping that is defined is listed and one that is not is absent.

Typing a further key SHALL narrow the list to the mappings that remain reachable, rather than dismissing it.

#### Scenario: Pausing on a prefix

- **WHEN** the user presses a key that begins several mappings and does not press another key
- **THEN** the keys that can continue the sequence are listed
- **AND** each is shown with its description

#### Scenario: Narrowing

- **WHEN** the list is displayed and the user presses a further key that is itself a prefix
- **THEN** the list is replaced by the keys that continue the longer sequence

#### Scenario: Completing the sequence

- **WHEN** the list is displayed and the user presses a key that completes a mapping
- **THEN** that mapping runs
- **AND** the list disappears

#### Scenario: Abandoning the sequence

- **WHEN** the list is displayed and the user presses `<Esc>`
- **THEN** the list disappears
- **AND** no mapping runs
- **AND** the keys typed so far have no further effect

#### Scenario: A prefix in visual mode

- **WHEN** the user has a visual selection and pauses on a prefix that has visual-mode mappings
- **THEN** the visual-mode mappings under that prefix are listed
- **AND** the selection is intact when the sequence completes

### Requirement: The hints do not change what any mapping does

Displaying hints SHALL NOT alter the meaning, the key, or the timing of any mapping. A sequence typed at speed SHALL run exactly as it did before this capability existed, with no hint displayed and no key consumed. No key SHALL become slower to resolve because hints exist, and the hint display SHALL NOT be reachable as the outcome of a completed mapping.

A count or register typed before a sequence SHALL still apply to it.

#### Scenario: Typing a known sequence at speed

- **WHEN** the user types a multi-key mapping without pausing
- **THEN** the mapping runs immediately
- **AND** no hint list is shown

#### Scenario: A count before a mapping

- **WHEN** the user types a count and then a mapping that honours one
- **THEN** the mapping runs with that count
- **AND** the count is not consumed by the hint display

#### Scenario: An operator awaiting a motion

- **WHEN** the user presses an operator and then a motion
- **THEN** the operator applies to that motion as it always has

### Requirement: The list is a bordered panel at the bottom of the screen

The list SHALL be presented in the layout this configuration selects, which is a bordered floating panel anchored to the bottom of the editor, padded from its border, and spanning the editor's width. Entries SHALL be laid out in columns within it, each entry showing an icon, the key, and the description. The panel SHALL overlay the editor without resizing any window or moving the cursor, and SHALL leave no trace once dismissed.

The panel SHALL take its colours from the active colorscheme, so switching colorscheme restyles it with no further configuration.

#### Scenario: Where the panel appears

- **WHEN** the hint list is shown
- **THEN** it appears as a bordered panel at the bottom of the editor
- **AND** the window layout is unchanged
- **AND** the cursor has not moved

#### Scenario: Dismissal leaves nothing behind

- **WHEN** the panel is dismissed by any means
- **THEN** the text it covered is redrawn intact

#### Scenario: Following the colorscheme

- **WHEN** the colorscheme is changed and the hint list is shown again
- **THEN** the panel is drawn in the new colorscheme's colours

### Requirement: Prefixes are listed as named groups

A key that is only ever a prefix SHALL be listed under its own name rather than as a bare character, so that the list of what `<leader>` begins reads as a menu of subjects. Every `<leader>` prefix this configuration defines mappings under SHALL be named: buffer, code, find, git, hunk, multi-cursor, notices, quit, restart and sessions, todo markers, and window.

Where one prefix carries mappings for more than one subject, its name SHALL name every subject rather than picking one and leaving the rest unlabelled.

A prefix that is named SHALL still not be bound to any command; naming it SHALL affect only how it is displayed.

#### Scenario: Pressing the leader key alone

- **WHEN** the user presses `<leader>` and pauses
- **THEN** each prefix defined under it is listed by name
- **AND** the single-key mappings defined directly under `<leader>` are listed alongside them with their own descriptions

#### Scenario: Entering a named group

- **WHEN** the user presses a named prefix and pauses
- **THEN** the mappings under that prefix are listed with their descriptions

#### Scenario: A named prefix runs nothing

- **WHEN** the user presses a named prefix
- **THEN** no command runs
- **AND** the editor waits for the next key of the sequence

#### Scenario: A prefix that is no longer used

- **WHEN** a prefix stops carrying mappings
- **THEN** it is no longer named
- **AND** pressing it lists nothing

#### Scenario: A prefix covering two subjects

- **WHEN** the user presses `<leader>` and pauses
- **THEN** `q` is listed under a name covering both quitting and sessions
- **AND** pausing after `q` lists the quit mappings and the session mappings together, each with its own description

#### Scenario: The notices prefix

- **WHEN** the user presses `<leader>` and pauses
- **THEN** the prefix that carries the message and notification history mappings is listed under a name
- **AND** pressing it lists those mappings with their descriptions

#### Scenario: The todo prefix

- **WHEN** the user presses `<leader>` and pauses
- **THEN** the prefix that carries the marker listings is listed under a name
- **AND** pausing after it lists the picker, quickfix, and location-list mappings with their descriptions

### Requirement: Descriptions come from the mappings themselves

The text shown beside a key SHALL be the description recorded with that mapping where it is defined. A mapping SHALL NOT need to be registered, listed, or described a second time in order to appear, so that adding a mapping with a description anywhere in the configuration is enough for it to be listed, and changing that description changes what is shown.

A mapping with no description SHALL still be listed, identified by its key and its target.

#### Scenario: A newly added mapping

- **WHEN** a contributor adds a mapping with a description under an existing prefix
- **AND** restarts the editor
- **THEN** it appears in that prefix's list with that description
- **AND** no other file was edited to make it appear

#### Scenario: A changed description

- **WHEN** a mapping's description is edited
- **THEN** the list shows the new text

### Requirement: Mappings local to the current buffer are listed and separately reachable

Mappings that exist only in the current buffer SHALL be listed alongside global ones while their prefix is pending, so that a mapping attached by a language server or by a plugin that activates per buffer is discoverable in the same way as any other. Where such a mapping shadows a global one, the buffer-local mapping SHALL be the one listed.

A single mapping SHALL additionally list the current buffer's local mappings on their own, so that what this buffer has that another does not can be seen without pressing every prefix.

#### Scenario: A buffer-local prefix

- **WHEN** the buffer is in a git repository and the user pauses on the hunk prefix
- **THEN** the hunk mappings are listed

#### Scenario: The same prefix elsewhere

- **WHEN** the buffer is not in a git repository and the user pauses on the same prefix
- **THEN** those mappings are absent, because they are not defined

#### Scenario: Listing what is local to this buffer

- **WHEN** the user invokes the buffer-local listing mapping
- **THEN** only mappings local to the current buffer are listed
- **AND** global mappings are absent from that list

### Requirement: Built-in and non-leader sequences are covered too

The hints SHALL NOT be limited to `<leader>`. Any pending sequence that has continuations SHALL be answered, including the window-command prefix, the `g` and `z` prefixes, the bracket-pair navigation prefixes, and the mappings plugins define outside `<leader>`. Where the pending sequence expects one of the editor's own built-in vocabularies — an operator's motions and text objects, a register, or a mark — those SHALL be listed as well.

#### Scenario: The window-command prefix

- **WHEN** the user presses the window-command prefix and pauses
- **THEN** the window commands available under it are listed
- **AND** the mapping this configuration adds under it is listed among them

#### Scenario: An operator's text objects

- **WHEN** the user presses an operator and pauses
- **THEN** the motions and text objects it can take are listed

#### Scenario: A plugin's non-leader prefix

- **WHEN** the user pauses on a prefix a plugin defines outside `<leader>`
- **THEN** that plugin's mappings under it are listed with their descriptions

### Requirement: The capability costs nothing at startup

The component providing this capability SHALL NOT be loaded on the startup path that produces the first screen. It SHALL be loaded once the editor is idle and ready, and SHALL be active before the user's first pause on a prefix, so that the first sequence of a session is hinted like any other.

#### Scenario: Startup

- **WHEN** the editor starts
- **THEN** the first screen is drawn without this capability having been loaded
- **AND** startup time is not measurably affected

#### Scenario: The first prefix of a session

- **WHEN** the user pauses on a prefix for the first time after startup
- **THEN** the hint list is shown
- **AND** the keys typed are not consumed by the load

### Requirement: The capability is declared in its own plugin file

Everything this capability needs — the component, its layout selection, its group names, and the mapping that lists buffer-local mappings — SHALL be declared in a single file under `lua/plugins/`. Deleting that file SHALL remove the capability entirely and leave every other mapping in the configuration working exactly as before.

#### Scenario: Locating the configuration

- **WHEN** a contributor looks for where the hints are configured
- **THEN** all of it is in one file under `lua/plugins/`

#### Scenario: Removing the capability

- **WHEN** that file is deleted and the editor is restarted
- **THEN** no hint list is shown
- **AND** every other mapping behaves as it did
- **AND** no error is raised

