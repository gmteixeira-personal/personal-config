---
description: Merge the current branch into another branch, ending on that branch
model: opus
effort: high
allowed-tools: Bash(git:*), Read
argument-hint: "BRANCH"
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Merge the current branch into `$ARGUMENTS` — the target branch — and finish with the target branch checked out.

## Steps

1. **Check the argument.** If no branch name was given, ask for one. Remember the current branch: it is the source.

2. **Check the working tree.** If uncommitted changes would prevent switching to the target, stop before switching and report the blocking paths. Do not stash or discard them.

3. **Reach the target.** Get to `BRANCH` by the same rule `/git:switch` uses: check out a local branch, otherwise fetch and track a remote branch of that name, otherwise create it from the current HEAD.

4. **Bring the target up to date.** If `BRANCH` has an upstream that is ahead, fast-forward it before merging. If that cannot be done cleanly, stop and report why.

5. **Merge the source in.** Run `git merge <source>` while on `BRANCH`.

6. **Handle conflicts.** If the merge conflicts, stop with the conflicted merge in progress **on the target branch**. Name the conflicted paths. Do not switch back to the source branch — that would mean aborting the merge and discarding the user's position in the work.

7. **Do not push.** Publishing the target branch is a separate decision.

## Report

Name the source branch, the target branch, the result, and — explicitly — that the target branch is now the checked-out branch. Mention `/git:push` as the way to publish the merge.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
