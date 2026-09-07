## Context

See proposal.md — Why.

The `binds` block of `.config/niri/config.kdl` has `Mod+O repeat=false { toggle-overview; }` under the compositor's own comment describing the Overview. `Mod+Tab` appears once more, 140 lines further down, as `// Mod+Tab { focus-workspace-previous; }` — an example the compositor ships commented out. Nothing in the file binds `focus-workspace-previous`, and nothing binds `Alt+Tab`.

Two properties of the compositor decide most of this change. Binding one chord twice is a parse error, not a precedence rule: `niri validate` reports `duplicate keybind later defined here` and refuses the file. And `Mod` is not a fixed key — it is Super on a virtual console and Alt when the compositor runs nested inside another session's window.

`niri validate` accepts `Mod+Tab repeat=false { toggle-overview; }` alongside the existing `Mod+O` on the installed version (niri 26.04).

## Goals / Non-Goals

**Goals:**
- Reach the Overview from the chord the hand already goes to, without giving up the chord that reaches it today.
- Leave the file in a state where the next reader cannot break it by uncommenting a line that looks available.

**Non-Goals:**
- Deciding what `Alt+Tab` does. It is left unbound so that applications keep it, which is the same state it is in now.
- Finding `focus-workspace-previous` a new chord. Nothing binds it today, so nothing is lost by taking the example away; wanting it is a separate request with its own chord to choose.
- Any other Overview behaviour — how it is navigated once open, the hot corner, or the touchpad gesture. None of them is a binding.

## Decisions

**Add `Mod+Tab` rather than move `Mod+O` onto it.**
Moving would keep the file to one binding per action, which is tidier to read. It would also silently break a chord that works today for no gain: the action costs nothing to bind twice, and a user who has learned the initial has learned it. Duplicating is the smaller change in behaviour even though it is the larger one in the file.

**Carry `repeat=false` onto the new binding.**
Without it a held chord toggles the Overview once per key repeat, so the view flickers and its final state depends on how long the key was down. The existing binding already carries the marking; the failure is invisible until someone holds the chord, which is exactly the kind of difference that is never found on purpose.

**Delete the commented `focus-workspace-previous` example rather than leave it or move it.**
Leaving it is the trap this change would create: the chord is bound after this change, so uncommenting the example stops the whole configuration from loading, and the session silently keeps running on the last good copy. Moving the example to a free chord would be choosing a binding nobody asked for and would put an unexplained suggestion in a file where every line states a decision. Deleting it, and recording in the comment above the new binding what the chord used to carry and why a duplicate is fatal, keeps the information without keeping the hazard.

**Put the new binding next to `Mod+O`, not where the deleted comment was.**
The two chords do the same thing and their comment is one comment. Splitting them across the file would put half the explanation 140 lines from the other half, in the workspace-switching section, which is not what either chord does.

**Do not bind `Alt+Tab` to anything, including a window switcher.**
The obvious adjacent feature is a most-recently-used window switcher on `Alt+Tab`, which is what the chord does on the desktops the muscle memory comes from. The request is explicit that the chord stays as it is, and the compositor's own model — a scrolling layout with an Overview — is not one a stacking switcher fits neatly. Rejected as out of scope, not as a bad idea.

## Risks / Trade-offs

- **Nested, `Mod` is Alt, so the new binding takes `Alt+Tab`** → Unavoidable: it follows from the compositor's definition of `Mod` and would be true of any binding on that chord. The nested case is a development configuration and not the session this describes. Recorded in the comment so it reads as a known consequence rather than a bug.
- **Two chords for one action is one more line to keep in step** → If the Overview's binding ever changes shape, both have to change. Keeping them adjacent under one comment is what makes that visible; they cannot drift apart unnoticed while they sit on consecutive lines.
- **The commented example is deleted, so the upstream file and this one diverge a little further** → Already true of most of this file, which states decisions the upstream example does not. The comment records what the line said, so the divergence is legible.
- **`Tab` may mean something inside the Overview later** → It does not today; the Overview is navigated with the focus bindings. If it gains a meaning, the toggle is the chord that opens the view rather than one used inside it, so the collision would be the compositor's to resolve.

## Migration Plan

Add the binding beside `Mod+O`, delete the commented example, run `niri validate`, and reload — niri reloads on write, and neither the compositor nor any client needs restarting. Press the chord to open the Overview, press it again to close it, hold it to confirm it acts once, and press `Alt+Tab` in an application that binds it to confirm the application still receives it.

Rollback is deleting the binding and restoring the comment.
