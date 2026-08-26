---
description: Fetch from origin and report what moved
model: sonnet
effort: low
allowed-tools: Bash(git:*), Read
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Fetch from the `origin` remote. Nothing else: no `--all`, no `--prune`, no pull. The working tree, the index, and the checked-out branch must be unchanged when this command finishes.

## Steps

1. **Check for `origin`.** Run `git remote`. If there is no remote named `origin`, stop and say so; if other remotes exist, name them.

2. **Fetch.** Run `git fetch origin`.

   If the fetch fails — unreachable host, refused authentication, unknown repository — report the failure with the shortest decisive line of git's output and stop. Do not retry with different credentials, a different remote, or a different protocol.

3. **Work out what changed.** Compare against the current branch's upstream, for example with `git status -sb` and `git log --oneline HEAD..@{upstream}` when an upstream exists. Note new branches, updated branches, and branches that disappeared from the remote.

## Report

Summarize what arrived: new commits on the current branch's upstream, new remote branches, and remote branches that are gone. If nothing came in, say everything is already up to date.

If the current branch is now behind its upstream, say so and mention `/git:pull`. If remote branches disappeared, mention `/git:cleanup`.
