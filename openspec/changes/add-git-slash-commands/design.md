## Context

See proposal.md — Why. The commands live in `.claude/commands/git/` inside the home configuration repository, so they ship to every machine that clones it and are available in whatever repository the session is working in.

Two facts about the environment shape the design. First, the home repository is deny-by-default and its tracked specification forbids `git add -A`, `git add .`, and `git add -u`; a commit-time guard rejects denylisted or secret-looking staged content. Second, interactive git flags are unavailable in this harness — `git rebase -i` and `git add -i` cannot be driven — so any history rewriting must be expressed with non-interactive plumbing.

`.claude/commands/` is already in the repository's allowlist, so new command files are trackable with no ignore-rule change.

## Goals / Non-Goals

**Goals:**

- One shared rule set behind all seven commands, written once rather than copied into each file.
- Every command safe to run on a dirty or unusual repository state: it either does the obvious right thing or stops with a clear reason.
- Command files that stay readable as prompts — the judgement calls (commit message, squash boundary, session scope) belong to the model, and the mechanical parts are spelled out as exact git invocations.

**Non-Goals:**

- No wrapper scripts, hooks, or aliases. These are prompt files only.
- No conflict resolution. Every conflicting operation stops and hands the repository back.
- No rebase, cherry-pick, stash, tag, or worktree verbs in this change.
- No `clone`. `/git:init` initializes a directory in place and points a remote at it; obtaining an existing repository's history is a different operation and is not in this set.
- No change to the home repository's ignore policy or commit guard.

## Decisions

### Prompt files, not shell scripts

Each command is a markdown prompt under `.claude/commands/git/<name>.md` with `description` and `allowed-tools` frontmatter, matching the existing `.claude/commands/opsx/` files.

A shell script would be more deterministic, but every command in this set has a judgement step that a script cannot make: which dirty paths belong to this session, what the commit message should say, where the current feature's commits begin. Scripting the mechanical half and prompting the judgemental half would mean two artifacts per command to keep in step. Alternative rejected: a single `/git` command dispatching on a subcommand argument — the user asked for `/git:command`, and separate files give each verb its own `allowed-tools` and description in the picker.

### Shared rules in one referenced file

The rules common to every command — staging discipline, commit message style, published-history detection, conflict handling, the closing report — live in `.claude/commands/git/conventions.md`, and each command file opens by instructing the assistant to read `~/.claude/commands/git/conventions.md` and follow it.

An `@`-reference would inline the file automatically, but these commands run in whatever repository the session is working in, and a relative `@.claude/...` reference resolves against that project rather than the home directory. An explicit read of the absolute path is unambiguous everywhere.

Because every `.md` under a commands directory registers as a command, this file is also reachable as `/git:conventions`; that is made deliberate by giving it a description that reads as documentation ("show the rules the /git:* commands follow"), which is useful in its own right. Alternatives rejected: duplicating the rules into seven files (they drift), or putting them outside `.claude/commands/` (that path is not allowlisted and would require an ignore-policy change the proposal explicitly avoids).

### Always stage by explicit path, in every repository

`git add -A` and friends are never used, even for `/git:push all`. The dirty set is read from `git status --porcelain` and each path is passed to `git add -- <path>` by name.

This makes the home repository's staging rule the universal rule instead of a special case, so no command needs to detect which repository it is in, and it has a second benefit everywhere: the set of paths is known before staging, so the report can list exactly what went in and what was skipped. The cost is a longer command line on very large diffs, which is acceptable — the paths are batched into a single `git add --` invocation.

### Session scope comes from the assistant's own edit record

`/git:push` with no argument and `/git:append` select paths the assistant created or modified through its tools during the present conversation, intersected with the porcelain dirty set.

The alternative heuristics are worse: mtime-since-session-start sweeps in editor autosaves, formatter runs, and background tool output; `git diff` against a session-start stash requires taking a snapshot the user never asked for. The edit record is the only signal that actually means "this session did it". Its weakness is that it can be lost or become uncertain — after a long conversation, or when the user edited files by hand alongside the assistant — and the spec answers that by requiring the command to ask rather than guess.

### Squash by soft reset, not interactive rebase

`/git:squash N` runs `git reset --soft HEAD~N` and then a single `git commit` with the regenerated message. The tree is untouched by construction, so the result is identical to a successful interactive squash without needing an editor or an interactive terminal.

