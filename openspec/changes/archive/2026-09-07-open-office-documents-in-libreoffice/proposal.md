## Why

Nothing in this session opens an office document. `xdg-mime query default` answers
with an empty line for `.docx`, `.xlsx` and `.pptx` alike, and for every
OpenDocument type beside them, because `.config/mimeapps.list` names a handler for
text, images and PDFs and stops there. Double-clicking a spreadsheet in the file
chooser, or pressing enter on one in yazi — which has no `[opener]` section of its
own and so hands the file to `xdg-open` — produces nothing at all: no window, no
error, no journal line. That is the worst shape a missing default takes, because
there is nothing at the point of use to read.

LibreOffice 26.2.6.1 is already installed here — writer, calc, impress, draw and
math — and its packaged desktop entries declare every one of these types. The
handler exists; the mapping that would reach it does not.

## What Changes

- Name the packaged LibreOffice entries as the default for the office document
  types: `libreoffice-writer.desktop`, `libreoffice-calc.desktop`,
  `libreoffice-impress.desktop`, `libreoffice-draw.desktop` and
  `libreoffice-math.desktop`. The types come from each entry's own `MimeType=`
  line, as the image and document mappings already do, so the list cannot claim a
  format LibreOffice will not open.
- Cover the OpenDocument types and the Microsoft ones together — `.odt`/`.ods`/
  `.odp` and `.docx`/`.xlsx`/`.pptx`, along with the legacy `.doc`/`.xls`/`.ppt`
  types and the macro-enabled variants each entry lists.
- Settle the overlaps, so each type keeps exactly one answer. Every type this
  session already maps stays where it is: `text/plain`, `text/csv`,
  `text/spreadsheet` and `text/tab-separated-values` stay in Neovim, and
  `application/pdf` stays in Zathura, even though Writer, Calc and Draw claim
  them. What LibreOffice adds is the types nothing else answers for.
- Copy no desktop entry into the repository. These are packaged entries, named in
  the tracked mapping and left where their package put them.
- Name LibreOffice in the README's required software, with what breaks without it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `default-applications`: adds a requirement that an office document opened from
  outside a shell opens in the session's office suite, extends the existing
  overlap rule to cover a type claimed by both the office suite and an already
  mapped handler, and extends the discoverability requirement to name the office
  suite.

## Impact

- `.config/mimeapps.list` — the tracked mapping gains an office document section.
- `README.md` — a LibreOffice entry under **Software this configuration expects**,
  and the sentence naming what text, image and document types open in.
- Depends on the `libreoffice-writer`, `libreoffice-calc`, `libreoffice-impress`,
  `libreoffice-draw` and `libreoffice-math` packages, all installed already.

## Non-goals

- The `x-scheme-handler/ms-word`, `ms-excel`, `ms-powerpoint`, `ms-visio` and
  `ms-access` URL schemes that `libreoffice-startcenter.desktop` also declares.
  Those are what a SharePoint or Teams page fires for "open in the desktop app",
  which is a different action from opening a file, and they can be mapped later on
  their own terms.
- Opening these files in the Microsoft 365 web apps. The installed Word, Excel and
  PowerPoint PWA entries declare no `MimeType=` and take no file argument, because
  their manifests register no file handlers — a local path cannot be handed to
  them at all.
