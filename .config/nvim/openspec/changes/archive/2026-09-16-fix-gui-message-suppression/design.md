## Context

See proposal.md — Why. What constrains the approach:

- The component raises its health reports through `Util.notify`, which calls `require("notify").notify` directly. Nothing in the routing layer sees them.
- The report comes from the one health check `noice.setup` runs before it defers the rest of its load. `health.checker` gates only the once-a-second re-check, so turning it off leaves this one — verified: with the checker off, both messages still arrive.
- `Util.notify_once` keys a private `_once` table by level concatenated with the message text and skips anything already in it.
- The front end writes the command-line height back twice during startup, both after the value has settled at zero. Sampling the option from launch shows `0` on the first tick and `1` from then on.

## Goals / Non-Goals

**Goals:**

- Suppress exactly the reports that are wrong, leaving the check and every other finding in place.
- Verify at the surface the user sees, not at the layer that happens to be easy to call.
- Put the command-line row back without policing the option for the session.

**Non-Goals:**

- Fixing the race inside the front end's UI attach, or its command-line-height restoration. Both are upstream.
- Suppressing anything under a terminal.

## Decisions

**Seed the de-duplication table, rather than filter or disable.** The two levers that look right were tried and recorded in the file because they will be tried again: a routing filter cannot see a report that never enters the router, and the checker switch does not gate the setup-time call. Seeding `_once` before setup is what is left, and it is the narrowest of the three — it names the three exact messages and touches nothing else.

Cost, stated in the file: `_once` is private, so a rename upstream turns the suppression off. The messages come back visibly rather than the suppression failing silently, which is the right direction for a private-API dependency.

**Verification against `require("notify").history()`.** This is the correction that matters more than the mechanism. The previous attempt was checked with the component's own filter predicate against synthetic messages, which answered a question — does this filter match this text — that was never the question. The history is what the user sees.

**`OptionSet` on the command-line height, torn down after three seconds.** A delay long enough to land after the front end's writes would be a guess about its startup; the event is not. Setting the value back re-enters the callback, so the callback ignores a new value of zero. The first attempt removed the autocmd after one correction and did not survive the second write, which is why the teardown is on a timer rather than on the first success. Three seconds is an upper bound on startup, not an estimate of when the writes land.

## Risks / Trade-offs

- **A real conflict under this front end is now hidden.** → `:checkhealth noice` still reports it, in the GUI as in a terminal, and the configuration says so.
- **The three seeded strings must match upstream's text exactly.** → A reword breaks the suppression loudly, and the same evidence in the comment applies to re-seeding it.
- **A command-line height set during the first three seconds is overridden.** → Nothing sets it then but the front end, and the window is bounded.