Preconditions are checked first: no uncommitted changes, `N` no greater than the commit count, no merge commit in the range, and the range must not reach past the merge-base with the upstream default branch. For `/git:squash *`, the count is chosen by reading `git log` for the boundary of the current line of work — typically the merge-base with the upstream branch, or the point where the subjects stop belonging to one feature — and the chosen count is reported before anything is rewritten.

### Published-history detection before any rewrite

Before `/git:squash` or `/git:append` rewrites anything, each commit in the range is tested with `git branch -r --contains <sha>`. If nothing comes back for every commit, the rewrite proceeds silently; if any commit is contained in a remote-tracking ref, the command names those commits and asks first.

When the user confirms, the follow-up push uses `git push --force-with-lease` so a remote that moved since the last fetch aborts the push instead of being overwritten. Plain `--force` is never used.

### Mergeinto ends on the target, including on conflict

`/git:mergeinto BRANCH` switches to `BRANCH` (obtaining it by the same local/remote/create rule as `/git:switch`), fast-forwards it to its upstream if it has one, merges the original branch in, and stays there.

On conflict it stays on `BRANCH` with the merge in progress. Returning to the original branch would require aborting the merge and discarding the user's position in the work, which is the opposite of helpful. The merge result is not pushed — publishing another branch is a separate decision, and `/git:push` is the way to make it.

### Init registers a remote without contacting it

`/git:init [REPO]` runs `git init` and, when a URL is given, `git remote add origin <REPO>`. It stops there: no initial commit, no staging, no push, and no attempt to reach the remote.

Not contacting the remote is deliberate — the common case is a repository just created empty on the host, or one that does not exist yet, and failing initialization because a URL is not yet live would be wrong. The URL is validated by shape only (HTTP(S) or SSH remote specifier), which is enough to catch a mistyped argument such as a branch name or a local path passed by accident. The initial branch name is left to the user's git configuration rather than forced, so a machine with `init.defaultBranch` set keeps its setting.

Running inside an existing repository never reinitializes: `git init` there is nearly a no-op but the intent is ambiguous, so the command reports the existing root instead, and offers to add `origin` if that is the part that is missing. An `origin` that already points elsewhere is a conflict the user must settle, not one to overwrite.

### Fetch is deliberately narrow

`/git:fetch` runs `git fetch origin` and nothing else — no `--all`, no `--prune`, no implicit pull. It is the command for the moment when the user wants remote-tracking refs refreshed without touching the working tree, so its value is in being predictable. The reporting is where the work is: it says what arrived and whether the current branch is now behind, and points at `/git:pull` when it is.

Other commands keep their own targeted fetches (see below) rather than depending on the user having run this one.

### Cleanup proposes, then deletes once confirmed

`/git:cleanup` never deletes anything before showing what it would delete. It fetches with `--prune`, builds the candidate list, prints it grouped by reason, and asks once for the whole plan; the user can approve all of it or name a subset.

Candidates come from two signals, because `git branch --merged` alone misses the common case. The first is genuine ancestry: a local branch contained in the default branch, found with `git branch --merged <default>`. The second is a branch whose upstream has disappeared after the prune — `git branch -vv` marking it `: gone]` — which is what a squash-merged or rebase-merged pull request leaves behind. The second signal is reported as a distinct, weaker reason, because a gone upstream can also mean someone deleted the remote branch by mistake; the confirmation step is where that is caught.

Local deletions use `git branch -d`, never `-D`, so a branch that turns out to hold unmerged commits refuses to be deleted and is reported instead of forced. The current branch and the default branch are excluded unconditionally. Remote branches are deleted only when the user explicitly approves that part, since `git push origin --delete` reaches outside the machine and affects everyone using the repository; protected or default remote branches are never offered.

Alternative rejected: a `--dry-run`-style argument that makes deletion the default. Inverting it — propose first, always — costs one confirmation and removes the failure mode where a mistyped flag deletes branches the user wanted.

### Commit is push minus the publishing half

`/git:commit [all]` shares the whole staging half of `/git:push` — the scope rule, staging by explicit name, the message written from the staged diff — and stops before the push. It exists because committing and publishing are separate decisions: work-in-progress worth a checkpoint is often not worth putting on a remote, and on a shared branch the push is the part with consequences.

