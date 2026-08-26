---
description: Show the shared rules the /git:* commands follow
model: haiku
effort: low
allowed-tools: Bash(git:*), Read
---

# Conventions for the `/git:*` commands

Every `/git:*` command follows the rules below. Invoked on its own, this command prints them so the rules can be reviewed without running an operation.

## Preconditions

- Run `git rev-parse --show-toplevel` first. If it fails, the working directory is not a git repository: stop, say so, and suggest `/git:init`. `/git:init` is the only command exempt from this check.
- Work on the repository the session's working directory is in. Never assume the home configuration repository's layout, branch names, or remote.
- Never pass `--no-verify` and never disable hooks in any other way. If a hook rejects a commit or a push, report its output verbatim and stop.

## Staging discipline

- Read the dirty set with `git status --porcelain` and stage each path by name: `git add -- <path> <path> ...`.
- Never use `git add -A`, `git add .`, or `git add -u`. This holds in every repository, including for `/git:push all`.
- Never force-add a path that an ignore rule matches. Report it as skipped instead.
- Because the paths are known before staging, the closing report can always name exactly what went in and what was left out. Do that.

## Session scope

Commands that stage "this session's work" — `/git:push` with no argument, and `/git:append` — select paths this way:

1. Take the paths created or modified through tool calls during the present conversation.
2. Intersect them with the dirty set from `git status --porcelain`.
3. A session path that is no longer dirty is dropped silently; that is not an error.

If the session's edit record is unavailable or the correct set is genuinely uncertain — for instance after a long conversation, or when the user has been editing by hand alongside the assistant — do not guess. Show the dirty paths and ask which to include before staging anything.

## Commit messages

- Read recent subjects with `git log --oneline -20` and match the style already in use. Use a conventional-commit prefix only where the history already uses one.
- Write the subject from the actual change, naming what changed rather than listing file names. Add a body when the subject alone does not explain the change.
- Do not add a co-author or tool-attribution trailer unless the repository's own configuration or recent history uses one.

## Published history

Before rewriting any commit — `/git:squash`, `/git:append` — check each commit in the range with `git branch -r --contains <sha>`.

- If no commit in the range appears on any remote-tracking ref, rewrite without asking.
- If any commit does, stop, name those commits, and ask for explicit confirmation before rewriting.
- After a confirmed rewrite, push with `git push --force-with-lease`. Never use plain `--force`.

## Conflicts and destructive operations

- Never resolve a conflict unprompted. On conflict, stop, name the conflicted paths, and leave the repository in the state git put it in — do not abort the operation for the user.
- Never discard, stash, or check out over uncommitted changes to get an operation moving. Stop and report the blocking paths instead.
- Deleting branches, force-pushing, and overwriting a configured remote all require an explicit confirmation of a named list first.

## Reporting

Every command ends with a short report.

- On success: the branch, what was done, any new or rewritten commit, and anything deliberately left untouched.
- On stopping: why it stopped, the shortest decisive line of git's own output quoted, and the next step to take. Do not clean up behind a failure; leave the repository as git left it.
- The report names what the command did. It never restates what the status block below it already shows — the counts, the branch position, or the file list.

## Closing status

A command that changed what the status block shows ends by rendering that block, so the last thing on screen is where the repository actually ended up.

- The commands that do it: `/git:init`, `/git:fetch`, `/git:commit`, `/git:push`, `/git:pull`, `/git:switch`, `/git:squash`, `/git:append`, `/git:merge`, `/git:mergeinto`, and `/git:cleanup`. `/git:status` is the block, and `/git:conventions` changes nothing, so neither adds one.
- `/git:fetch` is included even though it touches no file: it moves the remote-tracking refs the ahead and behind counts are measured against.
- The block goes last, after the prose report. The report says what was done; the block says where things stand.
- Only on success. A command that stopped on a precondition, a git failure, or a rejected hook prints its stop report and nothing else — no block, and no extra git commands run to build one.
- Only after the fact. A command waiting on a confirmation has changed nothing yet; it renders the block once the confirmed action completes.
- Building the block is read-only. It uses the same reads `/git:status` uses and changes nothing itself.

## The status block

The block below is the shared render contract. `/git:status` prints it as its whole output, and every command listed under **Closing status** prints the same block to close a successful run. It is described here once so the two cannot drift apart; no command restates any part of it.

### What it is built from

Run these, and nothing else:

