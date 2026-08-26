## Context

See `proposal.md` — Why. Design-relevant facts about this particular `$HOME`:

- **Secrets present right now**: `.ssh/id_ed25519` (private key), `.claude/.credentials.json`, `.config/gh/hosts.yml` (GitHub OAuth token), `.ghtoken`, `.claude.json` (76 KB, project state), and the history files `.bash_history` (20 KB), `.psql_history`, `.viminfo`.
- **Bulk**: `.vscode-server` 2.7 GB, `.nuget` 2.6 GB, `.local` 3.2 GB, `.cache` 1.4 GB, `.dotnet` 1.3 GB, `.npm` 410 MB, `.claude/projects` 359 MB, `.nvm` 289 MB, `.cargo` 234 MB. Roughly 12 GB that git must never walk.
- **`.claude` is mixed**: `settings.json`, `commands/` (68 KB), `skills/` (88 KB), `statusline-command.sh` are wanted; `projects/`, `file-history/`, `history.jsonl`, `session-env/`, `plugins/`, `.credentials.json` are not. So `.claude/` cannot be denied wholesale — the split runs inside it.
- **`.claude/settings.json` is already a plugin manifest**: it carries `extraKnownMarketplaces` (`caveman` → `github:JuliusBrussee/caveman`) and `enabledPlugins` (`caveman@caveman: true`, `frontend-design@claude-plugins-official: false`). `.claude/plugins/` (13 MB) is what Claude Code builds *from* that: cloned marketplace repos under `marketplaces/`, plus `cache/`, `data/`, and `installed_plugins.json`/`known_marketplaces.json` whose `installLocation` fields are absolute paths into this machine's home directory.
- **`.claude/settings.json` also carries organizational context**: its `autoMode.environment` block names a private repository (a private work repository) and its URL, branch-workflow policy, internal tooling, and a second username. Not a credential — but not publishable as-is either.
- **WSL artifacts**: `.claude/settings.json:Zone.Identifier` and `.claude/statusline-command.sh:Zone.Identifier` are Windows alternate-data-stream leftovers sitting beside wanted files.
- **`.config/nvim` is a git repository**: remote `https://github.com/gmteixeira-personal/nvim-config`, working tree clean, `main` level with `origin/main`. It carries its own `.gitignore`, `.claude/`, and `openspec/` subtrees.
- **The remote is public and empty.** Every tracking decision assumes the content becomes world-readable.

Requirements are in `specs/dotfiles-repo/spec.md` and `specs/dotfiles-ignore-policy/spec.md`.

## Goals / Non-Goals

**Goals:**

- One `.gitignore` whose behavior for any path is decidable by reading it top to bottom, and auditable per-path with `git check-ignore -v`.
- `git status` at `$HOME` completes in seconds, never descending into the ~12 GB of ignored trees.
- Two independent barriers against publishing a secret: the ignore file, and a commit-time guard that fires even when the ignore file is bypassed with `-f`.

**Non-Goals:**

- No symlink farm, no GNU Stow, no `chezmoi`, no bare-repo-with-alias scheme. The repository is the home directory, plainly.
- No per-machine templating or branching. One branch, one config; environment differences are handled inside the config files themselves if they ever arise.
- No secret management. Secrets stay out; nothing here encrypts or vaults them.
- No migration of the `nvim-config` commit history.

## Decisions

### D1: Allowlist via `*` + `!*/`, with the denylist placed last

`.gitignore` is ordered in four blocks:

```gitignore
# 1. baseline: ignore everything
*

# 2. but keep directories traversable, so nested allowlist entries can reach
!*/

# 3. allowlist: explicitly named files and subtrees
!/.bashrc
!/.claude/commands/**
...

# 4. denylist: security + bulk. LAST, so it overrides block 3.
.ssh/
.cache/
...
```

Git applies last-match-wins, which gives each block its role: block 2 overrides block 1, block 3 overrides block 2, block 4 overrides block 3. Two consequences worth stating because they are easy to get wrong:

- **`!*/` is what makes nested allowlisting work at all.** Git will not re-include a file whose parent directory is excluded, so without block 2 an entry like `!/.claude/settings.json` is silently inert and every level would need its own `!/.claude/` + `.claude/*` pair. With block 2, one line per wanted path suffices.
- **Directory allowlist entries need `/**`.** `!/.claude/commands/` re-includes only the directory; the files inside still match `*` from block 1. `!/.claude/commands/**` re-includes the contents.

