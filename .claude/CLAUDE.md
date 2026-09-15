# Tooling

All installed. Prefer each over the default it replaces; no need to check first.

| Tool | Use for | Over |
|---|---|---|
| `fd` | find files by name | `find` |
| `rg` | search file contents | `grep -r` |
| `ast-grep` (`sg`) | syntax-aware search/rewrite: renames, call-pattern changes, API migrations; `ast-grep outline F` maps a big file's symbols before reading it | regex `sed`/`grep`, per-file `Edit` |
| `sd` | literal string replace in place | `sed -i` |
| `difft` | syntax-aware diff; wired as git `diff.external` | |
| `tokei` | per-language line counts, to orient in an unfamiliar tree | |
| `bat -pn` | read a file with line numbers for `file:line` citations | |
| `jq` | query and edit JSON | |
| `shellcheck` / `shfmt` | lint and format shell before handing it over | |
| `gitleaks` | secret scan: `gitleaks git .`, or `--staged` | |
| `semgrep` | rule-based cross-file scan when ast-grep patterns get unwieldy | |
| `gh` | PRs, issues, CI status, GitHub API | |
| `tree-sitter` | inspect the AST when an ast-grep pattern won't match | |

Gotchas that cause failed commands:

- `fd`: pattern first, directory second — `fd . -e md docs/`. `find`'s order is rejected.
- `ast-grep`: `$VAR` captures one node, `$$$VAR` many. Run without `--update-all` first, review, then re-run with it. `-l` sets the language.
- `git diff` renders through `difft`. Add `--no-ext-diff` whenever the output must be parsed or applied.

Skip TUIs — `lazygit`, `yazi`, `tig`, `gitui`, `btm`, `jless`, interactive `fzf`. Not drivable from a non-interactive shell.
