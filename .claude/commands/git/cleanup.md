---
description: Propose and delete local and remote branches whose work has already landed
model: sonnet
effort: high
allowed-tools: Bash(git:*), Read
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Find branches that are no longer needed, propose them, and delete only what the user approves. Nothing is deleted before the list has been shown and approved.

## Building the candidate list

1. **Refresh first.** Run `git fetch --prune` so remote-tracking refs reflect what the remote actually has.

2. **Identify the default branch**, for example from `git symbolic-ref refs/remotes/origin/HEAD` or the remote's HEAD, falling back to `main` or `master` as the repository uses.

3. **Collect candidates under two reasons, reported separately:**

   - **Merged.** Local branches whose tip is contained in the default branch: `git branch --merged <default>`.
   - **Upstream gone.** Local branches whose tracked upstream no longer exists after the prune: the entries marked `: gone]` in `git branch -vv`. Report this as the weaker reason — it is what a squash-merged or rebase-merged pull request leaves behind, but it also matches a branch whose remote counterpart was deleted by mistake. Say that in the proposal.

   Also list remote branches that are merged into the default branch, as a separate group.

4. **Exclude unconditionally:** the current branch and the default branch, local and remote, even when they satisfy a reason.

## Approval

Present the candidates grouped by reason, with each branch's last commit subject and date so the user can judge. Then ask once for the whole plan. The user may approve everything, or name a subset — honour a partial selection exactly and report the rest as kept.

Remote deletion needs its own explicit approval, distinct from approving the local deletions: `git push origin --delete` reaches outside this machine and affects everyone using the repository.

If no branch qualifies, report that there is nothing to clean and delete nothing.

## Deleting

- Local: `git branch -d <branch>`. Never `-D`. If git refuses because the branch holds unmerged commits, report the refusal and move on — do not force it.
- Remote, only when separately approved: `git push origin --delete <branch>`.
- Leave the checked-out branch, the working tree, and the index unchanged.

## Report

List what was deleted, grouped local and remote; what was kept and why; and any deletion git refused, with its reason.