Block 4 also carries the performance property. `!*/` alone would make git walk all 12 GB; re-ignoring `.cache/`, `.local/`, `.vscode-server/` and friends *after* it means those directories match as ignored directories again, and git prunes the walk instead of descending.

*Alternatives considered.* A bare repo with a `config` alias and `status.showUntrackedFiles=no` is the common dotfiles trick, but it hides untracked files rather than ignoring them — the safety property becomes "you did not look", which is the wrong guarantee for a directory holding a private key. Stow/chezmoi add a tool dependency and an indirection layer for a problem that is one `.gitignore` here.

### D2: Denylist is both path-specific and pattern-based

Named paths (`.ssh/`, `.config/gh/hosts.yml`, `.claude/.credentials.json`, `.ghtoken`, `.claude.json`, `.bash_history`, `.psql_history`, `.viminfo`) cover what exists today. Patterns cover what appears tomorrow: `id_*` with `!*.pub` re-allowed, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `.env`, `.env.*`, `*_history`, `*.history`, `*credential*`, `*secret*`, `*token*`, `.netrc`, `.npmrc`, `.pypirc`, and `*:Zone.Identifier` for the WSL leftovers.

The patterns are deliberately over-broad. A false positive costs one line of deliberation before a force-add; a false negative costs a leaked key on a public repository. Where a pattern would swallow something wanted, the fix is a narrower named exception in block 3, never a loosening of block 4 — because block 4 is the thing the commit guard also reads.

### D3: Commit guard at `core.hooksPath`, not `.git/hooks`

The guard lives at `.githooks/pre-commit` — a tracked file — and is activated with `git config core.hooksPath .githooks`. Git does not clone hooks and does not clone repo-local config, so `.git/hooks/pre-commit` would exist only on this machine and vanish on every new environment. Tracking the script means the *content* travels; the one-line `config` command is then a documented bootstrap step rather than a rewrite.

The guard checks the staged set two ways: staged **paths** against the denylist patterns, and staged **content** for private-key headers (`-----BEGIN ... PRIVATE KEY-----`), `ssh-ed25519`/`ssh-rsa` private blocks, and high-entropy token literals (`ghp_`, `github_pat_`, `gho_`, `sk-`, `AKIA`). Content matters because the ignore file guards filenames, and a token pasted into `.bashrc` has an entirely innocent filename.

*Alternative considered.* `gitleaks` or `pre-commit` framework — better detectors, but a runtime dependency on every environment this repo is meant to bootstrap. A dependency-free shell script that runs on any machine with git is the right trade here; a stronger scanner can be layered on later without changing the contract.

### D4: `.config/nvim` absorbed by copy, not by subtree

Per the decision recorded in the proposal: remove `.config/nvim/.git` and track the files here. Chosen over the alternatives:

- **Submodule** — keeps history, but every clone needs `--recurse-submodules`, and updating config becomes a two-repo commit dance. Rejected for daily friction.
- **`git subtree add --prefix=.config/nvim`** — grafts the full history into this repo. Rejected because it requires the target path not to exist, meaning a move-aside/restore dance, and it imports commit history for a subtree whose value is its current state.

The safety property that makes plain absorption acceptable: `nvim-config` is clean and level with its remote, so its history is not being destroyed — it stays on GitHub, and the local `.git` is a copy. The implementation still archives that `.git` directory to a scratch location before deleting it, so the step is reversible for the duration of the work.

After absorption, `.config/nvim/.gitignore` remains in place and stays effective as a nested ignore file. It is additive to the root file and needs no adjustment.

### D5a: `settings.json` is the only portable settings file — measured, not assumed

Four tests against the installed binary settled where each key can live:

| test | result |
|---|---|
| `autoMode` moved to `~/.claude/settings.local.json` | **not read** — fell back to 20 shipped defaults |
| `enabledPlugins` moved to `settings.local.json` | **read**, and authoritative (flipped both plugins) |
| conflicting keys in both files, run from `$HOME` | local layer **wins** |
| same, run from outside `$HOME` | local layer **ignored**, `settings.json` applied |

