## 1. Restore the tooling this change is verified with

- [x] 1.1 Reinstall herdr with `curl -fsSL https://herdr.dev/install.sh | sh` and verify `herdr --version` reports 0.8.2 or later; the binary was removed when `cargo uninstall herdr` ran, and no step below can be checked without it
- [x] 1.2 Verify with `command -v herdr` that the binary resolves from a directory the tracked `PATH` already carries and not from `~/.cargo/bin`, so a later `cargo install` cannot replace it with the stale crates.io 0.1.0
- [x] 1.3 Run `herdr config check` and verify it reports `config: ok`, confirming the tracked configuration survived the uninstall unchanged

## 2. Make the change

- [x] 2.1 In `.config/herdr/config.toml`, replace the comment above `[ui.toast] delivery` so it states what `system` does, names mako as this session's daemon and `~/.config/mako/config` as where what happens to a notification is settled — pointing at the tracked config file rather than at the spec, since no tracked configuration in this repository cites `openspec/` — and says why the in-app toast was not kept; verify with `grep -n -B6 -A2 'delivery' .config/herdr/config.toml` that the comment describes the value the file holds and mentions neither `terminal` nor WSL as the reason for it
- [x] 2.2 Verify with the same output that `delivery = "system"` is the value present and that no other line in `[ui.toast]` changed
- [x] 2.3 Run `herdr config check` and verify it reports `config: ok` and does not warn that the delivery value is unknown or unsupported
- [x] 2.4 Start or attach a herdr session, run `herdr server reload-config`, and verify it succeeds and that `herdr status server` reports the server running with the session intact

## 3. Verify the behaviour

- [x] 3.1 Raise a notification with `herdr notification` over the socket API and verify mako displays it — checking `makoctl history` if the popup is missed — confirming it left herdr rather than being drawn inside the window
- [x] 3.2 Verify the displayed notification uses the session palette and the geometry from `~/.config/mako/config`, not a herdr-drawn toast: background `#1e1e2e`, top-right under the bar, 380px wide
- [ ] 3.3 With the herdr window on another niri workspace or otherwise not on screen, raise a notification again with `herdr notification show` and verify it is still displayed, which is the case the change exists for — left for direct observation, since confirming it needs someone looking at a workspace other than herdr's
- [x] 3.4 Verify an ordinary notification is removed after mako's 3s timeout and that a critical one stays until dismissed, confirming herdr's notifications are now under `desktop-notifications` rules
- [x] 3.5 Verify the notification sound still plays, confirming `[ui.sound]` was not disturbed
- [x] 3.6 Verify with `git ls-files .config/herdr` that exactly one herdr configuration file is tracked and no second per-machine copy was introduced

## 4. On the WSL machine, when it is next used

- [ ] 4.1 Install a `notify-send` on that machine's `PATH` — `wsl-notify-send`, or a script calling `powershell.exe` — outside this repository, and verify `notify-send 'herdr' 'test'` raises a Windows toast; this cannot be run from this machine and is what keeps `system` from being silent there

## 5. Land it

- [x] 5.1 Verify `git status --porcelain` lists `.config/herdr/config.toml` as the only modified path outside `openspec/`, confirming no machine-local herdr state leaked into the tracked set
- [x] 5.2 Run `openspec validate route-herdr-toasts-to-system --strict` and verify it passes
