## Why

Reaching a running agent means finding its pane by eye or cycling panes until the right one is focused — a search whose cost grows with the number of agents open, for something whose position on screen the user can already see in the agent panel. Workspaces do not have this problem: `prefix+w` opens a list and a digit selects from it. Agents have no such list. herdr ships an indexed `focus_agent` binding for exactly this and leaves it unset, so the direct route exists and goes unused.

## What Changes

- Bind `focus_agent` to `prefix+shift+1..9`, so the Nth agent in the agent panel is one chord away.
- The binding is declared in the tracked `.config/herdr/config.toml`, in the `[keys]` table beside the existing prefix.
- `prefix+1..9` keeps switching tabs, and `prefix+w` keeps being how a workspace is picked by number. Neither is touched.
- No new plugin, no script, and no change to the prefix key or any other herdr preference.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities
- `herdr-config`: the tracked configuration gains requirements that an agent is reachable by number and that the existing numbered tab keys are unaffected.

## Impact

- `.config/herdr/config.toml` — one line in the existing `[keys]` table.
- Applied with `herdr server reload-config`; open sessions survive.
- `focus_agent` numbers follow the agent panel's own order, which this configuration sets to `priority` — an attention queue that reorders as agents change state. An agent's number is therefore its current position in that queue, not a stable name for that agent. This is herdr's behaviour rather than something the change introduces, but it is what the key means, so the specs say so.
- Depends on the terminal delivering `shift+digit` as a distinct chord rather than as the shifted punctuation it normally produces. That distinction rides on the terminal honouring the keyboard protocol herdr negotiates, and this machine runs under WSL, so the binding is verified by pressing it rather than by the config parser alone.
