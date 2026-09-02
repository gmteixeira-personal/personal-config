---
description: Initialize a git repository here, optionally registering a remote URL as origin
model: opus
effort: low
allowed-tools: Bash(git:*), Read
argument-hint: "[REPO url]"
---

Read `~/.claude/commands/git/conventions.md` and follow it, except for the precondition that the working directory must already be a git repository — this command is the exception.

Initialize a git repository in the current working directory. `$ARGUMENTS` optionally holds `REPO`, the URL to register as the `origin` remote.

## Steps

1. **Validate the argument, if there is one.** `REPO` must look like a repository URL: an HTTP(S) URL (`https://host/owner/repo.git`) or an SSH remote specifier (`git@host:owner/repo.git` or `ssh://git@host/owner/repo.git`). Anything else — a branch name, a local path, a bare word — is a mistyped argument: stop, say the argument is not a usable remote URL, and initialize nothing.

   Do not contact the remote. A repository that does not exist yet, or a host that is currently unreachable, must not fail this command.

2. **Check whether this is already a repository.** Run `git rev-parse --show-toplevel`.

   If it succeeds, do not reinitialize. Report the existing repository root, then:
   - If `REPO` was given and no `origin` remote exists, offer to add `origin` to the existing repository and add it if the user agrees.
   - If `REPO` was given and `origin` already exists with a different URL, stop and report both URLs. Do not overwrite the remote without explicit confirmation.
   - If `REPO` was given and `origin` already points at the same URL, say so and do nothing.

3. **Initialize.** Run `git init`. Do not pass `--initial-branch`: the branch name comes from the user's own `init.defaultBranch` configuration.

4. **Register the remote.** If `REPO` was given, run `git remote add origin <REPO>`, then confirm with `git remote get-url origin`.

5. **Stop there.** Do not stage anything, do not create a commit, and do not push.

## Report

Name the repository path and the initial branch, and the remote URL if one was registered. Mention `/git:push` as the way to make and publish the first commit.

Then close a successful run with the status block, as **Closing status** in the conventions describes. It goes last, after this report, and is not printed at all when the command stopped.
