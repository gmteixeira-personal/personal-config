## 1. Capture the baseline

- [x] 1.1 Build a fixture payload that carries `current_dir`, a `display_name` of `Opus 5`, an `effort.level` of `xhigh` and a `context_window.used_percentage`, save it outside the repository, and record what `bash .claude/statusline-command.sh < fixture` prints today — verifying the capture is non-empty and contains `CAVEMAN:`, ` on `, and `effort:`

## 2. Shorten the fields

- [x] 2.1 Render the caveman badge as its level alone and verify the fixture output shows `[LITE]` when the caveman flag file holds `lite` and `[OFF]` when the flag file is absent, with `CAVEMAN` appearing nowhere in either
- [x] 2.2 Render the model badge as the family name and effort joined by a colon — dropping the ` · ` separator, the word `effort`, and everything in the display name after the first space — and verify the fixture output shows `[Opus:xhigh]`, that a `Haiku 4.5` fixture shows `[Haiku:...]`, and that a fixture with `fast_mode` true keeps the fast-mode marker against the family name
- [x] 2.3 Join the directory and branch with a colon in the final `printf` and verify the fixture output opens with `<dir>:<branch>` and that ` on ` appears nowhere in the line

## 3. Verify the fields that have no value

- [x] 3.1 Verify a fixture with a `display_name` but no `effort` prints the family name alone with no trailing colon inside the badge
- [x] 3.2 Verify a fixture whose `current_dir` is a directory outside any git repository prints the directory name alone, with no trailing colon and no git badge
- [x] 3.3 Verify a fixture whose `current_dir` is a repository with a detached HEAD prints the short commit hash after the colon

## 4. Verify the change as a whole

- [x] 4.1 Compare the fixture output against the baseline from 1.1 and confirm the same fields appear in the same order with the same colours, differing only in the three shortenings
- [x] 4.2 Confirm the live status line renders correctly in a running session, with the shortened caveman, model and directory fields all present
- [x] 4.3 Run `openspec validate shorten-status-line --strict` and confirm it passes
