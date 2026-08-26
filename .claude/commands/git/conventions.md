---
description: Show the shared rules the /git:* commands follow
model: sonnet
effort: low
allowed-tools: Bash(git:*), Read
---

# Conventions for the `/git:*` commands

Every `/git:*` command follows the rules below. Invoked on its own, this command prints them so the rules can be reviewed without running an operation.

## Preconditions

- Run `git rev-parse --show-toplevel` first. If it fails, the working directory is not a git repository: stop, say so, and suggest `/git:init`. `/git:init` is the only command exempt from this check.
- Work on the repository the session's working directory is in. Never assume the home configuration repository's layout, branch names, or remote.
- Never pass `--no-verify` and never disable hooks in any other way. If a hook rejects a commit or a push, report its output verbatim and stop.

## Staging discipline

- Read the dirty set with `git status --porcelain` and stage each path by name: `git add -- <path> <path> ...`.
- Never use `git add -A`, `git add .`, or `git add -u`. This holds in every repository, including for `/git:push all`.
- Never force-add a path that an ignore rule matches. Report it as skipped instead.
- Because the paths are known before staging, the closing report can always name exactly what went in and what was left out. Do that.

## Session scope

Commands that stage "this session's work" — `/git:push` with no argument, and `/git:append` — select paths this way:

1. Take the paths created or modified through tool calls during the present conversation.
2. Intersect them with the dirty set from `git status --porcelain`.
3. A session path that is no longer dirty is dropped silently; that is not an error.

If the session's edit record is unavailable or the correct set is genuinely uncertain — for instance after a long conversation, or when the user has been editing by hand alongside the assistant — do not guess. Show the dirty paths and ask which to include before staging anything.

## Commit messages

- Read recent subjects with `git log --oneline -20` and match the style already in use. Use a conventional-commit prefix only where the history already uses one.
- Write the subject from the actual change, naming what changed rather than listing file names. Add a body when the subject alone does not explain the change.
- Do not add a co-author or tool-attribution trailer unless the repository's own configuration or recent history uses one.

## Published history

Before rewriting any commit — `/git:squash`, `/git:append` — check each commit in the range with `git branch -r --contains <sha>`.

- If no commit in the range appears on any remote-tracking ref, rewrite without asking.
- If any commit does, stop, name those commits, and ask for explicit confirmation before rewriting.
- After a confirmed rewrite, push with `git push --force-with-lease`. Never use plain `--force`.

## Conflicts and destructive operations

- Never resolve a conflict unprompted. On conflict, stop, name the conflicted paths, and leave the repository in the state git put it in — do not abort the operation for the user.
- Never discard, stash, or check out over uncommitted changes to get an operation moving. Stop and report the blocking paths instead.
- Deleting branches, force-pushing, and overwriting a configured remote all require an explicit confirmation of a named list first.

## Reporting

Every command ends with a short report.

- On success: the branch, what was done, any new or rewritten commit, and anything deliberately left untouched.
- On stopping: why it stopped, the shortest decisive line of git's own output quoted, and the next step to take. Do not clean up behind a failure; leave the repository as git left it.
