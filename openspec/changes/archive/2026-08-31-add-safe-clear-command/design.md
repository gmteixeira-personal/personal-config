## Context

See proposal.md — Why. The mechanism is a single Markdown file under `~/.claude/commands/`, which is the whole implementation: Claude Code turns each file there into a slash command, and the file's body is the instruction the command runs. The repository already carries two such suites, `git/` and `opsx/`, whose files establish the house style — YAML frontmatter, then prose addressed to the assistant.

The one constraint that is not obvious from the existing files: this command runs *during* somebody else's task. Everything it does happens on top of whatever the session was already doing, and its output is the last thing the user reads before discarding the conversation.

## Goals / Non-Goals

**Goals**

- Land the work and describe it, in that order.
- Make the resume line survive the clear that follows it.

**Non-Goals**

- Deciding when to clear. The command answers "is now safe", never "is now wise".
- Automating the clear. Nothing about `/clear` is worth wrapping — it is one keystroke sequence, and taking it out of the user's hands removes the one moment they get to change their mind.
- Persisting the conversation. This is not a transcript or a session summary; the point is to make the transcript unnecessary, not to preserve it.

## Decisions

**Top-level file, not a suite member.** `safe-clear.md` sits directly in `~/.claude/commands/`, giving `/safe-clear`. The alternative, a namespace like `/session:safe-clear`, would put a suite prefix on a suite of one and make the command longer to type at exactly the moment the user is trying to spend less. The existing namespaces are wrong for it: it is not a git verb and not an OpenSpec phase.

**No `allowed-tools` frontmatter.** Every other command in the repository declares one. This command must not, because reaching a safe point means finishing whatever the session had in progress — an edit, a test run, a wait on a background agent — and none of that is knowable in advance. A tool restriction here would trade the command's entire purpose for a guarantee it cannot make anyway.

**The output block is fixed, and it is the whole output.** Specified verbatim in the command file rather than described, because the failure mode is drift: an assistant that also summarizes the session hands the user a wall of text to read and then throw away, which is the cost the clear was meant to avoid. Fixing the block also makes the resume line easy to find and copy.

**Durable artifacts before prose.** The best handoff is one that was going to exist anyway — a ticked `tasks.md`, a failing test, the dirty tree. Preferring those means the resume line usually only has to point somewhere. A handoff note is the fallback, not the mechanism, so the command does not accumulate a directory of stale notes for work that a task list already tracked.

**Handoff notes live at `~/.claude/handoff/<YYYY-MM-DD>-<slug>.md`.** Under `.claude/` because it is Claude Code state and that is where the rest of it lives; dated and slugged so two sessions on the same day do not collide; outside the tracked tree because the content is one machine's paths and one session's in-flight state. The session scratchpad was the alternative and is wrong: its path is session-scoped, which is precisely the thing about to be discarded.

**The ignore rule is a named entry in the denylist block.** `.gitignore` block 4 already lists the machine-local Claude Code directories one per line. `.claude/handoff/` joins them. The catch-all in block 1 already ignores it, so this changes no behavior — it makes `git check-ignore -v` name the decision instead of the default, which is what the ignore policy's rule-attribution requirement asks for. Nothing is needed on the allowlist side: `.claude/commands/**` is already there.

## Risks / Trade-offs

- **The assistant declares a safe point that is not one** → The conditions are written as observable properties of the tree and the session rather than as a judgment call, and the command is required to report failure in one line rather than round up to safety.
- **Reaching the safe point becomes its own long task** → The command may finish only what is in progress, and must back out instead of finishing where that would be substantial work. Backing out is stated in the handoff, so the user sees what was undone.
- **The resume line is written for someone who still remembers the conversation** → The spec makes standing alone in an empty context the test, and forbids the phrasings that fail it. The user reads the line before clearing and can ask for a better one.
- **Handoff notes accumulate** → They are the fallback rather than the default, and they are dated. Untracked and outside the repository, a stale one costs disk and nothing else.

## Migration Plan

Adding a file to `~/.claude/commands/` makes the command available; there is nothing to register and no restart. Rollback is deleting the file. The `.gitignore` line changes no path's ignored status, so it needs no cleanup either way.
