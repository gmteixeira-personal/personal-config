## Why

Every terminal window this session opens prints a line before the shell prompt:

```
deprecated: foot: [colors]: use [colors-dark] instead
```

foot 1.27 gained a light/dark colour theme pair. The single `[colors]` section became two — `[colors-dark]` and `[colors-light]` — with `initial-color-theme` in `[main]` selecting which one applies and defaulting to `dark`. The unsuffixed `[colors]` still parses, and its values still take effect, but foot warns on it at startup and the warning is on its way to becoming an error in a later release.

`.config/foot/foot.ini` carries a `[colors]` section holding one key, `foreground=aaaaaa`, and a comment explaining that foot's own default of `839496` reads brighter than the Linux virtual console. The value is correct and the reasoning is unchanged; only the section heading it lives under is now the old spelling.

The visible cost is that the first line of every terminal is a deprecation notice rather than the prompt, on a session whose whole point is that `Mod+T` is cheap and opens often. The cost that outlives it is that `terminal-colors` already requires this file to explain its values against the terminal version actually installed — a requirement added when the same comment named a default from an earlier release — and the section name is the same kind of drift the requirement was written to catch.

## What Changes

- `.config/foot/foot.ini` renames `[colors]` to `[colors-dark]`. The `foreground=aaaaaa` value and the comment explaining it are unchanged.
- The section gains a comment recording why the name carries the `-dark` suffix: foot 1.27 split the section in two, and `initial-color-theme` defaults to `dark`, so this is the section that applies. Without the note a reader meets a suffix that implies a light counterpart somewhere and has nothing to tell them there is none.
- No `[colors-light]` section is added. This configuration does not switch themes — nothing binds `color-theme-toggle` and nothing sends the terminal `SIGUSR1`/`SIGUSR2` — so a light section would be a second place to keep in step that no code path reaches. This mirrors the reasoning the file already records for leaving the sixteen palette slots unstated.
- The `terminal-colors` spec gains a requirement that the tracked terminal configuration names its colours under the section heading the installed terminal version expects, and that opening a terminal prints no deprecation notice before the prompt.

## Capabilities

### New Capabilities

<!-- None. The terminal's colours already have a spec; this change adds a requirement to it. -->

### Modified Capabilities

- `terminal-colors`: The spec requires that the tracked terminal configuration names the default foreground, and that a comment explaining a value names the default the installed version actually uses. It says nothing about where in the file that value is written. The capability gains a requirement that the section heading is the one the installed version expects, so a renamed section is caught the way a stale comment already is.

## Impact

- `.config/foot/foot.ini` — one changed section heading and three added comment lines. `foreground=aaaaaa` and the comment above it are untouched, as is every other section.
- `openspec/specs/terminal-colors/spec.md` — one added requirement. The existing requirements and their scenarios are unchanged.
- `README.md` — no change. Its one mention of a `[colors]` section is fuzzel's, not foot's, and it does not describe foot's foreground.
- `.gitignore` — no change. `.config/foot/foot.ini` is already allowlisted and already tracked.
- Packages: none installed or removed.
- Behaviour a reader should expect to change: the deprecation line stops being printed. Colours do not change — `initial-color-theme` defaults to `dark`, so `[colors-dark]` is read where `[colors]` was. foot runs as a server that reads its configuration once at startup, so the edit takes effect only after `systemctl --user restart foot-server.service`; windows opened before that keep the old reading and keep printing the warning.
