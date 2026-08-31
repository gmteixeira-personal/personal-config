## Purpose

Defines what the interactive fish command line's keys do: which editing mode the shell starts in, which actions this configuration binds on top of that mode's own keys, and what it means for such a binding to actually be in effect at a prompt rather than merely to have been issued during start-up.

## ADDED Requirements

### Requirement: One key accepts the autosuggestion and runs it

A single keystroke SHALL accept the autosuggestion fish is offering and run the resulting command line, without the user first accepting the suggestion and then pressing Enter. That keystroke SHALL be Ctrl+Enter wherever the terminal reports Ctrl+Enter as a key distinct from Enter. Where the terminal does not, a documented alternative keystroke SHALL perform the same action, so the capability is never absent — only reached by a different key.

#### Scenario: A pending suggestion is accepted and run

- **WHEN** the command line holds a prefix, fish is showing an autosuggestion for the rest of it, and the accept-and-run key is pressed
- **THEN** the suggested text SHALL be appended to the command line
- **AND** the resulting full command line SHALL be run
- **AND** the command that runs SHALL be the one that was displayed, not the prefix alone

#### Scenario: No suggestion is pending

- **WHEN** the command line holds text for which fish is offering no autosuggestion, and the accept-and-run key is pressed
- **THEN** the command line SHALL be run exactly as typed
- **AND** no text SHALL be appended to it

#### Scenario: The key works in both editing modes

- **WHEN** the accept-and-run key is pressed while the shell is in vi insert mode, and again while it is in vi normal mode
- **THEN** it SHALL perform the same accept-and-run action in both

### Requirement: The binding is in effect at the prompt

A binding this configuration declares SHALL be the one that acts when its key is pressed at a real prompt, after every start-up file and every plugin has finished loading. Issuing a binding during start-up SHALL NOT be treated as evidence that it is in effect: a binding that another component later replaces is absent, whatever the configuration says.

#### Scenario: The declared action is what the key resolves to

- **WHEN** an interactive shell has finished starting and the bindings in effect are inspected
- **THEN** the accept-and-run key SHALL report this configuration's action
- **AND** it SHALL NOT report an action installed by the prompt plugin or by any other component

#### Scenario: A key claimed by another component is not relied upon

- **WHEN** this configuration binds an action to a key
- **THEN** that key SHALL NOT be one the prompt plugin also binds
- **AND** where the two would collide, this configuration SHALL move its action to a key that does not

### Requirement: A command run from the key collapses its prompt

Running a command through the accept-and-run key SHALL leave the same scrollback behind as running it with Enter. The prompt above a finished command SHALL be collapsed to its transient form, so that a scrollback of finished commands is uniform regardless of which key ran each one.

#### Scenario: Scrollback is uniform across both keys

- **WHEN** one command is run with Enter and the next with the accept-and-run key
- **THEN** the prompt left above each finished command SHALL be in the same collapsed form
- **AND** neither SHALL leave a full-height prompt among collapsed ones

### Requirement: Bindings survive the editing mode being reinstalled

The bindings this configuration adds SHALL still be in effect after fish reinstalls its binding set, which it does whenever the editing mode is applied or reapplied. A binding SHALL NOT be lost by the user or a script switching editing modes during a session.

#### Scenario: Switching editing mode preserves the bindings

- **WHEN** the vi binding set is applied again in a running shell
- **THEN** every binding this configuration declares SHALL still be in effect afterwards

### Requirement: The bindings keep working across plugin updates

The accept-and-run behavior SHALL survive an update or reinstall of the prompt plugin. It SHALL NOT depend on an edit to any file that a plugin manager owns and rewrites, because such an edit is reverted silently and the loss shows up only as a key that has stopped working.

#### Scenario: The prompt plugin is reinstalled

- **WHEN** the prompt plugin is updated or reinstalled by the plugin manager
- **THEN** the accept-and-run key SHALL still perform its action
- **AND** no file the plugin manager owns SHALL have needed editing to achieve that
