## Context

See `proposal.md` — **Why**. What matters for the approach:

- LibreOffice 26.2.6.1 is installed with five components — `libreoffice-writer`,
  `-calc`, `-impress`, `-draw`, `-math` — and no `libreoffice-base`. Each ships a
  packaged desktop entry that declares `Terminal=false` and a `MimeType=` line;
  `libreoffice-startcenter.desktop` is `NoDisplay=true` and declares only the
  extension and URL-scheme handlers, not the document types.
- `.config/mimeapps.list` maps text to `nvim-foot.desktop`, images to
  `org.gnome.Loupe.desktop` and documents to
  `org.pwmt.zathura-pdf-mupdf.desktop`, in each case listing exactly the types
  the named entry declares. Nothing else on the machine claims the office types:
  `grep -l` over `/usr/share/applications` finds only the LibreOffice entries.
- yazi has no `[opener]` section, so it opens files through `xdg-open` and
  inherits whatever this mapping says. The same is true of the Nautilus-backed
  portal file chooser and of Chrome's downloads. One mapping answers all three.

## Goals / Non-Goals

**Goals:**

- Every office document type LibreOffice can open resolves to the component that
  opens it, from every caller.
- Each type keeps exactly one answer, and every answer this session has already
  chosen stays chosen.
- The list stays derivable: someone reading it can check it against the packaged
  entries without knowing what was in anyone's head.

**Non-Goals:**

- Changing where text, CSV, PDF or images open.
- Adding a repository-side desktop entry. LibreOffice's entries need no terminal
  and no wrapper, unlike the editor's.
- The URL schemes and the M365 web apps — see `proposal.md` — **Non-goals**.

## Decisions

### Name the five component entries, not the Start Center

`libreoffice-startcenter.desktop` is the entry that could stand for "LibreOffice",
and it is the wrong one to name: its `MimeType=` declares
`application/vnd.openofficeorg.extension` and the `x-scheme-handler/ms-*` schemes
and nothing else, so naming it for `.docx` would claim a type its own entry does
not declare — the failure the Zathura decision already avoided by naming the
`-pdf-mupdf` entry rather than the plain one. The per-component entries declare
the document types and are what the mapping names.

This is a naming decision, not a routing one. LibreOffice detects a file's real
format when it is given one, so a file that arrives at the wrong module still
opens in the right one; naming Calc for a spreadsheet keeps the mapping honest
rather than making the file open correctly.

### Take the types from each entry's `MimeType=` line, less what is already mapped

The existing image and document sections are exactly the named entry's own
`MimeType=` line, and this section follows that rule. Subtracting the types
already mapped leaves 118 lines: 42 for Writer, 33 for Calc, 18 for Impress, 18
for Draw and 7 for Math.

Eleven declared types are excluded because this session already answers for them:

| Type | Stays with | Why |
| --- | --- | --- |
| `text/plain`, `application/x-extension-txt` | Neovim | Writer claims both; a `.txt` file belongs in the editor |
| `text/csv`, `text/x-csv`, `text/x-comma-separated-values`, `text/comma-separated-values`, `application/csv` | Neovim | `text/csv` is already mapped and the middle two are its aliases; the other two are alternate spellings, excluded so a CSV opens in one program whichever name a caller resolves to |
| `text/spreadsheet`, `text/tab-separated-values`, `application/tab-separated-values` | Neovim | same, for the tab-separated spellings |
| `application/pdf` | Zathura | Draw claims it, and Draw opens a PDF to edit it, not to read it |

The alternative — letting Calc take the CSV types because it is the better program
for a large one — was rejected for the reason the text mapping exists at all: a
CSV is text, this session opens text in Neovim, and a rule with one exception in
it stops being checkable.

### Add the canonical name where the entry lists only an alias

Five types are mapped that no `MimeType=` line lists, because the entry lists an
alias and `/usr/share/mime/aliases` gives a different canonical name:
`application/x-docbook+xml` and `application/vnd.stardivision.writer` for Writer,
`application/vnd.dbf` for Calc, and `image/emf` and `image/wmf` for Draw.

The mapping already carries this shape for Markdown, and for the same reason:
resolution by glob and resolution by content can return different names for one
file, so mapping one name leaves the other caller with nothing. Mapping both is
cheap and the failure it prevents is silent.

### Give a type claimed by two components to the first one that claims it

`application/clarisworks` is declared by Writer, Calc and Draw, and
`application/vnd.ms-works` by Writer and Calc. Both go to Writer. These are
word-processor formats whose suites also had a spreadsheet, the file itself says
which it is, and LibreOffice routes on that; listing a type twice would be the
real error, because the resolver would answer with whichever line it read last
rather than with a decision.

## Risks / Trade-offs

- **A LibreOffice update changes a `MimeType=` line and the tracked list goes
  stale** → The list records the state at 26.2.6.1 and the file comment says so,
  which is the same exposure the Loupe and Zathura lists already carry and the
  same fix: re-derive from the entries. A stale entry here degrades to a type
  that opens in nothing, not to a wrong program.
- **Someone wants a large CSV in Calc** → It stays in Neovim by this design.
  Opening one in Calc is `libreoffice --calc file.csv`, and if that becomes the
  common case the decision is worth revisiting rather than working around.
- **Uninstalling a component leaves its types mapped to a missing entry** → The
  types resolve to nothing, exactly as they do today. The README entry names all
  five packages so the state is recognisable.

## Migration Plan

One commit: the office section added to `.config/mimeapps.list` and the README
entry beside it. Rollback is reverting it — the mapping is the whole change, and
nothing else in the session reads these types.
