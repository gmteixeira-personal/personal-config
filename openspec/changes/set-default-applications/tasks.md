## 1. The desktop entry

- [x] 1.1 Write `.local/share/applications/nvim-foot.desktop` with `Type=Application`, `Name=Neovim (foot)`, `Exec=footclient --no-wait nvim %F`, `TryExec=footclient`, `Terminal=false`, `NoDisplay=true`, `Icon=nvim` and `Categories=Utility;TextEditor;Development;`, and verify `desktop-file-validate` on it reports no errors
- [x] 1.2 Add a comment above the `Terminal=false` line recording why the entry exists — that GIO picks a terminal from a fixed list this session installs none of, and has no setting to name one — and verify the file still validates

## 2. The default-application mapping

- [x] 2.1 Write `.config/mimeapps.list` with a `[Default Applications]` section that keeps the seven existing `google-chrome.desktop` and `claude-code-url-handler.desktop` lines unchanged, and verify `git diff` shows only additions to that section
- [x] 2.2 Add `nvim-foot.desktop` as the default for every type the shared MIME database files under `text/` except `text/html`, plus `application/json`, `application/toml`, `application/yaml`, `application/xml`, `application/x-shellscript`, `application/x-ruby`, `application/x-perl`, `application/x-php`, `application/x-awk`, `application/x-csh`, `application/x-m4`, `application/ecmascript`, `application/json5`, `application/sql` and `application/xml-dtd`, taking the text list from the database rather than writing one by hand, and verify `xdg-mime query default <type>` returns `nvim-foot.desktop` for every one of them
- [x] 2.3 Add `org.gnome.Loupe.desktop` as the default for every image type named in that entry's `MimeType=` line, taking the list from `/usr/share/applications/org.gnome.Loupe.desktop` rather than writing one by hand, and verify `xdg-mime query default <type>` returns `org.gnome.Loupe.desktop` for each
- [x] 2.4 Add `org.pwmt.zathura-pdf-mupdf.desktop` as the default for `application/pdf`, `application/oxps`, `application/epub+zip`, `application/x-fictionbook` and `application/x-mobipocket-ebook`, and verify `xdg-mime query default <type>` returns it for each
- [x] 2.5 Verify no image type is mapped to Zathura — every type in Loupe's `MimeType=` line still returns `org.gnome.Loupe.desktop`, and neither `image/x-bmp` nor `image/tiff-fx` appears in the file at all
- [x] 2.6 Run `update-desktop-database ~/.local/share/applications` and verify `gio mime text/markdown` names `nvim-foot.desktop`, `gio mime image/png` names `org.gnome.Loupe.desktop`, and `gio mime application/pdf` names `org.pwmt.zathura-pdf-mupdf.desktop`

## 3. Tracking

- [x] 3.1 Add `!/.config/mimeapps.list` to block 3 of `.gitignore` with a comment saying why the file is tracked, and verify `git check-ignore -v ~/.config/mimeapps.list` reports no match
- [x] 3.2 Add `!/.local/share/applications/nvim-foot.desktop` to block 5's launcher-entry list with a comment, and verify `git check-ignore -v` reports no match for it
- [x] 3.3 Verify `git status --porcelain` lists both new files and nothing else from `.local/`, and that no copy of `org.gnome.Loupe.desktop` or of either Zathura entry was added

## 4. Verification in the session

- [x] 4.1 Run `gio open` on a `.md` file and verify a foot window opens with that file loaded in Neovim
- [x] 4.2 Run `xdg-open` on the same file and verify it opens the same way, confirming the `text/plain` mapping covers the caller that resolves by content
- [x] 4.3 Open a `.json`, a `.sh`, a `.rs` and a `.rb` file the same way and verify each opens in Neovim, covering a type filed under `application/` and one filed under `text/` outside the `x-` prefix
- [x] 4.4 Open an `.html` file and verify it still opens in Chrome
- [x] 4.5 Open a `.png` and verify Loupe opens showing it, and that no Chrome window or tab appears
- [x] 4.6 Open a `.svg` and verify it still opens in Loupe, unchanged from before this change
- [x] 4.7 Open a `.pdf` and verify Zathura opens showing the rendered page, and that no Chrome window or tab appears
- [x] 4.8 Verify the packaged `nvim.desktop`, `org.gnome.Loupe.desktop` and both Zathura entries are unmodified and still present under `/usr/share/applications/`
- [x] 4.9 Open the launcher and verify only one Neovim entry and one Zathura entry are listed, and that choosing each still opens it

## 5. Documentation

- [x] 5.1 Add a note to `README.md` in the section that covers the session's required software, stating that text files open in Neovim, images in Loupe and documents in Zathura through `.config/mimeapps.list`, that `nvim-foot.desktop` exists because GIO cannot be told which terminal to use, and that the entry depends on the `foot-server` units already documented there
- [x] 5.2 Add `loupe` to the required-software list, stating that without it every image type named in the mapping falls back to opening in Chrome
- [x] 5.3 Add `zathura` and `zathura-pdf-mupdf` to the required-software list as two separate packages, stating that without the backend Zathura opens every mapped type to a render error rather than failing to start
- [x] 5.4 Verify the note names both tracked files by path so a reader can find them
