## ADDED Requirements

### Requirement: The menus are reproducible from tracked configuration

Every file the radio menus need in order to be reachable and to run SHALL be tracked, and no tracked file among them SHALL name the home directory of the machine it was written on.

The menus are three kinds of file, not one: the scripts, the launcher entries that make the scripts findable, and the icons those entries name. Tracking only the scripts produces a clone where the interface exists and nothing opens it — which is not a partial installation but an absent one, since the entries are the whole of how a user reaches them.

The home directory is the second half of the same property. A launcher entry names its program in a field that has no way to say "this user's home", so the choice is between an absolute path that is wrong on any other machine and a bare command name resolved on `PATH`. The bare name is what makes the entry portable; a path is what makes tracking it pointless.

#### Scenario: A clone has working menus

- **WHEN** the repository is cloned into a home directory with a different name and the session is started
- **THEN** the radio menus SHALL be reachable from the launcher
- **AND** no file SHALL have to be recreated by hand for that to hold

#### Scenario: No tracked file names this machine

- **WHEN** the tracked files that make up the radio menus are inspected for an absolute path naming a home directory
- **THEN** none SHALL contain one

#### Scenario: The bar and the launcher name the same command

- **WHEN** the bar's click handler and the launcher's entry for a radio menu are compared
- **THEN** both SHALL name the same command
- **AND** neither SHALL name it by absolute path
