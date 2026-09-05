## Purpose

Defines how a machine running this configuration authenticates to a git forge when different repositories on it belong to different accounts, and what must be written down because the files that carry the answer are denylisted, so that a fresh machine can push rather than only commit.

## ADDED Requirements

### Requirement: The bootstrap reaches a repository that can push

The tracked bootstrap procedure SHALL carry the reader as far as a working push, not only a working commit.

A bootstrap that stops at the first successful commit leaves the reader with a failure that arrives later and explains nothing: git asks for a username on a remote that has no credential helper, which reads as a missing password rather than as a protocol that was never going to be used.

#### Scenario: The procedure covers authentication

- **WHEN** the bootstrap procedure is read
- **THEN** it SHALL describe how the machine authenticates to the forge in order to push
- **AND** that step SHALL come after identity is set

#### Scenario: Cloning precedes having keys

- **WHEN** the procedure is followed on a machine with no keys yet
- **THEN** the clone step SHALL work without them
- **AND** the procedure SHALL say when and why the remote is moved afterwards

### Requirement: Each account has its own alias and key

Where a machine carries more than one account on the same forge, each account SHALL have its own SSH host alias and its own key, and a repository's remote SHALL be written against the alias rather than against the forge's host name.

Two accounts on one host cannot be told apart by the host name, which is all a remote URL carries. The alias is what makes the URL itself say which identity to use, so that no repository depends on which key happened to be offered first.

#### Scenario: A second account is reachable

- **WHEN** a repository belongs to an account other than the machine's default
- **THEN** its remote SHALL name that account's host alias
- **AND** the alias SHALL be configured with that account's key

#### Scenario: The default account needs no alias

- **WHEN** a repository belongs to the account the default key authenticates as
- **THEN** its remote MAY name the forge host directly

### Requirement: No credential helper answers for every repository

A credential helper SHALL NOT be configured globally on a machine carrying more than one account for the same forge.

A global helper is asked for credentials by host, and the host is the same for every account. It would therefore answer with one account's credentials for repositories belonging to another, and would do so silently and successfully, which is worse than failing.

#### Scenario: No global helper is configured

- **WHEN** the machine's global git configuration is inspected
- **THEN** no credential helper SHALL be configured in it

#### Scenario: Authentication is per remote

- **WHEN** a repository authenticates to the forge
- **THEN** the identity used SHALL be determined by that repository's own remote

### Requirement: Untrackable authentication configuration is documented instead

Where the files that configure forge authentication cannot be tracked, the tracked documentation SHALL describe what those files must contain, so the arrangement can be rebuilt by hand.

The alias definitions live in the SSH client configuration and the remote lives in the repository's own git directory. Both are correctly excluded — one sits with private keys, the other is per-clone — so documentation is not a fallback here, it is the only available carrier. Without it the convention exists on exactly one machine and is lost with it.

#### Scenario: The alias convention is written down

- **WHEN** the tracked documentation is read on a machine with no SSH configuration
- **THEN** it SHALL describe the host alias entries that have to be created
- **AND** it SHALL state that the file holding them is deliberately not tracked

#### Scenario: No key material is carried

- **WHEN** the repository is inspected
- **THEN** no private key, no public key and no SSH client configuration SHALL be tracked
