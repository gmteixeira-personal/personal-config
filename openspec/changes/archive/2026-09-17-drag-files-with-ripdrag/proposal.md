## Why

A terminal grid is not a Wayland drag source. The compositor starts a drag from a surface, and the cells a file manager draws its listing in are not one, so yazi can show a file and has no way to hand it to Chrome, to Nautilus, or to any other window on the session. The file is on screen and the only way to get it into the other application is to leave yazi for a second file manager, or to copy the path as text and hope the target accepts typing where it expects a drop.

The same gap runs the other way. A file arriving by drag — off a browser, out of an archive tool, from a Nautilus window — has nowhere to land in yazi. Dropping it on the terminal makes foot insert the path as input, which against yazi's normal keymap is a series of keypresses rather than a file.

`ripdrag` is a small GTK4 program that closes both directions: as a source it holds the files in a real window that can be dragged out of, and as a target it takes a drop and prints the paths it received. It is installed here as of this change; the work is to give yazi two keys that drive it and to keep the window it opens out of the tiling.

## What Changes

- `.config/yazi/keymap.toml` is added, the first keymap this session gives yazi. It prepends two bindings and changes nothing else about yazi's defaults.
- `<C-n>` opens the drag-out window: `shell --orphan -- ripdrag -x -n -a %s`. `%s` is every selected file, and the hovered file when the selection is empty, so one key covers both cases. `--orphan` is what keeps ripdrag alive after yazi exits, because closing yazi to uncover the window being dropped into is exactly what a user does mid-drag.
- `<C-t>` opens the drop-in window: `shell -- ripdrag -t -x | xargs -d '\n' -r cp -r --backup=numbered -t .`. ripdrag prints one path per line on a drop, and the paths are copied into the directory yazi is showing. This binding deliberately does not take `--orphan`: the pipeline has to outlive the drop rather than the program.
- `--backup=numbered` is part of the requirement rather than a flag choice. A drop of a name that already exists renames the existing file to `name.~1~` instead of writing over it, which is the difference between a convenience key and a key that can lose a file to a mis-aimed drag.
- `.gitignore` block 3 gains `!/.config/yazi/keymap.toml`, beside the entries already there for `theme.toml` and `init.lua`.
- `.config/niri/config.kdl` gains a window rule floating any window whose app-id matches `ripdrag`. The window exists for the length of one drag; tiled, it would push every column on the workspace aside for those seconds and then push them back.
- The bindings are written in yazi 26's `%s` substitution rather than the `"$@"` positional-parameter form that older yazi used. This is recorded because the old form still parses and still runs: it produces a ripdrag window holding no files, which reads as ripdrag ignoring the selection rather than as a stale configuration.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `file-manager`: the capability describes which program browses files, how it is reached, how its status bar is coloured, and what its windows share with each other. It says nothing about what its windows exchange with the rest of the session. It gains requirements that a file can be dragged out of the file manager into another application, that files can be dropped into the directory it is showing, that a drop never overwrites, and that the helper program driving this is invoked from the file manager's own keymap.
- `window-placement`: the capability decides where the compositor puts tiled columns. It gains a requirement that a window opened only to carry a drag is floated rather than tiled, so a transient window does not rearrange a workspace it is about to leave.

## Impact

- `.config/yazi/keymap.toml` — new, tracked.
- `.gitignore` — one added negation with its comment.
- `.config/niri/config.kdl` — one added window rule with its comment.
- `ripdrag` 0.4.13, installed with `cargo install` into `~/.cargo/bin`, becomes a dependency of two keys. Neither key is on yazi's default keymap, so a machine without ripdrag has a file manager that behaves exactly as it did before, and two keys that report a command that is not found.
- Running yazi instances do not pick the keymap up: it is read at startup, so every open window has to be restarted. niri reloads its configuration on write and needs no restart.
- A drop out of a browser can yield a URL rather than a path, where the image being dragged has no local file yet. `cp` then fails and yazi reports it. This is a limit of the arrangement rather than a defect to fix here.
