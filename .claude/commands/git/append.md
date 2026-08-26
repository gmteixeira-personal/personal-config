---
description: Fold the current changes into the last commit, updating its message
model: opus
effort: medium
allowed-tools: Bash(git:*), Read
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Add the current working-tree changes to the most recent commit rather than creating a new one.

## Preconditions

Stop on the first that fails:

- **There is something to append.** If `git status --porcelain` is empty, report that there is nothing to append and leave the commit untouched.
- **There is a commit to append to.** If the branch has no commits, say so.
- **HEAD is not a merge commit.** Check with `git log -1 --merges`. Amending a merge is unsafe here; stop and say why.
- **Published history.** Run `git branch -r --contains HEAD`. If HEAD is on a remote, say so and ask for explicit confirmation before amending.

## Steps

1. **Choose what to include.** Use the same session-scope rule as `/git:push` with no argument: the paths this session touched, intersected with the dirty set. Ask when that set is uncertain.

2. **Stage by name.** `git add -- <path> ...`. Never `git add -A`, `git add .`, or `git add -u`.

3. **Decide about the message.** Read the existing message and the newly staged diff.
   - The existing message already covers the combined content: keep it, `git commit --amend --no-edit`.
   - It does not: rewrite it to describe the combined change, in the repository's prevailing style.

4. **Push if it was already published.** After a confirmed amend of a published commit, push with `git push --force-with-lease`. Never plain `--force`.

## Report

Name the commit that absorbed the changes, the paths added, whether the message changed, and whether the result was pushed. State any dirty path left behind.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
