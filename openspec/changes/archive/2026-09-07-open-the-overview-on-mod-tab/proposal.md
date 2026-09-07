## Why

The Overview — the zoomed-out view of every workspace and the windows on them — is reachable from one chord, `Mod+O`. That chord names the feature by its initial, which is a fine way to write it down and a poor way to remember it. Every other desktop this session's user comes from puts the same view on the Super key with Tab, so `Mod+Tab` is where the hand goes first, and today it goes nowhere: the compositor's own example binding for that chord sits commented out in the file, so the press is swallowed with no effect.

`Alt+Tab` is not the same question and is not being answered here. The compositor binds nothing to it, so it reaches the focused application and does whatever that application does with it. That is the behaviour to keep.

## What Changes

- `Mod+Tab` opens and closes the Overview, doing exactly what `Mod+O` does.
- `Mod+O` keeps working. This adds a second way in rather than moving the first.
- The chord does not act again while it is held down, matching the chord it duplicates.
- `Alt+Tab` remains unbound by the compositor, so it continues to reach the focused application.
- The compositor's commented-out example binding for `Mod+Tab` is removed rather than left in place. A second binding for a chord that is already bound is not a shadowed binding but a config that fails to load, so leaving the example is leaving a line that breaks the whole file if anyone uncomments it.

## Capabilities

### New Capabilities
- `workspace-overview`: how the zoomed-out view of workspaces is reached from the keyboard — which chords open it, what such a chord has to carry to behave while held, and which chord is deliberately left to applications.

### Modified Capabilities
<!-- None. `keyboard-mapping` governs what the physical keys carry before an application sees them, which is a layer below a compositor action bound to a chord. -->

## Impact

- `.config/niri/config.kdl`, `binds` block — one added binding, one removed comment.
- No new dependency, no new privilege, nothing spawned. The action is one the compositor already implements and already exposes on another chord.
- Takes effect on config reload; no restart of the compositor or of any client is required.
