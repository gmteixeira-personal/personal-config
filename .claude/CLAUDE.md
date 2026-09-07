# Tooling

## ast-grep

`ast-grep` is installed (`~/.cargo/bin/ast-grep`, also aliased `sg`). Prefer it over
per-file `Edit` calls or regex `sed`/`grep` for any multi-file, syntax-aware search or
rewrite: renames, call-pattern changes, argument reordering, API migrations.

Search:

```sh
ast-grep run -p 'OldName($$$ARGS)' -l csharp
```

Rewrite in place across the repo:

```sh
ast-grep run -p 'OldName($$$ARGS)' -r 'NewName($$$ARGS)' -l csharp --update-all
```

Notes:

- `$VAR` captures one node, `$$$VAR` captures zero or more (arguments, statements).
- Run without `--update-all` first to review the matches, then re-run with it.
- `-l` sets the language (`csharp`, `rust`, `python`, `ts`, `tsx`, `go`, ...).
- Reach for plain `grep` only when the target is not syntax (comments, strings, config
  files, log output).
