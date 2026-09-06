## Context

See proposal.md — Why. The constraints that shape the approach:

- The library that launches desktop entries for Nautilus, Chrome and `xdg-open` is GIO. For an entry marked `Terminal=true` it calls its own `find_terminal_executable()`, which tries `xdg-terminal-exec` and then a fixed list: `gnome-terminal`, `konsole`, `ptyxis`, `tilix`. This session installs none of them, and `foot` is not on the list. GIO exposes no setting to name a terminal.
- The application launcher is the one consumer that *does* have such a setting, and `.config/fuzzel/fuzzel.ini` already gives it `terminal=footclient`. Terminal entries therefore work from the launcher and fail everywhere else, which is why the fault has gone unnoticed.
- `foot` runs as a client/server pair. `foot-server.socket` and `foot-server.service` are enabled user units, and `footclient` attaches to that server.
- A `.md` file has two MIME answers. `/usr/share/mime/globs2` maps `*.md` to `text/markdown`; content inspection returns `text/plain`, because a Markdown file *is* plain text. `gio info` reports `text/markdown`, `xdg-mime query filetype` reports `text/plain`.
- `$HOME` is the git repository, ignoring everything by default. `.config/mimeapps.list` is reachable from the ignore file's block 3. `.local/share/applications/` is inside block 4's bulk-ignored `.local/` tree and already has a block 5 carve-out, added for the launcher's own entries.
- `~/.local/share/applications/mimeapps.list` exists and is empty. It is the deprecated location and is outranked by `$XDG_CONFIG_HOME/mimeapps.list`, so it needs no change.
- `loupe` is installed (`loupe-50.0-1.fc44`) and ships `org.gnome.Loupe.desktop`, which is `Terminal=false` and declares 26 image types, from `image/png` and `image/jpeg` through `image/avif`, `image/heic` and `image/jxl`. `image/svg+xml` already resolves to it; the rest resolve to `com.google.Chrome.desktop`.
- `zathura` is installed with the `zathura-pdf-mupdf` backend (`zathura-2026.07.18-1.fc44`) and ships two entries. `org.pwmt.zathura.desktop` is the one the launcher shows and declares **no** `MimeType` at all; `org.pwmt.zathura-pdf-mupdf.desktop` is `NoDisplay=true` and carries the type list. Both are `Terminal=false` and both run `zathura %U`. `application/pdf` currently resolves to `com.google.Chrome.desktop`.

## Goals / Non-Goals

**Goals:**

- One tracked mapping file and one tracked desktop entry, both surviving a clone onto another machine.
- Correct behaviour regardless of which MIME type the calling program resolved the file to.
- No dependency on any program's ability to find a terminal.
- One application per kind of file, so the same kind does not open in two programs.

**Non-Goals:**

- Fixing `Terminal=true` launching in general. `btop.desktop` and `htop.desktop` stay unopenable from GIO after this change.
- Replacing or shadowing the packaged `nvim.desktop`, or writing any entry for Loupe.
- Video and directory types. They keep their current defaults.
- Changing Chrome's role. It stays the default for web content and for everything this file does not name.

## Decisions

### A new desktop entry that opens its own terminal, rather than teaching GIO to find one

`.local/share/applications/nvim-foot.desktop` declares `Terminal=false` and runs `Exec=footclient --no-wait nvim %F`. Nothing launching it needs to know what terminal this session runs.

`--no-wait` was added after verification showed the plain form blocks. GIO spawns the entry and forgets it, so it does not care, but `xdg-open` execs the `Exec` line as its own child: without the flag, `xdg-open file.md` holds the terminal it was run from until the editor is quit, and Ctrl-C in that terminal kills the editor. With it, footclient detaches once the window exists and `xdg-open` returns 0 immediately.

*Alternative considered: install `xdg-terminal-exec`.* It is packaged for this Fedora release (`xdg-terminal-exec-0.14.1-2.fc44`), GIO tries it first, and pointing it at `foot.desktop` through `~/.config/xdg-terminals.list` would fix every `Terminal=true` entry at once rather than this one. Rejected for now: it buys a class-wide fix this change does not need, at the cost of a new package, a second tracked configuration file, and a dependency on a GIO code path whose behaviour varies by version — where the entry below depends on nothing but the desktop entry specification. The alternative stays available and is the right move if a second terminal entry ever needs to open from outside the launcher; it does not conflict with this change.

