---
description: Switch to a branch, tracking it from the remote or creating it as needed
model: opus
effort: low
allowed-tools: Bash(git:*), Read
argument-hint: "BRANCH"
---

Read `~/.claude/commands/git/conventions.md` and follow it.

End with `$ARGUMENTS` — the branch name — checked out, whether it exists locally, exists only on a remote, or does not exist at all.

## Steps

1. **Check the argument.** If no branch name was given, ask for one. Do not guess a branch.

2. **Already there?** If `BRANCH` is the current branch, say so and do nothing.

3. **Check the working tree.** If switching would overwrite uncommitted changes, stop and report the blocking paths. Do not stash, discard, or check out over them.

4. **Local branch.** If `git rev-parse --verify --quiet refs/heads/BRANCH` succeeds, run `git switch BRANCH` and stop here.

5. **Remote branch.** Otherwise fetch first — the answer changes what this command does — then look for `BRANCH` on the remotes with `git branch -r --list '*/BRANCH'`.

   - Exactly one match: create a local branch tracking it (`git switch --track <remote>/BRANCH`).
   - Several remotes carry that name: ask which one to track before creating the local branch.

6. **New branch.** If it exists nowhere after fetching, create it from the current HEAD with `git switch -c BRANCH`.

## Report

Name the branch and which case applied: checked out an existing local branch, created a local branch tracking a remote one, or created a new branch. For a new branch, say that it is not yet published and mention `/git:push`.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
