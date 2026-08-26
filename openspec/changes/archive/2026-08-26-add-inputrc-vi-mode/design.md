## Context

See proposal.md — Why. The mechanics that shape the approach: readline reads `$INPUTRC` if set, otherwise `~/.inputrc`, otherwise `/etc/inputrc`, and it stops at the first one it finds rather than merging them. On this machine `INPUTRC` is unset, `~/.inputrc` does not exist, and Debian's `/etc/inputrc` is present and currently in force. Bash is 5.3.9, so `show-mode-in-prompt` (bash 4.4+) is available.

## Goals / Non-Goals

**Goals:**

- One tracked file that a fresh clone picks up with no install step.
- A mode indicator that costs no prompt columns and does not interact with `PS1`.

**Non-Goals:**

- Changing `PS1` or any prompt text.
- Vi bindings inside other readline consumers that carry their own configuration (Python REPL, psql).
- A normal-mode-first prompt: readline always begins a line in insert mode and offers no setting to change that.

## Decisions

**Let readline load the file, rather than `bind -f` from `.bashrc`.** Readline already reads `~/.inputrc` at startup for every interactive shell, so a `bind -f ~/.inputrc` line would re-read the same file a second time and add a `.bashrc` dependency for no gain. Alternative considered: keeping the settings in a differently-named file and sourcing it with `bind -f`. Rejected — it buys nothing here, and it would run after the shell's prompt setup rather than as part of readline initialization. `bind -f ~/.inputrc` stays useful as a manual reload in an already-running shell; it is a usage note, not part of the configuration.

**Include `/etc/inputrc` as the first line.** Creating `~/.inputrc` makes readline stop looking, silently dropping the system defaults. `$include /etc/inputrc` restores them, and placing it first lets the later settings win where they overlap. Alternative considered: copying the parts of `/etc/inputrc` that matter. Rejected — it forks a distro-maintained file and drifts.

**Report the mode through cursor shape, not prompt text.** `set show-mode-in-prompt on` prepends `vi-ins-mode-string` / `vi-cmd-mode-string` to the prompt on every mode switch. Putting only DECSCUSR escapes there — `\e[5 q` for a blinking beam, `\e[0 q` to reset — changes the cursor and prints nothing. DECSCUSR has no empty-box shape; `\e[0 q` instead returns the cursor to the shape the terminal profile sets, and Windows Terminal here is already configured with `"cursorShape": "emptyBox"`. Naming `\e[2 q` would force a filled block and override that profile. Alternative considered: hard-coding a shape per mode. Rejected — it fights the terminal's own setting and would have to be revisited on a terminal that renders shapes differently. The strings are wrapped in `\1` / `\2`, readline's non-printing markers, so the visible prompt width stays correct and wrapping does not break. Alternative considered: a textual `(ins)` / `(cmd)` indicator. Rejected — it consumes columns and duplicates information the cursor already carries.

**Track it beside the other shell files.** `.gitignore` denies by default, so `/.inputrc` needs its own allowlist entry next to `!/.bashrc`, `!/.profile`, `!/.bash_logout`. No security denylist pattern matches it, and the file holds no machine-specific or confidential content.

## Risks / Trade-offs

- **A terminal that ignores DECSCUSR shows no mode indicator** → the escapes are inert in that case; vi mode still works, only the cue is missing. No fallback is worth its complexity.
- **A program that leaves the cursor in another shape** (a crashed TUI, an editor exiting abnormally) **keeps that shape until the next mode switch** → the next prompt's insert-mode string re-asserts the beam, so the drift lasts at most one prompt.
- **Muscle memory: emacs bindings that vi mode drops** (`Ctrl-a`, `Ctrl-e`, `Ctrl-k` are not all bound the same way) → readline's vi insert keymap keeps most of the common ones; anything genuinely missed can be re-bound later in the same file.
- **The change is global to interactive bash** → rollback is deleting `~/.inputrc`, after which readline falls back to `/etc/inputrc` and the previous behaviour returns in the next shell.
