## Why

An agent left to itself reaches for `find` and for reading a file end to end, because those are what it can assume exist. Both are the wrong default here. `fd` and `ast-grep` are installed under `~/.cargo/bin`, and neither announces itself: an agent that never learns they are there spends a `find . -name` on a path `fd` answers in one word, and spends a full-file read on a question `ast-grep outline` answers in a listing.

`~/.claude/CLAUDE.md` is read at the start of every Claude Code session in every project on this machine, which makes it the one place a tool preference can be stated once rather than restated per repository. The ast-grep rewrite note already lives there. Nothing states the file's purpose, and nothing states what it holds, so the note is a fact of the file rather than a described capability — the next tool note has no rule to follow and no reason to land there rather than in some repository's own instructions.

## What Changes

- `fd` is recorded in the global instruction file as the tool for locating a file or a directory, in place of `find`. The note carries what an agent has to know to use it correctly rather than only that it exists: the pattern is a regex against the file name and not the whole path, `-g` switches to globs, and `.gitignore`d paths and `.git` are skipped unless `-H -I` asks for them.
- The note names the cases that still belong to `find` — `-newer`, `-perm`, complex `-prune` — so preferring `fd` does not read as a claim that it replaces `find` everywhere.
- The ast-grep section gains `ast-grep outline`, which lists a file's symbols, imports, exports and members. It makes reading a large file in the ranges that matter the documented first move, where the section previously covered searching and rewriting but said nothing about reading.
- The capability itself is written down: that this instruction file is where a machine-wide tool preference goes, that a note there states the tool, the case it wins, and the case it does not, and that the note is a preference an agent applies rather than a permission it needs.
- `README.md` gains inventory entries for both tools. The tracked configuration now names them, and the repository's documentation requirement is that a reader can find every dependency without reading the configuration files to discover it.

## Capabilities

### New Capabilities
- `agent-code-tooling`: which tools an agent working in this configuration reaches for when it finds, reads, and rewrites code; where that instruction lives so that it applies to every project rather than one; and what a note there has to state to be usable.

### Modified Capabilities
<!-- None. `dotfiles-repo` already requires the tracked documentation to name the software the configuration depends on and to say what is lost when it is absent; the README entries here satisfy that requirement rather than change it. -->

## Impact

- `.claude/CLAUDE.md` — the `fd` section and the `outline` note. Untracked by any project's own instructions; it is the user-level file, so every repository on this machine sees the change at once.
- `README.md` — two entries under **Optional**. Both tools are absent-tolerant in the strongest sense: an agent that cannot run `fd` falls back to `find` and the work still completes, only slower and noisier.
- No new package and no install step. Both binaries are already present as cargo builds; this change records them and does not fetch them.
- No effect on any shell, editor, or session configuration. Nothing sources these files at runtime, and an agent reads the instruction file itself.
