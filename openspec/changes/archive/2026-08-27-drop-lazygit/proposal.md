## Why

lazygit is no longer part of this workflow, and it left three traces behind: a tracked `.config/lazygit/config.yml`, the block 3 allowlist entry that made it trackable, and — on any machine that had it — an installed binary with its own state and cache directories.

Leaving those in place is not neutral. A tracked config file is a standing instruction to every future environment that this tool belongs there, and the allowlist entry re-creates the file's eligibility even after the file itself is gone. Neither is visible from the tool's absence: nothing in the repository says lazygit was withdrawn rather than merely uninstalled on one machine.

The reason is that the tool is no longer used here. It is worth being precise about that, because a retirement with no reason attached invites the assumption that something was wrong with the software: lazygit is actively maintained — releases and commits are current — and this is a change of workflow, not a verdict on it.

The work this change records is already done in `8088603`. What is missing is the statement of intent that keeps it done.

## What Changes

- Stop tracking `.config/lazygit/config.yml` and remove the directory it lived in.
- Remove the block 3 allowlist exception that named it, so the path returns to the deny-by-default state the ignore policy gives every unnamed path.
- State that the tool is retired: no package installed, no configuration directory, and no leftover state or cache directory on a machine this repository is deployed to.

## Capabilities

### Modified Capabilities

<!-- None. -->

### New Capabilities

- `retired-tooling`: records a tool that has been withdrawn from this configuration and what must be absent for it, so a retired tool cannot return quietly through a stale config file, an allowlist entry, or a leftover state directory.

## Impact

- `.config/lazygit/config.yml` is deleted and untracked; `.gitignore` loses one line from block 3.
- No capability loses a feature. The git work lazygit did is served by the Neovim plugins already configured — neogit, diffview and gitsigns — and by the `/git:*` command suite.
- The `dotfiles-repo` spec's "Initial tracked set" requirement still names `.config/lazygit/config.yml` and is deliberately left alone: it describes what the first commit tracked, which remains true. The tracked set as it stands today is described by the allowlist itself, not by that requirement.
- Nothing needs uninstalling on the current machine — the package was never installed here. The requirement is written so a machine that does have it is not left in a half-retired state.
