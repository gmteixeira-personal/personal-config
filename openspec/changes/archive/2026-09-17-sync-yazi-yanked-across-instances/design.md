## Context

This session's yazi configuration is `.config/yazi/theme.toml` and nothing else. There is no `init.lua`, so yazi runs with every built-in plugin at its default settings. Beside the theme sit `flavors/` and `package.toml`, both untracked on the recorded reasoning that they are a third-party tree fetched by yazi's package manager and the record of that fetch.

Yazi 26.9.1 carries a `session` plugin compiled into the binary. Its `sync_yanked` option, off by default, publishes the yank list over the DDS socket that instances of one user on one machine already share. Turning it on is a `setup` call and no install step. See `proposal.md` for why the default is the wrong one here.

## Goals / Non-Goals

**Goals:**

- One Lua file, tracked, doing one thing, so the next setting yazi needs has a place to go.
- The reasoning that makes a pending cut acceptable lives beside the setting that creates it, where someone debugging a surprising move will read it.

**Non-Goals:**

- Any other yazi setting. `init.lua` can configure the manager, the status line, the previewers and every other built-in plugin; none of that is in scope and an empty-looking file is the correct outcome for a change about one option.
- Undoing the durability the sharing brings with it. Turning `sync_yanked` on writes the yank to `~/.local/state/yazi/.dds`, and yazi offers no option to share the list without storing it. This change records the consequence rather than fighting it.
- Tracking `flavors/` or `package.toml`. Their exclusion is unrelated to this file and its reasoning is unchanged.

## Decisions

**Turn the setting on in `init.lua` rather than bridging the clipboard.**

The alternative is a wrapper that yanks into the system clipboard with `wl-copy` and pastes out of it, either through yazi's keymap or through a shell around it. It loses on every count: the system clipboard is a string, so a multi-file yank has to be encoded and decoded; the copy-versus-cut distinction has no representation there without inventing one; and the clipboard outlives every yazi window, which turns a stale yank into a paste of a path that has since moved. The program already publishes the list over a socket. The configuration only has to ask.

**Write `init.lua` as the plain `setup` call, with the reasoning in comments.**

Yazi reads `init.lua` at startup and nothing guards against calling `setup` on a plugin that is absent; on a yazi old enough to lack `session`, the file raises rather than failing quietly. Wrapping it in a `pcall` was considered and rejected: it would turn a loud, immediate, correct error into a yazi that starts and does not sync, which is the failure mode hardest to diagnose and the one a user would misread as the setting not working. This session pins no yazi version, so the honest position is that the file states its requirement and breaks visibly where it is not met.

**Track the file through a `.gitignore` negation in block 3, beside the theme.**

The repository ignores by default and names what it keeps. `.config/yazi/theme.toml` is already kept there with a comment saying the theme is the only yazi file tracked and why the two beside it are not. That comment becomes false the moment `init.lua` is tracked, so it is rewritten rather than appended to: the shape is one negation per kept file, each with its own reason, and `flavors/`/`package.toml` keep theirs.

**Record the shared-cut consequence in the file, not only in the spec.**

The spec requires the configuration to state the reach of the shared list. A comment in `init.lua` is where that lands, because the person who will need it is the person who has just watched a file move and is reading the setting that caused it. `Esc` clears a pending yank; the comment says so, and it names `~/.local/state/yazi/.dds` as where a pending one can be read without opening yazi.

**Accept the durability rather than work around it, and state it.**

Verification turned up something the plan had backwards: the shared list is not live. yazi writes the shared `@yank` message to `~/.local/state/yazi/.dds` and reloads it at startup, so a pending yank survives every window closing and survives a reboot. This was measured against the alternative — the same yank with `sync_yanked` off leaves that file empty — so the durability is introduced by this change and not by yazi's defaults.

The workaround considered was truncating the state file on session start, from a systemd user unit or a shell hook. It was rejected: it races a running yazi that may rewrite the file, it puts the file manager's internal state format into a second place that has to track yazi's version, and it would make a deliberate cross-reboot yank silently fail. The requirement therefore changed to match the program: the list outlives the windows, and the configuration owes the reader that fact.

## Risks / Trade-offs

- **A cut left pending in a forgotten window completes on the next paste anywhere.** → Inherent to one shared list, and the feature being asked for. Mitigated by the comment in `init.lua` stating it and naming `Esc` as the clear, and by the spec requiring that statement to be there.
- **That pending cut is durable, so the paste that completes it can come after a reboot.** → The sharpest edge here and the least expected. No option turns the storage off, so the mitigation is disclosure: `init.lua` states it, and names `~/.local/state/yazi/.dds` so a pending `"cut":true` can be checked without opening yazi.
- **Windows already open do not pick the setting up.** → The file is read once per process. Called out in the tasks as a restart step and in `init.lua`'s comments, so the first test is not run against processes that never read the file.
- **A yazi without the `session` plugin fails at startup.** → Accepted deliberately over a silent fallback, per the decision above. 26.9.1 is what this session runs and it has the plugin.
- **DDS carries more than the yank list.** → Turning on `sync_yanked` scopes the sharing to the yank list alone; no other state is published by this change, and nothing else in the configuration subscribes.

## Migration Plan

Add the file, add the negation, restart every running yazi. Rollback is deleting `.config/yazi/init.lua` and its `.gitignore` line, and truncating `~/.local/state/yazi/.dds` — a yank stored while the sharing was on is still there after the setting goes away, and a yazi that no longer syncs will still act on it. Truncating that file is safe: it holds nothing else with the sharing off, which is the state before this change.
