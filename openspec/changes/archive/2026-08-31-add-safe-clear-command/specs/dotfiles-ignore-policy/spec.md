## MODIFIED Requirements

### Requirement: Bulk and machine-local trees are excluded

Caches, package stores, language toolchains, editor server state, Claude Code session data, and assistant-written scratch that describes one session's in-flight state SHALL be ignored so the repository stays small and portable across environments.

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

#### Scenario: Handoff notes are ignored by a named rule

- **WHEN** `.claude/handoff/` is checked
- **THEN** it SHALL be ignored
- **AND** `git check-ignore -v` on a file beneath it SHALL report a rule naming that directory, rather than the deny-by-default catch-all
- **AND** `git ls-files` SHALL list no path beneath it
