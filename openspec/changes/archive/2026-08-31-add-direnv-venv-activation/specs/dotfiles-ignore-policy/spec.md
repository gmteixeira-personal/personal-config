## ADDED Requirements

### Requirement: Per-machine approval state is never tracked

State recording that a person approved something on one machine SHALL be ignored, and SHALL NOT be reintroduced by any allowlist entry. Only the thing approved SHALL be trackable.

This is the opposite case to derived state. Derived state is ignored because a tool can rebuild it from a tracked declaration; approval state is ignored because it must not be rebuilt elsewhere. Carrying it to a clone would grant, on that machine, a trust that nobody on that machine gave — and would do so silently, since the point of an approval record is that its absence is what withholds the effect.

#### Scenario: Approval records are ignored

- **WHEN** a directory holding per-machine approval records is checked, such as the directory recording which directory-environment declarations have been approved
- **THEN** it SHALL be ignored
- **AND** `git ls-files` SHALL list no path beneath it

#### Scenario: The approved content is still trackable

- **WHEN** configuration that approvals are granted against is checked, such as a tracked helper that project declarations call
- **THEN** it SHALL be trackable
- **AND** tracking it SHALL NOT cause anything to be treated as approved

#### Scenario: A fresh clone starts unapproved

- **WHEN** the repository is cloned into a new environment
- **THEN** nothing SHALL be approved there by virtue of the clone
- **AND** each approval SHALL have to be granted on that machine
