## Context

See proposal.md — Why. The state this design has to work from:

- `onlyoffice-desktopeditors-9.4.0-129.el7.x86_64` is installed from `onlyoffice-repo-1.0.0-14`,
  which writes `/etc/yum.repos.d/onlyoffice.repo` and `/etc/pki/rpm-gpg/RPM-GPG-KEY-ONLYOFFICE`. The
  repository's `baseurl` is `http://download.onlyoffice.com/repo/centos/main/noarch/` — plain HTTP —
  with `gpgcheck=1`.
- The suite bundles its own Qt 5 under `/opt/onlyoffice/desktopeditors`, so a bare `ldd` on its
  plugins reports `libQt5Core.so.5` and friends as missing. That is a red herring; the real gap was
  `libSM.so.6` and `libICE.so.6`, which nothing on the system provided.
- All 18 LibreOffice packages are gone, removed in two `dnf` transactions. The second, nominally
  `dnf remove libreoffice-math`, altered 57 packages: with the office components already gone, Fedora's
  default `clean_requirements_on_remove` took `libreoffice-core` and Draw with it.
- `~/.config/mimeapps.list` is 399 lines, one `[Default Applications]` section, organised as
  commented blocks per handler. 118 of its lines name a `libreoffice-*.desktop` entry; none of those
  five entries exists on the machine any more.
- `onlyoffice-desktopeditors.desktop` declares 61 types on one `MimeType=` line. It is one entry for
  the whole suite — there is no per-component entry to name.
- The file's own convention, stated in its comments, is that a block is an application's `MimeType=`
  line less the types the file already answers for, and that types are written under the canonical
  name `/usr/share/mime/aliases` gives, not under whichever alias an entry happens to declare.

Of the 61 types OnlyOffice declares: 7 are already answered by Zathura or Neovim, 1 is FictionBook
under its canonical spelling, 37 are currently held by a LibreOffice component entry, and 16 have
never appeared in the file.

## Goals / Non-Goals

**Goals:**

- Every line in the office section names an entry that exists and declares the type on that line.
- The rewrite is derivable from `MimeType=` and `/usr/share/mime/aliases`, so it can be re-checked
  later without trusting this document.
- The install is reproducible from the tracked documentation alone, including the two packages the
  vendor RPM does not ask for.
- The block's comments explain the decisions that are not obvious from the data — chiefly what was
  dropped and why nothing was substituted for it.

**Non-Goals:**

- Restoring handlers for the formats LibreOffice used to open. No installed application declares
  them; finding a replacement suite is a separate decision.
- Reorganising the rest of the mapping. The Neovim, Loupe and Zathura blocks are untouched.
- Rewriting Zathura's `application/x-fictionbook` line into its canonical spelling. It is a
  pre-existing alias-form line, correct in behaviour, and touching it widens this change for no
  behavioural gain.
- Automating the package installation. This repository tracks configuration, not provisioning; the
  packages are named in README as every other required package is.

## Decisions

**Take the vendor's el7 build rather than a Flatpak or a rebuild.**
`onlyoffice-desktopeditors` is built against CentOS 7 and running on Fedora 44, which works because
the package bundles its own Qt, ICU and CEF rather than linking the system's. Alternatives
considered: the Flatpak, rejected because the portal-mediated file access would sit under a mapping
whose whole job is handing local paths to a handler, and because it would not share the session's
fonts; rebuilding the source RPM for Fedora, rejected as ongoing work to maintain for one desktop
application. The trade-off is accepted deliberately and recorded under Risks.

**Keep `gpgcheck=1` as the integrity guarantee and leave the plain-HTTP `baseurl` alone.**
The repository the vendor ships fetches over `http://`. Signature verification is what actually
establishes that a package is the vendor's, and it is enabled with the key the repo package
installed, so transport encryption is not what protects the install. Switching the `baseurl` to
`https://` by hand was considered and rejected here: it would edit a file `/etc/yum.repos.d/` owns
outside this repository's root, so a package update would silently revert it and the checkout would
never know. It is recorded rather than fixed.

**Install `libSM` and `libICE` explicitly and name them in README, rather than treating the crash as
an OnlyOffice bug to wait out.**
`rpm -q --requires onlyoffice-desktopeditors` lists `libX11`, `libxcb`, `xcb-util-image`,
`xcb-util-keysyms`, `xcb-util-renderutil` and `xcb-util-wm`, but neither `libSM` nor `libICE` —
which `/opt/onlyoffice/desktopeditors/platforms/libqxcb.so` links against directly. On a Fedora
system where nothing else pulled them in, the platform plugin cannot load, and Qt's own error names
`xcb` in the list of plugins it says are available, which sends the reader looking at the wrong
thing. Naming both packages in the required-software list is what stops the next rebuild from
repeating the diagnosis.

