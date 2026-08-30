## Why

The status line is one line of terminal width shared with the prompt, and three of its badges spend characters on labels that say what the reader can already see. `[CAVEMAN:LITE]` names the subject of a badge that has no other possible subject; `[Opus 5 · effort:xhigh]` carries a version number that never varies within a session and the word `effort` in front of a value that is obviously one; and `folder on branch` spends a whole word on a relationship that a colon states. None of the three carries information — each is the label of a field whose value already identifies it.

## What Changes

- Render the caveman badge as its level alone — `[LITE]`, `[OFF]`, `[FULL]` — dropping the `CAVEMAN:` prefix.
- Render the model badge as `[<model>:<effort>]`, dropping the ` · ` separator, the word `effort`, and everything in the model's display name after its family — `[Opus:xhigh]` rather than `[Opus 5 · effort:xhigh]`.
- Join the directory and branch with a colon — `personal-config:main` — rather than the word `on`.
- Leave every other badge as it is: the git pending counts, the fast-mode marker, and the context percentage all keep their present form.
- No change to what the status line reports. The same fields, the same values, the same order, the same colours — only shorter.

## Capabilities

### New Capabilities

- `claude-status-line`: what the Claude Code status line reports and the form each field takes — the rule that a field's value identifies it without a label, how the model name is shortened, and what the line degrades to when a field has no value.

### Modified Capabilities

None. `caveman-mode-default` governs which intensity a session starts at, not how the status line renders it, and no other capability describes this line.

## Impact

- `.claude/statusline-command.sh` — the three `printf` sites that build the caveman badge, the model badge, and the final line.
- Nothing else reads this script. It is invoked by the `statusLine` entry in `.claude/settings.json`, which does not change.
- No new dependency. The model shortening is a shell parameter expansion, not a new tool.
