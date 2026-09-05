## Context

See proposal.md — Why. Constraints that shape the approach:

- niri's `prefer-no-csd` works by offering `zxdg_decoration_manager_v1`. A client that binds the registry and finds no such global has no way to negotiate and falls back to drawing its own decorations.
- The compositor has been running since before the option was set, and niri creates that global when it starts.
- foot runs as a server holding one Wayland connection for every window it opens. Its registry was enumerated when the server started, so its view of the available globals is fixed for the server's lifetime, not per window.
- foot's `[csd] preferred` defaults to `server`, and its manual states plainly that the value is only a hint the compositor may override.
- The border was already `off`; the focus ring was the only remaining separator once gaps went to zero.

## Goals / Non-Goals

**Goals:**

- Windows that meet, without decoration neither the layout nor the user asked for.
- An honest record of why the decoration change appears to do nothing until a restart.

**Non-Goals:**

- Forcing decorations off for clients that refuse the request. GTK applications draw header bars and do not implement server-side decorations; no compositor setting removes those.
- Turning the focus ring off. With gaps and borders gone it is the only focus indication left.
- Restarting the session as part of this change. That is the user's to time.

## Decisions

**Set both halves of the decoration request, knowing neither binds.**
`prefer-no-csd` in the compositor and `[csd] preferred=none` in foot are each hints, and the manual says so in both directions. Setting only the compositor side leaves foot's default of `server` in play; setting only foot's side leaves it asking a compositor that offers no decoration manager. Setting both makes the intended outcome the one that happens wherever it can.

**Keep the focus ring at the compositor's default rather than narrowing it.**
It was briefly set to 1 pixel while the trade-off was being weighed, then returned to the default width of 4. At zero gaps the ring is no longer one separator among several — it is the only one, with the border off and no gap. A 1-pixel indicator on a seamless field is close to no indicator.

**Record the restart dependency rather than trying to design around it.**
This was diagnosed rather than assumed. foot's own log carries the decisive line — `no decoration manager available - using CSDs unconditionally` — logged for a window opened six minutes *after* the option was set. Cross-checking process start times against file modification times showed why: the compositor predates the option, and so does the foot server. There is no way to make a running compositor offer a global it did not offer at startup, so the only honest response is to document the dependency and let the restart happen when it suits.

**Fix the diagnosis, not the symptom.**
The obvious reading of "the title bar is still there" was that foot's configuration had not been picked up, and the obvious response was to restart foot's server. That would have been wrong on its own: with the compositor still not offering the global, a fresh foot server would enumerate the registry, find no decoration manager, and draw CSDs exactly as before. The unit timestamps are what separated "the restart did not happen" from "the restart would not have helped" — both were true here, and only one of them was visible.

## Risks / Trade-offs

- **The change is unverified on the machine that made it.** → The compositor has not been restarted. The tasks record the verification as outstanding rather than claiming it passed, and it is a single observation once the session restarts.
- **Zero gaps plus a client that insists on a header bar looks worse than either alone.** → Those windows are now flush against their neighbours with a title strip between them. That is a consequence of the client's decision, and the alternative is keeping a gap for every window because some clients decorate themselves.
- **A future foot or niri may change the default hint.** → Both values are stated explicitly in tracked configuration rather than relied on as defaults.
