## Why

Opening a text file from anything other than a shell does nothing in this session. A file chosen in Nautilus, a download opened from Chrome, or an `xdg-open README.md` all resolve to the packaged `nvim.desktop`, which is marked `Terminal=true` — and the library that launches it, GIO, finds a terminal from a fixed list of `xdg-terminal-exec`, `gnome-terminal`, `konsole`, `ptyxis` and `tilix`. This session runs `foot` and installs none of those, so the launch fails with no window and no error.

This is the same defect the launcher's `terminal=footclient` line already fixes for fuzzel, in the one consumer that cannot be told which terminal to use. Fixing it needs a desktop entry that opens its own terminal rather than asking to be given one.

Images fail differently: they open, but not consistently and not in the viewer installed for them. `image/svg+xml` resolves to Loupe, the session's image viewer; every other image type resolves to `com.google.Chrome.desktop`. One folder of pictures therefore opens in two different programs depending on the file, and most of them land in a browser tab with no zoom, no rotate, and no way to step to the next image. Nothing chose this — it is what the last program to claim a type left behind.

PDF is the third case: `application/pdf` resolves to Chrome because Chrome was the only thing installed that claimed it. Zathura is installed now, so that is no longer true.

All three are the same underlying problem: this session has no tracked statement of which application opens what, so the answer is whatever each machine accumulated.

## What Changes

- Add a tracked desktop entry that runs Neovim inside `footclient` and declares `Terminal=false`, so any launcher can start it without knowing what terminal this session runs.
- Add a tracked `mimeapps.list` naming that entry as the default application for the text types this session edits — every type filed under `text/` except `text/html`, which stays with Chrome, plus the source-code types filed under `application/`: JSON, TOML, YAML, XML, shell scripts, Ruby, Perl, PHP, awk, csh, m4, ECMAScript, JSON5, SQL and DTDs.
- Map `text/markdown` and `text/plain` both, because a `.md` file resolves to `text/markdown` under GIO and to `text/plain` under `file(1)`, and the two disagree about the same file.
- Name Loupe in the same file as the default for the image types it declares support for, so every image opens in the viewer that already answers for SVG.
- Name Zathura in the same file as the default for the document types it handles and Loupe does not — PDF, OpenXPS, EPUB, FictionBook and Mobipocket. Zathura's backend entry also claims several image types; those stay with Loupe.
- Extend the ignore file so both new files are tracked: the desktop entry through a block 5 carve-out under `.local/share/applications/`, the `mimeapps.list` through a block 3 entry.
- Record the new required-software facts in `README.md`.

Video and directory types are deliberately left at their current defaults. This change covers text, images and documents.

## Capabilities

### New Capabilities
- `default-applications`: which application the session opens a file in when the file is opened from outside a shell, and what a desktop entry must do to be launchable by a consumer that cannot be configured with a terminal.

### Modified Capabilities
<!-- none -->

## Impact

- New: `.local/share/applications/nvim-foot.desktop`, `.config/mimeapps.list`.
- Modified: `.gitignore` (block 3 and block 5 entries), `README.md` (required-software notes).
- Depends on `foot` and `neovim`, both already required, and on the `foot-server` user units already enabled. Also on `loupe` (`loupe-50.0-1.fc44`) and on `zathura` with the `zathura-pdf-mupdf` backend (`zathura-2026.07.18-1.fc44`), both installed and both shipping their own desktop entries — nothing new is written for either.
- No change to any running process. The session reads `mimeapps.list` per launch, so the effect is immediate and needs no restart.
