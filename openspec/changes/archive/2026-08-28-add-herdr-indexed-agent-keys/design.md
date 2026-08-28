## Context

See proposal.md — Why. herdr 0.8.2 declares built-in actions in the `[keys]` table. Three of them are *indexed*: they take a range spelling rather than a single key, and herdr expands the range across the digits. `switch_tab` is bound to `prefix+1..9` by default; `switch_workspace` and `focus_agent` ship as `""` — parsed, documented, and unbound — with `prefix+shift+1..9` and `prefix+alt+1..9` given as their example spellings in herdr's own commented configuration. An older `[keys.indexed]` table is still parsed for compatibility, and that same commented configuration says to prefer the named actions for new configs.

Workspaces are already reachable by number through `workspace_picker` (`prefix+w`), whose list takes a digit. Agents have no equivalent overlay: herdr's keybind-help table lists `previous agent`, `next agent`, and `focus agent 1-9`, but no agent list. `focus_agent` is therefore the only by-number route to an agent.

`.config/herdr/config.toml` is tracked and currently sets `prefix = "ctrl+f"` in `[keys]`, followed by four `[[keys.command]]` blocks. It also sets `agent_panel_sort = "priority"`.

## Goals / Non-Goals

**Goals:**
- Agents reachable by number from the tracked configuration, with every other numbered key left alone.
- Confidence that the chord survives the terminal, not only the parser.

**Non-Goals:**
- Binding `switch_workspace`. The workspace list already covers selecting a workspace by number, and a second route to the same place is not worth a chord.
- A stable, agent-specific number that does not move — that is the agent panel's ordering, and changing it is a separate decision from binding a key to it.
- Binding `previous_agent` or `next_agent`, which are also unset. They are a different motion, and the numbered keys are what was asked for.
- Extending the family past 9, or reaching a tenth agent by number.
- Migrating anything to or from the legacy `[keys.indexed]` table, which this configuration does not use.

## Decisions

**Use the named `focus_agent` action rather than `[keys.indexed].agents`.** herdr's configuration comments explicitly steer new configs to `switch_tab`, `switch_workspace`, and `focus_agent`, and the legacy table is described as parsed for compatibility. Nothing here needs the old form.

**Bind it to `prefix+shift+1..9`.** herdr documents `prefix+alt+1..9` beside this action and reserves `prefix+shift+1..9` as the example for `switch_workspace`, but that binding is out of scope here — the workspace list already covers selecting a workspace by number — so `shift` is free, and it is the more comfortable of the two chords to reach repeatedly. It was checked against `herdr config check` using a scratch copy of the real config through `HERDR_CONFIG_PATH`: it parses. The checker was confirmed to be doing real work by feeding it a deliberately broken variant, which it rejected with `invalid keybinding: keys.focus_agent = "boguskey+alt+1..9"; disabling binding` — so `config: ok` on the intended spelling is evidence rather than silence.

*Alternatives considered.* `prefix+alt+1..9`, herdr's documented spelling, is the fallback below rather than the first choice: `alt+digit` is the chord herdr's own notes single out as terminal-dependent. `prefix+ctrl+1..9` is the chord herdr calls most reliable and is the second fallback. A two-step `prefix a` then a digit — the shape `prefix+w` has for workspaces — is not expressible: `focus_agent` accepts only single chords, and `"prefix+a 1..9"`, `"prefix+a,1..9"`, and `"prefix+a+1..9"` were each rejected as invalid keybindings. That shape works for workspaces because the picker is an overlay that captures the digit itself, and herdr has no agent overlay to open. Non-prefixed chords would be faster still and were rejected: every other navigation key in this configuration is prefixed, and unprefixed digits would be swallowed by whatever runs in the pane.

**Keep the spelling to one chord, not a list.** `focus_agent` accepts an array — `["prefix+shift+1..9", "prefix+ctrl+1..9"]` checks clean — so both could be bound at once as a hedge against the terminal. Left at one: two chords for one action is a cost paid on every reading of the config against a risk the keypress task settles in a minute. The array form is the ready answer if the chord turns out to need company.

**Verify by pressing, not only by parsing.** `config check` validates the spelling; it cannot know whether the terminal emits the chord. A terminal reports `shift+1` as `!` unless it speaks the keyboard protocol herdr negotiates, and this machine runs under WSL, so whether the shifted digit arrives as a digit is a property of the terminal rather than of the config. The task list therefore presses the binding and names the fallbacks in order: `prefix+alt+1..9`, then `prefix+ctrl+1..9`.

**Say in the spec that agent numbers move.** With `agent_panel_sort = "priority"` the panel is an attention queue, so an agent's index changes as its state changes. This is not a defect to design around — the priority ordering is a deliberate setting here, and the numbered key is a way to reach whatever is at the top of the queue. It is written into the specs because a reader who assumed a fixed number per agent would call the behaviour a bug.

**Apply with `herdr server reload-config`.** Consistent with the prefix binding and the zoom key before it; open sessions survive.

## Risks / Trade-offs

- **`shift+digit` arrives as punctuation rather than as a shifted digit** → Caught by the keypress task, not by the parser. Fallbacks are `prefix+alt+1..9` and then `prefix+ctrl+1..9`, which herdr's notes call among the most reliable chords. Nothing else in the change depends on the spelling.
- **An agent's number moves under the user mid-reach** → Inherent to `priority` ordering, stated in the specs. Switching `agent_panel_sort` to `"spaces"` would give positional stability at the cost of the attention queue; that trade is out of scope here and the setting is one line if it is ever wanted.
- **The panel lists more than nine agents** → The tenth onwards is unreachable by number. `previous_agent` and `next_agent` remain unbound and are the natural answer if it comes up.
