## 1. Record the installed suite

- [x] 1.1 Verify `onlyoffice-repo` is installed and owns both `/etc/yum.repos.d/onlyoffice.repo` and `/etc/pki/rpm-gpg/RPM-GPG-KEY-ONLYOFFICE`, via `rpm -ql onlyoffice-repo`
- [x] 1.2 Verify the repo file has `gpgcheck=1` and a `gpgkey=` pointing at the installed key, and record that `baseurl` is plain HTTP
- [x] 1.3 Verify `onlyoffice-desktopeditors` is installed and note its exact version-release-arch from `rpm -q onlyoffice-desktopeditors` for the README entry
- [x] 1.4 Verify `libSM` and `libICE` are installed, and confirm the vendor RPM does not ask for them: `rpm -q --requires onlyoffice-desktopeditors | grep -E 'libSM|libICE'` returns nothing
- [x] 1.5 Verify `LD_LIBRARY_PATH=/opt/onlyoffice/desktopeditors ldd /opt/onlyoffice/desktopeditors/platforms/libqxcb.so` reports no missing libraries. A bare `ldd` on the plugin reports the bundled `libQt5Core.so.5`, `libQt5Gui.so.5` and `libQt5XcbQpa.so.5` as missing and that is expected, not a fault: the suite resolves them through `RPATH $ORIGIN` on `/opt/onlyoffice/desktopeditors/DesktopEditors`, which a standalone `.so` inspection has no context for — this is the red herring that hides the real `libSM`/`libICE` gap
- [x] 1.6 Launch `onlyoffice-desktopeditors` and verify it opens a window with no `could not find or load the Qt platform plugin "xcb"` error and no core dump

## 2. Confirm LibreOffice is gone

- [x] 2.1 Verify `rpm -qa | grep -i libreoffice` returns nothing
- [x] 2.2 Verify neither `libreoffice` nor `soffice` resolves on `PATH`
- [x] 2.3 Verify `/usr/lib64/libreoffice/` is absent and no `libreoffice-*.desktop` remains under `/usr/share/applications/`
- [x] 2.4 Verify `.config/libreoffice/` and `.cache/libreoffice/` are absent, and remove them if the uninstall left them behind
- [x] 2.5 Verify `git ls-files` lists no path under `.config/libreoffice/`

## 3. Derive the new office block

- [x] 3.1 Extract the 61 types from `MimeType=` in `/usr/share/applications/onlyoffice-desktopeditors.desktop`, one per line, and verify the count is 61
- [x] 3.2 Extract every `type=handler` line already in `~/.config/mimeapps.list` and verify the 7 types OnlyOffice shares with Zathura and Neovim are found by exact match: `application/pdf`, `application/epub+zip`, `application/oxps`, `text/plain`, `text/csv`, `text/markdown`, `text/tab-separated-values`. Match on the full type, not `grep -F` substrings — a substring match pulls in Neovim's `text/csv-schema`, which OnlyOffice does not declare
- [x] 3.3 Resolve each remaining type through `/usr/share/mime/aliases` and verify `application/x-fictionbook+xml` is identified as the canonical name of Zathura's `application/x-fictionbook` line, so it is excluded
- [x] 3.4 Build the final list as the 61 types less the 7 already answered and less FictionBook, and verify it holds exactly 53 types — 37 currently under a LibreOffice component entry (13 Writer, 11 Calc, 12 Impress, and `application/vnd.oasis.opendocument.graphics` from Draw) and 16 new to the file

## 4. Rewrite the mapping

- [x] 4.1 Back up `~/.config/mimeapps.list` to the scratchpad so the 118 deleted lines can be diffed after the rewrite
- [x] 4.2 Replace the five LibreOffice blocks (Writer, Calc, Impress, Draw, Math, lines 246-399) with a single OnlyOffice block of the 53 lines from 3.4, sorted, each as `type=onlyoffice-desktopeditors.desktop`
- [x] 4.3 Write the block's comment header in the style of the surrounding blocks: that it is the entry's `MimeType=` line less the types the file already answers for, that OnlyOffice ships one entry rather than one per component, that FictionBook stays with Zathura as an alias of a type it already holds, and that XPS goes here while OpenXPS stays with Zathura because each entry declares only its own
- [x] 4.4 Record the dropped formats in that comment — the legacy word processor and spreadsheet filters, the Math set, and every Draw type but `.odg` — stating that no installed entry declares them and that opening one now starts nothing
- [x] 4.5 Diff the rewritten file against the 4.1 backup and verify exactly 118 `libreoffice-*.desktop` lines are gone, 53 `onlyoffice-desktopeditors.desktop` lines are present, and no line outside the office section changed

## 5. Verify the mapping resolves

- [x] 5.1 Run `grep -c libreoffice ~/.config/mimeapps.list` and verify it returns 0
- [x] 5.2 Verify every desktop entry named anywhere in the file exists on the machine, by checking each distinct handler name against `/usr/share/applications` and `~/.local/share/applications`
- [x] 5.3 Verify no type appears twice: cut the type field from every mapping line, sort, and confirm `uniq -d` is empty
- [x] 5.4 Run `xdg-mime query default` for `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, `...spreadsheetml.sheet` and `...presentationml.presentation` and verify each returns `onlyoffice-desktopeditors.desktop`
- [x] 5.5 Run `xdg-mime query default` for `application/pdf` and `text/plain` and verify they still return the Zathura and Neovim entries
- [x] 5.6 Open a real `.xlsx` and a `.docx` through `xdg-open` and verify each opens in OnlyOffice with the file loaded, confirmed by the window title. No `.pptx` exists on this machine; `application/vnd.openxmlformats-officedocument.presentationml.presentation` is verified by 5.4 instead, since the suite routes all three through the one entry and a hand-built minimal `.pptx` failing to parse would say nothing about the mapping

## 6. Update the tracked documentation

- [x] 6.1 Update the office-documents sentence in `README.md` (around line 146) to name OnlyOffice instead of LibreOffice, and verify no other line in that paragraph still says LibreOffice
- [x] 6.2 Replace the `libreoffice-*` package entry in README's required-software list (lines 293-311) with an `onlyoffice-desktopeditors` entry covering: that it is one entry for the whole suite, which types it answers for, the `onlyoffice-repo` package it comes from, and which formats lost their handler when LibreOffice was removed
- [x] 6.3 Add `libSM` and `libICE` to that entry as required alongside it, with the exact error text `could not find or load the Qt platform plugin "xcb"` and the note that the vendor RPM does not declare them, so the symptom is searchable from the repository
- [x] 6.4 Add LibreOffice to README's record of tools that must stay absent, in the style of the existing alacritty entry, stating that OnlyOffice serves its purpose and which formats lost their handler with it
- [x] 6.5 Verify the README still satisfies the discoverability scenario: it states which applications text, image, document and office files open in, and that without the office suite these documents have no handler at all

## 7. Close out

- [x] 7.1 Run `openspec validate open-office-documents-in-onlyoffice --strict` and verify it passes
- [x] 7.2 Commit `.config/mimeapps.list`, `README.md` and the change directory, and verify those paths are committed. `git status` is not clean afterwards and should not be forced to be: `.config/fish/conf.d/aliases.fish` and `openspec/changes/add-cls-clear-alias/` belong to a separate unfinished change and are deliberately left alone
