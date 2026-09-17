## 1. Recover the tracked mapping file

- [x] 1.1 Back up the machine's rewritten `.config/mimeapps.list` outside the repository, and verify the backup differs from `HEAD` only by the stripped comments and the added `[Added Associations]` block
- [x] 1.2 Rebuild `.config/mimeapps.list` from `git show HEAD:.config/mimeapps.list` so the commentary returns, and verify `git diff --no-ext-diff` removes no comment line except the three rewritten in task 2.3

## 2. Repoint the mapping

- [x] 2.1 Substitute `neovide.desktop` for `nvim-foot.desktop` throughout `.config/mimeapps.list`, and verify the file names `neovide.desktop` on 164 mapping lines and `nvim-foot.desktop` only in the commentary
- [x] 2.2 Append the `[Added Associations]` block carrying `application/x-zerosize` forward verbatim, and verify it is the only section beyond `[Default Applications]`
- [x] 2.3 Rewrite the file's text block commentary to say the types go to Neovide and why a graphical caller gets the window-drawing entry, and verify no comment in the file still asserts that a terminal entry answers for text
- [x] 2.4 Verify the image, document and office mappings are untouched: `gio mime image/png` answers `org.gnome.Loupe.desktop`, `gio mime application/pdf` answers `org.pwmt.zathura-pdf-mupdf.desktop`, and `text/html` still answers the browser

## 3. Correct the two desktop entries

- [x] 3.1 Rewrite the `%F` paragraph in `.local/share/applications/neovide.desktop` — it claims `nvim-foot.desktop` remains the MIME handler — to record that `mimeapps.list` names this entry and that GIO honours that without a `MimeType=` line, and verify no sentence in the file still points the reader at the other entry as the handler
- [x] 3.2 Add a paragraph to the same file recording that `TryExec` is what makes the fall-through safe on a machine without Neovide, and verify it names `nvim-foot.desktop` as what the type reaches instead
- [x] 3.3 Rewrite the closing line of `.local/share/applications/nvim-foot.desktop` — it claims the entry is reached by MIME association — to record that nothing points at it now and why it is kept, and verify `desktop-file-validate` still reports no error on either entry

## 4. Update the surrounding documentation

- [x] 4.1 Update `.gitignore` block 5's comment above `!/.config/mimeapps.list` to name `neovide.desktop` for text, and verify no remaining comment there names `nvim-foot.desktop` as what the mapping points at
- [x] 4.2 Update the two comments in `.gitignore` above the `nvim-foot.desktop` and `neovide.desktop` tracking lines so each states its present role, and verify `git check-ignore -v` reports no match for either path
- [x] 4.3 Rewrite the required-software passage in `README.md` to state that a text file opened from outside a shell opens in Neovide's own window, that `nvim-foot.desktop` is the fall-through where Neovide is absent, and to keep the GIO terminal-list explanation attached to that entry, and verify the passage no longer says text opens in a foot terminal

## 5. Verify the change end to end

- [x] 5.1 Run `update-desktop-database ~/.local/share/applications`, then verify `xdg-mime query default` answers `neovide.desktop` for `text/plain`, `text/markdown`, `text/x-python` and `application/json`
- [x] 5.2 Open a file with `gio open` and verify a window with app ID `neovide` appears in `niri msg windows` with the file loaded
- [x] 5.3 Verify `systemctl --user show-environment` puts `~/.cargo/bin` on `PATH`, so the entry's bare `Exec=neovide` resolves for a GIO-launched process and not only in an interactive shell
- [x] 5.4 Verify a shell is unaffected: `EDITOR`, `VISUAL` and `SUDO_EDITOR` still name `nvim`, and no file under `.config/fish/` or `.bashrc` was changed