### A separate entry, not an override of `nvim.desktop`

A file named `nvim.desktop` in `~/.local/share/applications/` replaces the packaged one entirely rather than merging with it, so this repository would then own the full `MimeType=` list, the icon, the translated names and the `TryExec` line — and a package update would no longer reach any of them. A separate ID inherits nothing that can go stale.

The cost is a duplicate "Neovim" in the launcher, so the new entry sets `NoDisplay=true`. The launcher already opens the packaged entry correctly through its `terminal=footclient` setting, so nothing is lost by hiding the new one: it exists to be named by MIME association, not to be chosen from a menu.

### `footclient`, not `foot`

Matches `fuzzel.ini`, and attaches to the server the session already runs — the window appears immediately and shares the server's configuration. `foot` would start a second, independent terminal process per file opened.

The trade-off: if `foot-server.service` is not running, `footclient` fails and the file does not open. That is already true of `Mod+T` and of every terminal entry the launcher opens, so this change does not add a failure mode, it joins an existing one. The units are enabled and README already documents them as required.

### Both `text/markdown` and `text/plain` are mapped

Not a preference between the two — the callers disagree and both are reachable, so mapping one leaves the other broken. Mapping `text/plain` also covers every extensionless and unrecognised text file, which is the desired behaviour anyway.

### Loupe is named directly, with no entry of our own

`org.gnome.Loupe.desktop` is already `Terminal=false`, so none of the reasoning behind `nvim-foot.desktop` applies to it. The image half of this change is a list of lines in `mimeapps.list` and nothing else — no new file, no wrapper, nothing for a package update to go stale against.

*Alternative considered: leave images on Chrome.* Chrome does display them, so this is not a broken-versus-working choice. It is rejected because Chrome shows an image as a document in a tab — no zoom control, no rotate, no stepping to the next file in the directory — and because the split is already visible: SVG opens in Loupe today and PNG does not. Picking Loupe for all of them removes the inconsistency rather than adding a preference.

### The image type list is taken from Loupe's own declaration

The types mapped are exactly the ones `org.gnome.Loupe.desktop` names in its `MimeType=` line. Adding a type Loupe does not declare would route a file to a viewer that cannot open it, which is a worse outcome than the browser tab it replaces. Copying the list is the one place in this change where the packaged entry is the source of truth, and it is a list of types rather than behaviour, so it does not carry the staleness problem that copying the entry itself would.

`image/svg+xml` is in that list and already resolves to Loupe. It is written out anyway: the tracked file is meant to state the whole decision, and a mapping that is correct today by accident is not a decision.

### Zathura takes the types Loupe does not declare

Zathura's backend entry claims twelve types, and seven of them are image types Loupe already answers for: `image/png`, `image/jpeg`, `image/bmp`, `image/tiff`, `image/svg+xml`, plus `image/x-bmp` and `image/tiff-fx`. Loupe keeps all of them. Zathura is a document reader whose image support exists so that it can render pages, not so that it becomes the program a photo opens in.

That leaves the five document types nothing else installed handles: `application/pdf`, `application/oxps`, `application/epub+zip`, `application/x-fictionbook` and `application/x-mobipocket-ebook`.

The two image types Loupe does *not* declare — `image/x-bmp` and `image/tiff-fx` — are not given to Zathura either, because neither is reachable. `/usr/share/mime/aliases` records `image/x-bmp` as an alias of `image/bmp`, so resolution canonicalises it away before any lookup, and `image/tiff-fx` has no entry in the MIME database at all. A line for either would never be consulted.

### The `NoDisplay` backend entry is what gets named, not the visible one

`org.pwmt.zathura.desktop` declares no `MimeType`, so naming it would make the tracked file the only thing asserting that Zathura opens PDFs. `org.pwmt.zathura-pdf-mupdf.desktop` is the entry that actually declares the types, and it is the one whose declaration this change reads to build the list — naming a different entry than the one the list came from would be two sources of truth for one decision.

