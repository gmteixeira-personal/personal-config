## Context

See proposal.md — Why. What shapes the approach is what is already on the machine and what is already tracked.

swaylock and swayidle are both installed. swaylock is bound at `.config/niri/config.kdl:367` as `Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }` and is reached no other way. swayidle was installed in the same transaction as swaylock, ships **no** systemd unit — its package contains `/usr/bin/swayidle` and three shell completions, nothing else — and nothing on this machine starts it or refers to it.

niri supports `ext-idle-notify-v1`, which is the protocol swayidle uses to be told about idleness. That is the whole of the compositor-side requirement; no niri configuration beyond a startup entry is involved.

The repository's ignore policy is deny-by-default, so any new configuration file is untracked until block 3 of `.gitignore` names it. That makes "which file holds the setting" a tracked-surface question rather than only a tidiness one.

## Goals / Non-Goals

**Goals:**

- One place that decides what the lock screen looks like, reached identically by every trigger.
- An idle timeout visible in the same file a reader already opens to find out what starts with the session.
- No new packages, and no new units to enable — the rebuild procedure gains an install target and nothing else.

**Non-Goals:**

- Blanking or powering off the display, on idle or otherwise. It is a separate timeout with a separate failure mode, and swayidle can be given it later without disturbing anything decided here.
- Idle inhibition rules of our own. niri and its clients already negotiate `zwp_idle_inhibit_manager_v1`; adding a second opinion about when idleness counts would mean two mechanisms disagreeing.
- Anything about greeters or the display manager. The session is already running by the time any of this applies.
- Replacing swaylock. Its lack of blur and screenshot backgrounds is a known limit (those live in swaylock-effects, which is not installed and not proposed here); flat dark is the intended look, not a workaround.

## Decisions

**The lock screen's appearance lives in swaylock's own configuration file, not in the arguments each caller passes.**

swaylock reads `$XDG_CONFIG_HOME/swaylock/config` with no argument at all, and every long option is valid there with the leading dashes removed. So `spawn "swaylock"` at the binding and `swaylock -f` from the idle daemon both pick up the same file without either one naming it. The alternative — putting the colours on the command line — would mean the compositor binding and the idle daemon each carrying a copy of about thirty options, and the screen you got would depend on which one fired. This is what makes the `screen-locking` requirement "one configuration serves every trigger" checkable by reading one file rather than three call sites.

Tracking it costs one `.gitignore` entry, `!/.config/swaylock/config`, in the wayland-session block beside `config.kdl` and `foot.ini`. That block already exists for exactly this: configuration read once by a program the session starts.

**The idle timeout lives in the compositor's startup entry, not in a swayidle config file.**

swayidle also reads `$XDG_CONFIG_HOME/swayidle/config`. Using it would need a second allowlist entry and a second file for two lines of content, and it would split "what starts with the session" from "what that thing does" across two places. The startup entry is short enough to state both:

```kdl
spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock -f" "before-sleep" "swaylock -f"
```

`spawn-at-startup` passes its strings as argv with no shell, and swayidle runs each event's command through `sh -c` itself, so `"swaylock -f"` arrives as one command. A reader opening `config.kdl` to find out what the session starts also learns, on the same line, that it locks after 300 seconds. That is where the spec's "the idle timeout it declares SHALL be 300 seconds" is satisfied.

Rejected: `spawn-sh-at-startup`, which would allow the friendlier `swayidle -w timeout 300 'swaylock -f' ...` at the cost of an `sh` living for the session's whole life as the daemon's parent, for quoting convenience alone.

**`swaylock -f` from the daemon, plain `swaylock` from the binding.**

`-f` daemonizes, so the command swayidle spawned returns immediately. This matters because of `-w`: swayidle waits for each event's command to finish before carrying on, which is what makes `before-sleep` a real barrier rather than a race against suspend. Without `-f`, the timeout lock would never return and `-w` would wedge the daemon on the first idle lock. The compositor binding needs no `-f` — niri spawns it detached already, and adding it there would change nothing except make the two call sites look gratuitously different.

