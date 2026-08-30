## Context

See proposal.md — Why. The status line is built by `.claude/statusline-command.sh`, a single bash script that reads Claude Code's JSON payload from stdin and prints one line. Every field this change touches is already parsed and already rendered; the change is confined to the three `printf` calls that format them.

Two constraints shape the approach. The model's display name arrives as free text from the payload — the script has no separate family field to read — so shortening it means deciding what part of a string to keep. And the status line has no error channel: a script that fails prints nothing and the line silently disappears, so no change here may introduce a failure mode where a field is missing or malformed.

## Goals / Non-Goals

**Goals:**

- Shorten the three fields the specs name, with the resulting line legible without the labels that were removed.
- Keep every field's absent-value behaviour intact, so a missing effort level or a directory outside a repository degrades exactly as it does today.

**Non-Goals:**

- Any change to which fields the line carries, their order, or their colours. The git pending counts, the fast-mode marker and the context percentage are untouched.
- Any change to how a field is parsed out of the payload. The `display_name`, `effort.level` and `fast_mode` reads stay as they are; only what is done with them afterwards changes.
- Making the script's parsing more robust in general. It mixes `sed`, `grep` and one `python3` call, and that is a separate concern from this change.

## Decisions

**Shorten the model name by taking everything before the first space, rather than matching against a list of known families.**

`${model%% *}` turns `Opus 5` into `Opus`, `Haiku 4.5` into `Haiku`, and `Opus 5 (1M context)` into `Opus`, with no list to maintain. The alternative — a `case` matching `Opus|Sonnet|Haiku|Fable` and falling back to the full name — was rejected because it fails closed in the wrong direction: a model family this configuration has not seen yet would render at full length, which is exactly the case the shortening exists for. Taking the first word has no such gap, and if a future display name were a single word already, the expansion leaves it alone.

**Build the model badge by appending rather than by one format string.**

The badge has an optional effort level and an optional fast-mode marker, so a single `printf '%s:%s'` would leave a trailing colon when the effort is absent. Keeping the existing append style — the family name first, then the marker, then `:` and the level only when there is a level — makes the separator conditional on the value it separates, which is what the spec requires. This is the same shape the current code uses for ` · `; only the separator and the dropped word change.

**Join the directory and branch inside the existing branch conditional, not with a new one.**

The final `printf` already has two arms, one for a branch and one without. Changing `"%s on %s ..."` to `"%s:%s ..."` needs nothing else: the no-branch arm already prints the directory alone, which is what "no colon left behind" means. Substituting a colon for `on` in the format string is the whole edit.

**Keep the badge for the caveman level when it is off.**

`[OFF]` is shorter than `[CAVEMAN:OFF]` and still unambiguous in position, and dropping the badge entirely when off would move every field to its right between sessions. A line whose fields shift position is harder to read at a glance than one carrying a short word that says nothing is on.

## Risks / Trade-offs

- **A future display name whose first word is not the family** — for instance a vendor prefix — would render as that first word and lose the family. → No such name exists today, and the failure is visible the moment it happens: the badge would read something obviously wrong rather than silently showing the wrong model. Revisit the expansion then rather than pre-empting a shape nobody has seen.
- **`[OFF]` and `[LITE]` are less self-describing than `[CAVEMAN:OFF]`** to someone who has not seen the line before. → The line has one reader, who chose the change. The set of values is small and fixed, and the badge holds a stable position.
- **Verification is by eye.** The script has no test harness, and its output is a colour-coded line. → Each task checks the script by piping a fixture payload into it and reading the printed line, which exercises the same code path Claude Code does without needing a live session.

## Migration Plan

None. The script is read fresh on every status line render, so the change takes effect at the next render with no restart and no state to migrate. Reverting is `git revert` of the one commit.
