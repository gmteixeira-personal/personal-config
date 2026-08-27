## Context

See proposal.md — Why. herdr 0.8.2 is installed and exposes a plugin system (`herdr plugin install <owner>/<repo>`) plus a socket API that includes `pane layout`, `pane resize`, and `pane list`. Its own resize primitive is relative and per-split; there is no built-in "equalize tab" action. This repository is an allowlist-style dotfiles checkout: `.gitignore` ignores everything and re-admits named paths, and `.config/herdr/config.toml` is the single admitted herdr path today. `/usr/bin/perl` is present.

## Goals / Non-Goals

**Goals:**
- Get even pane sizing without a per-machine setup ritual: one install command plus tracked configuration.
- Keep the tracked surface minimal — declaration only, with the install tree re-derived on a new machine.

**Non-Goals:**
- Writing our own equalize implementation against the socket API.
- Vendoring the plugin's source into this repository.
- Changing pane arrangement, ordering, or focus behaviour; only sizes are in scope.

## Decisions

**Use `shibayu36/herdr-equalize-panes` rather than writing an equalize script.** The behaviour needs to run on herdr's split and close events, which means subscribing to the socket API's event stream and recomputing a layout tree — a few hundred lines to own and to keep working across herdr releases. The plugin is MIT, ~3 stars, last pushed 2026-08-22, requires herdr ≥ 0.7.2 (we run 0.8.2), and shells out only to the system Perl.

*Alternatives considered.* `markhuot/herdr-equalize-splits` (4 stars) equalizes only on a keypress, which leaves the drift this change exists to remove. `jeph/herdr-pane-balancer` (4 stars) is also automatic but additionally re-tiles — it moves panes, which the specs forbid. `edouard-andrei/herdr-layout-tools` bundles an unrelated reshape feature. Star counts across all of these are in the low single digits and are not a meaningful signal; the selection is on behaviour. Note this contradicts the premise that shibayu36's plugin is the most popular — it is not, it is merely the closest fit.

**Bind the manual action even though the plugin is automatic.** The plugin deliberately lets a hand resize stick until the next split or close. Without a key there is no way to say "never mind, even them out" short of splitting a throwaway pane. `prefix+E` is the plugin's own documented suggestion and is unbound in our config.

**Track `.plugins.lock`, not the install tree.** This mirrors `.config/nvim/lazy-lock.json`: the lock is the declaration of intent, the tree beneath it is derived and machine-specific. It is one allowlist line next to the existing `config.toml` entry. This reverses the current `herdr-config` requirement that the whole directory except `config.toml` stay ignored, so that requirement is edited rather than worked around — see `specs/herdr-config/spec.md`.

**Apply with `herdr server reload-config` rather than restarting.** Consistent with how the prefix binding was introduced; open sessions survive.

## Risks / Trade-offs

- **A single-maintainer, 3-star plugin becomes unmaintained or breaks on a herdr upgrade** → The blast radius is pane sizing only; `herdr plugin disable` restores stock behaviour instantly, and `herdr plugin uninstall` plus reverting the two tracked lines removes it entirely. Failure is visible on the first split.
- **Installing from GitHub runs third-party code inside the terminal workspace** → Read the plugin's manifest and its Perl before enabling it, and pin the install to a ref if the review raises anything.
- **Automatic equalize fights deliberate asymmetric layouts** (a wide editor beside a narrow log) → Accepted and specified: the manual size holds until the next split or close in that tab. If it proves annoying, the fallback is switching to a manual-only plugin, which is a config change, not a redesign.
- **`.plugins.lock` may carry machine-local fields** (absolute paths, install timestamps) that churn in `git status` → Inspect the file after install; if it is not portable, drop the tracking half of this change and record the install in the proposal's stead as a documented step, leaving `herdr-config` unmodified.

## Open Questions

- Whether the plugin's equalize applies per row and column of a nested layout or flattens to a single grid. It changes nothing above — both satisfy the specs' scenarios — and is answered by the first two-axis split after install.
