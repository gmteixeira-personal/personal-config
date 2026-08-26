---
description: List open OpenSpec proposals and suggest the next change to do
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(grep:*), Bash(find:*), Read, Glob, Grep
---

What proposals do we have open? Don't say anything else, just print a table and the name of the suggested change to do next. If the proposals have dependencies, instead of a table draw them as a tree.

Open proposals live in `openspec/changes/`, excluding `openspec/changes/archive/`. Read each one's `proposal.md` (and `tasks.md` if needed) to find stated dependencies or ordering constraints, and check `openspec/changes/archive/` to see whether a named dependency is already archived.

For the status of each proposal, show task progress rather than a word like "pending" or "in progress". Count the checklist items in the change's `tasks.md`: completed items are the lines matching `- [x]` (case-insensitive) and total items are all lines matching `- [ ]` or `- [x]`. Print the status as `completed/total`, for example `3/12`. When completed equals total — every task is done — keep the total and replace only the completed count with a green check, so it reads `✅/12`. When a change has no `tasks.md` or it holds no checklist items, print `—`.
