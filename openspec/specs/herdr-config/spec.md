# herdr-config Specification

## Purpose
Defines how herdr, the terminal workspace manager these sessions run inside, is configured across machines: which part of its directory is configuration that belongs in this repository, which part is machine-local runtime state that must never enter it, and the prefix key its configuration fixes.

## Requirements

### Requirement: herdr preferences travel with the repository

The herdr configuration file SHALL be tracked, so that preferences set on one machine are present on the next without being rebuilt by hand. The allowlist entry SHALL name that single file rather than its directory.

#### Scenario: The configuration file is tracked

- **WHEN** `git ls-files` is inspected
- **THEN** `.config/herdr/config.toml` SHALL appear

#### Scenario: A restored machine keeps the preferences

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the preferences in the tracked file SHALL be in effect
- **AND** herdr SHALL NOT fall back to its shipped defaults for any setting the file names

### Requirement: herdr runtime state is never tracked

Everything in herdr's configuration directory other than the configuration file and the scripts its keybindings invoke SHALL remain ignored. That state is machine-local, is recreated on demand, and in the case of the sockets is not a regular file at all. A script bound to a key is neither: it is configuration in executable form, it belongs beside the file that names it, and it SHALL be tracked.

Plugin trees under that directory SHALL be ignored by name rather than by the default deny, because each managed plugin checkout carries its own repository and git would otherwise offer it as an embedded one.

#### Scenario: Runtime state stays ignored

- **WHEN** the client and server sockets, the log files, the session record, the plugin lock, and the plugin registry in that directory are checked
- **THEN** each SHALL be reported as ignored

#### Scenario: A plugin tree is never offered

- **WHEN** a plugin has been installed and `git status` lists untracked files
- **THEN** it SHALL NOT list the plugin's checkout
- **AND** the checkout SHALL NOT be stageable as an embedded repository

#### Scenario: Only the configuration file is offered

- **WHEN** `git status` lists untracked files with the directory populated by a running herdr
- **THEN** the only paths from that directory it may list SHALL be the configuration file and the scripts its keybindings invoke

### Requirement: The prefix key is ctrl+space

herdr's prefix key SHALL be `ctrl+space`. The shipped default of `ctrl+b` SHALL NOT apply, nor SHALL the previous `ctrl+f`, and the binding SHALL be declared in the tracked configuration file so it survives a reinstall and reaches every machine.

#### Scenario: The prefix is bound

- **WHEN** the herdr configuration is read
- **THEN** its keys section SHALL name `ctrl+space` as the prefix

#### Scenario: A prefixed action responds to it

- **WHEN** `ctrl+space` is pressed and followed by the key of a prefixed action
- **THEN** that action SHALL run
- **AND** pressing `ctrl+b` or `ctrl+f` first SHALL NOT run it

#### Scenario: Every existing prefixed action keeps its second key

