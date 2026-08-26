## 1. Initialize the repository (no staging)

- [x] 1.1 Run `git init -b main` at `/home/gmteixeira`; confirm `git rev-parse --show-toplevel` prints `/home/gmteixeira` and the branch is `main`
- [x] 1.2 Add the remote: `git remote add origin https://github.com/gmteixeira-personal/personal-config`; confirm with `git remote get-url origin`
- [x] 1.3 Do **not** stage anything yet — `.gitignore` must exist before git ever walks the tree

## 2. Write the ignore file

- [x] 2.1 Write `/home/gmteixeira/.gitignore` block 1 (`*`) and block 2 (`!*/`), with a comment naming each block's role
- [x] 2.2 Write block 4 (denylist) before block 3, so the tree is never briefly walkable: named secret paths `.ssh/`, `.config/gh/hosts.yml`, `.claude/.credentials.json`, `.ghtoken`, `.claude.json`, `.bash_history`, `.psql_history`, `.viminfo`
- [x] 2.3 Add block 4 secret **patterns**: `id_*` (with `!*.pub` re-allowed), `*.pem`, `*.key`, `*.p12`, `*.pfx`, `.env`, `.env.*`, `*_history`, `*.history`, `*credential*`, `*secret*`, `*token*`, `.netrc`, `.npmrc`, `.pypirc`, `*:Zone.Identifier`
- [x] 2.4 Add block 4 bulk exclusions: `.cache/`, `.npm/`, `.nuget/`, `.cargo/`, `.dotnet/`, `.nvm/`, `.vscode-server/`, `.ServiceHub/`, `.local/`, `.aspnet/`, `.templateengine/`, `.landscape/`, `.copilot/`, `.wget-hsts`, `.motd_shown`
- [x] 2.5 Add block 4 Claude Code exclusions: `.claude/projects/`, `.claude/sessions/`, `.claude/plugins/`, `.claude/file-history/`, `.claude/session-env/`, `.claude/shell-snapshots/`, `.claude/paste-cache/`, `.claude/backups/`, `.claude/cache/`, `.claude/downloads/`, `.claude/daemon/`, `.claude/jobs/`, `.claude/tasks/`, `.claude/plans/`, `.claude/ide/`, `.claude/history.jsonl`, `.claude/daemon.log`, `.claude/*.jsonl`, `.claude/*.json`, `.claude/settings.json.doctor-backup`
- [x] 2.6 Verify the denylist alone holds: `git status --porcelain` reports **only** `.gitignore` as untracked, and completes in seconds (proves the bulk trees are pruned, not walked)

## 3. Add the allowlist

- [x] 3.1 Insert block 3 between blocks 2 and 4; shell + git: `!/.bashrc`, `!/.profile`, `!/.bash_logout`, `!/.gitconfig`
- [x] 3.2 Tool configs: `!/.config/lazygit/config.yml`, `!/.config/gh/config.yml` — `.config/openspec/config.json` excluded, it holds only telemetry state
- [x] 3.3 Claude Code: `!/.claude/settings.json`, `!/.claude/statusline-command.sh`, `!/.claude/commands/**`, `!/.claude/skills/**`, and the ahead-of-creation entries `!/.claude/agents/**`, `!/.claude/hooks/**`
- [x] 3.4 Neovim: `!/.config/nvim/**`
- [x] 3.5 OpenSpec workspace as the stated non-dot exception: `!/openspec/**`
- [x] 3.6 The guard itself: `!/.githooks/**`
- [x] 3.7 Re-order check — confirm block 4 sits after block 3 in the file, since block 4 must win on conflict

## 4. Verify the ignore contract

- [x] 4.1 For each allowlisted path, confirm `git check-ignore -v <path>` reports **no match** (exit 1)
- [x] 4.2 For each named secret path, confirm `git check-ignore -v <path>` reports a **block 4** line number, not a block 3 one
- [x] 4.3 Confirm precedence directly: `git check-ignore -v .claude/.credentials.json` must cite the denylist even though `.claude/` holds allowlisted siblings
- [x] 4.4 Confirm `.ssh/id_ed25519.pub` is not caught by the `id_*` pattern, while `.ssh/id_ed25519` is (both remain ignored via `.ssh/` — check the rule cited, not just the outcome)
- [x] 4.5 Confirm the non-dot root rule: `repos/` and a loose JSON file at the root are ignored, `openspec/` is not
- [x] 4.6 Confirm `.claude/plugins/` is ignored as a whole and that `git status` does not descend into its `marketplaces/` clones
- [x] 4.7 Time `git status` at the repo root and record it; investigate block 4 for a missing directory if it exceeds a few seconds

## 5. Install the commit guard

- [x] 5.1 Write `/home/gmteixeira/.githooks/pre-commit` — dependency-free POSIX shell, no tools beyond git and grep
- [x] 5.2 Guard check A (paths): read the staged path list via `git diff --cached --name-only --diff-filter=ACM`, reject any path matching the block 4 secret patterns, naming the offending path and exiting non-zero
- [x] 5.3 Guard check B (content): scan staged blobs for `-----BEGIN .* PRIVATE KEY-----`, `ssh-ed25519`/`ssh-rsa` private material, and token literals `ghp_`, `github_pat_`, `gho_`, `sk-`, `AKIA`; reject and name the offending path
- [x] 5.4 `chmod +x .githooks/pre-commit` and activate with `git config core.hooksPath .githooks`
- [x] 5.5 Test check A: `git add -f .ghtoken`, attempt a commit, confirm rejection naming `.ghtoken`, then `git reset .ghtoken`
- [x] 5.6 Test check B: stage a scratch allowlisted file containing a fake OpenSSH private-key header line, confirm rejection, then unstage and delete it
- [x] 5.7 Test the negative case: stage `.bashrc` alone and confirm the guard permits the commit to proceed

