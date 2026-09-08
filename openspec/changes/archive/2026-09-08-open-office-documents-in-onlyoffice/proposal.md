## Why

The session's office suite has been replaced. LibreOffice is uninstalled and OnlyOffice Desktop
Editors is installed in its place, and neither half of that swap is recorded anywhere this
repository can check.

The visible failure is the mapping. `~/.config/mimeapps.list` still names
`libreoffice-writer.desktop`, `libreoffice-calc.desktop`, `libreoffice-impress.desktop`,
`libreoffice-draw.desktop` and `libreoffice-math.desktop` for 118 types. None of those entries exists
on disk any more, so every office document type resolves to a handler that is not installed — opening
a `.docx` produces no window, no error and no journal line, which is exactly the failure the existing
spec calls out as unacceptable.

The install needs recording for a different reason. OnlyOffice does not start on a clean Fedora
system: its vendor RPM omits two libraries its own bundled Qt plugin links against, and the fix was
found by hand. Undocumented, the next machine built from this repository reproduces the crash and the
same afternoon is spent rediscovering it.

## What Changes

- Record the OnlyOffice installation as part of this configuration: the `onlyoffice-repo` package
  from `download.onlyoffice.com`, which adds `/etc/yum.repos.d/onlyoffice.repo` and the
  `RPM-GPG-KEY-ONLYOFFICE` signing key, and `onlyoffice-desktopeditors` on top of it.
- Record `libSM` and `libICE` as required alongside it. The vendor RPM declares `libX11`, `libxcb`
  and four `xcb-util-*` packages but not these two, which its own
  `/opt/onlyoffice/desktopeditors/platforms/libqxcb.so` links against. Without them Qt reports
  `could not find or load the Qt platform plugin "xcb"` and the process dumps core, having listed
  `xcb` among the plugins it says are available.
- **BREAKING** Retire LibreOffice. All 18 packages are removed, and the drawing and formula
  components go with the office ones — `libreoffice-core` is 288 MB of the 378 MB total and every
  component requires it, so keeping Draw or Math means keeping the whole engine.
- Repoint the 37 office document types that OnlyOffice declares from the LibreOffice component
  entries to the single `onlyoffice-desktopeditors.desktop` entry — 13 from Writer, 11 from Calc,
  12 from Impress, and `application/vnd.oasis.opendocument.graphics` from Draw.
- Add the 16 types OnlyOffice declares that this mapping never listed: the Visio drawing, stencil and
  template types, the six WPS Office types, `application/vnd.ms-xpsdocument`, `image/vnd.djvu`,
  `application/msword-template`, and the `x-scheme-handler/oo-office` URL scheme.
- **BREAKING** Drop the 81 types no installed handler declares. These are the legacy word processor
  and spreadsheet formats LibreOffice carried filters for (WordPerfect, AbiWord, Lotus 1-2-3,
  StarOffice, dBASE, Gnumeric, Parquet, iWork sidecar types, ODF master documents), the whole Math
  block, and every Draw type but `.odg`. Opening one of these files from the desktop will no longer
  start anything.
- Leave the types another handler already answers for where they are: `application/pdf`,
  `application/epub+zip` and `application/oxps` stay with Zathura; `text/plain`, `text/csv`,
  `text/csv-schema`, `text/markdown` and `text/tab-separated-values` stay with Neovim.
- Keep FictionBook with Zathura. OnlyOffice declares `application/x-fictionbook+xml`, which
  `/usr/share/mime/aliases` gives as the canonical name of the `application/x-fictionbook` line
  Zathura already holds. It is one format, so it keeps one handler, and that handler stays the
  document viewer.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `default-applications`: The office suite requirement is written around a suite that ships one
  desktop entry per component and routes a document by which component declares its type. OnlyOffice
  ships a single entry that routes internally by file type, so the requirement that each format open
  "in the component that declares it" no longer describes anything observable, and the scenario that
  inspects "the office suite's desktop entries" now inspects one entry. The requirement that a type
  nothing else answers for goes to the suite also needs a bound: it currently reads as though the
  suite answers for every office format, and the formula formats and every drawing format but `.odg`
  now have no handler at all.
- `retired-tooling`: Adds LibreOffice to the tools recorded as withdrawn, in the form the existing
  entries use — the package absent, no leftover state, the documentation naming it, and re-adding it
  a deliberate act. It differs from every entry already there in one way worth stating in the spec
  rather than leaving to be rediscovered: lazygit, zoxide, noctalia and alacritty were each retired
  as duplicates of something the session already had, so retiring them cost nothing. This one costs
  something. The formula formats, the drawing formats other than `.odg`, and the legacy import
  filters have no handler after it.

## Impact

- `~/.config/mimeapps.list` — the office document section, rewritten.
- `openspec/specs/default-applications/spec.md` and `openspec/specs/retired-tooling/spec.md` —
  office suite requirements, and the record of LibreOffice's withdrawal.
- `README.md` — the office documents sentence, and the required-software list: the LibreOffice entry
  replaced by an OnlyOffice one that carries the `libSM`/`libICE` requirement, and LibreOffice named
  among the tools that must stay absent.
- Depends on the `onlyoffice-repo`, `onlyoffice-desktopeditors`, `libSM` and `libICE` packages.
- No desktop entry is written by this repository; `onlyoffice-desktopeditors.desktop` is the packaged
  entry and is named, not copied, consistent with the existing requirement.

## Non-goals

- Replacing the drawing and formula editors. OnlyOffice opens `.odg` but edits no other Draw format
  and nothing answers for the Math formats after this change; choosing a successor — or deciding to
  keep living without one — is its own decision with its own trade-offs.
- Packaging around the vendor RPM's missing dependencies. `libSM` and `libICE` are named as required
  software and installed; this change does not carry a local RPM, an override, or a wrapper to make
  the vendor package declare them correctly.
