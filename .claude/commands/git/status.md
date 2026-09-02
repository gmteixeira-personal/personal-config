---
description: Show the working tree's changes as an icon-annotated tree
model: opus
effort: low
allowed-tools: Bash(git:*), Read
---

Read `~/.claude/commands/git/conventions.md` and follow it.

Show what has changed in the working tree, drawn as a directory tree. Each entry carries an emoji naming its state, and colour marks whether the change is staged. This command is read-only: it never stages, commits, fetches, or contacts a remote, and the working tree, the index, and the checked-out branch must be unchanged when it finishes.

## Steps

Build and print the status block exactly as **The status block** in the conventions describes it — the reads it is built from, the session column, how the tree is built, the colours, the states, and the field widths all live there. This command adds nothing to that format and changes nothing about it.

Where other commands print the block to close an operation, here it is the operation. There is no prose report before it and nothing after it.

## Report

The block is the entire output. Print it and stop.

Do not follow it with prose restating what it already shows. The status line answers, in one line, whether the tree is clean, whether the branch is ahead or behind, how many files are in each state, and how many lines moved; the tree answers which files and where. A sentence beneath repeating any of that is noise, and it is noise at exactly the moment the output was clearest.

This rules out the whole family of closing remarks that feel helpful and are not: "the working tree is clean", "you are level with origin/main", "nothing to commit", "the branch is 2 ahead — `/git:push` to publish", "5 files modified". Every one of those is a translation of a field the reader is already looking at. Suggesting a next command is the same mistake wearing a different hat — `⇡2` is the reason to push and it is on screen, so naming `/git:push` adds a word and no information.

Exactly one thing may be said outside the block, because it is the one thing the block cannot express: when session ownership could not be determined, a blank session column is indistinguishable from "this session touched everything", so say once that ownership is unknown. Nothing else qualifies. An untracked directory hit by the cap does not, since the tree already prints its count; a hook or git failure does not, since that is an error path, not a report.
