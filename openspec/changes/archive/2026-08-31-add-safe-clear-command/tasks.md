## 1. The command file

- [x] 1.1 Write `~/.claude/commands/safe-clear.md` with frontmatter carrying `description` and `argument-hint` and no `allowed-tools` key, and verify `grep -c allowed-tools` on the file returns 0
- [x] 1.2 Write the safe-point conditions, the rules for reaching one, and the prohibitions — no new work, no commit or push, no self-clear — and verify each requirement in `specs/claude-safe-clear-command/spec.md` has a passage in the file that states it
- [x] 1.3 Write the handoff section: the durable-artifact preference, the `~/.claude/handoff/<YYYY-MM-DD>-<slug>.md` fallback, and the resume-line rules, and verify the fallback path appears verbatim in the file
- [x] 1.4 Write the output block as a verbatim template rather than a description, and verify it renders as a block containing the resume line and the `continue` alternative
- [x] 1.5 Write the one-line report for the case where no safe point can be reached, and verify the file states that the block is not printed in that case

## 2. Ignore policy

- [x] 2.1 Add `.claude/handoff/` to the `.gitignore` denylist beside the other machine-local Claude Code directories, with a comment saying why, and verify `git check-ignore -v .claude/handoff/x.md` names that line rather than the block 1 catch-all
- [x] 2.2 Verify the command file is trackable through the existing allowlist: `git check-ignore -v .claude/commands/safe-clear.md` reports the `!/.claude/commands/**` entry and `git status --porcelain` lists the file

## 3. Verification

- [x] 3.1 Run `openspec validate add-safe-clear-command --strict` and verify it reports no errors
- [x] 3.2 Confirm the command is registered by Claude Code — it appears in the slash-command list as `/safe-clear` with the description from its frontmatter
- [x] 3.3 Stage `.claude/commands/safe-clear.md` and `.gitignore` by name and verify `git status --porcelain` shows both staged and no handoff path present
