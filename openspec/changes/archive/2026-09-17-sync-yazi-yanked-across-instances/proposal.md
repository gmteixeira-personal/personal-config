## Why

Yazi keeps its yank list per process. Two yazi windows are two processes, so a file yanked in one is invisible to the other and there is nothing to paste. The move a file manager exists for — see a file over here, put it over there — is the one move two windows cannot make together, and the workaround is to give up the second window and navigate the first one twice.

Yazi ships the fix in the binary. Its built-in `session` plugin has a `sync_yanked` option that publishes the yank list over the DDS socket every instance of the same user already shares. It is off by default and this session never turned it on, because this session has no `init.lua` at all — the yazi configuration here is a theme and nothing else.

## What Changes

- `.config/yazi/init.lua` is added, calling `require("session"):setup { sync_yanked = true }`. It is the first Lua this session gives yazi; no plugin is fetched, because `session` is compiled into the binary.
- `.gitignore` block 3 gains `!/.config/yazi/init.lua` beside the existing `!/.config/yazi/theme.toml`, and its comment stops saying the theme is the only yazi file tracked. `flavors/` and `package.toml` stay ignored for the reasons already recorded there.
- The sharing is the whole yank list, cut included. A forgotten `x` in a window left open is therefore a pending move that a paste in another window completes, which is the cost of the feature rather than a defect in it. `Esc` clears the list.
- Turning the sharing on also makes the yank list durable, which was not expected and was measured rather than assumed: yazi writes the shared message to `~/.local/state/yazi/.dds` and reloads it at startup, so a pending yank survives every window closing and survives a reboot. With `sync_yanked` off, that file stays empty after a yank. The durability is therefore introduced by this change, and `init.lua` says so — including that `~/.local/state/yazi/.dds` is where a pending `"cut":true` can be read without opening yazi.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `file-manager`: the capability so far says which program browses files, how it is reached, and how its status bar is coloured. It says nothing about what two of its windows share. It gains a requirement that a file yanked in one window is pastable in another, and a requirement that this comes from the program's own configuration rather than an external clipboard bridge.

## Impact

- `.config/yazi/init.lua` — new, tracked, three lines.
- `.gitignore` — one added negation and the comment above it.
- No change to `.config/yazi/theme.toml`, to `.local/share/applications/yazi.desktop`, or to how yazi is launched.
- Running instances do not pick this up: the file is read at startup, so every open yazi has to be restarted before the two of them share anything.
- On a checkout without the `session` plugin — an older yazi that predates it — `init.lua` raises at startup instead of failing quietly. This session runs 26.9.1, which has it.
