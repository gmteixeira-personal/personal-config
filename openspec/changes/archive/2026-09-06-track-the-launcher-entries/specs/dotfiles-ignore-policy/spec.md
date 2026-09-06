## ADDED Requirements

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

## MODIFIED Requirements

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
