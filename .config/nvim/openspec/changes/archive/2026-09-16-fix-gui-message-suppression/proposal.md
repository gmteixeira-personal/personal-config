## Why

The suppression `add-neovide-front-end-support` recorded does not work, and the way it was verified is why. The route added there matched the two messages when tested against the component's filter in isolation, and never fired in practice: the component raises its own health reports by calling the notification backend directly rather than through the editor's notify function, so they never enter its router and no filter it offers can see them. Both errors were still arriving on every launch, in the backend's history, where nobody looked.

A second fault sat behind the first and was read as one gap. The command line is meant to take no screen row here — the floating input replaces it — and under the graphical front end it takes one anyway: the front end reads the option at startup and writes it back twice, after the value has settled. That row plus the grid's own leftover is more than twice the empty band the terminal shows.

## What Changes

- The suppression is re-done through the component's own message de-duplication, which is the only lever that reaches a report raised outside its router. The health check still runs on its timer and every other finding it makes still surfaces.
- The requirement gains a scenario putting the check where the user would see it — the notification backend's history — so a filter that matches in isolation cannot be mistaken for a suppression that works.
- The recorded evidence is corrected: the pair arrives once per session because the component de-duplicates by message text, not because the condition passes.
- A requirement that the command line keeps taking no screen row under a front end that rewrites the option.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `message-ui`: the self-diagnosis requirement — corrected evidence, and verification at the surface the user sees rather than at the filter.
- `message-ui`: added — the command line takes no screen row under a front end that rewrites the option.

## Impact

- `lua/plugins/noice.lua` — the route is replaced by seeding the de-duplication table, and the command-line row is reclaimed with an `OptionSet` autocmd dropped after startup.
- Nothing else. The terminal's behaviour is unchanged in both cases; both are guarded on the front end.
