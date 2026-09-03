---
description: Stop at the next safe point and hand off, so the context can be cleared and the work resumed
argument-hint: "[optional: where to stop]"
---

Bring the current work to the nearest safe point, then stop and hand off, so that the context can be cleared and the work picked up again in a fresh one.

`$ARGUMENTS`, when given, names the boundary to stop at — a task number, a file, or a condition such as "after the tests pass". With no argument, choose the nearest safe point yourself; do not ask where to stop.

## What a safe point is

A place where clearing the context loses nothing but the conversation. All of these hold:

- **No half-finished edit.** Every file touched this session is in a state that parses and that a reader would recognise as deliberate. A function opened and not closed, an import added for a call not yet written, a rename applied to three of five call sites — none of those is a safe point.
- **Nothing running.** No background command, agent, or task is still in flight whose result only this context knows how to interpret.
- **Nothing pending in the conversation.** No question waiting on the user, no confirmation half-given.
- **The next step is describable in a few sentenses.** If it takes a page to say what comes next, the point is not yet safe — either finish to a coarser boundary or write the handoff file described below.

If all of that already holds when the command runs, print the block and stop. Change nothing to get there.

## Reaching it

Reaching a safe point is allowed to take a few more tool calls: closing the edit in progress, reverting one that was going nowhere, waiting on a command already started. It is not licence to start anything new.

- Finish the in-flight unit when a small amount of work would make it coherent.
- Back out of it instead when finishing would be substantial work — and say in the handoff that it was reverted, and what it was.
- Do not start the next task, do "while you are here" cleanups, or summarise the session.
- Do not commit, push, or otherwise publish anything to reach a safe point. Uncommitted work is fine: `/clear` does not touch the working tree. Commit only if the user asked for it separately.
- Do not clear the context yourself. `/clear` is the user's to type, and it stays that way.

## Where the handoff lives

Prefer state that already exists on disk over prose: an OpenSpec change's `tasks.md` with its boxes ticked, a failing test, the working tree itself. Bring that state up to date first, then point at it from the resume line.

Write a handoff file only when the state genuinely does not fit in the resume line. Put it at `~/.claude/handoff/<YYYY-MM-DD>-<slug>.md` — untracked, and it survives the clear — and make the resume line name that path.

## The resume line

The resume line is what the user types into an empty context, so it has to stand on its own: no "continue what we discussed", no pronoun whose referent died with the conversation. Name the repository path, the file, the change, and the next action. One or two sentences. Where an existing slash command is the next step, start with it — `/opsx:apply add-direnv-venv-activation`, say.

## Output

Print exactly this, and nothing else. No preamble, no recap of the session, no closing offer or follow-up question.

````
Clear context safe point. You may `/clear`.

Use:

```
<resume line>
```

Alternatively you can type `continue`.
````

If a safe point cannot be reached — something is genuinely mid-flight and finishing it is real work — say that in one line, name what is unfinished, and print no block. Do not suggest that clearing is safe anyway.
