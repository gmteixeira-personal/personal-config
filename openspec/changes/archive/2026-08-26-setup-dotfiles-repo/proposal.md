## Why

Configuration for this machine (shell, git, nvim, lazygit, gh, Claude Code) lives loose in `$HOME` and is re-created by hand on every new environment. Turning `$HOME` into a git repository backed by `https://github.com/gmteixeira-personal/personal-config` makes one config portable across every environment.

`$HOME` is a hostile directory to version: it also contains SSH private keys, OAuth tokens, shell history, and ~10 GB of tool caches. So the repository cannot be opt-out (`.gitignore` a few bad things); it must be opt-in — nothing is tracked until it is named explicitly, and a security denylist overrides the allowlist unconditionally.

## What Changes

- Initialize a git repository at `/home/gmteixeira` on branch `main`, with `https://github.com/gmteixeira-personal/personal-config` as `origin`.
- Add a root `.gitignore` implementing deny-by-default:
  - everything is ignored (`*`), directories stay traversable so nested allowlist entries can work;
  - every root entry that does not begin with `.` is ignored (`repos/`, a loose JSON file at the root) unless explicitly allowlisted;
  - an explicit allowlist re-includes only named files and directories;
  - a security denylist is placed last, so it wins over any allowlist entry (last-match-wins in gitignore).
- Establish the initial tracked set (each entry added deliberately, not by glob):
  - shell: `.bashrc`, `.profile`, `.bash_logout`
  - git: **not tracked** — `.gitconfig` holds per-machine identity and credential helpers, so it is deliberately excluded
  - editors/tools: `.config/lazygit/config.yml`, `.config/gh/config.yml`
  - Claude Code: `.claude/settings.json`, `.claude/commands/`, `.claude/skills/`, `.claude/statusline-command.sh`, plus `.claude/agents/` and `.claude/hooks/` (allowlisted ahead of creation — neither exists yet)
  - OpenSpec: `openspec/` as a stated exception to the non-dot root rule, so specs and changes travel with the config
  - Neovim: `.config/nvim/` absorbed into this repository (see below)
- Permanently exclude known secret-bearing paths found in this `$HOME`: `.ssh/` (contains `id_ed25519`), `.claude/.credentials.json`, `.config/gh/hosts.yml`, `.ghtoken`, `.claude.json`, `.bash_history`, `.psql_history`, `.viminfo`, plus pattern-based rules for keys, certs, `.env`, and credential files anywhere in the tree.
- Manage Claude Code plugins **declaratively**: `.claude/settings.json` carries `extraKnownMarketplaces` (marketplace sources) and `enabledPlugins` (which plugins are on), and Claude Code fetches, installs, and updates them from that declaration on a new machine. `.claude/plugins/` — the 13 MB of cloned marketplaces, caches, and `installed_plugins.json`/`known_marketplaces.json` holding machine-absolute install paths — is derived state and is ignored.
- Exclude bulk/machine-local trees so `git status` stays fast and the repo stays portable: `.cache/`, `.npm/`, `.nuget/`, `.cargo/`, `.dotnet/`, `.nvm/`, `.vscode-server/`, `.ServiceHub/`, `.local/`, `.claude/projects/`, `.claude/sessions/`, `.claude/plugins/`, `.claude/history.jsonl`.
- Adopt an explicit-add workflow: `git add <path>` only. `git add -A`/`git add .` are not used, and a pre-commit hook rejects a commit whose staged set matches the security denylist.
- Verify with a scan of staged content before the first push, then push to the empty remote.

**Not breaking** — no existing tracked history to migrate; the remote is empty.

## Capabilities

### New Capabilities
- `dotfiles-repo`: `$HOME` as a git repository — initialization, remote wiring, the explicit-add staging discipline, the pre-commit safety hook, and the bootstrap path for cloning onto a new machine.
- `dotfiles-ignore-policy`: the deny-by-default ignore contract — the ignore-everything baseline, the non-dot root rule, how a path is explicitly allowlisted (including nested paths), and the security denylist that overrides the allowlist.

### Modified Capabilities
None. `openspec/specs/` is empty; this is the first capability set.

## Impact

- **New files**: `/home/gmteixeira/.gitignore`, `/home/gmteixeira/.git/` (repo), `/home/gmteixeira/.git/hooks/pre-commit`.
- **Remote**: first commit and push to `https://github.com/gmteixeira-personal/personal-config` (currently empty).
- **Existing files**: none modified. Only `.gitignore` is created; all other `$HOME` content is untouched.
- **Nested repository absorbed**: `.config/nvim` is currently its own git repository (remote `https://github.com/gmteixeira-personal/nvim-config`, working tree clean, `main` level with `origin/main`). Its `.git` directory is removed and its files are tracked directly here, giving one repository and one history. The nvim repository's own commit history is **not** carried over — it remains intact on the `nvim-config` remote, which is the recovery path if it is ever wanted back.
- **`openspec/` tracked as a stated exception**: it does not start with `.`, so it is allowlisted explicitly rather than by the general root rule.
- **`autoMode` removed from `.claude/settings.json`**: the block recorded a private repository name and URL, branch-workflow policy, and a second username. Measured against the shipped defaults, 14 of its 23 entries were byte-identical and 2 more were section headers — every one of the 7 real customizations named a private work repository or its layout. Since it is a *user*-scope key, it applied globally, describing one project even while working elsewhere. Deleting it removes the confidential content and corrects that misconfiguration in one step; auto mode falls back to the shipped defaults, verified as 20 entries with no reference to that project.
- **Git identity is repo-local**, set in `.git/config` rather than the untracked `.gitconfig`, so this repository commits as the personal account while other repositories on the same machine keep their own identity. It must be set again on each new clone.
- **Blast radius if wrong**: publishing a private key or OAuth token to a public GitHub repository. This drives the verify-before-push task and the pre-commit hook.
