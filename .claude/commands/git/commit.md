---
description: Stage and commit the current work without pushing it
model: sonnet
effort: low
allowed-tools: Bash(git:*), Read
argument-hint: "[all]"
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Commit on the current branch and stop there. Nothing is pushed, no upstream is created, and the remote is never contacted. `$ARGUMENTS` is either empty or the word `all`.

- Empty: stage only the paths this session touched, using the session-scope rule from the conventions.
- `all`: stage every dirty path in the repository — modified, deleted, and untracked-but-not-ignored — whether or not this session touched it.

## Steps

1. **Work out what to stage.** Read the dirty set with `git status --porcelain`.

   - Without `all`: intersect it with the paths this session created or modified. If the session set is uncertain, show the dirty paths and ask before staging.
   - With `all`: take the whole dirty set, minus anything an ignore rule matches.

2. **Nothing to do?** If nothing qualifies, report that, create no empty commit, and stop. If unrelated dirty paths exist, list them and mention `/git:commit all`.

3. **Stage by name.** `git add -- <path> ...`. Never `git add -A`, `git add .`, or `git add -u`. Never force-add an ignored path; report it as skipped.

4. **Commit.** Write the message from the staged diff in the repository's prevailing style, as the conventions describe. If a hook rejects the commit, report its output and stop.

5. **Stop.** Do not push and do not set an upstream. A repository with no remote is not a special case here.

## Detached HEAD

Committing does not need a branch, so a detached HEAD is not a reason to stop. Make the commit, then warn in the report that it is not on any branch and give its hash, so it can be recovered with `/git:switch` before it is lost.

## Report

Name the branch, the new commit, and the paths committed. State any dirty path deliberately left behind. Mention `/git:push` as the way to publish the commit.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
