---
description: Commit and push the current branch, creating its upstream if needed
model: sonnet
effort: medium
allowed-tools: Bash(git:*), Read
argument-hint: "[all]"
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Commit and push on the current branch. `$ARGUMENTS` is either empty or the word `all`.

- Empty: stage only the paths this session touched, using the session-scope rule from the conventions.
- `all`: stage every dirty path in the repository — modified, deleted, and untracked-but-not-ignored — whether or not this session touched it.

## Steps

1. **Check the branch.** If HEAD is detached, stop, say there is no branch to push, and suggest `/git:switch BRANCH`.

2. **Work out what to stage.** Read the dirty set with `git status --porcelain`.

   - Without `all`: intersect it with the paths this session created or modified. If that leaves nothing, report that there is nothing from this session to commit, create no empty commit, and — if unrelated dirty paths exist — list them and mention `/git:push all`. If the session set is uncertain, show the dirty paths and ask before staging.
   - With `all`: take the whole dirty set, minus anything an ignore rule matches.

3. **Stage by name.** `git add -- <path> ...`. Never `git add -A`, `git add .`, or `git add -u`. Never force-add an ignored path; report it as skipped.

4. **Commit.** Write the message from the staged diff in the repository's prevailing style, as the conventions describe. If a hook rejects the commit, report its output and stop.

   If there was nothing to stage but the branch has unpushed commits, skip the commit and go on to push them. If there was nothing to stage and nothing unpushed, report that the branch is already up to date and stop.

5. **Push.**

   - The branch has an upstream: `git push`.
   - No upstream, exactly one remote: `git push -u <remote> <branch>`, establishing tracking.
   - No upstream, several remotes: ask which remote to publish to before pushing.
   - No remote at all: the commit stands; report that it is local only because the repository has no remote.

6. **Handle a rejection.** If the push is rejected as non-fast-forward, stop and report it. Do not force-push. Suggest `/git:pull` as the next step.

## Report

Name the branch, the remote, the new commit, and the paths committed. State any dirty path deliberately left behind.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
