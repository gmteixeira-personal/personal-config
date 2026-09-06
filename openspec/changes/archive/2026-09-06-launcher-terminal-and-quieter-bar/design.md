## Context

See proposal.md — Why. Two facts shape the approach and neither is obvious from the files being edited.

The first is where fuzzel's terminal comes from. fuzzel has one `terminal` setting, documented in `fuzzel.ini(5)` with the default `$TERMINAL -e`, and it is used for exactly one thing: launching a desktop entry whose `Desktop Entry` group carries `Terminal=true`. The setting accepts an optional `{cmd}` placeholder; with no placeholder, fuzzel appends the entry's `Exec` line to the command. There is no fallback chain. If the resulting command cannot be executed, the launcher exits normally and reports nothing.

The second is where the bar's configuration comes from. `.config/waybar/config.jsonc` is not a fork of `/etc/xdg/waybar/config.jsonc`; it `include`s it and restates individual keys, and waybar resolves a duplicate key in favour of the including file. Both `modules-left` and `modules-right` are already restated — that happened in `0349715`, so removing a module from the bar means editing the tracked list, not overriding the packaged one. A module also has a footprint in three places: the list, its options object, and its stylesheet selector.

## Goals / Non-Goals

**Goals:**

- Every desktop entry marked `Terminal=true` launches, in the terminal the session already runs.
- The bar stops carrying `cpu` and `memory`, with nothing left behind in either tracked file.
- `bar-appearance` stops contradicting the file it governs.

**Non-Goals:**

- Making the bar report load some other way. The premise of the removal is that the bar is the wrong place for it; a tooltip or a click-through would be the same claim on attention re-parked.
- Auditing the rest of the module list against the new "earns its place" requirement. `power-profiles-daemon` is a live candidate — the service is not installed, so the module renders nothing — but it fails a different test and is left alone here.
- Setting `TERMINAL` in the environment. See Decisions.
- Changing `nvim.desktop` or any other packaged desktop entry.

## Decisions

**Configure fuzzel rather than set `TERMINAL`.**

Exporting `TERMINAL=footclient` from `.config/fish/conf.d/env.fish` would fix fuzzel too, and it is the smaller diff. It is rejected because the variable would have to reach fuzzel, and fuzzel is started by the compositor, not by a shell — it inherits the compositor's environment, and niri's environment is not fish's. Making it work would mean declaring the variable in `config.kdl`'s `environment` block, which sets it for every client in the session, to fix one program's default. `TERMINAL` is also a convention rather than a specification: what reads it and what it is allowed to contain are not agreed on, so setting it session-wide invites a second program to interpret it differently. One line in the launcher's own configuration is the narrower fix, and it is the one a reader will find when the launcher misbehaves.

**Use `footclient`, not `foot -e`.**

Both open a terminal. `footclient` attaches to the `foot --server` instance the session already starts, which is what `Mod+T` runs and what the session is built around; `foot` would start a second, independent instance carrying its own copy of the font and configuration. Matching `Mod+T` also means the terminal a launcher entry opens in is the same terminal in every respect — same server, same configuration, same lifetime.

**Write no `{cmd}` placeholder.**

`terminal=footclient` with no placeholder makes fuzzel append the entry's `Exec` to it, producing `footclient nvim`. `footclient` takes the command to run as trailing positional arguments, so this is correct as-is. Writing `terminal=footclient {cmd}` would be equivalent and adds a second thing to get wrong.

**Replace the module-list requirement rather than amend it.**

The existing requirement's name — *without owning its module list* — is the part that is wrong, and its scenario `Geometry is overridden without copying the module list` checks the thing that is no longer true. A `MODIFIED` delta must carry every scenario the current spec has, so amending it would mean keeping a scenario that asserts the opposite of the file. `REMOVED` plus `ADDED` states the reversal plainly and lets the replacement keep only the scenarios that still hold.

**Remove all three parts of each module's footprint.**

The list entry alone would stop the module rendering. Leaving the `cpu` and `memory` objects in `config.jsonc` and the `#cpu, #memory` selectors in `style.css` would leave configuration for something that does not exist — read later as a module that has gone missing rather than one deliberately dropped. The stylesheet comment naming `green cpu, purple memory` as examples of the stock fills is corrected for the same reason.

## Risks / Trade-offs

**The new "earns its place" requirement is a judgement, not a measurement** → It is written with its own counter-examples (battery, volume) and a stated test — whether the reading leads anywhere — so a future reader applying it to a new module has something to argue against rather than a bare preference. It constrains what may be added as well as what was removed, which is the point.

**Removing `cpu` and `memory` removes the only ambient signal that the machine is loaded** → Accepted, and it is the change. The signal was a percentage with no path to the process causing it; a terminal answers the question properly. Nothing about the removal is hard to reverse — three edits, all in tracked files.

**`footclient` fails if the foot server is not running** → The session starts `foot-server.socket`, which is socket-activated, so the first `footclient` starts the server. A machine where the unit is not enabled has a broken `Mod+T` already, which is the louder symptom and is documented under **Rebuilding the desktop session**.

**A future waybar package could change a module option this configuration relies on inheriting** → Unchanged by this design and inherent to including rather than copying. It is the trade the existing requirement already accepted, and the replacement keeps it deliberately.
