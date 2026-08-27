## ADDED Requirements

### Requirement: Deleting an entry removes it permanently

Deleting an entry through the explorer SHALL remove it from disk. It SHALL NOT be moved to a trash or any other holding area the user could restore it from, and the editor SHALL offer no undo for it once the write has run.

The confirmation shown before a destructive write is therefore the last point at which a deletion can be stopped, and SHALL NOT be presented as though the operation were reversible.

Sending deletions to a trash instead SHALL remain a deliberate configuration change rather than something that could be arrived at by leaving a default alone.

#### Scenario: A deleted file is gone

- **WHEN** the user deletes an entry in the listing and writes the buffer
- **AND** confirms the operation
- **THEN** the file is removed from disk
- **AND** it is not recoverable from a trash or from within the editor

#### Scenario: The confirmation is the last check

- **WHEN** a pending write includes a deletion
- **AND** the user declines the confirmation
- **THEN** nothing is deleted
- **AND** the filesystem is unchanged
