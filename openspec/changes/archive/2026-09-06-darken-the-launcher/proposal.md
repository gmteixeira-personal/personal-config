## Why

Every surface this session presents has been darkened on purpose except the one that opens most often. `config.kdl` paints the desktop `#181825`, `.config/swaylock/config` fills the lock screen `#11111b` over a `#1e1e2e` indicator, and `.config/waybar/style.css` states outright that its state colours are Catppuccin Mocha, "the palette `.config/swaylock/config` already uses". The launcher was never brought along: `.config/fuzzel/fuzzel.ini` sets `terminal=footclient` and nothing else, so fuzzel runs its packaged defaults, and those defaults are Solarized Light — `background=fdf6e3ff`, near-white.

The result is that `Mod+D` is a flash of white on a session that is otherwise dark, and it is the keystroke pressed most often. The lock screen's own rationale already treats a light-grey default as a defect worth a tracked file to fix; the launcher has the same defect and has not been given the same treatment.

There is a second cost that outlives the appearance. Three files now carry Mocha values with no fourth file to check them against, and each states the palette in a comment rather than sharing a definition — there is no mechanism that could share one, since niri reads KDL, swaylock reads its own key/value format and waybar reads CSS. The palette holds together only because each file names where it got its values. A launcher themed with plausible dark colours and no such note would be the first surface whose values a reader could not trace.

## What Changes

- `.config/fuzzel/fuzzel.ini` gains a `[colors]` section holding the full set of colour keys fuzzel exposes, set to Catppuccin Mocha values assigned the way the rest of the session already assigns them: base `#1e1e2e` for the surface, text `#cdd6f4` for entries and input, overlay0 `#6c7086` for the prompt, the placeholder and the match counter, surface0 `#313244` for the selected row and the border, and blue `#89b4fa` for the matched substring.
- Every key fuzzel's `[colors]` section defines is set, rather than only the ones that look wrong today. A partially themed launcher would leave the unset keys on Solarized values that happen not to be visible in the common case — the placeholder, the counter, the border — and reintroduce the white a suffix at a time as those states are reached.
- The file gains a comment recording that the palette is Catppuccin Mocha and that `.config/swaylock/config` is where this repository's copy of it lives, matching what `.config/waybar/style.css` already says, so the values are traceable rather than arbitrary.
- The `application-launcher` spec gains a requirement that the launcher is themed from the session's palette rather than left on its upstream default, and that the tracked configuration records where the palette comes from.
- `README.md` stops describing `.config/fuzzel/fuzzel.ini` as "one line, `terminal=footclient`", which this change makes untrue, and the rebuild procedure stops describing the tracked fuzzel configuration as "the one launcher setting".

## Capabilities

### New Capabilities

<!-- None. The launcher already has a spec; this change adds a requirement to it. -->

### Modified Capabilities

- `application-launcher`: The spec covers what the launcher does with a desktop entry that asks for a terminal, and says nothing about what the launcher looks like. Its appearance is currently whatever the package ships, which is a light theme in a dark session. The capability gains a requirement that the launcher's colours are the session's own and that their source is recorded.

## Impact

- `.config/fuzzel/fuzzel.ini` — one added `[colors]` section and its comment. The existing `terminal=footclient` line and the comment above it are untouched.
- `openspec/specs/application-launcher/spec.md` — one added requirement. The existing terminal requirements and their scenarios are unchanged.
- `README.md` — the sentence in the session-software entry that counts the file's lines, and the clause in the rebuild procedure that calls it one setting.
- `.gitignore` — no change. `.config/fuzzel/fuzzel.ini` is already allowlisted at line 82 and already tracked.
- Packages: none installed or removed.
- Behaviour a reader should expect to change: nothing but colour. fuzzel re-reads its configuration on each launch, so the next `Mod+D` after the edit shows the new palette with no restart of the session, the compositor or the launcher. What the launcher matches, how it sorts, what it lists and what it opens are all unaffected.
