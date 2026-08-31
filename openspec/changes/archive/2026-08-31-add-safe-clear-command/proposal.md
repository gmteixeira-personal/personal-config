## Why

A long session eventually costs more in context than it earns: replies slow down, older detail is summarized away, and the useful move is `/clear` followed by a fresh start. But clearing mid-task is destructive in practice — the working tree can hold a half-applied rename, a background command can still be running, and the only record of what came next is the conversation about to be discarded. So the clear gets postponed, and the session degrades instead.

What is missing is a way to ask for a landing rather than an interruption: bring the work to a point where the conversation is the only thing lost, then say so, and say what to type next.

## What Changes

- Add a `/safe-clear` slash command to the personal Claude Code configuration, at `~/.claude/commands/safe-clear.md`. Top-level rather than namespaced: it is not part of the `/git:*` or `/opsx:*` suites, and it applies to whatever the session happens to be doing.
- Define what the command treats as a safe point: no half-finished edit, nothing still running, nothing pending on the user, and a next step that fits in a sentence or two.
- Allow the command a few more tool calls to reach that point — closing the edit in progress, backing out of one that was going nowhere, waiting on a command already started — while forbidding new work, and forbidding committing or pushing as a means of getting there. `/clear` does not touch the working tree, so uncommitted work is not a reason to commit.
- Fix the output as a short block naming the safe point, the line to type after `/clear`, and `continue` as the alternative. The command prints that block and nothing else, and never clears the context itself — `/clear` stays the user's to type.
- Require the resume line to stand alone in an empty context: repository, file, change, next action, with no pronoun whose referent died with the conversation.
- Prefer durable on-disk state as the handoff — a change's ticked `tasks.md`, a failing test, the working tree — over prose. Where that genuinely does not fit, allow a handoff note under `~/.claude/handoff/`, which survives the clear.
- Ignore `~/.claude/handoff/` explicitly in `.gitignore`. It is per-session scratch naming this machine's paths and in-flight state; the catch-all already ignores it, but a named rule makes the decision auditable rather than incidental.

No allowlist change is needed for the command itself: `.claude/commands/**` is already allowlisted, so `safe-clear.md` is trackable the moment it exists.

## Capabilities

### New Capabilities

- `claude-safe-clear-command`: a `/safe-clear` command that brings the current work to a state where clearing the context loses only the conversation, then stops and prints a fixed handoff block — the safe point, a resume line that stands on its own in an empty context, and `continue` as the alternative — without committing, without starting new work, and without clearing anything itself.

### Modified Capabilities

- `dotfiles-ignore-policy`: adds handoff notes to the machine-local Claude Code state that is ignored by a named rule. The existing rule covers session data the tool itself writes; a handoff note is written by the assistant on request, so it is not covered by that wording, and it carries this machine's paths and one session's in-flight state.

## Impact

- **New tracked files**: `.claude/commands/safe-clear.md`
- **Modified tracked files**: `.gitignore`
- **Untracked, per machine**: `~/.claude/handoff/`
- **Not affected**: the `/git:*` and `/opsx:*` suites, which keep their own conventions; `settings.json`, since a command file needs no registration.
