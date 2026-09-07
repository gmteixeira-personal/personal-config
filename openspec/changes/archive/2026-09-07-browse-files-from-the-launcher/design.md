## Context

See proposal.md — Why.

`~/.local/share/applications/` holds seven entries, six of them tracked here. Five point at scripts this repository ships (`fuzzel-power`, `fuzzel-calc`, `fuzzel-bluetooth`, `fuzzel-wifi`); one, `nvim-foot.desktop`, wraps a terminal program. yazi ships nothing — `/usr/share/applications` has no entry for it, and the binary is a cargo build at `~/.cargo/bin/yazi`.

Two things the launcher already does make this small. `.config/fuzzel/fuzzel.ini` sets `terminal=footclient`, which `application-launcher` requires and which is what makes `Terminal=true` work at all in a session that installs none of the terminals GIO's fixed list names. The same file states the fields a query is matched against, keywords included.

`nvim-foot.desktop` is the nearest existing entry and is the one this deliberately does not copy. It carries `Terminal=false` and `Exec=footclient --no-wait nvim %F`, and its comment says why: it is reached by MIME association from `.config/mimeapps.list`, so GIO launches it, and GIO cannot be told which terminal this session runs. That entry is also `NoDisplay=true`, because a packaged `nvim.desktop` already appears in the launcher and fuzzel opens it correctly through `terminal=footclient`.

## Goals / Non-Goals

**Goals:**
- Put yazi in the launcher with the smallest entry that works, and make the entry say which of the two available shapes it is and why.
- Have the entry disappear on a machine where yazi is not installed, rather than offering something that fails.

**Non-Goals:**
- Any MIME association. Making yazi the handler for `inode/directory` is a different requirement with a different answer to the terminal question, and nothing asks for it yet.
- yazi's own configuration — its theme, its flavor, its keys. A separate change covers the flavor that is installed but not yet selected.
- A launcher entry for anything else that is currently terminal-only.

## Decisions

**Use `Terminal=true` rather than `nvim-foot.desktop`'s `Exec=footclient …`.**
Both work from the launcher. They differ in what else can launch the entry: naming the terminal in `Exec` makes it work from GIO and `xdg-open` too, at the cost of restating an answer the launcher's configuration already gives, in a file with no way to notice when that answer changes. The editor pays that cost because a MIME association forces it to; yazi has none, so its only route in is the launcher, and the launcher's answer is the whole answer. Choosing the simpler shape also means this entry exercises the requirement `application-launcher` states rather than routing around it.

**Do not set `NoDisplay`.**
`nvim-foot.desktop` hides itself because a packaged entry for the same program is already listed and works. Nothing lists yazi, so hiding this entry would leave the launcher exactly as empty as before.

**`TryExec=yazi`.**
This is what makes the entry self-hiding: a launcher skips an entry whose `TryExec` binary is not on its path, so a checkout on a machine without yazi shows nothing rather than an entry that opens a terminal and closes it again. It costs one line and mirrors `TryExec=footclient` in the editor's entry.

**Name the entry for the program and let keywords carry the task.**
The launcher matches name, generic name, filename and keywords. "yazi" is what a user who knows the program types; `GenericName=File Manager` and keywords covering files, browse, manager and explorer are what a user who does not know it types. Naming the entry "File Manager" instead would invert that and lose the name the program is actually called.

**Rely on `~/.cargo/bin` already being on the terminal's path rather than writing an absolute path in `Exec`.**
It is: the systemd user manager's environment carries it, and so does the running `foot-server`, which is what `footclient` attaches to. An absolute path would work too and would hard-code an installation location that differs per machine — the same argument `shell-environment` already makes about assembling `PATH` rather than restating install locations.

## Risks / Trade-offs

- **The entry cannot be launched by GIO or `xdg-open`** → Accepted and stated in the spec. Those routes only matter for a program with a MIME association, and adding one is the point at which to revisit the shape, not before.
- **`~/.cargo/bin` reaching `foot-server` is inherited from the session rather than declared** → True today on this machine and verified there, but nothing in this repository states it. If a future session starts the server with a narrower path, the entry opens a terminal that reports `yazi: command not found` — a visible failure with a readable message, not a silent one. Worth its own change if it happens; not worth pre-empting with an absolute path here.
- **A second file manager later** → The capability names one program. If another arrives, the requirement to name one is what forces the choice to be made rather than both being present and neither being the session's.

## Migration Plan

Add the entry, open the launcher and type "files" to confirm it is offered and starts. Rollback is deleting the file; nothing else reads it.
