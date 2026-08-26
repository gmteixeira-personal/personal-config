## Purpose

Fixes the intensity the caveman response style starts at in a new session, and states where that preference is stored so it survives a plugin reinstall and travels to every environment.

## ADDED Requirements

### Requirement: Sessions start at the lite intensity

A new Claude Code session SHALL start with the caveman style at its `lite` intensity, which keeps articles and full sentences while dropping filler and hedging. The shipped default of `full` SHALL NOT apply.

#### Scenario: A fresh session reports lite

- **WHEN** a new session starts
- **THEN** the caveman activation context SHALL name `lite` as the active level

#### Scenario: A mid-session switch still wins

- **WHEN** the user runs `/caveman <level>` during a session
- **THEN** that level SHALL apply for the rest of the session
- **AND** the next new session SHALL start at `lite` again

### Requirement: The default lives in user configuration

The default intensity SHALL be declared in the user-level caveman configuration file, at `~/.config/caveman/config.json` on this platform, as its `defaultMode` field. It SHALL NOT be set by editing the plugin's installed files.

#### Scenario: Configuration file declares the mode

- **WHEN** the user-level caveman configuration file is read
- **THEN** its `defaultMode` field SHALL be `lite`

#### Scenario: Preference survives a plugin reinstall

- **WHEN** the caveman plugin cache under `.claude/plugins/` is removed and the plugin is reinstalled
- **THEN** the default intensity SHALL still resolve to `lite`
- **AND** no file under the plugin cache SHALL have needed editing

### Requirement: The preference is tracked

The user-level caveman configuration file SHALL be tracked by the home repository, so a new environment starts at the same intensity without the preference being set by hand.

#### Scenario: File is allowlisted

- **WHEN** the root ignore file is inspected
- **THEN** it SHALL carry an explicit allowlist entry for `/.config/caveman/config.json`
- **AND** `git check-ignore -v .config/caveman/config.json` SHALL attribute the path to that entry

#### Scenario: File is committed

- **WHEN** `git ls-files` runs after the change is implemented
- **THEN** `.config/caveman/config.json` SHALL appear

#### Scenario: Derived plugin state stays untracked

- **WHEN** `git ls-files` is inspected
- **THEN** no path under `.claude/plugins/` SHALL appear
- **AND** the session flag files `.claude/.caveman-active` and `.claude/.caveman-nudge-shown` SHALL remain ignored
