## Context

See proposal.md — Why. The constraints that shape the approach:

- niri implements `wlr-screencopy` and `wlr-layer-shell`, so the standard Wayland capture and region-selection tools work here with nothing bridging them.
- niri's own `screenshot` action is a compositor-internal operation. It captures, writes the file and sets the clipboard in one step, and there is no point in that sequence at which another program can be inserted. Annotation is therefore not something the built-in action can be configured into — reaching it means not using the built-in action.
- `prefer-no-csd` is set, `mod-key` is unset so `Mod` is Super, and `~/.local/bin` is on the environment niri passes to the programs it spawns.
- The ignore policy denies by default: `.gitignore:323` ignores `/.local/bin/*`, so a binary placed there is untracked without any rule being added.
- `/usr/share/xdg-desktop-portal/niri-portals.conf` sets `default=gnome;gtk;`, which routes the file chooser to `xdg-desktop-portal-gnome`.

## Goals / Non-Goals

**Goals:**

- One chord from wanting a screenshot to having an annotated one on the clipboard.
- Keep the configuration portable across machines that differ in keyboard.
- Fix the file chooser at its cause rather than working around it in the one application where it was noticed.

**Non-Goals:**

- Screenshot history, a save directory, or any on-disk record. See the spec's clipboard requirement.
- Replacing niri's built-in screenshot actions. They stay for the machines that can press them.
- A window or full-screen annotated capture. Region is the case that is wanted; the built-in actions already cover the other two where the keyboard allows.

## Decisions

**Capture and annotation as a pipeline, not an integrated tool.** `slurp` draws the region, `grim` captures exactly that region to stdout, and `satty` reads the image from stdin. Each program does one thing and is replaceable without touching the other two.

The alternative was to keep niri's `screenshot` action and open the file it writes in an editor afterwards. Rejected: it needs a second chord or a directory watcher to find the file just written, it writes a file the spec says should not exist, and the two halves cannot be cancelled as one gesture.

**satty over swappy as the annotator.** swappy is packaged in Fedora at 130 KB and satty is not packaged at all, which is the whole argument for swappy. satty wins on the thing being optimised: `--early-exit` closes it the moment the copy is made, so the gesture ends on the same keystroke that produces the result, and its annotation set (numbered markers, blur, crop) is the one this is for. swappy remains the fallback if satty's unpackaged status becomes a maintenance problem.

**satty from the upstream release binary, not `cargo install`.** Building it needs `gtk4-devel`, `libadwaita-devel` and `glib2-devel`, none of which are installed and all of which exist only to compile it. The published `x86_64-unknown-linux-gnu` binary links against the GTK4 and libadwaita runtimes already present. Cost: updates are manual, and the version is a decision recorded in documentation rather than resolved by a package manager.

**The binary lives in `~/.local/bin` and stays untracked.** It is a 6.8 MB architecture-specific build; committing it would put a binary in a repository whose whole discipline is that content is named explicitly, and it would be wrong on any machine of another architecture. The README entry is what carries it to the next machine.

**`--copy-command wl-copy` rather than relying on the editor.** satty has no Wayland clipboard of its own and needs to be told what to shell out to. This is also what makes the clipboard survive satty exiting: `wl-copy` forks a process that holds the selection, which the Wayland protocol requires of whoever owns it.

**`--output-filename` is omitted, which disables saving entirely.** satty's own help is explicit that omitting it disables the save action. This is the mechanism behind the spec's no-file requirement, and it is also why the editor's Save As is the only way a file is ever produced by hand.

**`Mod+Shift+S` as the chord.** It is the Windows Snipping Tool combination, so the muscle memory exists already. `Mod+Alt+S` was the other candidate and is taken: it is `Super+Alt+S`, the screen-reader toggle. `Mod+S` and `Mod+Ctrl+S` are free and were left free rather than spent on the window and full-screen variants, which are Non-Goals above.

**The `Print` binds are kept rather than deleted.** They cost nothing on a keyboard without the key and are the whole capability on a keyboard with it. This configuration is one checkout across machines, so a bind is deleted only when it is wrong everywhere.

**The file chooser is fixed by installing the delegate, not by re-routing the portal.** The alternative was a user-level `~/.config/xdg-desktop-portal/niri-portals.conf` restating the shipped file with `org.freedesktop.impl.portal.FileChooser=gtk`, which installs nothing and gets the GTK3 dialog from the already-running `xdg-desktop-portal-gtk`.

Installing nautilus was chosen instead for three reasons, in order: it is also a file manager, which this session did not have and which the drag-and-drop and right-click cases want; it is GTK4/libadwaita and follows the session's `prefer-dark` setting, where the GTK3 dialog is a themed-differently window in a session that otherwise agrees with itself; and the override file would be a tracked copy of a packaged file, which goes stale silently when the packaged one changes. The cost is 14.6 MB plus `gvfs` and `gnome-autoar`, against roughly zero for the override.

## Risks / Trade-offs

- **satty is unpackaged, so security updates are manual.** → The README entry names the exact version and the release URL, so checking for a newer one is a defined action rather than a memory. It is a local image editor with no network surface, which is what makes this acceptable rather than merely tolerable.
- **A fresh checkout has no satty, and the chord fails silently** — `sh -c` reports nothing to the screen when a program in a pipeline is missing. → This is the failure mode `desktop-session-declaration` exists to prevent, and the required-software entry is the mitigation it prescribes.
- **Cancelling the region selection is implemented as a failed pipeline**: `slurp` exits non-zero, `grim` receives no geometry and errors, and nothing is captured. → This satisfies the spec's cancel requirement exactly — nothing written, nothing copied, nothing reported — but it is a silence that comes from an error path rather than from a handled one, so a genuine failure of `grim` is equally silent.
- **`grim` captures at the output's scale**, so a selection of 200×120 logical pixels produces a 250×150 image at this display's 1.25 scale. → Correct behaviour, and worth knowing before reading it as a bug.
- **nautilus brings `gvfs` and its daemons into a session that had neither.** → Accepted as the price of the file chooser, and the file manager is independently wanted.

## Migration Plan

Not applicable. Nothing is being replaced: the `Print` binds keep working where they can be pressed, and installing the portal delegate changes no existing behaviour except that file dialogs, which previously did not appear, now do.

Rollback is removing one bind from `config.kdl` and `~/.local/bin/satty`. The packages can stay; none of them changes anything on its own.