- `git status --porcelain=v1 -uall --branch` — the dirty set, with untracked directories expanded to individual files and the branch header included.
- `git diff --numstat` and `git diff --cached --numstat` — line counts for the summary, when the dirty set is non-empty.

`-uall` is what makes the tree real: without it an untracked directory collapses to a single `dir/` entry and its contents never appear.

Read the branch from the `##` header those produce, which has three forms: `## main...origin/main [ahead 2]` when an upstream exists, `## main` alone when there is none, and `## HEAD (no branch)` when HEAD is detached. Only the detached case needs a fourth read — `git rev-parse --short HEAD` — because the header carries no sha.

If the dirty set is empty, print the status line alone — no legend, no tree. Do not add a sentence saying the tree is clean: `✅0 ✏️0 ❓0 💥0` already says it, and `⇡0 ⇣0` already says the branch is level.

### The session column

Split the dirty paths into the ones the present conversation created or modified through tool calls and the ones it did not, using the session-scope rule above.

Uncertainty here is never a reason to ask, in `/git:status` or in a closing block: rendering the block must not block on a question. When the session edit record is unavailable or untrustworthy, leave the session column blank on every row and say once beneath the block that ownership could not be determined — do not guess per file.

### Building the tree

Split each path on `/` and merge the paths into one tree.

- Collapse a directory that has exactly one child directory and no files of its own into its parent, joined with `/` — `.claude/commands/git/` rather than three nested levels. This keeps deep, narrow paths on one line.
- Sort directories before files, each group alphabetically.
- Never invent an entry. Only paths git reported appear in the tree, so a directory shows only the children that actually changed.
- If a single untracked directory holds more than 20 files, do not list them. Show the directory with a count instead — `📁 build/ (147 untracked)`. The count in the tree is the whole report of it; do not add a sentence about it underneath.
- Ignored paths are never listed. `--ignored` is not passed.

### Colour