## 6. Make plugins declarative

- [x] 6.1 Reconcile the declaration: every marketplace named in an `enabledPlugins` key of `.claude/settings.json` must be either a built-in marketplace or present in `extraKnownMarketplaces` — currently `caveman@caveman` (declared) and `frontend-design@claude-plugins-official` (built-in)
- [x] 6.2 Cross-check against the ignored `.claude/plugins/known_marketplaces.json`: any marketplace listed there but absent from `extraKnownMarketplaces` is a plugin that would restore here and fail on every other machine — add it to the declaration or drop the plugin
- [x] 6.3 Confirm no tracked file contains the absolute path `/home/gmteixeira` (the `installLocation` fields that make `.claude/plugins/` unportable must not appear anywhere in the tracked set)
- [x] 6.4 Delete the `autoMode` key from `.claude/settings.json`: diffed against shipped defaults, all 7 real customizations named a private work repository or its layout, and the key is user-scope so it applied globally. Auto mode falls back to 20 default entries, none naming the work project
- [x] 6.5 Confirm `settings.json` is still valid JSON, plugins still resolve, and the pre-commit guard rejects any staged `settings.json` that carries `autoMode`

## 7. Absorb `.config/nvim`

- [x] 7.1 Re-confirm the safety precondition: `git -C .config/nvim status -sb` is clean and `git -C .config/nvim rev-list --count origin/main..main` is `0` — abort this group if either fails
- [x] 7.2 Record the remote URL `https://github.com/gmteixeira-personal/nvim-config` in the bootstrap doc as the recovery path for the dropped history
- [x] 7.3 Copy `.config/nvim/.git` to the scratch directory as a reversible backup, then `rm -rf .config/nvim/.git`
- [x] 7.4 Confirm `.config/nvim` files now appear as untracked-and-allowlisted in the parent repo, and that `.config/nvim/.gitignore` is still honored as a nested ignore file

## 8. Stage and verify

- [x] 8.1 Stage each path from the spec's tracked set **by name** — no `git add -A`, `.`, or `-u`
- [x] 8.2 Reconcile `git ls-files` line by line against the tracked set in `specs/dotfiles-repo/spec.md`; nothing extra, nothing missing
- [x] 8.3 Read the **full content** of every staged file; look for keys, tokens, passwords, internal hostnames, and personal identifiers beyond the git-authorship email
- [x] 8.4 Confirm `.claude/settings.json` and `.config/gh/config.yml` carry no credential (the token lives in `hosts.yml`, absent from the staged set) and that no `.gitconfig` is staged
- [x] 8.5 Confirm no `:Zone.Identifier` file, no `.doctor-backup` file, and no path under `.claude/plugins/` is staged
- [x] 8.6 Record the staged file count and total size; an unexpectedly large number means an allowlist entry is broader than intended

## 9. Bootstrap documentation

- [x] 9.1 Write a tracked bootstrap doc covering: clone-into-non-empty-home without overwriting, `git config core.hooksPath .githooks` as step one, and the explicit-add discipline
- [x] 9.2 Document the diagnostic for a file that will not stage: `git check-ignore -v <path>` names the responsible rule; fix by adding a narrow block 3 exception, never by loosening block 4
- [x] 9.3 Document how to add a new dotfile to the repo: block 3 entry, then `git add <path>` by name
- [x] 9.4 Document plugin management: add the marketplace to `extraKnownMarketplaces` and the plugin to `enabledPlugins` in `.claude/settings.json`, commit that — never commit `.claude/plugins/`
- [x] 9.5 Document the recurring `settings.json` check: `autoMode.environment` regenerates over time, so re-read it for private repository names, hosts, and usernames every time `settings.json` is re-staged
- [x] 9.6 Stage the bootstrap doc

## 10. First commit and push

- [ ] 10.1 Commit; confirm the guard ran and passed
- [ ] 10.2 Final pre-push gate — re-read `git show --stat HEAD` and confirm the tracked set is exactly as reviewed in 7.2
- [ ] 10.3 Confirm with the user before pushing: this publishes the content to a public GitHub repository and cannot be undone by a later force-push
- [ ] 10.4 `git push -u origin main`
- [ ] 10.5 Verify on the remote that the pushed file list matches, and that no secret path appears
- [ ] 10.6 Verify the declarative plugin path end to end: on a second environment (or a scratch `CLAUDE_CONFIG_DIR`), clone the repo, start Claude Code, and confirm `caveman@caveman` is fetched and installed with no manual step

## 11. Cleanup

- [ ] 11.1 Remove the scratch `.git` backup of `.config/nvim` once the push is verified
- [ ] 11.2 Re-run `git status` and confirm a clean tree with no unexpected untracked paths
