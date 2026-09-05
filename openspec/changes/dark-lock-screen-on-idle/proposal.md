## Why

The session's lock screen is reachable only by hand. `Super+Alt+L` spawns swaylock and nothing else ever does, so a machine left alone stays unlocked for as long as it is left alone. That is the gap worth closing: an on-demand lock protects against the walk-away you remember, and there is no protection at all against the one you don't.

The appearance is the second half of the same problem. Unconfigured swaylock fills the screen with light grey and draws a small segmented dial, so every lock — and every glance at a locked screen — is a flash of white. A lock screen that is unpleasant to trigger is one that gets triggered less, which makes the appearance a security property here rather than a decorative one.

Both are cheap to fix and neither needs new software. swaylock is already installed and already bound; swayidle was installed alongside it and has sat unused since, with nothing starting it and nothing referring to it.

## What Changes

- swaylock gains a tracked configuration at `.config/swaylock/config`: a near-black background in place of the light-grey default, and an unlock indicator restyled into a single large thin ring with per-state colours for typing, verifying, failure, clearing and Caps Lock.
- swayidle is started with the session from `.config/niri/config.kdl` and locks the screen after five minutes of idle.
- The same daemon locks the screen before the system sleeps, so suspending — by lid, by menu or by timer — cannot leave an unlocked session behind a resumed screen.
- The ignore policy gains one allowlist entry so the swaylock configuration is tracked rather than machine-local.
- The required-software documentation gains swayidle and stops saying the lock screen runs on its built-in defaults, which the first bullet makes untrue.

## Capabilities

### New Capabilities

- `screen-locking`: What locks the session and when — on demand, after a fixed idle period, and before sleep — together with what the lock screen must look like when it appears and what must remain legible on it while a password is being typed.

### Modified Capabilities

- `desktop-session-declaration`: The requirement that the session's software is named in tracked documentation asserts, in its rationale, that the bar, the launcher and the lock screen have no tracked configuration at all. A tracked `.config/swaylock/config` makes that false, and swayidle becomes a program the session depends on that the documentation does not yet name.

## Impact

- `.config/swaylock/config` — new, and newly tracked.
- `.config/niri/config.kdl` — one added `spawn-at-startup` entry. The `Super+Alt+L` binding is untouched; it keeps working exactly as it does now, and now shares its appearance with the idle lock because both run the same program against the same file.
- `.gitignore` — one allowlist entry in the wayland-session block.
- `README.md` — the required-software entry for the lock screen, the rebuild procedure's statement of what the checkout configures, and a new entry for swayidle.
- `openspec/specs/desktop-session-declaration/spec.md` — rationale correction, no scenario changes.
- Packages: none installed or removed. swaylock and swayidle are both already present.
- Behaviour a reader should expect to change: the screen now locks on its own. Anything that must survive an unattended five minutes — a long build watched from across the room, a screen share, a video — will meet a lock screen that did not previously appear.