So `~/.claude/settings.local.json` is scoped to `$HOME`-as-a-project, not to the user. Tracking the declaration there would enable plugins only while working inside the home directory — the opposite of the goal. `settings.json` is the only file that applies everywhere, so it must be the tracked one.

`autoMode` is then stuck in a tracked file with no layer to escape to. It is deleted rather than scrubbed or filtered: diffed against `claude auto-mode defaults`, 14 of 23 entries were byte-identical and 2 were section headers, leaving 7 real customizations that **all** named a private work repository, a project's `CONTRIBUTING.md` branch policy, its layout, or another user's home path. There was no generic tuning to preserve — scrubbing and deleting yield the same file. And because the key is user-scope, it applied globally, asserting one project as "the trusted repo" in every session regardless of directory. Deleting it fixes that too.

*Alternatives considered.* A `.gitattributes` clean filter stripping `autoMode` on staging would keep the local tuning and commit nothing — correct, but it buys back only work-project-specific text that was already wrong to apply globally, at the cost of a per-machine `git config` that silently reintroduces the key if forgotten. Scrubbing the identifying entries was rejected once the diff showed that *is* the whole customization.

### D5b: `.gitconfig` is not tracked

Identity and credential helpers are per-machine and per-user: this machine authenticates as a work account but commits here as the personal one, and its helper line hardcodes `/home/gmteixeira/.local/bin/gh`. A shared `.gitconfig` would carry one machine's answers to every other. Identity goes in `.git/config` instead — repo-local, never committed, and correctly scoped so that other repositories on this machine keep their own identity.

The cost is that identity must be set per clone, or `git commit` fails with exit 128 before the hook runs. That is a bootstrap step, not a silent failure.

### D5c: Plugins tracked as a declaration, `.claude/plugins/` ignored

`.claude/settings.json` already *is* the plugin manifest. `extraKnownMarketplaces` says where a marketplace lives, `enabledPlugins` says which plugins are on, and Claude Code reconciles `.claude/plugins/` against that on startup — fetching, installing, and updating as needed. So the tracked artifact is the declaration; the 13 MB install tree is derived and ignored wholesale.

This is not just a size argument. `.claude/plugins/installed_plugins.json` and `known_marketplaces.json` record `installLocation` as `/home/gmteixeira/.claude/plugins/marketplaces/<name>` — absolute paths that are wrong on any machine with a different home directory. Committing them would ship state that is actively incorrect elsewhere, and it would fight the reconciler rather than feed it. The general rule, recorded in the ignore-policy spec: **track the declaration, ignore what the tool rebuilds from it.**

One correctness obligation follows. Every marketplace referenced by an `enabledPlugins` key must be resolvable on the new machine — either built in (`claude-plugins-official`) or declared in `extraKnownMarketplaces` (`caveman`). A plugin enabled from a marketplace that appears only in the ignored `known_marketplaces.json` would restore on this machine and fail everywhere else, and the failure would surface as a missing plugin long after the commit. Verifying that correspondence is an explicit task, not an assumption.

*Alternative considered.* Vendoring `.claude/plugins/marketplaces/` for pinned, offline-reproducible versions. Rejected: it is 13 MB of someone else's git history duplicated into this repo, it defeats the update path the declaration gives for free, and the absolute-path problem above remains.

### D5d: Telemetry state is denylisted, not tracked

`.config/openspec/config.json` was on the initial tracked list, but its entire content is `{"telemetry": {"noticeSeen": true, "anonymousId": "<uuid>"}}` — no configuration at all. An "anonymous" id stops being anonymous once it is published next to a name, and copying one to every machine makes them all report as a single install, which is worse than having none. The path is denylisted, along with patterns for `telemetry.json`, `machine-id`, and similar per-install state.

The general rule this shares with D5c: **derived or per-install state is never tracked, only the declaration that produces it.** Here there is no declaration worth keeping, so nothing is tracked.

### D6: `openspec/` allowlisted as a stated exception

The root rule ignores non-dot entries. `openspec/` is exempted explicitly, so specs and change artifacts travel between environments. This is the one exception in block 3 that overrides the root rule; `repos/` and a loose JSON file at the root remain ignored. `openspec/changes/archive/` is included — archived changes are the record of how the config got here.

### D7: Verification before the first push, not after

The first push is the irreversible step: a public repository is scraped, and force-pushing a corrected history does not un-publish a key. So verification is a gate, not a follow-up. Four checks, in order:

