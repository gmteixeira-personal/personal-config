---
description: Squash the last N commits into one with a regenerated message
effort: high
allowed-tools: Bash(git:*), Read
argument-hint: "N | *"
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Combine the last commits on the current branch into a single commit whose message covers their combined content. `$ARGUMENTS` is either a count `N` or `*`.

## Choosing the count

- **A number**: use it as given.
- **`*`**: choose the count by judgement, aiming for roughly one commit per feature. Read `git log --oneline -30` and find where the current line of work begins — usually the merge-base with the upstream default branch, or the point where the subjects stop belonging to one piece of work. Report the chosen count and the reason **before** rewriting anything. If no boundary is clear, propose a count and ask for confirmation rather than guessing.

## Preconditions

Check all of these before touching history, and stop on the first that fails:

- **Clean tree.** `git status --porcelain` must be empty. If it is not, report the dirty paths and suggest `/git:append` or `/git:push` first.
- **Enough history.** `N` must not exceed the number of commits on the branch.
- **Not past the merge-base.** The range must not reach past the merge-base with the upstream default branch. If it does, stop and report the limit rather than rewriting shared history.
- **No merge commit in range.** Check with `git log --merges HEAD~N..HEAD`. If the range contains one, stop and say the range is not safely squashable.
- **Published history.** Run `git branch -r --contains <sha>` for each commit in the range. If any is on a remote, name those commits and ask for explicit confirmation before rewriting.

## Squashing

1. Read the messages being replaced (`git log -N`) and the combined change (`git diff HEAD~N`).
2. `git reset --soft HEAD~N` — the tree is untouched by construction.
3. `git commit` with a message written from the combined change in the repository's prevailing style. Do not concatenate the old subjects; make sure nothing meaningful they carried is lost.
4. If the rewritten commits were published and the user confirmed, push with `git push --force-with-lease`. Never plain `--force`.

## Report

Name how many commits were squashed, the new commit, and the new subject. Say whether the result was pushed.
