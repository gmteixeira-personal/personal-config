## MODIFIED Requirements

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
