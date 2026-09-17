## Why

A text file opened from outside a shell is opened from a graphical session — from the file manager, from a browser download, through `xdg-open`. Until now it opened in Neovim inside a foot window, which is the shell answer given to a caller that had no shell. The session already installs a Neovim that draws its own window, names it as the graphical text editor, and tracks a desktop entry for it; that entry was reachable only from the launcher. Pointing the file type mapping at it makes the graphical caller and the graphical editor meet, and leaves the terminal answer where it belongs — in a terminal, where `EDITOR` still names `nvim`.

## What Changes

- The default application for every text and source type in `.config/mimeapps.list` becomes `neovide.desktop` instead of `nvim-foot.desktop`. The set of types is unchanged: all 164 mapping lines are repointed, and `text/html`, the image types, the document types and the office types are untouched.
- `nvim-foot.desktop` stays tracked and stays valid, no longer as the handler but as what the mapping falls through to. Its `TryExec=footclient` was already the reason it works; `neovide.desktop`'s `TryExec=neovide` is what makes the fallback reachable — GIO skips an entry whose binary is absent and goes on to the registered applications for the type.
- The comments in `.local/share/applications/neovide.desktop` and `.local/share/applications/nvim-foot.desktop` are corrected. Each asserted the old arrangement in prose: the first said `nvim-foot.desktop` remained the MIME handler, the second said it was reached by MIME association.
- `.gitignore` block 5 and the required-software section of `README.md` are updated for the same reason.
- `EDITOR`, `VISUAL` and `SUDO_EDITOR` are deliberately unchanged and keep naming `nvim`. A shell already has a terminal, so the reason for the graphical entry does not apply to it.

## Capabilities

### New Capabilities

None. Both capabilities this touches already exist.

### Modified Capabilities

- `default-applications`: the entry named as the default for text types no longer opens a terminal — it draws its own window. The requirement that it opens the session's terminal itself is removed and split in two: one requirement over what the named default may demand of its caller, and one over the fall-through entry that still opens a terminal. The discoverability scenario changes with them, and the tracking requirement gains what recovering from an in-place rewrite means.
- `gui-text-editor`: the graphical editor gains a second route in. It was reachable from the launcher alone, on the stated grounds that nothing opened it by association; it is now what a text file opened from outside a shell opens in.

## Impact

- `.config/mimeapps.list` — 164 mapping lines and the commentary around them.
- `.local/share/applications/neovide.desktop`, `.local/share/applications/nvim-foot.desktop` — comment blocks only; no key in either entry changes.
- `.gitignore`, `README.md` — the prose describing which entry answers for text.
- Nothing in `.config/fish/`, `.bashrc` or `.config/nvim/` changes.
- Without Neovide installed, text types fall through to `nvim-foot.desktop` and open as before, so a checkout on a machine that has not built Neovide is not left without a handler.