The two commands are kept as separate files rather than `/git:push` growing a "don't push" flag, because a flag that suppresses the main verb reads wrong at the call site and is easy to forget. The shared half lives in `conventions.md`, so the duplication between them is a few lines of scope selection, not the rules themselves.

Two differences from `/git:push` follow from never contacting a remote. A detached HEAD is fine — committing does not need a branch, so the command commits and warns rather than stopping as `/git:push` does. And a repository with no remote is not a special case at all.

### Model and effort are set per command

Each command file carries `model:` and `effort:` frontmatter, tuned to what that command actually has to decide. Claude Code accepts both keys on a slash command: `model` takes an alias (`sonnet`, `opus`, …) and `effort` takes `low`, `medium`, `high`, `max`, or an integer.

| Command | Model | Effort | Why |
| --- | --- | --- | --- |
| `conventions`, `fetch`, `init` | `sonnet` | `low` | A fixed sequence and a report; `init`'s only judgement is a URL shape check. |
| `pull`, `switch`, `merge` | `sonnet` | `medium` | A small decision tree over repository state, with every stop condition spelled out. |
| `mergeinto`, `cleanup` | `sonnet` | `high` | Several state transitions, and a mistake is expensive: the wrong branch mid-merge, or a deleted branch. The reasoning is still mechanical, so the model tier does not need to change. |
| `commit` | `sonnet` | `low` | Same judgement as `push` — scope and message — but nothing leaves the machine, and both failure modes are cheap to undo locally. |
| `push`, `append` | inherit | `medium` | Session-scope selection and commit message quality are judgement, so these stay on the session's main model; the work itself is short. |
| `squash` | inherit | `high` | `*` infers where the current line of work begins and the message is regenerated from a combined diff — the most judgement in the suite. |

`model` is omitted rather than pinned to `opus` on the last three, so they follow whatever main model the session is running.

`/git:commit` is where that reasoning is easiest to see. It makes the same two judgements as `/git:push` — which paths belong to this session, and what the message says — but its mistakes stay local: an over-broad scope is undone with `git reset --soft HEAD~1`, and a weak message is fixed by `/git:append`. Nothing is published, so a cheaper model is a fair trade. `/git:push` makes the same calls with a remote at the end of them, which is why it stays on the main model.

The split is drawn on failure mode, not on how destructive the command is. Every destructive path in this suite is already gated by an explicit confirmation of a named list, so what a weaker model can get wrong there is the proposal, which the user reads before approving. Where a weaker model would be wrong *silently* — a commit message that misdescribes the change, a session-scope guess that sweeps in someone else's work, a squash boundary in the wrong place — the command keeps the main model.

### Fetch only where a decision depends on it

`/git:switch` and `/git:merge` fetch before concluding that a branch does not exist, because the answer changes what they do. `/git:push` does not fetch preemptively; it pushes and reads the rejection if the upstream has moved, then points at `/git:pull`.

## Risks / Trade-offs

- **The session edit record is imperfect** → When the set cannot be determined confidently, the command lists the dirty paths and asks instead of staging. `/git:push all` remains the escape hatch, and the report always names what was left behind.
- **A regenerated squash or amend message can lose detail the old subjects carried** → The message is written from the combined diff, and the original subjects are read first so nothing meaningful is dropped; for `*`, the chosen range is reported before the rewrite.
- **`--force-with-lease` can still overwrite a collaborator's work if the local remote-tracking ref is stale from an earlier fetch** → The rewrite path already requires explicit confirmation naming the published commits, which is the real guard; the lease is the second line of defence.
- **`/git:mergeinto` leaves the user on a different branch than they started on** → That is the command's stated contract, and the closing report says which branch is now checked out.
- **`/git:cleanup` deleting a branch someone still needed** → Nothing is deleted without an explicit confirmation of a named list; local deletes use `-d` so unmerged work refuses to be dropped; remote deletion is approved separately from local; a deleted local branch whose commits are merged is recoverable from the default branch, and any local delete is recoverable from the reflog for as long as it is retained.
- **Ten prompt files can drift from each other** → The shared half lives in one file that all of them reference.
- **A repository with an unusual commit convention could get a mismatched message** → Message style is inferred from that repository's own recent history rather than hardcoded.

## Migration Plan

Additive: create the files, commit them with the repository's explicit-staging rule, push. Rollback is deleting `.claude/commands/git/`; nothing else references it.
