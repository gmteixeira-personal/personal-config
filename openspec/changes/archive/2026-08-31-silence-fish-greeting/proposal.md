## Why

Every interactive fish prints a banner before its first prompt:

```
Welcome to fish, the friendly interactive shell
Type help for instructions on how to use fish
```

Nothing in this configuration asks for it. It is fish's default when `fish_greeting` is unset — `fish_greeting` falls back to composing those two lines itself:

```fish
if not set -q fish_greeting
    set -l line1 (_ 'Welcome to fish, the friendly interactive shell')
    set -l line2 \n(printf (_ 'Type %shelp%s for instructions on how to use fish') (set_color green) (set_color --reset))
    set -g fish_greeting "$line1$line2"
end
```

It is not shown once per machine or once per login. `~/.bashrc` ends with `exec fish` for every interactive bash, so the banner is printed on every terminal window, every new tab, every split, and every `exec fish` after a config edit — two lines of onboarding text for a shell that has been in daily use for months, pushing the first prompt down the screen each time.

## What Changes

- Suppress the greeting, so an interactive fish prints its prompt and nothing else. The banner is the whole target: `help` still works, and no other startup output is silenced.
- Set the value from a tracked startup snippet rather than as a universal variable. `fish_variables` is where `set -U` records its result, and that file is deliberately untracked — a universal variable set here would silence the greeting on this machine only and leave a clone printing it.
- Give the setting its own `conf.d/` file. It is a greeting, which is none of the four named categories the startup-file layout defines, and that layout says a setting fitting none of them gets a file of its own rather than being appended to the nearest existing one. `conf.d/tide.fish` and `conf.d/direnv.fish` are the precedents.

## Capabilities

### New Capabilities
- `fish-greeting`: what an interactive fish prints before its first prompt — that it prints no banner, that the suppression comes from the repository rather than from machine-local state, and that a non-interactive shell is unaffected either way.

### Modified Capabilities

<!-- none. `fish-startup-files` already governs where a setting of a new kind
     goes; this change follows that rule rather than changing it. -->

## Impact

- `.config/fish/conf.d/greeting.fish` — new, and the whole of the change. One guard and one `set`.
- No `.gitignore` change. Block 3 already allowlists `!/.config/fish/conf.d/**`, so the new snippet is offered for staging as soon as it exists — which is what the startup-file layout requires of a new snippet.
- No change to `.bashrc`. bash prints no banner of its own; it reaches this one only by handing the session to fish, and the fix belongs on the fish side of that handover.
- No new dependency. `fish_greeting` is a fish variable read by a fish built-in function.
- No vendored file is touched. tide owns `functions/fish_prompt.fish` and the `_tide_*` files and rewrites them on update; none of them is involved in the greeting.
