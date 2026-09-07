## 1. Derive the type lists

- [x] 1.1 Read the `MimeType=` line of `/usr/share/applications/libreoffice-writer.desktop`, `-calc`, `-impress`, `-draw` and `-math`, and verify all five entries also declare `Terminal=false`
- [x] 1.2 Subtract the eleven types the design excludes (`text/plain`, `application/x-extension-txt`, the five CSV spellings, the three tab-separated spellings, `application/pdf`) and verify none of the remaining types already appears in `.config/mimeapps.list`
- [x] 1.3 Assign `application/clarisworks` and `application/vnd.ms-works` to Writer only, and verify no type appears under two components
- [x] 1.4 Add the five canonical names the entries list only as aliases — `application/x-docbook+xml`, `application/vnd.stardivision.writer`, `application/vnd.dbf`, `image/emf`, `image/wmf` — and verify each against `/usr/share/mime/aliases`
- [x] 1.5 Verify the result is 118 lines: 42 Writer, 33 Calc, 18 Impress, 18 Draw, 7 Math

## 2. Write the mapping

- [x] 2.1 Append an office document section to `.config/mimeapps.list` under `[Default Applications]`, naming `libreoffice-writer.desktop`, `libreoffice-calc.desktop`, `libreoffice-impress.desktop`, `libreoffice-draw.desktop` and `libreoffice-math.desktop`, grouped one component per block
- [x] 2.2 Write the section's comment in the style the file already uses: that the types are each entry's own `MimeType=` line at LibreOffice 26.2.6.1, which types were left with Neovim and Zathura and why, and that the five canonical names are there because the entries list only the aliases
- [x] 2.3 Verify the file still parses and no type is listed twice: `awk -F= '/^[a-z]/ {print $1}' ~/.config/mimeapps.list | sort | uniq -d` prints nothing
- [x] 2.4 Verify no packaged desktop entry was copied into the repository: `git status --short` shows only `.config/mimeapps.list` and `README.md`

## 3. Verify the behaviour

- [x] 3.1 Verify `xdg-mime query default` now answers for the three types the change was asked for — `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, `...spreadsheetml.sheet`, `...presentationml.presentation` — with the Writer, Calc and Impress entries respectively
- [x] 3.2 Verify the OpenDocument and legacy types answer too: `application/vnd.oasis.opendocument.text`, `.spreadsheet`, `.presentation`, `application/msword`, `application/vnd.ms-excel`, `application/vnd.ms-powerpoint`
- [x] 3.3 Verify the existing mappings are unchanged: `xdg-mime query default text/plain` and `text/csv` still answer `nvim-foot.desktop`, `application/pdf` still answers `org.pwmt.zathura-pdf-mupdf.desktop`, `image/png` still answers `org.gnome.Loupe.desktop`
- [x] 3.4 Open a real `.docx`, `.xlsx` and `.pptx` with `gio open` and verify each opens on screen in Writer, Calc and Impress
- [x] 3.5 Open one of the same files from the file chooser and from yazi and verify both reach the same program

## 4. Document it

- [x] 4.1 Add a **`libreoffice-writer`, `libreoffice-calc`, `libreoffice-impress`, `libreoffice-draw` and `libreoffice-math`** entry to the README's required software list, beside the Loupe and Zathura entries and in their style: which types open where, that the mapping names the packaged component entries rather than the Start Center and why, and that without these packages the documents open with no window and no error at all
- [x] 4.2 Update the README sentence that names what text, image and document files open in so it names office documents too, and verify the README's own description of `.config/mimeapps.list` still matches the file
