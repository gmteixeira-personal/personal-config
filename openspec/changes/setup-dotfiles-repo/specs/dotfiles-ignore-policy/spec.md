## Purpose

Defines the ignore contract for a git repository rooted at `$HOME`: nothing is tracked unless it is named explicitly, and a security denylist overrides every allowlist entry so that secrets cannot reach a public remote even by mistake.

## ADDED Requirements

### Requirement: Deny by default

The repository SHALL ignore every path by default. A path SHALL become eligible for tracking only through an explicit allowlist entry naming it or naming a directory that contains it.

#### Scenario: Unmentioned new file stays untracked

- **WHEN** a file is created anywhere under the repository root and no allowlist entry names it or an ancestor directory of it
- **THEN** `git status --porcelain` SHALL NOT list it
- **AND** `git check-ignore -v <path>` SHALL report a matching ignore rule

#### Scenario: Repository is empty of surprises at initialization

- **WHEN** the repository is initialized and the ignore file is in place, before any allowlist entry is added
- **THEN** the only path reported as untracked SHALL be the ignore file itself

### Requirement: Non-dot root entries are ignored

Every file and directory directly under the repository root whose name does not begin with `.` SHALL be ignored, unless an allowlist entry names it explicitly as a stated exception.

#### Scenario: Non-dot root directory is ignored

- **WHEN** a directory such as `repos/` exists at the repository root and is not an allowlisted exception
- **THEN** it SHALL be ignored

#### Scenario: Non-dot root file is ignored

- **WHEN** a file such as a loose JSON file at the root exists at the repository root and is not an allowlisted exception
- **THEN** it SHALL be ignored

#### Scenario: Stated exception is tracked

- **WHEN** `openspec/` is named as an explicit allowlist exception
- **THEN** its contents SHALL be trackable despite the non-dot root rule

### Requirement: Explicit allowlist reaches nested paths

The allowlist SHALL be able to re-include a file at any depth, including a file whose parent directories would otherwise be ignored. Re-including a nested file SHALL NOT re-include its sibling files.

#### Scenario: Nested file allowlisted without its siblings

- **WHEN** `.claude/settings.json` is allowlisted and `.claude/.credentials.json` is not
- **THEN** `.claude/settings.json` SHALL be trackable
- **AND** `.claude/.credentials.json` SHALL remain ignored

#### Scenario: Allowlisted directory includes its subtree

- **WHEN** a directory such as `.claude/commands/` is allowlisted
- **THEN** files at any depth beneath it SHALL be trackable unless a denylist rule matches them

### Requirement: Security denylist overrides the allowlist

A security denylist SHALL take precedence over every allowlist entry. A path matched by the denylist SHALL remain ignored regardless of any allowlist entry that also matches it.

#### Scenario: Denylist beats a broader allowlist

- **WHEN** a directory is allowlisted and it contains a file matched by the denylist
- **THEN** that file SHALL remain ignored
- **AND** `git check-ignore -v` on it SHALL report the denylist rule as the matching rule

#### Scenario: Known secret-bearing paths are ignored

- **WHEN** any of `.ssh/`, `.claude/.credentials.json`, `.config/gh/hosts.yml`, `.ghtoken`, `.claude.json`, `.bash_history`, `.psql_history`, or `.viminfo` is checked
- **THEN** each SHALL be ignored

#### Scenario: Secret-shaped paths are ignored by pattern

- **WHEN** a file anywhere in the tree matches a credential pattern — a private key (`id_*` without a `.pub` suffix, `*.pem`, `*.key`, `*.p12`, `*.pfx`), an environment file (`.env`, `.env.*`), a history file (`*_history`, `*.history`), or a named credential store (`*credential*`, `*secret*`, `*token*`, `.netrc`, `.npmrc`, `.pypirc`)
- **THEN** it SHALL be ignored

#### Scenario: Public key counterpart remains allowlistable

- **WHEN** a `.pub` file sits beside a private key matched by the denylist
- **THEN** the `.pub` file SHALL NOT be ignored by the private-key pattern

### Requirement: Bulk and machine-local trees are excluded

Caches, package stores, language toolchains, editor server state, and Claude Code session data SHALL be ignored so the repository stays small and portable across environments.

#### Scenario: Cache and toolchain directories are ignored

- **WHEN** any of `.cache/`, `.npm/`, `.nuget/`, `.cargo/`, `.dotnet/`, `.nvm/`, `.vscode-server/`, `.ServiceHub/`, `.local/`, `.aspnet/`, or `.templateengine/` is checked
- **THEN** each SHALL be ignored

#### Scenario: Ignored bulk directories are not traversed

- **WHEN** `git status` runs at the repository root
- **THEN** it SHALL complete without descending into the ignored bulk directories
- **AND** it SHALL return within a few seconds despite those directories holding multiple gigabytes

#### Scenario: Claude Code session data is ignored

- **WHEN** `.claude/projects/`, `.claude/sessions/`, `.claude/history.jsonl`, `.claude/shell-snapshots/`, `.claude/file-history/`, or `.claude/paste-cache/` is checked
- **THEN** each SHALL be ignored

### Requirement: Derived state is ignored in favour of its declaration

State that a tool reconstructs from a tracked declaration SHALL be ignored. Only the declaration SHALL be tracked.

#### Scenario: Plugin install state is ignored

- **WHEN** `.claude/plugins/` is checked — including `marketplaces/`, `cache/`, `data/`, `installed_plugins.json`, and `known_marketplaces.json`
- **THEN** all of it SHALL be ignored

#### Scenario: Plugin declaration is tracked

- **WHEN** `.claude/settings.json` is checked
- **THEN** it SHALL be trackable, since it carries the `extraKnownMarketplaces` and `enabledPlugins` declaration that `.claude/plugins/` is rebuilt from

#### Scenario: Machine-absolute paths do not enter the repository

- **WHEN** any tracked file is inspected for absolute filesystem paths naming this machine's home directory
- **THEN** none SHALL be found in files that a different environment must reuse verbatim

### Requirement: Ignore rules are verifiable

Each ignore decision SHALL be attributable to a single named rule, so that any path can be audited without reasoning about the whole file.

#### Scenario: Rule attribution for an ignored path

- **WHEN** `git check-ignore -v <path>` is run for any ignored path
- **THEN** it SHALL print the ignore file, the line number, and the pattern responsible