**`before-sleep` is in scope even though the request was an idle timeout.**

An idle lock that suspend can outrun is not a lock. Close the lid inside the five minutes and, without this, the machine sleeps unlocked and resumes unlocked — the exact outcome the timeout exists to prevent, reached by a route the timeout cannot see. It is the same daemon, the same lock command and one more argument pair, so the cost of covering it is a phrase. Its limit is worth knowing: `before-sleep` delays sleep only up to `InhibitDelayMaxSec` in `logind.conf(5)`, so a lock command slow enough to exceed that would finish after the resume rather than before the sleep. `swaylock -f` returns as soon as it has daemonized, well inside any default.

**Five minutes, stated as `300`.**

The requested figure. It is short enough to matter for a walk-away and long enough not to fire while reading. swayidle takes seconds, so it appears as `300` in `config.kdl`; the spec says "five minutes" and pins the number, so the two cannot drift apart silently.

**The dark palette is Catppuccin Mocha, chosen and written down rather than inherited.**

`retired-tooling` records what happened last time a palette arrived: noctalia's theming engine wrote colour files into seven directories it did not own, and every one of them had to be deleted. So the colours here are literal values in one file that only swaylock reads, matched to the neutral role each state has to carry — near-black ground, a resting ring barely above it, blue for accepted input and verification, red for rejection and deletion, yellow for cleared, orange for Caps Lock. No theme engine, no imports, nothing generated, and nothing written outside `.config/swaylock/`.

## Risks / Trade-offs

- **The screen locks during something that should have held it open — a video, a long read, a presentation.** → niri and its clients already speak `zwp_idle_inhibit_manager_v1`, so a full-screen video in a browser that requests inhibition suppresses the timeout without any configuration here. What is genuinely uncovered is a program that never requests it. Mitigation is per-case and deliberate: `systemd-inhibit` around the command, or raising the number. Adding our own inhibition rules is a non-goal above.
- **A password typed into a screen that has just appeared unannounced goes to the wrong place.** → It does not: the lock takes the keyboard before it draws. The real edge is a keystroke already in flight, which lands in the password field and is cleared by the empty-submission rule rather than counted as a failure — which is part of why that rule is in the spec.
- **swayidle dies and the session silently stops locking itself.** → Real, and not mitigated here. Nothing supervises a `spawn-at-startup` process; niri starts it once and does not restart it. The failure is invisible until you notice the screen never locks. A systemd user unit with `Restart=` would fix it, at the cost of the unit file this design avoids. Left as a known limit rather than papered over; if it ever happens once, that is the moment to reach for the unit.
- **Editing `config.kdl` and reloading does not start the daemon.** → niri re-reads the file live, but `spawn-at-startup` entries run only at session start. After this change lands, swayidle is running only from the next `niri-session` onward, or after being started by hand once. This is why the verification task is a session restart rather than a config reload.
- **The lock screen is unreadable on a display the palette was not chosen for.** → The colours are fixed values, not adaptive. On a very bright display the resting ring at `313244` against `11111b` is deliberately low-contrast; the states that matter — verifying, rejected, Caps Lock — are the saturated ones, so the information survives even where the resting state does not stand out.

## Migration Plan

There is nothing to migrate; there is something to be able to undo. The whole change is one new file, one `.gitignore` line, one `config.kdl` line, README prose and a spec rationale. Reverting is deleting the `spawn-at-startup` entry — which returns the session to locking only on `Super+Alt+L` — and, if the appearance is unwanted too, deleting `.config/swaylock/config` and its allowlist entry, which returns swaylock to its built-in light grey. No state is written anywhere by either program, so nothing outlives the revert.

The one ordering constraint: swayidle must be installed before `config.kdl` names it, which is the same rule the rebuild procedure already states for every other program the compositor spawns. On a machine without it, the startup entry fails silently and the session locks only on demand — a degradation, not a broken session, and the README entry says so.
