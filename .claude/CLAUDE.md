# Tooling

All installed. Prefer each over the default it replaces; no need to check first.

| Tool                         | Use for                                                                                                                                                                                     | Over                                                      |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `fd`                         | find files by name                                                                                                                                                                          | `find`                                                    |
| `rg`                         | search file contents                                                                                                                                                                        | `grep -r`                                                 |
| `ast-grep` (`sg`)            | syntax-aware search/rewrite: renames, call-pattern changes, API migrations; `ast-grep outline F` maps a big file's symbols before reading it                                                | regex `sed`/`grep`, per-file `Edit`                       |
| `sd`                         | literal string replace in place                                                                                                                                                             | `sed -i`                                                  |
| `difft`                      | syntax-aware diff; wired as git `diff.external`                                                                                                                                             |                                                           |
| `tokei`                      | per-language line counts, to orient in an unfamiliar tree                                                                                                                                   |                                                           |
| `bat -pn`                    | read a file with line numbers for `file:line` citations                                                                                                                                     |                                                           |
| `jq`                         | query and edit JSON                                                                                                                                                                         |                                                           |
| `shellcheck` / `shfmt`       | lint and format shell before handing it over                                                                                                                                                |                                                           |
| `gitleaks`                   | secret scan: `gitleaks git .`, or `--staged`                                                                                                                                                |                                                           |
| `semgrep`                    | rule-based cross-file scan when ast-grep patterns get unwieldy                                                                                                                              |                                                           |
| `gh`                         | PRs, issues, CI status, GitHub API                                                                                                                                                          |                                                           |
| `tree-sitter`                | inspect the AST when an ast-grep pattern won't match                                                                                                                                        |                                                           |
| `LSP` tool (C#, `csharp-ls`) | references, implementations, definitions, call hierarchy; compile errors after each edit. Navigation only — rewrites stay with `ast-grep`. Deferred: load it with `ToolSearch` `select:LSP` | `rg`/`Grep` for symbol usage, a full build to find errors |

Gotchas that cause failed commands:

- `fd`: pattern first, directory second — `fd . -e md docs/`. `find`'s order is rejected.
- `ast-grep`: `$VAR` captures one node, `$$$VAR` many. Run without `--update-all` first, review, then re-run with it. `-l` sets the language.
- `LSP`: every operation's `filePath` must be a `.cs` file, `workspaceSymbol` included — the server is chosen by extension, so a directory fails.
- `LSP` sees `.cs` only: `.razor` markup and `@code` blocks get no diagnostics, and references may miss usages there. Build to verify Razor.
- `git diff` renders through `difft`. Add `--no-ext-diff` whenever the output must be parsed or applied.
