## Context

This session's yazi configuration is `.config/yazi/theme.toml` and `.config/yazi/init.lua`; there is no keymap file, so yazi runs its shipped bindings unchanged. yazi is 26.9.1. The compositor is niri, on Wayland, and the terminal is foot.

`ripdrag` 0.4.13 is installed with `cargo install` at `~/.cargo/bin/ripdrag`. It opens a GTK4 window and works in two modes: as a drag source it lists the paths given on its command line and each row is draggable, and with `-t` it is a drop target that prints each dropped path on stdout, one per line. Its GTK application identifier is `it.catboy.ripdrag`.

Two properties of yazi 26 shape the bindings and are the reason this design exists rather than a one-line keymap. First, `shell` substitutes selected paths through `%`-placeholders — `%s` for the selection, `%h` for the hovered file — and does not pass them as shell positional parameters; the `"$@"` form that earlier yazi used parses, runs, and expands to nothing. Second, `shell` runs the command through `sh -c` with the current directory as its working directory, which is what lets the drop-in binding copy into `.`. Both were measured against a live instance rather than taken from documentation. See `proposal.md` — Why for the motivation.

## Goals / Non-Goals

**Goals:**

- Two keys, each doing one thing, in one tracked file that is the obvious place for the next yazi binding this session needs.
- A drop that cannot lose a file, given that a drag is aimed at a window showing nothing about the destination.
- The `%s`-versus-`$@` trap recorded where someone debugging an empty drag window will read it, because the failure does not name itself.

**Non-Goals:**

- Any other yazi binding. The keymap prepends two chords and leaves the rest of yazi's keymap alone.
- Moving rather than copying on a drop. A drag out of another application is a copy gesture there; making it a move here would delete from a source the user did not choose to empty.
- Handling a drag whose payload is a URL rather than a file. An image dragged straight off a web page has no local file to copy, and inventing a download step would make a file manager binding into a fetch tool.
- A compositor-level drag binding. Dragging has to know which files are selected, and only yazi knows that.

## Decisions

**Drive ripdrag from yazi's keymap rather than from a wrapper beside it.**

The alternative is a script or compositor binding that opens ripdrag against some other notion of "the current files" — the last yanked set, or a directory listing. Both are a second source of truth for a selection yazi already holds, and both are wrong the moment the two disagree. yazi's `shell` action already substitutes the selection into a command, so the binding can say `%s` and be right by construction.

**Use `%s` alone rather than `%s` with an `%h` fallback.**

`%s` was measured to expand to the hovered file when the selection is empty, so one placeholder covers both of the ways a user indicates files. A binding that tried to choose between them would need a conditional in the shell command and would be choosing between two values that are never both meaningful.

**`--orphan` on the drag-out binding, and deliberately not on the drop-in one.**

They fail in opposite directions. The drag-out window has to outlive yazi, because a user mid-drag closes yazi to uncover the window they are dropping into, and a window killed at that moment reads as the drag failing. The drop-in binding has to outlive the *drop* instead: ripdrag prints paths and the pipeline copies them, and detaching that from yazi's task scheduling would take the copy's errors — a URL where a path was expected is the common one — out of the place that reports them. Orphaning the second would trade a visible failure for a silent one.

**Copy with `--backup=numbered` rather than `-n`, `-i` or a bare `cp`.**

A bare `cp` overwrites, which is unacceptable for a gesture aimed with a pointer at a window that shows nothing of the destination. `-i` prompts, and there is no terminal attached to prompt on. `-n` skips the file, which loses the thing the user just dragged and says nothing about it. `--backup=numbered` is the only one of the four where nothing is lost and the outcome is visible: the drop lands, the previous file is beside it as `name.~1~`, and both are one listing away.

**Pipe through `xargs -d '\n' -r` rather than a read loop.**

`-d '\n'` is what keeps a name containing a space one argument; without it `xargs` splits on whitespace and a dropped `two words.txt` becomes two missing files. `-r` makes the closing of a drop window with nothing dropped a no-op rather than a bare `cp -t .`. A `while read` loop would do the same job and would invoke `cp` once per file, which turns one collision-handling decision into several.

**Float the ripdrag window with a niri rule matching `ripdrag`, not the full `it.catboy.ripdrag`.**

niri matches `app-id` as an unanchored regular expression, so the short form matches and is what the compositor's own bundled examples use for this case. The full identifier is recorded in the comment beside the rule so the match can be checked against reality without launching the program. An anchored `^it\.catboy\.ripdrag$` was written first and replaced: it is precise about a value that has one producer on this machine, and precision bought nothing a comment does not.

**Choose `<C-n>` and `<C-t>`, verified against yazi's shipped keymap.**

yazi's defaults bind `<C-[>`, `<C-c>`, `<C-z>`, `<C-u>`, `<C-d>`, `<C-b>`, `<C-f>`, `<C-a>`, `<C-r>`, `<C-->` and `<C-s>` in manager mode; `<C-n>` appears only in input mode, where this keymap does not reach. Both chosen keys are therefore free. `prepend_keymap` rather than `keymap` is what keeps the rest of the defaults, which a plain `keymap` table would replace wholesale.

## Risks / Trade-offs

- A machine without `ripdrag` gets two keys that report a command that is not found → Accepted rather than guarded. Neither key is on yazi's default keymap, so the file manager behaves exactly as before; a guard would be a wrapper script existing only to turn a clear error into a quieter one.
- A drop out of a browser can deliver a URL, and `cp` fails → yazi surfaces the failure, and the keymap comment says to save the file first. Not worth a download path.
- `--backup=numbered` leaves `name.~1~` files behind after a repeated drop → Accepted. They are visible in the listing the user is looking at, which is the point.
- Both bindings depend on GNU `cp` and `xargs` behaviour (`-t`, `--backup=numbered`, `-d`) → Accepted for a configuration repository targeting this session's Fedora machine, which is the same assumption the rest of these dotfiles make.
- The keymap is read at yazi startup, so open windows do not gain the bindings → Recorded in the tasks and the same startup rule `init.lua` already documents for the yank sharing.

## Migration Plan

Writing the files is the whole deployment. niri reloads its configuration when the file is written, so the floating rule takes effect with no restart; yazi reads its keymap at startup, so every open yazi window has to be restarted before it has the bindings. Rollback is deleting `.config/yazi/keymap.toml`, its `.gitignore` negation, and the window rule: yazi returns to its shipped keymap and niri to tiling everything, and nothing else in the session refers to either.
