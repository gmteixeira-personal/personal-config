## Why

yazi is installed and there is no way to start it except by typing its name into a terminal. It ships no desktop entry of its own — it is a cargo build under `~/.cargo/bin`, and nothing in `/usr/share/applications` or `~/.local/share/applications` mentions it — so the launcher cannot offer it and never will on its own.

Every other thing this session reaches without a terminal is reached the same way: an entry in `~/.local/share/applications` that the launcher finds. Locking, powering off, the radios and the calculator all work that way. A file manager is the same kind of thing and is currently the exception.

## What Changes

- A desktop entry for yazi is added under `~/.local/share/applications`, so the launcher offers it.
- The entry declares that it needs a terminal rather than naming one itself. The launcher already answers that question with the session's own terminal, and this is the first entry to exercise that answer for a program that is only ever started from the launcher.
- The entry carries keywords, so it is found by the words a user reaches for — "files", "browser", "manager" — and not only by the program's name, which says nothing about what it does.
- The session gains a stated file manager. Which program browses files was previously not written down anywhere, which is why nothing could offer it.

## Capabilities

### New Capabilities
- `file-manager`: which program this session browses files with, that it is reachable without a terminal, and what its desktop entry has to declare given that the program ships none.

### Modified Capabilities
<!-- None. `application-launcher` already requires the launcher to give a terminal entry the session's terminal, and this change relies on that requirement rather than altering it. `default-applications` maps MIME types to applications, which is a different question from what a launcher lists. -->

## Impact

- `~/.local/share/applications/` — one added desktop entry, tracked in this repository beside the six already there.
- Depends on the launcher's existing `terminal=footclient` setting and on its `Keywords` field matching, both of which `application-launcher` already requires and neither of which changes.
- No new package. yazi is already installed; nothing here builds or fetches it.
- Takes effect as soon as the file exists; the launcher reads the entry directories on each run.