**One entry replaces five, and the spec stops describing component routing.**
OnlyOffice picks the editor from the opened file's type inside a single process. The old spec
language — each format opens "in the component that declares it" — described something observable
with LibreOffice's five entries and describes nothing now. The requirement is rewritten to state
what still holds: the document arrives in the right *kind* of editor, however the suite packages
itself. Alternative considered: naming `onlyoffice-desktopeditors.desktop` five times under the old
component comments. Rejected — it would preserve a structure the suite does not have.

**Record LibreOffice's removal in `retired-tooling`, with the capability loss stated in the spec.**
The capability already exists for exactly this and its entries share a shape: package absent, no
leftover state, documented, deliberate to undo. LibreOffice fits the shape but not the reasoning —
the four tools already listed were duplicates, and this one was not. Writing the requirement without
that distinction would file a real trade-off under a heading that has so far meant "removed
something redundant". Alternative considered: leaving the removal undocumented as a machine detail.
Rejected — a suite whose absence changes which files open is not a machine detail.

**Drop the 81 orphaned types rather than pointing them at OnlyOffice.**
The legacy formats, the Math set and every Draw type but `.odg` are declared by nothing installed. Mapping them
to OnlyOffice would make a double-click fail inside OnlyOffice — an error dialog from an application
that never claimed the format — instead of failing as an absent mapping. The spec gains an explicit
requirement for this so the reasoning survives the change.

**FictionBook stays with Zathura.**
`/usr/share/mime/aliases` line 72 gives `application/x-fictionbook` as an alias of
`application/x-fictionbook+xml`. Zathura holds the alias spelling; OnlyOffice declares the canonical
one. Mapping both would put one format under two handlers and break the file's "each type has one
line" rule in the one way the resolver silently tolerates. Ebooks are already a document-viewer
decision, so the format stays where it is and drops out of the OnlyOffice block.

**DjVu and XPS go to OnlyOffice, even though they read like document-viewer formats.**
`image/vnd.djvu` and `application/vnd.ms-xpsdocument` are canonical names that OnlyOffice declares
and this build of Zathura does not — `org.pwmt.zathura-pdf-mupdf.desktop` declares `application/oxps`
and no DjVu type at all. Sending them to Zathura would claim types its entry does not list, which is
the exact thing the file's Start Center comment refuses to do. They follow the declaration.
`application/oxps` stays with Zathura for the same reason, so XPS and OpenXPS end up split between
two handlers — recorded here because it looks like an oversight and is not.

**The block is generated from the entry, then reviewed, not hand-typed.**
The 53 lines come from intersecting the `MimeType=` line with the file's existing answers. Producing
them by script and diffing the result against the old block keeps a 118-line deletion from quietly
dropping a type that should have been kept.

## Risks / Trade-offs

**The vendor RPM's undeclared dependencies return on every rebuild** → `libSM` and `libICE` are not
in the package's `Requires`, so a fresh install on a machine that has nothing else pulling them in
crashes the same way, and a future package update will not fix it on this machine either. Mitigated
by naming both in the required-software list with the exact error text, so the symptom is
searchable in the repository rather than only in the vendor's issue tracker.

**An el7 build on Fedora 44 is unsupported by the vendor** → It works because the package bundles
its own Qt, ICU and CEF, but a Fedora upgrade could break a system library it does still link
against, and the vendor will not treat that as a supported configuration. Accepted; the fallback is
the Flatpak, which is a change of its own.

**The repository is fetched over plain HTTP** → Package signatures are checked against the vendor's
key, which is what establishes authenticity; the exposure is metadata and the ability to serve stale
signed packages. Recorded rather than mitigated, for the reason under Decisions.

**A format that used to open now does nothing, and the failure is silent** → This is the documented
behaviour of an unmapped type and the reason the spec calls unmapped a non-neutral state. Mitigated
by recording the dropped set in the block's comments and in README, so the silence has a written
explanation. The formats affected are legacy ones; the mainstream OpenDocument and Microsoft Office
sets are fully covered.

**Draw's formats leave with no successor** → Visio, Publisher, CorelDRAW, EMF and WMF had a handler
before this change and have none after. OnlyOffice declares the Visio types, so those survive; the
rest do not. Accepted rather than mitigated — reinstalling `libreoffice-draw` alone would pull
`libreoffice-core` back for ~290 MB, and would put a second suite under a mapping that must keep one
answer per type.

**`mimeapps.list` is rewritten in place by other programs** → Unchanged by this design; the file is
tracked for exactly this reason, and the existing requirement covers it.

**OnlyOffice's `MimeType=` line changes on package update** → The block would drift from the entry.
The generation step is scripted and re-runnable, so a later check is cheap.