That it is `NoDisplay=true` is not a problem here for the same reason it is not one for `nvim-foot.desktop`: the entry is reached by MIME association, not from a menu. `org.pwmt.zathura.desktop` remains the visible entry in the launcher.

### `%F`, not `%f`

Neovim opens several files in one instance. `%F` passes all selected files to one window; `%f` would open one terminal per file.

### The type list is written out, not inherited

`[Default Applications]` in `mimeapps.list` names each type explicitly. The packaged `nvim.desktop` declares a `MimeType=` list, but it predates `text/markdown`, `application/json`, `application/toml`, `application/yaml` and `application/xml`, so inheriting it would miss most of what this change is for. Listing the types in the tracked file also makes the covered set readable in one place.

### The text list is the whole `text` media type, not the `text/x-` prefix

An earlier draft of this change took the source types to be the ones filed under `text/x-`. Verification against real files showed that prefix does not hold: `.rs` resolves to `text/rust`, `.rb` to `application/x-ruby`, `.ts` to `text/vnd.trolltech.linguist`, while `.go` is `text/x-go` and `.py` is `text/x-python`. The placements record how each type was registered over the years, not what kind of file it is, so any prefix rule leaves gaps — and the gap shows up as one source file opening and the next doing nothing, which reads as a broken editor rather than as an unmapped type.

The list is therefore every type under `text/` less `text/html`, plus the ten source types the database happens to file under `application/`: `x-ruby`, `x-perl`, `x-php`, `x-awk`, `x-csh`, `x-m4`, `ecmascript`, `json5`, `sql` and `xml-dtd`.

`text/html` is the one subtraction, because Chrome already answers for it and a saved page is something to view rather than edit. Binary types filed under `application/` are not added — `x-executable`, `x-python-bytecode`, `x-sqlite2` — and neither is `application/x-desktop`, where opening a desktop entry means running it rather than editing it.

## Risks / Trade-offs

- **The text list is a wide net — it catches log files, `.csv`, `.ini`, `text/calendar`, `text/vcard` and the `text/vnd.*` types nothing on this machine reads.** → Intended. Neovim is the right answer for all of them in this session, and nothing else is installed that would be a better one. A type that later gains a purpose-built viewer is one line to move.
- **A future `mimeapps.list` rewrite by another program.** A browser or file manager offering to become the default for a type rewrites this file in place, silently reordering or dropping entries. → The file is tracked, so the rewrite shows up in `git status` and is revertible. This is the reason to track it rather than leave it to the machine.
- **`nvim-foot.desktop` and the packaged entry both claim these types.** → `[Default Applications]` is an explicit override and wins over any `MimeType=` declaration, so the ordering is decided by the tracked file rather than by which entry was scanned first.
- **`NoDisplay=true` hides the entry from anything that lists applications, including an "Open With" menu.** → Nautilus's "Open With" reads `NoDisplay`, so the entry will not be offered there by name. It remains the default, which is how it is meant to be reached; the packaged Neovim entry is still listed for anyone looking for it.
- **Loupe's declared type list can change with a package update, leaving the tracked mapping naming a type it dropped or missing one it gained.** → A dropped type falls back to the next handler rather than failing; a gained type keeps its current default until the list is refreshed. Neither is silent breakage, and both are visible by re-reading the entry's `MimeType=` line.
- **`image/svg+xml` maps to Loupe, so an SVG opens as a picture rather than as markup.** → That is already today's behaviour and this change preserves it. An SVG to be edited is reached through Neovim from a shell, which is how it is edited now.
- **Chrome loses PDF, and Chrome's own downloads still open in Chrome's internal viewer.** → Unchanged and out of scope: Chrome renders a PDF it downloaded in its own tab without consulting the desktop's default. This change governs what happens when the file is opened from the file manager or `xdg-open`.
- **Zathura with no backend installed opens a window and fails to render.** → `zathura-pdf-mupdf` is installed and README will name it. The backend is a separate package from `zathura` itself, so a clone that installs only `zathura` gets a viewer that opens every mapped type to an error.
