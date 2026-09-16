## Why

A graphical front end now opens this configuration as well as a terminal does — the session gained a launcher entry for Neovide, recorded in the home repository's own OpenSpec project. Two things in this configuration are wrong under it, and neither is visible from a terminal.

The message UI greets every start with two errors of its own: that the GUI has `ext_cmdline` and `ext_messages` enabled and that it therefore cannot work. Both are false. The front end sets neither — `nvim_list_uis()` reports all three extension flags false on every sample from launch onward, and `:checkhealth noice` inside the running GUI answers that the GUI should work ok. The pair arrives once, sharing a timestamp, rather than repeating on the health check's one-second interval, which is a race during UI attach and not a standing conflict. The user is told the message UI is broken when it is not.

The second is a setting the front end reads only from this configuration. It has no other home: its own configuration file accepts the setting and then silently ignores it.

## What Changes

- The message UI stops showing its own "cannot work when the GUI has ext_cmdline / ext_messages enabled" errors, under that front end only. The check keeps running and stays reachable on demand; only the notification is dropped.
- The general options module gains one guarded block holding the four window-padding values the front end exposes nowhere else, so the graphical window frames its text grid the way the session's terminal does.

## Capabilities

### New Capabilities

<!-- None. Both changes are requirement-level additions to capabilities that already exist. -->

### Modified Capabilities

- `message-ui`: a self-diagnosis this capability raises about its host, where the claim is demonstrably false, is not put in front of the user.
- `editor-options`: a setting that only a graphical front end reads, and that the front end offers nowhere else, is set here behind a guard.

## Impact

- `lua/plugins/noice.lua` — one `routes` entry, and the comment above `views` that claimed no route was present.
- `lua/config/options.lua` — one `if vim.g.neovide` block, which is the first GUI-specific branch in a file that opens by declaring it holds general editor options.
- Nothing outside this configuration. The launcher entry, the font and the rasterization that go with the front end are the home repository's `gui-text-editor` capability.