1. `git status --porcelain` before any `add` — the only untracked path should be `.gitignore`. Anything else means block 1 or block 4 has a hole.
2. `git ls-files` after staging — compare against the declared tracked set in the spec, path by path.
3. Read the full content of every staged file. At this scale the tracked set is on the order of dozens of small files, so complete reading is feasible and is the only check that catches a token pasted into an otherwise-wanted file.
4. Judge that content against **publishability**, not just secrecy. `autoMode.environment` was the concrete case — no credential, but a private repository name, its URL, branch policy, and a second username. Resolved by deletion (D5a). The remote is confirmed public (`"private": false`), so this is not a hypothetical.

Only then `git push -u origin main`.

## Risks / Trade-offs

- **A secret leaks to a public repo.** → Layered: denylist patterns in `.gitignore`, path *and* content checks in the pre-commit guard, and full manual content review before the one-way first push (D6). If a leak happens anyway, the response is credential rotation first — removing the commit is secondary and insufficient on its own.
- **`!*/` makes git traverse 12 GB and `git status` crawls.** → Block 4 re-ignores every bulk directory after `!*/`, restoring pruning. Verified by timing `git status` as an acceptance step; if it is slow, a bulk directory is missing from block 4.
- **Over-broad denylist patterns silently swallow a wanted file.** → `*token*`/`*secret*`/`*credential*` will match innocent filenames eventually. The symptom is confusing (a file that refuses to stage), so the mitigation is diagnostic: `git check-ignore -v <path>` names the exact rule, and the bootstrap doc points at it as the first thing to run when a file will not stage.
- **Author email is published even though `.gitconfig` is not.** → Commit objects carry it and GitHub displays it. Mitigated by using the account's `users.noreply.github.com` address rather than a real inbox.
- **`.claude/settings.json` may accumulate secrets later.** → It is tracked today because it currently holds none. Content scanning in the guard is what keeps that true over time, not a one-time inspection.
- **`autoMode` returns if auto-mode setup is re-run on a machine.** → It is written only by an explicit setup flow, not per session, so this is not per-commit churn. The pre-commit guard rejects a staged `settings.json` containing the key, so its return cannot reach the remote unnoticed.
- **A plugin is enabled from a marketplace that is not declared.** → It works here (the marketplace sits in the ignored `known_marketplaces.json`) and silently fails on every other machine. Caught by reconciling `enabledPlugins` keys against `extraKnownMarketplaces` plus the built-in marketplaces as an explicit verification step.
- **Plugin versions are unpinned.** → Accepted. The declaration restores whatever the marketplace currently offers, so a new machine can get a newer plugin than this one. That is the intended update path; pinning would require vendoring, which D5 rejects.
- **Absorbing `.config/nvim` drops its local history.** → Accepted by decision; history remains on the `nvim-config` remote, and the local `.git` is archived to scratch before deletion so the step is reversible during the work.
- **The commit guard is inactive in a fresh clone until `core.hooksPath` is set.** → Unavoidable: git will not let a cloned repository configure itself. Mitigated by making it step one of the bootstrap doc, ahead of any instruction that stages a file.
- **`git add -A` typed out of habit stages everything allowlisted at once.** → Not catastrophic, since block 1 means "everything" is only the allowlist. The explicit-add discipline is about intent, and the guard remains the real barrier.

## Migration Plan

1. `git init -b main` at `$HOME`, remote added, **no staging yet**.
2. `.gitignore` written; verify the only untracked path is `.gitignore` itself (D7.1). Fix holes before proceeding.
3. `.githooks/pre-commit` written, `core.hooksPath` set, guard tested against a deliberately staged denylisted path.
4. `.config/nvim/.git` archived to scratch, then removed.
5. Allowlisted paths staged by name; `git ls-files` reconciled against the spec's tracked set (D7.2).
6. Full content review of the staged set (D7.3), including the `settings.json` scrub and the plugin-declaration reconciliation (D5, D7.4).
7. First commit, then `git push -u origin main`.

**Rollback.** Before the push, rollback is `rm -rf $HOME/.git` plus restoring `.config/nvim/.git` from scratch — no file in `$HOME` has been modified, only `.gitignore` and `.githooks/` added. After the push, rollback is no longer a file operation: anything leaked is rotated, not deleted.
