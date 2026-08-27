## Context

See proposal.md — Why. The constraints that shape where this is recorded:

- The ignore file denies by default. A tool's configuration is trackable only while a block 3 allowlist entry names it, so removing that entry is what actually retires the path — deleting the file alone leaves it eligible to return.
- `dotfiles-repo` already has an "Initial tracked set" requirement that names `.config/lazygit/config.yml`. It is scoped to the first commit and is still true; it is not a live inventory, and it did not gain `.config/caveman/config.json` when that file was allowlisted later.
- A tool's footprint is larger than its tracked config: a package, a configuration directory, and XDG state and cache directories that no repository ever sees.

## Goals / Non-Goals

**Goals:**

- One place a reader can look to learn that lazygit was withdrawn deliberately, rather than inferring it from an absence.
- A statement that holds on a machine that still has the tool installed, not only on the machine where it never was.

**Non-Goals:**

- Rewriting `dotfiles-repo`'s account of the first commit. That is history, and editing it to match the present would make it a list every future config addition has to maintain.
- Enforcing any of this in the commit guard. The guard exists for secrets; a retired tool is a preference, and a preference that blocks commits is a nuisance.
- Choosing a replacement. Nothing is replacing it.

## Decisions

**A new `retired-tooling` capability, not a modification of `dotfiles-repo`.** The precedent is `set-caveman-default-lite`: it allowlisted `.config/caveman/config.json` and created `caveman-mode-default` rather than amending the tracked-set requirement. Allowlist churn is not itself a capability change, and treating it as one would put every tool config into a single growing list. Alternative considered: a `REMOVED Requirements` entry against `dotfiles-repo`. Rejected — nothing in that spec required lazygit to exist, so there is no requirement to remove; the entry would have to invent one first.

**State machine facts, not only repository facts.** The requirement names the package and the state and cache directories as well as the tracked file. A spec that only said "the config is not tracked" would be satisfied by a machine with lazygit installed and configured, which is the state this change exists to prevent. It also gives a reader a checklist for a machine that has it, which is where the removal work actually is.

**Delete the allowlist entry rather than leave it pointing at nothing.** A block 3 exception naming a file that does not exist is inert today and a trap tomorrow: re-creating the file re-tracks it silently, and the next reader has to work out whether the entry is deliberate. The repository's own documentation makes block 3 the declaration of what is tracked, so an entry with nothing behind it is a false declaration.

**Say why, and say what the reason is not.** A negative requirement with no rationale is read as a warning about the software. The retirement is a workflow change: the project is actively maintained, and the check was made rather than assumed before the reason was written down. Recording the distinction costs a sentence and stops the spec from making a claim about someone else's project that it has no business making.

**Capability name is about retirement, not about lazygit.** `retired-tooling` takes further entries as tools are withdrawn. A per-tool capability would leave a spec directory that says nothing beyond one negative fact.

## Risks / Trade-offs

- **A machine still carrying an installed lazygit** → the requirement names exactly what to remove; nothing detects it automatically, and nothing breaks while it is there.
- **A negative requirement can only be verified, never enforced** → accepted. It is a statement of intent whose audience is the next person to consider adding the tool.
- **Wanting lazygit back later** → the spec says how: a new allowlist entry plus a change that supersedes this requirement, so the return is deliberate and recorded rather than a quiet re-add.
- **A third-party package shipping the tool's name** → `tokyonight.nvim` carries theme-export templates for lazygit inside its own checkout. They are that plugin's files, not configuration for the tool, and deleting them would leave a plugin repository dirty for a plugin update to restore. The requirement excludes them explicitly.
- **Git history still contains the deleted config** → it does, and it is published. The content was two lines of screen-mode preference with nothing sensitive in it, so history is left alone rather than rewritten.
- **Rollback** → restore the file from `8088603^` and re-add the block 3 line.
