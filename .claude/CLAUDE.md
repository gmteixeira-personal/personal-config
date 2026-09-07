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

Map the symbols of a large file before reading it, so only the interesting ranges get
read:

```sh
ast-grep outline path/to/File.cs
```

Notes:

- `$VAR` captures one node, `$$$VAR` captures zero or more (arguments, statements).
- Run without `--update-all` first to review the matches, then re-run with it.
- `-l` sets the language (`csharp`, `rust`, `python`, `ts`, `tsx`, `go`, ...).
- Reach for plain `grep` only when the target is not syntax (comments, strings, config
  files, log output).

## fd

`fd` is installed (`~/.cargo/bin/fd`). Prefer it over `find` for every file and
directory lookup. It skips `.gitignore`d paths and `.git` by default, so its output is
already scoped to the working tree.

```sh
fd '\.cs$'                  # regex match on the file name
fd -g '*.config.js'         # glob match instead
fd -e md -e txt docs/       # by extension, under a directory
fd -H -I secrets            # include hidden and ignored files
fd -t d node_modules -x rm -rf   # act on each match
```

Notes:

- The pattern is a regex by default and matches the file name, not the whole path;
  use `-p` to match against the full path.
- `-t f` / `-t d` restrict to files or directories.
- `-x cmd` runs `cmd` once per match, `-X cmd` once with all matches appended.
- Reach for `find` only when a predicate `fd` lacks is needed (`-newer`, `-perm`,
  complex `-prune` logic).
