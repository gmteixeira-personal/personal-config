## Purpose

Defines the ignore contract for a git repository rooted at `$HOME`: nothing is tracked unless it is named explicitly, and a security denylist overrides every allowlist entry so that secrets cannot reach a public remote even by mistake.

## Requirements

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

Caches, package stores, language toolchains, editor server state, Claude Code session data, and assistant-written scratch that describes one session's in-flight state SHALL be ignored so the repository stays small and portable across environments.

A tree on this list MAY carry a carve-out for a path that cannot be tracked any other way. Where it does, everything the carve-out does not name SHALL still be ignored, and the tree SHALL still be excluded for every purpose except reaching those paths.

#### Scenario: Cache and toolchain directories are ignored

- **WHEN** any of `.cache/`, `.npm/`, `.nuget/`, `.cargo/`, `.dotnet/`, `.nvm/`, `.vscode-server/`, `.ServiceHub/`, `.aspnet/`, or `.templateengine/` is checked
- **THEN** each SHALL be ignored

#### Scenario: A bulk tree carrying a carve-out still ignores the rest of itself

- **WHEN** a bulk-ignored tree carries a carve-out for one or more named paths
- **THEN** every other path beneath that tree SHALL be ignored
- **AND** a directory beneath it that the carve-out does not open SHALL be ignored

#### Scenario: Ignored bulk directories are not traversed

- **WHEN** `git status` runs at the repository root
- **THEN** it SHALL complete without descending into the ignored bulk directories, except into those directories a carve-out opens in order to reach a named path
- **AND** it SHALL return within a few seconds despite those directories holding multiple gigabytes

#### Scenario: Claude Code session data is ignored

- **WHEN** `.claude/projects/`, `.claude/sessions/`, `.claude/history.jsonl`, `.claude/shell-snapshots/`, `.claude/file-history/`, or `.claude/paste-cache/` is checked
- **THEN** each SHALL be ignored

#### Scenario: Handoff notes are ignored by a named rule

- **WHEN** `.claude/handoff/` is checked
- **THEN** it SHALL be ignored
- **AND** `git check-ignore -v` on a file beneath it SHALL report a rule naming that directory, rather than the deny-by-default catch-all
- **AND** `git ls-files` SHALL list no path beneath it

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

### Requirement: Ignore rules are verifiable

Each ignore decision SHALL be attributable to a single named rule, so that any path can be audited without reasoning about the whole file.

#### Scenario: Rule attribution for an ignored path

- **WHEN** `git check-ignore -v <path>` is run for any ignored path
- **THEN** it SHALL print the ignore file, the line number, and the pattern responsible

### Requirement: A carve-out inside a bulk tree is narrow and named

Where a path must be tracked from inside a tree the bulk list excludes, the ignore file MAY carry a carve-out re-including it. Such a carve-out SHALL narrow the bulk half of the denylist only, SHALL NOT weaken any security rule, and SHALL re-include only paths it names.

Reaching a path inside an excluded tree SHALL be done by re-including each ancestor directory and immediately re-excluding that directory's contents, so that opening a tree to reach one file does not make the rest of it traversable.

A carve-out SHALL exist only for a path that cannot be moved somewhere the ordinary allowlist already reaches, and the ignore file SHALL record which of those two cases each carve-out is.

Without this the policy has no answer for a file that must live at a path a specification fixes. The allowlist cannot reach it — git does not consult a re-inclusion for a file whose parent directory is excluded, so such an entry is not outranked but unread — and the alternative is leaving the file untracked, which means a clone that is missing something and does not say so.

The narrowness is the whole of the safety. A tree is on the bulk list because it is large, machine-local, or both, and the tree this exists for holds gigabytes of package state and a keyring directory beside the twenty kilobytes wanted from it. Re-including the tree and relying on the allowlist below to be the only matches would trade a stated size rule for an unstated one.

#### Scenario: A carve-out reaches its file

- **WHEN** a file inside a bulk-excluded tree is named by a carve-out
- **THEN** it SHALL be trackable
- **AND** `git check-ignore -v` on it SHALL report no matching ignore rule

#### Scenario: A carve-out opens nothing it did not name

- **WHEN** a file sits beside one a carve-out names, in the same directory
- **THEN** it SHALL remain ignored

#### Scenario: The rest of the tree is still not traversed

- **WHEN** `git status` runs at the repository root and a bulk tree carries a carve-out
- **THEN** git SHALL NOT descend into the parts of that tree the carve-out does not open
- **AND** the command SHALL still return within a few seconds

#### Scenario: A carve-out does not reach a secret

- **WHEN** a path matched by a security rule sits inside a tree a carve-out opens
- **THEN** it SHALL remain ignored
- **AND** `git check-ignore -v` on it SHALL report the security rule
