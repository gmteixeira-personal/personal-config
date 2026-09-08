## ADDED Requirements

### Requirement: `cat` and `bat` stay separate names

`cat` and `bat` are both wanted, for different jobs, and SHALL be reachable under their own names. `cat` SHALL print the file and nothing else: this configuration SHALL NOT bind it to `bat` or to any other replacement, and SHALL NOT decorate its output with highlighting, line numbers, git markers, or a pager.

Highlighted output SHALL be obtained by asking for `bat`. The two names mean two different things, and keeping them distinct is what lets either be chosen deliberately — a `cat` that sometimes highlights is surprising where its output is being read as plain text, and a `bat` that has to be reached through a second name is not being used at all.

This is a standing decision, not an absence. The configuration bound `cat` to `bat` once and withdrew it; this requirement records the withdrawal so the binding is not proposed again as though the question were open.

#### Scenario: Printing a source file

- **WHEN** `cat` is given a source file at an interactive prompt
- **THEN** the file's contents SHALL be printed as plain text
- **AND** no highlighting, line number, git marker, or pager SHALL be applied

#### Scenario: `cat` is the real executable

- **WHEN** `cat` is invoked by name in an interactive shell under this configuration
- **THEN** it SHALL resolve to the `cat` executable on `PATH`, not to a shorthand or function of the same name

#### Scenario: Highlighting on request

- **WHEN** highlighted output is wanted at an interactive prompt
- **THEN** `bat` SHALL be available under its own name to provide it

## REMOVED Requirements

### Requirement: `cat` shows highlighted output

**Reason**: The binding it describes was withdrawn in commit `b9343e9` on 2026-09-05, one shell-configuration change after it was added — highlighting was judged not worth the surprise of `cat` printing something other than the file. The requirement was left in place when the code was reverted, so it has described a behavior this configuration does not have ever since.

**Migration**: None for any caller. `cat` already behaves as this removal implies, in both shells, and has since the revert. Anyone who wants the highlighting the removed requirement described runs `bat`, which stays installed and unchanged. The replacement requirement above states the same outcome as a decision rather than as an omission.