- **WHEN** the prefix is pressed and followed by `\`, `e`, `=`, `+`, or `shift` and a digit from 1 to 9
- **THEN** the same action SHALL run as ran under the previous prefix
- **AND** no `[[keys.command]]` block SHALL have had its `key` value changed

#### Scenario: The released key reaches the pane

- **WHEN** `ctrl+f` is pressed in a pane running a program that binds it
- **THEN** herdr SHALL NOT consume it
- **AND** the program in the pane SHALL receive it

#### Scenario: A change applies without restarting

- **WHEN** the prefix is changed in the configuration file and herdr is asked to reload its configuration
- **THEN** the new prefix SHALL take effect in the running server
- **AND** open sessions SHALL survive the reload

### Requirement: Zoom is reachable from prefix+backslash

Pressing the prefix followed by `\` SHALL toggle zoom on the focused pane. The action SHALL be the same one the built-in zoom key performs — the focused pane fills its tab, and pressing the key again restores the previous layout — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key zooms the focused pane

- **WHEN** the prefix is pressed followed by `\` in a tab holding more than one pane
- **THEN** the focused pane SHALL fill the tab
- **AND** the other panes of that tab SHALL be hidden while it is zoomed

#### Scenario: The key restores the layout

- **WHEN** the prefix is pressed followed by `\` while the focused pane is zoomed
- **THEN** the tab SHALL return to the pane sizes it had before the zoom
- **AND** focus SHALL stay on the same pane

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** it SHALL declare a binding for `\` that toggles zoom

### Requirement: Zoom is reachable from prefix+f

Pressing the prefix followed by `f` SHALL toggle zoom on the focused pane. The action SHALL be the same one the built-in zoom key performs — the focused pane fills its tab, and pressing the key again restores the previous layout — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key zooms the focused pane

- **WHEN** the prefix is pressed followed by `f` in a tab holding more than one pane
- **THEN** the focused pane SHALL fill the tab
- **AND** the other panes of that tab SHALL be hidden while it is zoomed

#### Scenario: The key restores the layout

- **WHEN** the prefix is pressed followed by `f` while the focused pane is zoomed
- **THEN** the tab SHALL return to the pane sizes it had before the zoom
- **AND** focus SHALL stay on the same pane

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** it SHALL declare a binding for `f` that toggles zoom

### Requirement: The built-in zoom key keeps working

Adding the alias keys SHALL NOT remove or rebind herdr's built-in zoom key. All three keys — the built-in `z`, `\`, and `f` — SHALL toggle the same state, so alternating between any two of them SHALL behave as pressing either one twice.

#### Scenario: The built-in key still zooms

- **WHEN** the prefix is pressed followed by `z`
- **THEN** the focused pane SHALL toggle zoom exactly as it did before this change

#### Scenario: The two keys share one state

- **WHEN** a pane is zoomed with one of the three keys and another of them is then pressed
- **THEN** the pane SHALL be unzoomed
- **AND** no second zoom SHALL be stacked on the first

#### Scenario: The alias keys do not displace each other

- **WHEN** the tracked herdr configuration file is read
- **THEN** it SHALL declare both the `\` binding and the `f` binding
- **AND** neither SHALL replace the other

### Requirement: The binding survives a restore and a reload

The zoom alias bindings SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the key

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `\` SHALL toggle zoom with no further setup
- **AND** the prefix followed by `f` SHALL toggle zoom with no further setup

#### Scenario: The binding applies without restarting

- **WHEN** a binding is added and herdr is asked to reload its configuration
- **THEN** the key SHALL work in the running server
- **AND** open sessions SHALL survive the reload

### Requirement: An agent is reachable by number

The prefix followed by `shift` and a digit from 1 to 9 SHALL focus the agent at that position in the agent panel. The binding SHALL be declared in the tracked configuration file.

#### Scenario: The key focuses an agent

- **WHEN** the prefix is pressed followed by `shift` and a digit naming an agent present in the panel
- **THEN** the pane running that agent SHALL take focus
- **AND** the workspace and tab holding it SHALL become active if they were not already

#### Scenario: A digit with no agent behind it

- **WHEN** the prefix is pressed followed by `shift` and a digit higher than the number of agents in the panel
- **THEN** focus SHALL NOT move

#### Scenario: The numbers follow the panel's order

- **WHEN** the agent panel's order changes because an agent's state changed
- **THEN** the digits SHALL address the new order rather than the order at the time the session started
- **AND** the digit for a given agent MAY therefore differ between one press and the next

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `focus_agent` across the digits 1 to 9

### Requirement: The other numbered keys are unaffected

Adding the agent family SHALL NOT change what the unmodified digits do, and SHALL NOT change how a workspace is selected. The prefix followed by a bare digit SHALL continue to switch tabs, and selecting a workspace by number through the workspace list SHALL continue to work as it does today.

#### Scenario: A bare digit still switches tab

- **WHEN** the prefix is pressed followed by a digit with no modifier
- **THEN** the tab at that position SHALL become active
- **AND** the focused agent SHALL NOT change as a side effect

#### Scenario: The workspace list is untouched

- **WHEN** the workspace list is opened from the prefix and a digit is pressed
- **THEN** the workspace at that position SHALL become active, as before this change

### Requirement: The indexed binding survives a restore and a reload

The binding SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the numbered agent keys SHALL work with no further setup

#### Scenario: The binding applies without restarting

- **WHEN** the binding is added and herdr is asked to reload its configuration
- **THEN** the keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload

### Requirement: The tab row is hidden while a workspace holds one tab

A workspace showing exactly one tab SHALL NOT draw the tab row, and the line it occupied SHALL go to the panes below it. The row SHALL return as soon as the workspace holds a second tab, so the row is drawn exactly when it has something to distinguish. The setting SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: One tab draws no row

- **WHEN** a workspace holding exactly one tab is displayed
- **THEN** no tab row SHALL be drawn
- **AND** the line it would have occupied SHALL be part of the pane area

#### Scenario: A second tab brings the row back

- **WHEN** a second tab is created in that workspace
- **THEN** the tab row SHALL be drawn
- **AND** it SHALL list both tabs

#### Scenario: Closing back down to one tab hides it again

- **WHEN** a workspace holding two tabs is reduced to one
- **THEN** the tab row SHALL stop being drawn
- **AND** the remaining tab SHALL keep its panes and their running processes

#### Scenario: The setting is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its `[ui]` section SHALL hide the tab row when a workspace has a single tab

### Requirement: Tab actions work while the row is hidden

Hiding the row SHALL NOT disable or rebind any tab action. Creating, renaming, switching, moving, and closing a tab SHALL work from the same keys as before, whether or not the row is drawn.

#### Scenario: A tab is created with the row hidden

- **WHEN** the new-tab key is pressed in a workspace showing one tab and no row
- **THEN** a second tab SHALL be created and focused
- **AND** the row SHALL appear listing both tabs

#### Scenario: Switching by number is unaffected

- **WHEN** the prefix is pressed followed by a bare digit
- **THEN** the tab at that position SHALL become active, as before this change

### Requirement: The tab row setting survives a restore and a reload

The setting SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine hides the row

- **WHEN** this repository is checked out into a fresh home directory and herdr starts with a single tab
- **THEN** no tab row SHALL be drawn, with no further setup

#### Scenario: The setting applies without restarting

- **WHEN** the setting is added and herdr is asked to reload its configuration
- **THEN** the row SHALL disappear in the running server
- **AND** open sessions SHALL survive the reload

### Requirement: A new tab is created with prefix+t

The prefix followed by `t` SHALL create a tab in the active workspace. The action SHALL be the one herdr's shipped `prefix+c` performed — the same tab, created the same way — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key creates a tab

- **WHEN** the prefix is pressed followed by `t`
- **THEN** a tab SHALL be created in the active workspace
- **AND** it SHALL become the focused tab

#### Scenario: The shipped key no longer creates a tab

- **WHEN** the prefix is pressed followed by `c`
- **THEN** a tab SHALL NOT be created

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `new_tab` to `prefix+t`

### Requirement: A new workspace is created with prefix+c

The prefix followed by `c` SHALL create a workspace and focus it. The action SHALL be the one herdr's shipped `prefix+shift+n` performed, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key creates a workspace

- **WHEN** the prefix is pressed followed by `c`
- **THEN** a workspace SHALL be created
- **AND** it SHALL become the active workspace

#### Scenario: The shipped chord is left unbound

- **WHEN** the prefix is pressed followed by `shift` and `n`
- **THEN** a workspace SHALL NOT be created
- **AND** no other action SHALL run in its place

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `new_workspace` to `prefix+c`

### Requirement: The other tab and workspace keys are unaffected

Moving the two creation keys SHALL NOT change any other tab or workspace action. Moving between tabs, renaming, and closing SHALL keep the keys they have, and `prefix+n` SHALL continue to move to the next tab rather than creating anything.

#### Scenario: Moving between tabs is untouched

- **WHEN** the prefix is pressed followed by `n` or by `p`
- **THEN** focus SHALL move to the next or the previous tab, as before this change
- **AND** no tab or workspace SHALL be created

#### Scenario: A bare digit still switches tab

- **WHEN** the prefix is pressed followed by a digit
- **THEN** the tab at that position SHALL become active, as before this change

#### Scenario: No custom command block is disturbed

- **WHEN** the prefix is pressed followed by `\`, `e`, `=`, or `+`
- **THEN** the same action SHALL run as ran before this change
- **AND** no `[[keys.command]]` block SHALL have had its `key` value changed

### Requirement: The creation keys survive a restore and a reload

Both bindings SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `t` SHALL create a tab and the prefix followed by `c` SHALL create a workspace, with no further setup

#### Scenario: The bindings apply without restarting

- **WHEN** the bindings are added and herdr is asked to reload its configuration
- **THEN** both keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload

### Requirement: The focused pane is closed with prefix+q

The prefix followed by `q` SHALL close the focused pane. The action SHALL be the one herdr's shipped `prefix+x` performed — the pane and the process it runs are ended, and the remaining panes take its space — and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key closes the focused pane

- **WHEN** the prefix is pressed followed by `q` in a tab holding more than one pane
- **THEN** the focused pane SHALL be closed
- **AND** the surviving panes SHALL take its space
- **AND** focus SHALL move to one of them

#### Scenario: The key does not detach

- **WHEN** the prefix is pressed followed by `q`
- **THEN** the session SHALL NOT detach
- **AND** the terminal SHALL still be showing herdr afterwards

#### Scenario: The shipped key no longer closes a pane

- **WHEN** the prefix is pressed followed by `x`
- **THEN** no pane SHALL be closed

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `close_pane` to `prefix+q`

### Requirement: The active workspace is closed with prefix+d

The prefix followed by `d` SHALL close the active workspace, after asking for confirmation. The action SHALL be the one herdr's shipped `prefix+shift+d` performed, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key closes the active workspace

- **WHEN** the prefix is pressed followed by `d` and the confirmation is accepted
- **THEN** the active workspace SHALL be closed with its tabs and panes
- **AND** another workspace SHALL become active

#### Scenario: The confirmation still guards it

- **WHEN** the prefix is pressed followed by `d`
- **THEN** a confirmation SHALL be asked for before anything is closed
- **AND** declining it SHALL leave the workspace, its tabs, and its panes intact

#### Scenario: The shipped chord detaches instead of closing

- **WHEN** the prefix is pressed followed by `shift` and `d`
- **THEN** no workspace SHALL be closed
- **AND** the session SHALL detach

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `close_workspace` to `prefix+d`

### Requirement: The active tab is closed with prefix+shift+q

The prefix followed by `shift` and `q` SHALL close the active tab with the panes in it. The action SHALL be the one herdr's shipped `prefix+shift+x` performed, and its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key closes the active tab

- **WHEN** the prefix is pressed followed by `shift` and `q` in a workspace holding more than one tab
- **THEN** the active tab SHALL be closed with its panes
- **AND** another tab of that workspace SHALL become active

#### Scenario: The shipped chord no longer closes a tab

- **WHEN** the prefix is pressed followed by `shift` and `x`
- **THEN** no tab SHALL be closed

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `close_tab` to `prefix+shift+q`

### Requirement: The session is detached with prefix+shift+d

The prefix followed by `shift` and `d` SHALL detach the session, leaving it running for a later attach. Its binding SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The key detaches

- **WHEN** the prefix is pressed followed by `shift` and `d`
- **THEN** the session SHALL detach
- **AND** the shell that launched herdr SHALL be shown

#### Scenario: The detached session survives

- **WHEN** the session is reattached after such a detach
- **THEN** its workspaces, tabs, and panes SHALL be as they were
- **AND** the processes running in them SHALL still be running

#### Scenario: The binding is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its keys section SHALL bind `detach` to `prefix+shift+d`

### Requirement: Moving between tabs is unaffected

Moving the closing and detach keys SHALL NOT change how focus moves between tabs. Every tab navigation key SHALL keep the key it has.

#### Scenario: Moving between tabs is untouched

- **WHEN** the prefix is pressed followed by `n`, by `p`, or by a digit
- **THEN** focus SHALL move to the next tab, the previous tab, or the tab at that position, as before this change

#### Scenario: No custom command block is disturbed

- **WHEN** the prefix is pressed followed by `\`, `e`, `=`, or `+`
- **THEN** the same action SHALL run as ran before this change
- **AND** no `[[keys.command]]` block SHALL have had its `key` value changed

### Requirement: The closing keys survive a restore and a reload

All four bindings SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine has the keys

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the prefix followed by `q` SHALL close the focused pane, `shift` and `q` the active tab, `d` the active workspace, and `shift` and `d` SHALL detach, with no further setup

#### Scenario: The bindings apply without restarting

- **WHEN** the bindings are added and herdr is asked to reload its configuration
- **THEN** all four keys SHALL work in the running server
- **AND** open sessions SHALL survive the reload

### Requirement: Creating a tab does not ask for a name

Creating a tab SHALL NOT open a name prompt. The prefixed new-tab key SHALL create the tab and focus it in one keystroke, and herdr SHALL name the new tab itself. The setting SHALL be declared in the tracked configuration file so it reaches every machine.

#### Scenario: The new-tab key creates a tab directly

- **WHEN** the prefix is pressed followed by `t`
- **THEN** a new tab SHALL be created immediately
- **AND** no name prompt SHALL be shown
- **AND** the new tab SHALL take focus with its shell ready for input

#### Scenario: The new tab carries a name it was given

- **WHEN** a tab is created without a prompt in a workspace that already holds a tab
- **THEN** the tab row SHALL list the new tab with the name herdr assigned it
- **AND** that name SHALL NOT be empty

#### Scenario: The setting is tracked

- **WHEN** the tracked herdr configuration file is read
- **THEN** its `[ui]` section SHALL disable the new-tab name prompt

### Requirement: A tab can still be renamed afterwards

Removing the prompt SHALL NOT remove the ability to name a tab. Renaming SHALL stay available through the same means it is available today, so a name is a later choice rather than a required one.

#### Scenario: A tab is renamed after creation

- **WHEN** a tab created without a prompt is renamed
- **THEN** the tab row SHALL show the new name
- **AND** the name SHALL survive for the life of the tab

### Requirement: Workspace creation keeps its prompt

This change SHALL apply to tabs only. Creating a workspace SHALL continue to ask for a name exactly as it does today, and the configuration SHALL NOT disable that prompt.

#### Scenario: The workspace key still prompts

- **WHEN** the prefix is pressed followed by `c`
- **THEN** the workspace name prompt SHALL be shown, as before this change

### Requirement: The tab prompt setting survives a restore and a reload

The setting SHALL come from the tracked configuration file rather than from a machine-local edit, and SHALL take effect in a running server when herdr is asked to reload its configuration.

#### Scenario: A restored machine creates tabs without a prompt

- **WHEN** this repository is checked out into a fresh home directory and herdr starts
- **THEN** the new-tab key SHALL create a tab with no prompt and no further setup

#### Scenario: The setting applies without restarting

- **WHEN** the setting is added and herdr is asked to reload its configuration
- **THEN** tab creation in the running server SHALL stop prompting
- **AND** open sessions SHALL survive the reload
