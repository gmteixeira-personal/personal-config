## Context

See proposal.md — Why. What shapes this design is that the machine is already correct and only the record is missing, so every decision here is about where a fact goes rather than what to build.

The state being recorded, verified on this machine:

- `/etc/greetd/config.toml` runs `tuigreet --time --remember --remember-user-session --asterisks --cmd niri-session` on VT 1 as the `greetd` user.
- `greetd.service` is `enabled` and `active`; the system default target is `graphical.target`.
- `/usr/share/wayland-sessions/niri.desktop`, which is what tuigreet's picker lists, has `Exec=niri-session`.
- `.config/fish/functions/niri.fish` makes a bare `niri` at a prompt `exec niri-session`.
- The running session confirms the result rather than the intent: `graphical-session.target` is active, the user manager carries `WAYLAND_DISPLAY=wayland-1`, and `foot-server.service` and `foot-server.socket` are both active.

Two existing capabilities border this one. `graphical-session-startup` owns the shell wrapper and the property that starting the compositor by name activates the target. `desktop-session-declaration` owns what the session needs once running and what a checkout reproduces.

## Goals / Non-Goals

**Goals:**

- A rebuild procedure that ends with a machine that boots into the session, rather than one that can be talked into a session by hand.
- One place that says all three routes in run `niri-session`, so a future edit to any one of them has something to be checked against.
- An honest entry for the file the repository cannot hold, filed as impossible rather than as declined.

**Non-Goals:**

- Changing anything about how the machine boots. greetd is configured and working; this change would be complete with the machine untouched, and is.
- Tracking `/etc/greetd/config.toml` by any mechanism — a symlink out of `$HOME`, a copy kept in sync, an install script that writes it. Each converts a documentation problem into a synchronisation problem, and the file changes about once per session redesign.
- Replacing or evaluating greetd. It works and it is what is installed.
- Anything about what the greeter looks like. Its flags are recorded because they must be reproduced, not because they are being chosen here.

## Decisions

**A new `session-login` capability rather than a delta on `desktop-session-declaration`.**

The obvious alternative is a delta: `desktop-session-declaration` already requires that every program the session depends on is named, and greetd is arguably one. Two reasons against.

The first is substantive. That capability's requirements are about a session that is running and a checkout that reproduces it. The distinguishing fact here is different in kind — a configuration file that no allowlist entry can reach, because the repository root is `$HOME` and the file is under `/etc`. Its untrackable-state requirements are about tools whose *state* directory is denylisted while their *config* directory is not; that is a choice between two layers the repository can see. Here there is no reachable layer at all. Filing it as a scenario under a requirement about a different problem would blur the one thing worth saying.

The second is mechanical, and would be enough on its own. `dark-lock-screen-on-idle` is open and unarchived, and it already carries a MODIFIED delta on `desktop-session-declaration`'s "The session's software is named in tracked documentation". A second open change modifying the same requirement block means whichever archives second overwrites the first's edit with a copy taken before it existed. Keeping this change's deltas disjoint removes the hazard rather than relying on archive order.

**The login step goes at the end of the rebuild procedure, not the start.**

Chronologically the greeter comes first — it is what boots. But the procedure's existing order is a dependency order, stated as such: each step is what makes the next one mean anything. The greeter is the last thing that becomes true, because configuring it before niri, foot and their units exist gives a greeter that launches a session that cannot start. Putting it last also means the procedure's first three steps remain a complete route to a working session for anyone who does not want a display manager at all, which is a reasonable thing to want on a machine reached only over SSH.

**The greeter's configuration is reproduced in full, not described.**

The file is eleven lines and one of them carries five flags whose combination is the whole behaviour. Prose describing it would be longer than it and still leave the reader assembling a command line from adjectives. It contains no secret and no machine-specific value — no path under a home directory, no token, no hostname — so reproducing it verbatim costs nothing and is checkable by `diff` against the machine. The existing comments in that file explain the flags, and they come along.

**Recorded in the not-tracked table with a reason of a different kind.**

Every other row in that table is a deliberate exclusion: a credential, a per-machine identity, derived state. This row is not a decision at all, and the spec requires the reason to say so. It sits in the same table because the table answers the question a reader actually has — "the repo does not have this; is that a bug?" — and the answer needs to be there whichever kind of "no" it is.

**Both greetd and tuigreet are named, separately.**

They fail differently. No greetd and the machine boots to a text console, where the fish wrapper still gets you a session — a degradation. No tuigreet and greetd starts, finds its configured command missing, and presents nothing, which reads as a broken boot rather than a missing package. A single entry naming "the login manager" would leave the second case undiagnosable from the documentation.

## Risks / Trade-offs

- **The reproduced configuration drifts from `/etc/greetd/config.toml` after a future edit.** → Real and unmitigated by anything structural; a copy in a README cannot be checked automatically against a root-owned file. What limits it is that the file changes only when the session is redesigned, and that a redesign already means editing the rebuild procedure. The copy is verbatim precisely so the check is `diff`, not reading.
- **`--remember-user-session` records a choice that outlives the documented default.** → tuigreet stores it under `/var/lib/greetd/`, and a remembered entry takes precedence over `--cmd`. On this machine the risk is nil: `/usr/share/wayland-sessions/` contains exactly one entry, `niri.desktop`, and its exec line is `niri-session` too, so both paths agree. It becomes live the moment a second session type is installed, which is worth the sentence in the documentation and not worth configuring against now.
- **Documenting the login path invites treating it as this repository's responsibility.** → The spec says the opposite explicitly: the file is outside the repository root, and the obligation created is to describe it, not to own it. The non-goals name the three tempting ways to "fix" that and reject each.
- **A reader follows the new step on a machine where a display manager is already installed.** → Enabling greetd on a machine already running another one is a conflict the documentation should not walk someone into silently. The step names the target and the unit; the case of an incumbent belongs in the step's own wording rather than in a mechanism.

## Migration Plan

Nothing to migrate and nothing to roll back — no tracked configuration file changes, no package changes, no machine state changes. The change is complete when the README says what is already true, and reverting it is reverting a documentation commit.

Verification is by comparison rather than by restart: the reproduced configuration must match the file on this machine, the enablement claims must match what `systemctl` reports, and the three routes must each be shown to name `niri-session`. All of that is checkable in the session that is already running, which is why this change has no unverifiable tail the way `dark-lock-screen-on-idle` does.
