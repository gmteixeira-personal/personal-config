---
description: Pull the current branch from its matching remote branch
model: opus
effort: low
allowed-tools: Bash(git:*), Read
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Bring the current branch up to date with its matching remote branch.

## Steps

1. **Find the upstream.** Run `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`.

   If there is none, fetch and check whether a branch of the same name exists on the remote:
   - It does: ask before setting it as the upstream, then pull.
   - It does not: report that there is nothing to pull from, and stop.

2. **Check the working tree.** Run `git status --porcelain`. If uncommitted changes would be touched by the pull, stop before anything changes and report which paths block it. Do not stash or discard them.

3. **Pull.** Run `git pull`. If the branch already matches its upstream, report that there is nothing to pull and stop.

4. **Handle conflicts.** If the pull conflicts, stop. Name the conflicted paths and leave the repository in the conflicted state for the user to resolve. Do not resolve conflicts and do not abort the merge.

## Report

Summarize what arrived — commits, and the files they touched — or say the branch was already up to date. On a stop, quote the decisive line of git's output and name the next step.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