The whole output goes in a single ```diff fenced block, because that is the only mechanism that reaches the terminal with colour intact. ANSI escape sequences do not survive the trip and must never be emitted. The fence's syntax highlighting gives exactly four colours, selected by the first non-space character of each line:

| Line begins with | Colour | Used for |
| --- | --- | --- |
| `+` | green | the change is staged — in the index, and `/git:commit` would carry it |
| `-` | red | the path is conflicted and needs resolving before anything else |
| anything else | default | everything else: unstaged and untracked entries, directory rows, the legend, and the status line |

Colour carries staged-ness rather than direction because staged-ness is the thing that gets acted on — it is precisely what `/git:commit` will and will not pick up — and the emoji already says whether content was added, modified, or deleted, so colouring direction would only repeat it. The consequence to accept: a staged deletion renders green. The `❌` carries that, and green there means "staged", not "added".

The grammar offers a fourth colour, dark grey, but only inside `@@ … @@` — the delimiters are the mechanism, not decoration, so anything grey wears them on screen. Nothing in this output is worth that: the legend and the status line are both short, both read directly, and both look like stray diff-hunk headers once wrapped. Grey is therefore unused, `@@` never appears, and the palette is green, red, and default.

Leading whitespace does not defeat the marker, so the tree indents normally.

### States

One emoji per entry, and nothing else — no word beside it. The legend is therefore not optional decoration: with the word gone it is the only place the mapping is written down, so it is printed on every non-empty tree.

| Emoji | Meaning | Porcelain |
| --- | --- | --- |
| `❓` | untracked | `??` |
| `➕` | added to the index | `A ` |
| `✏️` | modified | ` M`, `M `, `MM`, `AM`, `MD` |
| `❌` | deleted | `D `, ` D` |
| `🔀` | renamed | `R `, `RD` |
| `📋` | copied | `C ` |
| `🔁` | type changed | `T `, ` T` |
| `💥` | conflicted | `UU`, `AA`, `DD`, `AU`, `UA`, `DU`, `UD` |
| `📁` | a directory | — |
| `👻` | changed outside this session | — |
| `✅` | staged | the green rows; also the staged count in the status line |
| `🟢` | lines added | the status line only |
| `🔴` | lines removed | the status line only |

`🟢` and `🔴` never appear in the tree; they label the two line totals on the status line and nowhere else. Note that `🟢` and the green row colour are not the same signal — green on a row means staged, while `🟢` counts added lines — which is why the legend names both.

`✅` is the one state with no column of its own. Staged-ness is carried by the green colour on the row, so `✅` appears only where staged has to be named in words — the status line's count, and the legend's gloss on what green means. Do not add it as a second emoji beside the state emoji; that would spend a column repeating the colour.

Every emoji above must occupy two columns, because that is the grid the tree is aligned on. Most are single double-width codepoints and are safe anywhere. `✏️` is the exception: it carries a trailing `U+FE0F` variation selector, and such glyphs — `🗑️` and `⚠️` are others — render one column wide in some terminals and two in others. It is used here because it was checked by eye in the target terminal and aligns. Apply the same test before substituting any emoji, and prefer a variation-selector-free codepoint when one will do. Do not add an emoji for the file's type; the extension in the name already says that.

Directories always end in `/`. Files never do.

### Output format

The block reads legend first, then tree, then status line. The legend goes on top because it is the key to everything below it, and the status line goes on the bottom because it is the summary you are left holding when you finish reading — and because it sits directly above whatever is said outside the fence.

#### Entry lines

Every entry is built from four fields at fixed widths, so the left edge reads as a status column and the tree hangs off it:

    <marker><session><state><indent><name>

- **marker** — `+` when the change is staged, `-` when it is conflicted, a space otherwise, followed by a space. Two columns. This is the field that carries the colour.
- **session** — `👻` when the path was changed outside this conversation, two spaces when this session touched it, followed by a space. Three columns. Held in a fixed column so foreign entries line up as a scannable column instead of hiding at varying tree depths.
- **state** — the emoji from the table above, followed by a space. Three columns. Directory rows leave this field blank.
- **indent** — two spaces per tree level, so the names form the tree.
- **name** — the file name, or `📁 <dir>/` on a directory row.

The three fixed fields total eight columns, so an entry at tree level `N` puts its name at column `8 + 2N` and a directory row puts its `📁` there. Every row lines up on that grid, whatever its depth.

#### Legend — first line

A single plain line, no wrapping of any kind. It gives the meaning of every state appearing in this tree, glosses the colour as `✅ green = staged`, and ends with `🟢🔴 tracked lines` to supply the unit and scope of the two totals on the status line. Omit it only when the tree is empty.

#### Conflicts — directly beneath the legend

If any path is conflicted, put `- <N> conflicted — resolve before anything else` immediately under the legend, so it lands in red above the tree. Conflicts come first because they block everything else, and the status line at the bottom is too late to learn about them.

#### Status line — last line

One plain line, no `@@` wrapping:

    [⎇ <branch>] ⇡<ahead> ⇣<behind> | ✅<staged> ✏️<unstaged> ❓<untracked> 💥<conflicted> | 🟢<added> 🔴<removed>

- All four counts are always printed, including zeros. A fixed shape means the number you want is always in the same place, and `💥0` is worth seeing.
- `🟢<added> 🔴<removed>` is one combined figure summed across both numstats, not one per stage. Keeping it as emoji-plus-number makes the whole line one shape; an earlier version wrote it as a bare `+190 −4`, which sat beside four emoji-labelled file counts and read as a fifth count of files. The unit and the tracked-only scope are stated in the legend rather than trailed after the numbers here.
- Untracked lines are deliberately not counted. Getting them would mean a `git diff --no-index` per untracked file, which is unbounded — a directory caught by the twenty-file cap would cost twenty subprocess calls to produce a number nobody asked for. The file count is the useful figure there, and it is already shown.
- With no upstream, replace `⇡N ⇣N` with `no upstream`. On a detached HEAD, the branch field reads `⎇ detached @<short sha>` and the ahead/behind field is dropped.

#### Renames

A rename occupies one porcelain line carrying both paths, written `R  <old> -> <new>`. Take the entry's position in the tree from the **new** path, and render it as `new-name ← old-name`. When the rename crosses directories, show the old path in full after the arrow so the move is readable; within one directory the bare old name is enough.

### Example

A branch two commits ahead, with one file left dirty by an earlier session. Note that nothing follows the block:

```diff
✅ green = staged · ❓ untracked · ✏️ modified · 🔀 renamed · ❌ deleted · 👻 other session · 🟢🔴 tracked lines
        📁 .claude/commands/git/
+    ❓    status.md
+    ✏️    conventions.md
        📁 src/
          📁 render/
+    🔀      icons.ts ← glyphs.ts
     ✏️      tree.ts
  👻 ✏️    index.ts
+    ❌  notes.md
[⎇ feature/tree-status] ⇡2 ⇣0 | ✅4 ✏️2 ❓1 💥0 | 🟢84 🔴12
```
