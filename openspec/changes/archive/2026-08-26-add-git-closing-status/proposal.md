## Why

Every `/git:*` command that changes the repository ends with a prose report, and the natural next move is to run `/git:status` to see the resulting tree. That is a second command, a second model turn, and a gap in which the reader has only the prose to go on. The tree is the clearest statement of where the repository ended up, so the command that moved it should print it.

Separately, the suite's model assignments have drifted. Three commands — `push`, `append`, `squash` — carry no `model` field at all, so they run on whatever the session is using, which is the largest model available. Others sit on `sonnet` regardless of how much judgment they actually need. Nothing has been decided deliberately about which commands are cheap enough to run on a faster model, and adding a rendered tree to every mutating command makes that decision worth making now rather than paying for it on every invocation.

## What Changes

- Add a closing status block to every `/git:*` command that changes what the status block shows: `init`, `fetch`, `commit`, `push`, `pull`, `switch`, `squash`, `append`, `merge`, `mergeinto`, and `cleanup`. The block is rendered exactly as `/git:status` renders it, and it comes last, after the command's own report.
- Print the closing block only on a successful run. A command that stops on a precondition or a git failure keeps its existing stop report and adds nothing.
- Factor the render contract — legend, tree, entry-line fields, colour, status line — out of `status.md` into a single description both `/git:status` and the closing block follow, so the two cannot drift apart.
- Assign every command in the suite an explicit `model` by risk tier: a fast model for the command that only prints text, the mid-tier model for bounded mutations and message writing, and the largest model for the commands that rewrite published history or delete refs. No command is left inheriting the session model.

## Capabilities

### New Capabilities

<!-- None. This extends the existing suite rather than introducing a separate capability. -->

### Modified Capabilities

- `git-slash-commands`: the reporting requirement gains the closing status block; the status requirement's render contract becomes a shared contract rather than one command's output format; and a new requirement fixes the model tier each command runs on.

## Impact

- `~/.claude/commands/git/conventions.md` gains the closing-status rule and the shared render contract; every mutating command file gains a line pointing at it; `status.md` is rewritten to reference the shared contract instead of holding it.
- Every command file's frontmatter gains or changes a `model` field.
- Each mutating command's output grows by the block — one line when the tree is clean, more when it is not.
- No change to what any command does to the repository. The closing block is read-only, built from `git status --porcelain` and the two `--numstat` reads that `/git:status` already uses.
