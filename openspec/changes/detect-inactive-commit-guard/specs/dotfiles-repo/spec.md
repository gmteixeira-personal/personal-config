## MODIFIED Requirements

### Requirement: Commit-time secret guard

A commit SHALL be rejected when its staged set contains a path matched by the security denylist or content that looks like a private key or credential.

The guard SHALL NOT be able to be inactive silently. Git clones neither hooks nor repository-local configuration, so the guard is switched on by hand in every environment and a missed step leaves a repository where commits succeed exactly as they do with the guard running. Where it is not active, that SHALL be reported to the person at the prompt, along with the action that activates it.

Activity SHALL be judged on whether the guard would actually run, not on whether a configuration key is present: the repository's hooks path names the tracked hooks directory, and the hook in it is executable. Either half failing SHALL be reported the same way, since either half failing has the same effect.

The report SHALL be silent in the active case. A message on a correctly set-up machine would be seen at every prompt and would train its reader to ignore the one that matters.

#### Scenario: Commit rejected on a denylisted staged path

- **WHEN** a commit is attempted with a security-denylisted path staged, whether force-added or otherwise
- **THEN** the commit SHALL be rejected with a non-zero exit status
- **AND** the offending path SHALL be named in the rejection message

#### Scenario: Commit rejected on secret-looking staged content

- **WHEN** staged content contains a private key header, an `ssh-rsa`/`ssh-ed25519` private block, or a recognizable API-token literal
- **THEN** the commit SHALL be rejected and the offending path SHALL be named

#### Scenario: Clean commit proceeds

- **WHEN** a commit is attempted with only allowlisted, non-secret paths staged
- **THEN** the commit SHALL succeed

#### Scenario: Guard survives a fresh clone

- **WHEN** the repository is cloned into a new environment
- **THEN** the guard SHALL be installable from tracked content by a documented step, since git does not clone hooks

#### Scenario: An unconfigured guard is reported

- **WHEN** an interactive shell starts in an environment whose home repository has no hooks path configured
- **THEN** the shell SHALL report that the commit guard is not active
- **AND** the report SHALL name the command that activates it

#### Scenario: A configured but unrunnable guard is reported

- **WHEN** an interactive shell starts in an environment where the hooks path is configured but the hook is missing or not executable
- **THEN** the shell SHALL report it exactly as it reports an unconfigured guard

#### Scenario: An active guard is silent

- **WHEN** an interactive shell starts in an environment where the hooks path names the tracked hooks directory and the hook is executable
- **THEN** the shell SHALL print nothing about the guard

#### Scenario: The report reaches a shell that is not the interactive one

- **WHEN** a shell that is not interactive reads the same configuration
- **THEN** it SHALL print nothing, since a warning there has no reader

#### Scenario: The bootstrap document names the check

- **WHEN** the tracked bootstrap document's guard-activation step is read
- **THEN** it SHALL say that a shell reports the guard being inactive, so the check is discoverable from the step it backs up
