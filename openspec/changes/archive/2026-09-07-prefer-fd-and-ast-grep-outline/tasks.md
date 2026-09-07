## 1. The fd section in the global instruction file

- [x] 1.1 Add a `## fd` section to `.claude/CLAUDE.md` naming the binary at `~/.cargo/bin/fd` and stating that it, not `find`, locates a file or a directory — verify the section states the preference rather than only the tool's presence
- [x] 1.2 State in that section that `.gitignore`d paths and `.git` are skipped by default, so a search is already scoped to the working tree — verify `-H` and `-I` are named as what includes them
- [x] 1.3 Add the example block covering a regex match on the name, `-g` for a glob, `-e` for extensions under a directory, `-H -I`, and `-x` acting on each match — verify each example is accepted by `fd` as written, and that none of them modifies or deletes a file
- [x] 1.4 Add the `Notes:` list carrying that the pattern is a regex against the file name with `-p` for the whole path, that a search directory is a second positional after the pattern where `find` takes it first, `-t f` / `-t d`, the difference between `-x` and `-X`, and the predicates that send a search back to `find` — verify the list names `find`'s remaining cases by example rather than in the abstract

## 2. The outline note

- [x] 2.1 Add `ast-grep outline` to the `## ast-grep` section with the reason it is run — mapping a file's symbols so only the interesting ranges are read — and verify `ast-grep --help` lists `outline` as a subcommand rather than the command being plausible but absent
- [x] 2.2 Place it after the rewrite form and before the `Notes:` list, so the section reads search, rewrite, map, then details — verify the existing notes still apply to what precedes them

## 3. The software inventory

- [x] 3.1 Add a `**fd**` entry under **Optional** in `README.md` stating that `.claude/CLAUDE.md` names it as the file finder, that its absence is silent and costs speed rather than function because an agent falls back to `find`, and that it comes from `cargo install` rather than a Fedora package — verify the entry states what is lost, not only what the tool is
- [x] 3.2 Add an `**ast-grep**` entry under **Optional** in the same form, naming the multi-file rewrite and the outline as what is lost and the per-file edit loop and whole-file read as the fallback — verify both entries name a source without prescribing a package-manager command line

## 4. Verification

- [x] 4.1 Run `openspec validate prefer-fd-and-ast-grep-outline --strict` and verify it reports the change valid
- [x] 4.2 Read `.claude/CLAUDE.md` back and verify each of the four requirements in the delta spec is satisfied by text in the file
- [x] 4.3 Verify `git ls-files` lists `.claude/CLAUDE.md`, so the preference is tracked rather than local to this machine
