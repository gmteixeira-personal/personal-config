## Context

See proposal.md — Why. herdr 0.8.2 exposes a plugin system and a socket API in which a tab is a binary tree: every split carries a `direction` (`right` for a vertical divider between columns, `down` for a horizontal one between rows) and a `ratio`, the share given to its first child. `layout.export` returns that tree and `layout.set_split_ratio` moves one divider by path. Nothing else in the API resizes a tab.

Custom keybindings in `config.toml` can be `type = "shell"` (detached, receives `HERDR_BIN_PATH` and the active workspace, tab, and pane ids) or `type = "plugin_action"`. Plugins declare actions and event hooks in a manifest and own a config and a state directory that herdr creates for them.

This repository is an allowlist-style dotfiles checkout: `.gitignore` block 1 ignores everything, block 3 re-admits named paths, and block 4 denies unconditionally. Python 3.14 is installed.

## Goals / Non-Goals

**Goals:**
- Equal-width columns, then equal-height rows inside each column — one rule, applied identically by the automatic behaviour and by the key.
- Switch the automatic behaviour off and on from one key, taking effect immediately.
- Keep the tracked surface small and the behaviour itself in the repository.

**Non-Goals:**
- Changing pane arrangement, ordering, or focus. Only divider positions move.
- Restructuring a tab into a grid, which is what a "tiling" equalizer does.
- Carrying the on/off state between machines, or making it per-tab. It is one global runtime choice.

## Decisions

**Write the plugin rather than install one.** Four published plugins do this job and every one of them weights a divider by the number of panes on each side. Measured on a real tab, a middle column holding three stacked panes came out at `61 | 183 | 61` — triple width — from `shanefully-done/herdr-pane-equalizer`, and `equalize-width` returned byte-identical widths, because the axis flag only selects which dividers are touched, not how their ratio is computed. `ponko2/herdr-equalize-panes` documents the same pane-count formula. `markhuot/herdr-equalize-splits` has the rule we want but declares no event hooks, so it cannot drive the automatic half. `jeph/herdr-pane-balancer` is automatic but rebuilds the tab into a grid, moving panes between rows.

So the rule is ours. It is one line — `ratio = slots(first) / (slots(first) + slots(second))`, where a slot is one column or row along that split's own axis, a pane is one slot, a same-axis split flattens into the group, and a cross-axis subtree counts as one — and the plugin around it is under 200 lines of Python with no dependencies. That is cheaper to own than a fork kept in sync, and it is tracked in this repository rather than declared and fetched.

*Why slots and not panes.* Counting panes answers "give every pane the same area". Counting slots answers "give every column the same width", which is what a person means by three even columns with a stack in the middle. The two agree exactly when every column holds one pane, which is why the pane-count plugins look right until the first nested split.

**One script per concern.** `.config/herdr/herdr-equalize-toggle` owns the mode and nothing else; the plugin owns the geometry and reads the mode on every invocation. The toggle therefore needs no knowledge of layouts and the plugin needs no knowledge of keys. The script sits in herdr's configuration directory rather than in `.local/bin`, which block 4 denies wholesale.

**The toggle resizes nothing, in either direction.** An earlier revision equalized on switching auto on, so that entering auto looked like entering auto. In use that is the wrong trade: it makes the mode key a layout-rearranging key, and pressing it to arm the behaviour throws away the sizes on screen. Arming is silent; the tab evens out at the next pane change.

**Keys: `prefix+plus` toggles, `prefix+e` and `prefix+=` equalize once.** `+` and `=` are the same physical key, which puts the toggle beside the one-shot; `prefix+e` is the mnemonic. herdr rejects `prefix++` — its parser splits on `+` — and `plus` is the documented name for that key.

**Settle before measuring.** Pane events can arrive before herdr has committed the change that caused them, so an equalize fired immediately reads a stale tree. The plugin polls `layout.export` until two consecutive reads agree on the tab's shape (ratios excluded) before planning anything, capped at 1.5 s.

**Resolve the tab from the event, or fall back to the workspace.** A create or move names its tab. A close often does not, since the pane has already left the tree; there the plugin equalizes every tab in the workspace the event names. Equalizing an unchanged tab is a no-op — the plan comes out empty — so the fallback costs one `layout.export` per tab rather than a wrong answer. This is why no direction log or pane-to-tab state file is needed: the rule is total and idempotent, unlike a pane-count rule that has to know which axis a departed pane sat on.

**Track the plugin; track nothing herdr writes for it.** The plugin is ours, so it lives in the repository like any other config. herdr's own registry (`plugins.json`) records absolute paths and an install timestamp, `.plugins.lock` is an empty lock file, and the per-plugin config directory holds the live mode — all per-machine, all ignored. Registration is one `herdr plugin link`, documented in the README beside the same story for Claude Code plugins. `.config/herdr/plugins/` needs an explicit block 4 entry rather than resting on the default deny: block 2's `!*/` re-includes directories, and a GitHub-installed plugin keeps its own `.git`, which git offers as an embedded repository.

**In-app toasts.** `ui.toast.delivery` was `terminal`, which asks the outer terminal for a desktop notification — under WSL, nothing appears, so the toggle was silent. `herdr` draws the toast in its own frame. herdr shows one toast at a time and answers `shown: false, reason: busy` for about two seconds after the previous one, which is exactly what a quick off-then-on double press hits, so the toggle retries until the report lands.

## Risks / Trade-offs

- **The equalizer is ours to maintain** → It is ~200 lines against two documented API calls, and `min_herdr_version` in the manifest makes herdr refuse to link it rather than misbehave if those calls move. Failure is visible on the first split.
- **A fresh machine has the keys but not the plugin** → The bindings are inert until `herdr plugin link` runs, and the toggle exits non-zero when `herdr plugin config-dir` cannot resolve the plugin. Same trade the repository already accepts for Claude Code plugins; the README names the command.
- **A close falls back to equalizing every tab in the workspace** → Only tabs that are already uneven change, so with the automatic state on this is invisible. It would matter if a tab were deliberately uneven while the automatic state was on, which is a contradiction the manual state exists to resolve.
- **Turning auto on leaves a lopsided tab lopsided** → Deliberate, per the decision above. `prefix+e` and `prefix+=` are there when the tab needs evening out now.
- **Toast delivery is global** → Agent notifications now render in herdr's frame rather than being handed to the terminal. That is the point, but it is not scoped to this feature.
