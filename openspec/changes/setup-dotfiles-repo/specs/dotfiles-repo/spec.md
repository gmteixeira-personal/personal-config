## Purpose

Makes `$HOME` itself a git repository published to a personal remote, so one configuration can be carried to every environment, with a staging discipline and a commit-time safety check that keep the repository free of secrets.

## ADDED Requirements

### Requirement: Repository rooted at the home directory

The home directory SHALL be a git repository whose default branch is `main` and whose `origin` remote is `https://github.com/gmteixeira-personal/personal-config`.

#### Scenario: Repository identity

- **WHEN** `git rev-parse --show-toplevel` runs from the home directory
- **THEN** it SHALL print the home directory path

#### Scenario: Branch and remote

- **WHEN** the repository is inspected after setup
- **THEN** the current branch SHALL be `main`
- **AND** `git remote get-url origin` SHALL print `https://github.com/gmteixeira-personal/personal-config`

### Requirement: Explicit staging only

Content SHALL enter the repository only by naming a path. Recursive whole-tree staging SHALL NOT be used to add content.

#### Scenario: Paths are staged by name

- **WHEN** a configuration file is to be tracked
- **THEN** it SHALL be staged by an `add` naming that path
- **AND** `git add -A`, `git add .`, and `git add -u` SHALL NOT be used to introduce it

#### Scenario: Force-add is a deliberate exception

- **WHEN** a path must be tracked despite matching an ignore rule
- **THEN** it SHALL require an explicit force-add
- **AND** it SHALL NOT be force-added if the matching rule is a security denylist rule

### Requirement: Initial tracked set

The first commit SHALL track exactly the following, and nothing else: the root ignore file; the shell configuration `.bashrc`, `.profile`, `.bash_logout`; `.config/lazygit/config.yml`; `.config/gh/config.yml`; the Claude Code configuration `.claude/settings.json`, `.claude/commands/`, `.claude/skills/`, `.claude/statusline-command.sh`; the Neovim configuration under `.config/nvim/`; and the OpenSpec workspace under `openspec/`.

#### Scenario: Tracked set matches the declared list

- **WHEN** `git ls-files` runs after the first commit
- **THEN** every listed path SHALL belong to the declared set
- **AND** no path outside the declared set SHALL appear

#### Scenario: Allowlisted-but-absent paths are tolerated

- **WHEN** an allowlist entry names a path that does not yet exist, such as `.claude/agents/` or `.claude/hooks/`
- **THEN** setup SHALL succeed with no error
- **AND** that path SHALL become trackable when it is later created

### Requirement: Plugins are declared, not vendored

Claude Code plugins SHALL be reproduced on a new environment from the declaration in `.claude/settings.json`, not from committed plugin files. The declaration SHALL name every marketplace a listed plugin comes from.

#### Scenario: Declaration is complete

- **WHEN** `.claude/settings.json` is inspected
- **THEN** every marketplace referenced by an entry in `enabledPlugins` SHALL either be resolvable as a built-in marketplace or appear in `extraKnownMarketplaces` with its source

#### Scenario: Plugin install state is not committed

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.claude/plugins/` SHALL appear

#### Scenario: Plugins are restored on a new environment

- **WHEN** the repository is cloned into a fresh environment and Claude Code is started
- **THEN** the plugins enabled in `enabledPlugins` SHALL be fetched and installed from their declared marketplaces without any manual install step

### Requirement: Tracked content carries no confidential material

Because the remote is public, tracked files SHALL NOT contain credentials, private repository or host identifiers, internal organizational policy, or personal identifiers beyond the git authorship email.

#### Scenario: Machine-specific git configuration is not tracked

- **WHEN** `git ls-files` is inspected
- **THEN** `.gitconfig` SHALL NOT appear, since identity and credential helpers differ per machine and per user

#### Scenario: Auto-mode environment context is not published

- **WHEN** `.claude/settings.json` is staged
- **THEN** it SHALL NOT contain an `autoMode` key
- **AND** auto mode SHALL fall back to its shipped default environment

#### Scenario: Commit identity is set per repository

- **WHEN** a commit is made in this repository
- **THEN** the author identity SHALL come from repository-local configuration, not from a tracked file
- **AND** setting it SHALL be a documented step for each new clone

#### Scenario: Telemetry identifiers are not published

- **WHEN** any tracked file is inspected for a per-install or per-machine identifier
- **THEN** none SHALL be found, including telemetry `anonymousId`, machine ids, and install ids

#### Scenario: Reviewed against a public-readership assumption

- **WHEN** any file is considered for tracking
- **THEN** the question asked SHALL be whether its content is acceptable to publish, not merely whether it is a secret

### Requirement: Commit-time secret guard

A commit SHALL be rejected when its staged set contains a path matched by the security denylist or content that looks like a private key or credential.

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

### Requirement: Pre-push verification

Before the first push to the remote, the full content of every tracked file SHALL be reviewed for secrets, and the push SHALL NOT proceed while any is found.

#### Scenario: Content review precedes the first push

- **WHEN** the first commit exists and has not been pushed
- **THEN** the content of every path in `git ls-files` SHALL be inspected for keys, tokens, passwords, and personal identifiers
- **AND** the push SHALL be withheld until the review is clean

#### Scenario: Public repository assumption

- **WHEN** deciding whether a path may be tracked
- **THEN** the decision SHALL assume the remote is publicly readable

### Requirement: Bootstrap into a new environment

The repository SHALL be adoptable by a fresh home directory that already contains conflicting files, without those files being silently overwritten.

#### Scenario: Adopting a non-empty home directory

- **WHEN** the repository is brought into a home directory that already contains files with the same names as tracked files
- **THEN** the procedure SHALL surface the conflicting paths before any file is overwritten
- **AND** the existing content SHALL be preserved or explicitly replaced by choice, never lost without notice

#### Scenario: Documented bootstrap procedure

- **WHEN** a new environment is set up
- **THEN** a tracked document SHALL describe the steps to obtain the repository, install the commit guard, and resolve conflicts
