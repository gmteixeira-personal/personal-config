## Context

See proposal.md — Why.

Three files already existed and did not need to be created. `.config/mimeapps.list` mapped 164 text and source types to `nvim-foot.desktop`. `.local/share/applications/nvim-foot.desktop` wrapped `nvim` in `footclient --no-wait` and was written because GIO cannot be told which terminal this session runs. `.local/share/applications/neovide.desktop` was added by `2026-09-16-add-neovide-gui-editor` for the launcher, declares `TryExec=neovide` and `Exec=neovide %F`, and nothing routed a file to it.

Two facts about the machine shape what follows. `neovide` is a cargo build at `~/.cargo/bin/neovide`, which is on the systemd user PATH — the environment GIO launches desktop entries with — so a bare `Exec=neovide` resolves for a launched entry and not only for an interactive shell. And Neovide 0.16.2 defaults to `--no-fork`; `--fork` is the opt-in. Nothing here depends on that, since GIO does not wait on what it launches, but it is what would matter if the entry were ever reached from a shell.

The working copy of `.config/mimeapps.list` had also been rewritten in place by another program before this change started: every comment stripped, and an `[Added Associations]` block added mapping `application/x-zerosize` to `claude-code-url-handler.desktop`. That is the failure the file's own header predicts and the reason it is tracked.

## Goals / Non-Goals

**Goals:**

- Change which entry the mapping names, and nothing else about the mapping.
- Leave a machine without Neovide opening text files as it does today.
- Leave every comment in the four touched files true, since each asserts the arrangement in prose.

**Non-Goals:**

- `EDITOR`, `VISUAL` and `SUDO_EDITOR`. See the decision below.
- Neovide's own configuration. Font, padding and rasterization were settled by `2026-09-16-add-neovide-gui-editor` and this change opens the same program with a file argument.
- Whether `application/x-zerosize` should be associated with anything. Carried forward as it was found; noted rather than decided.

## Decisions

**Repoint all 164 lines rather than a subset.**

The alternative was to send the common types to Neovide and leave the rest, which is what "try it on Markdown first" produces. It fails the existing requirement that the same handler answers from every caller and that a source file opens whichever media type its type happens to be filed under: with a split, `text/x-python` opens one way and `application/x-ruby` another, and nothing at the point of use explains why. The set of types was chosen once, from the shared MIME database, and it stays one set with one answer.

**Keep `nvim-foot.desktop` as a fall-through rather than deleting it.**

`neovide.desktop` declares `TryExec=neovide`, and GIO skips an entry whose `TryExec` binary is absent, then goes on to the applications registered for the type. `nvim-foot.desktop` is registered for none of them by `MimeType=` — it has no such line — but it is installed and remains the tracked answer to the terminal problem, so it is what the arrangement reverts to by editing one word rather than by rewriting an entry from scratch.

Deleting it was considered and rejected on two grounds. Neovide is a cargo build, so a fresh checkout is exactly the case where it is missing, and that is the worst place to discover an unmapped type, which fails with no window and nothing logged. And the entry is the only written record of the GIO terminal-list problem, which is a property of the session rather than of this change.

**Do not declare `MimeType=` on `neovide.desktop`.**

`[Default Applications]` in `mimeapps.list` is an explicit override and GIO honours it whether or not the named entry declares the type — confirmed with `gio mime text/plain`, which answers `neovide.desktop`. Adding a 164-type `MimeType=` line would restate the mapping in a second place, where the two could drift, and its only added effect is to put Neovide in a file manager's "open with" list, which is a different question from which entry a double-click opens.

**Leave `EDITOR`, `VISUAL` and `SUDO_EDITOR` naming `nvim`.**

The obvious-looking alternative is to set them conditionally on `WAYLAND_DISPLAY`, so that "graphical session" picks Neovide. It does not do what it appears to. A terminal running under the compositor has `WAYLAND_DISPLAY` set, so `git commit` typed into foot would leave the terminal and open a separate window — the test answers "is there a display", and the question being asked is "did the caller have a terminal". The shell always has one, and the desktop's open mechanism never does, so the split belongs entirely in the MIME mapping, where it is exact. A shell keeps the terminal editor for the same reason a file manager gets the graphical one.

**Restore the mapping file from `HEAD` rather than editing the rewritten copy.**

Editing in place would have made the comment loss permanent in the next commit while the diff read as a one-word change. The tracked copy was taken as the base, the handler substitution applied to it, and the `[Added Associations]` block appended verbatim, so the diff shows the handler change and the added block and nothing else.

## Risks / Trade-offs

**A caller that resolves a type but ignores `mimeapps.list` gets the packaged `nvim.desktop`.** → Unchanged by this: it was true while `nvim-foot.desktop` was the default, for the same reason, and the packaged entry is deliberately left in place.

**Neovide takes visibly longer to appear than a foot window does.** → Accepted. It is a GPU-accelerated editor starting cold against a terminal client attaching to a running `foot-server`. The alternative is the arrangement this change replaces.

**`nvim-foot.desktop` is now `NoDisplay=true` and named by nothing, so it reads as dead code.** → Its comment states what it is for and when it is reached, and `.gitignore` block 5 says the same beside the line that tracks it.

**A future program rewrites `mimeapps.list` again and strips the comments.** → Not prevented by anything here; it is why the file is tracked. The spec delta records the restore as part of recovering from such a rewrite, so the next occurrence is a known procedure rather than a discovery.

## Migration Plan

One commit, no ordering constraints — `mimeapps.list` is read at open time and needs no reload beyond `update-desktop-database ~/.local/share/applications`. Rollback is substituting `neovide.desktop` back to `nvim-foot.desktop` in the mapping, which the fall-through path already exercises on any machine without Neovide.
