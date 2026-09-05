## Why

noctalia was adopted as the session's single desktop shell in `2026-09-05-noctalia-desktop-shell`, replacing waybar's bar and the fuzzel and swaylock bindings. It works, and it is being withdrawn anyway: it brings far more of a desktop than this session wants. It ships a plugin system with two git-backed source repositories, a community template catalogue, a community palette catalogue, an encrypted clipboard store and a theming engine that writes into other programs' configuration directories — and, once running, it did exactly that. Beyond its own `.config/noctalia/` and `.local/state/noctalia/` it had authored `.config/gtk-3.0/`, `.config/gtk-4.0/`, `.config/kdeglobals`, `.config/kitty/`, `.config/btop/themes/`, `.config/foot/themes/` and `.config/niri/noctalia.kdl`, none of which this repository asked for or tracks.

That is the problem, not a defect: a shell that writes theme files into seven directories it does not own is generating untracked machine state faster than the ignore policy can classify it, and the tracked `settings.toml` declaration existed only to work around one of its own state directories being untrackable. The three components it replaced — waybar, fuzzel, swaylock — are still installed, still have no configuration of their own, and were kept installed for exactly this, as `desktop-shell` recorded at the time.

foot stays. It arrived in a different change (`2026-09-05-foot-terminal-on-niri`), is configured independently, and has nothing to do with the shell.

## What Changes

- Restore the three `config.kdl` lines the shell displaced: `spawn-at-startup "waybar"`, `Mod+D` spawning fuzzel, and `Super+Alt+L` spawning swaylock.
- Drop the `Mod+Alt+V` clipboard binding and the `include "noctalia.kdl"` line, both of which exist only for the shell.
- Drop the noctalia theme include from `foot.ini`, returning foot to its built-in colours. Everything else in `foot.ini` — the server-mode notes, `shell=/usr/bin/fish`, the font, the `[csd]` block — is untouched.
- Untrack `.config/noctalia/settings.toml` and remove its allowlist entry, along with the `.local/state/noctalia/` row in the not-tracked table that only existed to explain it.
- Remove the files the shell wrote outside its own directories, and its state directory.
- Remove the `desktop-shell` capability, and record noctalia under `retired-tooling` alongside lazygit and zoxide.
- Accept the loss of clipboard history. It was the strongest single argument for the shell, and nothing replaces it here: a Wayland selection dies with the client that set it, so copying in a window and closing it before pasting loses the text again. `cliphist` is installed and unwired, exactly as it was before the shell arrived.

## Capabilities

### New Capabilities

None.

### Removed Capabilities

- `desktop-shell`: the session no longer has a single shell providing its bar, launcher, lock screen and clipboard history. Each of the first three returns to the separate program that provided it before; the fourth is not replaced.

### Modified Capabilities

- `retired-tooling`: adds a requirement that noctalia is retired, stating what must be absent — tracked configuration, allowlist entry, compositor startup entry or binding, the files it wrote into other programs' configuration directories, and its state directory.
- `desktop-session-declaration`: the required-software requirement is restated without its reference to a desktop shell, and the rebuild-procedure requirement is replaced by one that asks which programs the checkout configures instead of asking after the shell's declared settings. The requirements about declaring settings that live in an untrackable state directory are left alone: they are conditional on such a tool existing, and are simply unexercised now.

## Impact

- `.config/niri/config.kdl` — one startup entry and three bindings; validated with `niri validate`.
- `.config/foot/foot.ini` — one include line.
- `.gitignore` — the noctalia allowlist block.
- `README.md` — the required-software entry, the superseded-components note under **Optional**, the rebuild procedure's opening and step 1, the shell-settings section, and one row of the not-tracked table.
- `openspec/specs/desktop-shell/` — removed. `openspec/specs/retired-tooling/spec.md` and `openspec/specs/desktop-session-declaration/spec.md` — modified.
- Off the repository: `.config/gtk-3.0/`, `.config/gtk-4.0/`, `.config/kdeglobals`, `.config/kitty/`, `.config/btop/`, `.config/foot/themes/`, `.config/niri/noctalia.kdl`, `.config/noctalia/` and `.local/state/noctalia/` are deleted. GTK and Qt applications return to their system default themes.
- Not affected: foot and its server units, the compositor's own settings, `prefer-no-csd` and the window appearance from `2026-09-05-seamless-window-appearance`, and the fish `niri` function.
