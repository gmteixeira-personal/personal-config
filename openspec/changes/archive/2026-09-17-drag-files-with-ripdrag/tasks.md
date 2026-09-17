## 1. Give yazi the drag-out binding

- [x] 1.1 Write `.config/yazi/keymap.toml` with a `[[mgr.prepend_keymap]]` entry binding `<C-n>` to `shell --orphan -- ripdrag -x -n -a %s`, and verify the file parses as TOML and the `run` value reads exactly that
- [x] 1.2 Verify `<C-n>` is not in yazi's shipped manager-mode keymap, and that `prepend_keymap` rather than `keymap` is used so the defaults survive
- [x] 1.3 Verify the substitution end to end: start yazi against a directory of test files, select several, press `<C-n>`, and read the launched process's `/proc/<pid>/cmdline` to confirm each selected path arrives as its own argument
- [x] 1.4 Verify the empty-selection case: with nothing selected, `%s` SHALL expand to the hovered file
- [x] 1.5 Verify a filename containing a space arrives as one argument rather than two
- [x] 1.6 Record in the file's comments that `%s` is yazi 26 syntax and that the superseded `"$@"` form runs with no files rather than failing

## 2. Give yazi the drop-in binding

- [x] 2.1 Add a second `[[mgr.prepend_keymap]]` entry binding `<C-t>` to `shell -- ripdrag -t -x | xargs -d '\n' -r cp -r --backup=numbered -t .`, and verify it parses and `<C-t>` is likewise unbound in yazi's defaults
- [x] 2.2 Verify that yazi runs a shell command with the current directory as its working directory, so `-t .` targets the directory on screen rather than the directory yazi was started from
- [x] 2.3 Verify the copy half against a stub standing in for ripdrag: a name with a space stays one file, a directory is copied with its contents, and an existing file of the same name is kept as `name.~1~` while the dropped one takes the name
- [x] 2.4 Verify `xargs -r` makes a closed-with-no-drop window a no-op — no file created, replaced or removed
- [x] 2.5 Verify `<C-t>` launches ripdrag with `-t -x` and that the pipeline is the parent process, by reading both `/proc/<pid>/cmdline` entries from a live yazi
- [x] 2.6 Record in the file's comments why this binding takes no `--orphan`, that `--backup=numbered` is what keeps a drop from overwriting, and that a browser drop can deliver a URL that `cp` will reject

## 3. Track the keymap

- [x] 3.1 Add `!/.config/yazi/keymap.toml` to `.gitignore` block 3 beside `!/.config/yazi/init.lua`, with its own comment stating what the two bindings do and that they depend on `ripdrag`
- [x] 3.2 Verify `git check-ignore -q .config/yazi/keymap.toml` exits 1 so the path is no longer ignored
- [x] 3.3 Verify nothing else was let through: `git status --porcelain` lists `.config/yazi/keymap.toml` and no other newly untracked file under `.config/yazi/`

## 4. Keep the drag window out of the tiling

- [x] 4.1 Add a `window-rule` to `.config/niri/config.kdl` matching `app-id="ripdrag"` with `open-floating true`, placed beside the existing floating rule for the picture-in-picture player
- [x] 4.2 Record in the comment why the window is floated rather than tiled, that its full application identifier is `it.catboy.ripdrag`, and that niri matches `app-id` as an unanchored regular expression so the bare fragment is enough
- [x] 4.3 Verify the configuration is accepted: `niri validate -c ~/.config/niri/config.kdl` reports it valid
- [x] 4.4 Verify the rule takes effect: launch ripdrag and confirm `niri msg --json windows` reports the window with `app_id` `it.catboy.ripdrag` and `is_floating` true

## 5. Record the capability

- [x] 5.1 Widen the `window-placement` specification's Purpose, which speaks only of tiled columns, so that it covers deciding a window is not tiled at all
- [x] 5.2 Verify `openspec validate --change drag-files-with-ripdrag --strict` passes

## 6. Confirm nothing else moved

- [x] 6.1 Verify `.config/yazi/init.lua` and `.config/yazi/theme.toml` are unchanged by this change
- [x] 6.2 Verify the only addition to `.config/niri/config.kdl` is the new window rule and its comment
- [x] 6.3 Verify every process started for testing is gone and no scratch directory is left behind
