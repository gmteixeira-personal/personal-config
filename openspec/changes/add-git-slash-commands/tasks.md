## 1. Shared foundation

- [x] 1.1 Create `.claude/commands/git/` and write `conventions.md` with frontmatter (`description`, `allowed-tools: Bash(git:*)`) covering the shared rules: stage by explicit path only, never `git add -A/./-u`, never `--no-verify`, never force-add an ignored path, commit message style inferred from the repository's recent `git log`, no attribution trailer unless the history uses one, published-commit detection via `git branch -r --contains`, conflicts stop and report, and the closing report format for both success and stop.
- [x] 1.2 Write the session-scope rule into `conventions.md`: select paths edited by the assistant this session, intersect with `git status --porcelain`, and ask when the set is uncertain rather than guessing.
- [x] 1.3 Verify `/git:conventions` registers and prints the rules when invoked.

## 2. Repository setup

- [x] 2.1 Write `init.md`: validate the optional `REPO` argument as an HTTP(S) or SSH URL by shape, run `git init` without forcing a branch name, and `git remote add origin <REPO>` when one is given.
- [x] 2.2 Add `init.md` guards: report the existing root instead of reinitializing when already inside a repository (offering to add `origin` when it is the missing part), stop when `origin` exists with a different URL, never contact the remote, and never stage, commit, or push.
- [x] 2.3 Write `fetch.md`: run `git fetch origin` only — no `--all`, no `--prune` — report new, updated, and deleted branches, say when the current branch is behind and point at `/git:pull`, stop when there is no `origin`, and quote git's decisive line on failure.

## 3. Push and pull

- [x] 3.1 Write `push.md`: session-scoped staging by default, `all` argument staging every dirty non-ignored path by name, no empty commit, report of paths left behind.
- [x] 3.2 Add push publishing to `push.md`: push to upstream, create upstream on first push with a single remote, ask when several remotes and no upstream, commit-only when no remote, stop on non-fast-forward rejection and point at `/git:pull`, stop on detached HEAD and point at `/git:switch`.
- [x] 3.3 Write `pull.md`: pull the upstream branch, handle already-up-to-date, missing upstream (offer the same-named remote branch), dirty tree, and conflicts.
- [x] 3.4 Write `commit.md`: the staging half of `push.md` — session scope by default, `all` for every dirty non-ignored path, staged by name, message from the staged diff — with no push, no upstream creation, and no remote contact; commit on a detached HEAD but warn; point at `/git:push` to publish.

## 4. Branch movement

- [x] 4.1 Write `switch.md`: check out an existing local branch; otherwise fetch, then track a remote branch of that name, asking which remote when several match; otherwise create the branch from HEAD and report it as unpublished.
- [x] 4.2 Add `switch.md` guards: stop on uncommitted changes that the switch would overwrite, report and do nothing when already on the branch, ask when no branch name was given.

## 5. History rewriting

- [x] 5.1 Write `squash.md` with the soft-reset approach: precondition checks (clean tree, `N` within history, no merge commit in range, range not past the merge-base with the upstream default branch), then `git reset --soft HEAD~N` and a single commit with a regenerated message.
- [x] 5.2 Add the `*` mode to `squash.md`: infer the boundary of the current line of work, report the chosen count and the reason before rewriting, and ask for confirmation when no boundary is clear.
- [x] 5.3 Write `append.md`: `git commit --amend` with session-scoped staging, update the message only when the existing one no longer covers the change, and stop when the tree is clean, the branch has no commits, or HEAD is a merge commit.
- [x] 5.4 Add the published-history gate to both `squash.md` and `append.md`: proceed silently when nothing in the range is on a remote; otherwise name the published commits and require confirmation, then push with `--force-with-lease` and never plain `--force`.

## 6. Merging

- [x] 6.1 Write `merge.md`: merge `BRANCH` into the current branch, fetching for a remote-only source, staying on the current branch, stopping on a dirty tree, reporting when the branch is already an ancestor, and leaving conflicts in place without aborting.
- [x] 6.2 Write `mergeinto.md`: reach `BRANCH` by the `/git:switch` rule, bring it up to date with its upstream first, merge the original branch in, and end on `BRANCH`.
- [x] 6.3 Add `mergeinto.md` edge cases: stop before switching when uncommitted changes block it, stay on `BRANCH` with the conflicted merge in progress rather than returning, and do not push the result — point at `/git:push`.

## 7. Branch cleanup

- [x] 7.1 Write `cleanup.md`: fetch with `--prune`, build the candidate list from branches merged into the default branch (`git branch --merged`) and branches whose upstream is `gone` (`git branch -vv`), excluding the current and default branches.
- [x] 7.2 Add the approval flow to `cleanup.md`: present candidates grouped by reason, ask once for the whole plan, honour a partial selection, and delete nothing that was not approved.
- [x] 7.3 Add the deletion rules to `cleanup.md`: local deletes use `git branch -d` and report a refusal instead of forcing, remote deletes need their own separate approval and never target the default remote branch, and the checked-out branch, working tree, and index are left unchanged.

## 8. Verification

- [x] 8.1 Exercise the read-only and additive paths in a scratch repository: `/git:init` with and without a URL, `/git:fetch`, `/git:switch` for the local, remote-only, and new-branch cases, `/git:push` and `/git:push all`, `/git:pull` up-to-date and fast-forward, `/git:merge` clean and already-ancestor.
- [x] 8.2 Exercise the stopping paths in a scratch repository: `/git:init` inside an existing repository and with a conflicting `origin`, `/git:fetch` with no `origin`, dirty-tree blocks, detached HEAD, non-fast-forward rejection, merge conflict, squash range past the merge-base, and append with a clean tree — confirming each reports the reason and leaves the repository untouched or in git's own state.
- [x] 8.3 Confirm the published-history gate asks before rewriting a pushed commit and that nothing force-pushes without confirmation.
- [x] 8.4 Exercise `/git:cleanup` in a scratch repository with a merged branch, a gone-upstream branch, an unmerged branch, and the default branch present — confirming the proposal is correct, that declining deletes nothing, and that the unmerged branch is refused rather than forced.
- [x] 8.5 Stage the new files by explicit path in the home repository, confirm the commit guard passes, and confirm `git status --porcelain` shows no unintended additions.
- [x] 8.6 Set `model:` and `effort:` frontmatter on each command per the design's table, and confirm the commands still register.
