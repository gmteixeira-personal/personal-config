## Context

See proposal.md — Why. The constraint that shapes everything here is that niri's configuration language has no conditionals: an `output` block carries one scale and one position, applied whenever that output is present. The laptop needs two answers depending on what else is attached, so the answer cannot live in that file.

Niri implements `zwlr_output_manager_v1`, the wlr output-management protocol, which lets an external client read the connected heads and push a configuration back. That is the seam this change uses. The session already spawns several long-lived helpers — the bar, the notification daemon, the idle manager — from niri's `spawn-at-startup`, so there is an established shape for adding another.

## Goals / Non-Goals

**Goals:**

- One file that holds every output's scale and position, keyed on the connected set.
- Applied on hotplug with no user action and no session restart.
- Geometry legible without running anything: the numbers and the reasoning behind them readable in the file.

**Non-Goals:**

- Per-workspace or per-window behaviour. Which workspace lands on which screen is out of scope and unchanged.
- Arrangements for sets beyond the two the user actually works in. See the spec's requirement on undeclared sets.
- A general display-settings interface. This is a declarative file, not a GUI, and nothing here is meant to be adjusted at runtime.

## Decisions

**kanshi, rather than a hand-written client of the output-management protocol.** Kanshi is the established Wayland tool for exactly this problem — profiles keyed on the connected set, applied on hotplug — it is packaged in Fedora, and it does nothing else, so its whole surface is the config file. The alternative considered was a script watching `niri msg --json event-stream` for `OutputConfigChanged` and calling `niri msg output <name> scale <n>`. That keeps the session free of a new dependency and stays inside niri's own IPC, but `niri msg output` documents its changes as temporary — "if the output configuration subsequently changes in the config file, these temporary changes will be forgotten" — so the geometry would be reapplied by a daemon rather than declared, and the daemon would be ours to write, supervise and debug. A third option, two config files swapped by hand, was rejected: it needs the user to know they have docked, which is the thing being automated.

**Geometry leaves `config.kdl` entirely rather than niri holding a docked default that kanshi overrides.** Both files are applied on every session start, niri's first, kanshi's second, and the second silently wins. A split would leave `config.kdl` stating positions that are read, believed and then overridden — a file that is wrong in a way that produces no error. The cost is that with kanshi absent the screens fall back to niri's automatic row rather than to a sensible default, which is a visible failure rather than a silent one. That is the trade the spec's single-declaration requirement makes deliberately. In place of the removed blocks `config.kdl` keeps a comment naming the file that took over, so the next reader is not left inferring it.

**Spawned from `spawn-at-startup`, not from kanshi's systemd user unit.** The bar, the notification daemon and the idle manager are all started this way, and starting a session helper through systemd instead has already caused trouble here: a unit-started bar runs alongside the niri-spawned one rather than replacing it. Keeping every helper on the same mechanism means one place to look and one lifecycle — when niri exits, its children lose the Wayland socket and exit with it.

**The externals are matched by make, model and serial; the laptop by connector name.** Reasoning is in the spec. In kanshi's syntax the match string is `"<make> <model> <serial>"`, which is exactly what `niri msg outputs` prints as the output's description, so the values can be copied across without transcription.

**Docked laptop scale is 1.5.** The user asked for roughly a fifth larger than the 1.25 the panel uses alone; 1.25 × 1.2 is exactly 1.5, and 1.5 divides the panel's 1920 physical pixels into 1280 logical ones without remainder. The nearby alternatives are worse: 1.75 gives 1097.14, which niri rounds, and the centring offset is then computed from a rounded width. The offset itself is `(3840 − 1280) / 2 = 1280`, which is derived from the scale and has to move with it — recorded in a comment beside the numbers rather than left for a future reader to rediscover.

## Risks / Trade-offs

- **Kanshi not running leaves the screens in niri's automatic row** → It is spawned at startup beside the other session helpers, and the failure is immediately visible rather than subtle: the laptop is beside the externals instead of below them, at the wrong scale.
- **A kanshi config syntax error leaves the previous profile or none applied** → Kanshi reports parse errors on stdout at startup; the first run is checked against its log rather than assumed.
- **Docked scale and docked position can drift apart** → They are adjacent in the file with a comment stating the arithmetic that ties them, and the spec carries the constraint as a requirement rather than only a convention.
- **A new monitor of the same model would not be distinguished by the profile** → Serial matching means an added third external simply matches no profile, and the undeclared-set requirement makes that outcome the intended one rather than a malfunction.
- **The undocked profile is exercised only when the externals are physically unplugged** → It is the simpler of the two, and its failure mode is a laptop at the wrong scale, correctable by editing one line.
