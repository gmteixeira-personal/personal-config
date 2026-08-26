---
description: Merge a branch into the current branch
model: sonnet
effort: medium
allowed-tools: Bash(git:*), Read
argument-hint: "BRANCH"
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Merge `$ARGUMENTS` — the source branch — into the current branch, ending on the current branch.

## Steps

1. **Check the argument.** If no branch name was given, ask for one.

2. **Check the working tree.** If `git status --porcelain` is not empty, stop and report the uncommitted changes before starting the merge.

3. **Find the source branch.** If `BRANCH` does not exist locally, fetch and use the remote branch of that name. If it exists on several remotes, ask which one. If it exists nowhere, stop and say so.

4. **Anything to do?** If `BRANCH` is already an ancestor of the current branch (`git merge-base --is-ancestor BRANCH HEAD`), report that and make no commit.

5. **Merge.** Run `git merge <source>`. Stay on the current branch throughout.

6. **Handle conflicts.** If the merge conflicts, stop. Name the conflicted paths and leave the merge in progress for the user to resolve. Do not run `git merge --abort` and do not resolve conflicts.

## Report

Name the source branch, the current branch, and the result — fast-forward, merge commit, or already up to date. Say that the merge is not pushed and mention `/git:push`.
