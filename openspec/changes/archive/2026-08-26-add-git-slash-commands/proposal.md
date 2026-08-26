## Why

Everyday git work in Claude Code is repetitive and error-prone to drive by hand: staging the right subset of a dirty tree, writing a decent commit message, creating an upstream branch on first push, fetching a branch that only exists on the remote, and tidying a run of noisy commits into one per feature. Each of these is a short sequence of git commands plus a judgement call, which is exactly the shape a slash command should carry. Doing this in the personal config means the same verbs are available in every repository on every machine that clones it.

## What Changes

- Add a `git` command namespace under `.claude/commands/git/`, invoked as `/git:<command>`, available in any repository.
- `/git:init [REPO]` — initialize a git repository in the working directory, and when `REPO` is given as an HTTP(S) or SSH URL, register it as the `origin` remote.
- `/git:fetch` — fetch from `origin`, reporting what moved.
- `/git:status` — show the uncommitted changes as a directory tree, one icon per entry marking untracked, staged, modified, deleted, renamed, or conflicted. Read-only.
- `/git:commit [all]` — stage and commit without pushing, using the same scope rule as `/git:push`: with no argument only the paths touched in the present session, with `all` every dirty path.
- `/git:push [all]` — stage, commit, and push to the current branch, creating the upstream on first push. With no argument it stages only the paths touched in the present session; with `all` it stages every dirty path in the repository.
- `/git:pull` — pull the current branch from its matching remote branch, reporting cleanly when there is no upstream, when the tree is dirty, or when the merge conflicts.
- `/git:switch BRANCH` — switch to `BRANCH`, checking out a local branch, tracking an existing remote branch (fetching first when needed), or creating a new branch from the current HEAD.
- `/git:squash N` — squash the last `N` commits into one with a regenerated message. `*` means choose the count by judgement, aiming for roughly one commit per feature.
- `/git:append` — fold the working-tree changes into the last commit, updating its message to cover the combined content.
- `/git:merge BRANCH` — merge `BRANCH` into the current branch, ending on the current branch.
- `/git:mergeinto BRANCH` — merge the current branch into `BRANCH`, ending on `BRANCH`.
- `/git:cleanup` — prune stale remote-tracking refs, then propose the local and remote branches that have already landed and delete only the ones the user approves.
- History-rewriting commands (`squash`, `append`) stop and ask before rewriting any commit that already exists on the remote; branch deletion in `cleanup` is proposed and confirmed, never automatic; merges stop and report on conflict rather than resolving them unprompted.
- Commands respect a repository's own staging discipline. In the `$HOME` config repo this means paths are always staged by name and never through `git add -A`, `git add .`, or `git add -u`, and the commit-time secret guard is never bypassed.

## Capabilities

### New Capabilities
- `git-slash-commands`: The `/git:*` command suite — the behavior of each command, repository initialization and remote registration, how the working tree is reported, how session-scoped staging is determined, commit message generation, upstream creation, and the safety rules for history rewriting and merging.

### Modified Capabilities

<!-- None. The existing dotfiles-repo and dotfiles-ignore-policy specs already
     constrain staging and secret handling; these commands obey those rules
     without changing them. Adding files under .claude/commands/ is already
     permitted by the tracked set. -->

## Impact

- New files: `.claude/commands/git/init.md`, `fetch.md`, `status.md`, `cleanup.md`, `commit.md`, `push.md`, `pull.md`, `switch.md`, `squash.md`, `append.md`, `merge.md`, `mergeinto.md`.
- No change to `.gitignore`, `.claude/settings.json`, or the commit guard — `.claude/commands/` is already an allowlisted, tracked directory.
- Commands are prompt files only; they add no runtime dependency beyond `git` itself, and they inherit whatever permission mode the session runs in.
