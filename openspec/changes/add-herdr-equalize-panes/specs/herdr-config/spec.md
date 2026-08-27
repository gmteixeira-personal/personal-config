## MODIFIED Requirements

### Requirement: herdr runtime state is never tracked

Everything in herdr's configuration directory other than the configuration file and the plugin lock SHALL remain ignored. That state is machine-local, is recreated on demand, and in the case of the sockets is not a regular file at all. The plugin lock is excepted because it records which plugins a machine is meant to have rather than the state of a running herdr, and tracking it is what carries the plugin set to the next machine.

#### Scenario: Runtime state stays ignored

- **WHEN** the client and server sockets, the log files, and the session record in that directory are checked
- **THEN** each SHALL be reported as ignored

#### Scenario: The plugin lock is tracked

- **WHEN** `.config/herdr/.plugins.lock` is checked
- **THEN** it SHALL NOT be reported as ignored
- **AND** it SHALL appear in `git ls-files`

#### Scenario: Only the configuration file is offered

- **WHEN** `git status` lists untracked files with the directory populated by a running herdr
- **THEN** the only paths from that directory it may list SHALL be the configuration file and the plugin lock
