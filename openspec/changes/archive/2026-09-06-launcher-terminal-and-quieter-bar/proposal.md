## Why

Choosing Neovim in the launcher opens nothing. `nvim.desktop` declares `Terminal=true`, so fuzzel is meant to launch it inside a terminal, and the terminal it uses is its `terminal` setting — whose default is `$TERMINAL -e`. This session sets no `TERMINAL`, and fuzzel has no tracked configuration, so what actually runs is `-e nvim`. It fails, and it fails silently: the launcher closes, nothing appears, and nothing reports why. Every entry marked `Terminal=true` is affected, not only Neovim.

Separately, the bar carries two readings nobody acts on. `cpu` and `memory` each report a percentage that moves all day. When load actually matters the question is *which process*, and a percentage on the bar cannot answer it — a terminal and `btop` can. They are the same complaint that retired `temperature` from this bar already: a number present all day, consulted never.

The bar's spec has also drifted from the bar. `bar-appearance` requires that the repository declare how the bar looks *without* owning which modules it shows, and commit `0349715` restated both module lists to name the niri modules — the sway ones the packaged file lists cannot start here. The configuration is right and the requirement is stale. Removing two more modules deepens the gap, so the requirement is corrected here rather than left to contradict the file it governs.

## What Changes

- fuzzel gains a tracked `.config/fuzzel/fuzzel.ini` whose single setting is `terminal=footclient`, so desktop entries marked `Terminal=true` launch in the terminal this session already runs. It is the same `footclient` that `Mod+T` opens, attaching to the foot server the session starts.
- The bar drops `cpu` and `memory`: both are removed from `modules-right`, their `format` overrides are removed from `.config/waybar/config.jsonc`, and their selectors are removed from `.config/waybar/style.css`.
- `bar-appearance` stops requiring the repository to take its module list from the system configuration, and requires instead that it name the modules the session can actually run while continuing to inherit each module's own options. This ratifies what the tracked file has done since `0349715`; it is a correction of the spec, not a change of behaviour.
- The ignore policy gains one allowlist entry so `fuzzel.ini` is tracked rather than machine-local.
- The required-software documentation stops saying the launcher runs on built-in defaults with nothing tracked, and stops saying the module list is still the system file's decision — the second of which `0349715` already made untrue.

## Capabilities

### New Capabilities

- `application-launcher`: What the launcher must do with the desktop entries it presents — specifically that an entry which asks for a terminal is given the session's own terminal rather than a default naming a program that is not installed, and that the repository tracks that decision rather than leaving it to an unset environment variable.

### Modified Capabilities

- `bar-appearance`: The requirement that the repository obtain its module list from the system configuration rather than restate it is removed and replaced. The tracked file has restated both lists since `0349715`, because the packaged list names `sway/*` modules that render nothing under niri, so the requirement has been contradicting the file it governs. Its replacement says what ownership of the list obliges — name only modules the session can run, and still inherit each module's options by including rather than copying the system file. A second requirement is added: a module earns its place by being acted on.
- `desktop-session-declaration`: The requirement that every program the session depends on be named in tracked documentation asserts, in its rationale, that the launcher has no tracked configuration at all and is therefore announced only by that documentation. One tracked fuzzel file makes that false.

## Impact

- `.config/fuzzel/fuzzel.ini` — new, and newly tracked. One setting.
- `.config/waybar/config.jsonc` — two entries removed from `modules-right`, two module objects removed, one comment rewritten.
- `.config/waybar/style.css` — two selectors removed, one comment corrected.
- `.gitignore` — one allowlist entry in the wayland-session block.
- `README.md` — the required-software entry for the launcher and the bar, and the rebuild procedure's statement of what the checkout configures.
- `openspec/specs/bar-appearance/spec.md` — one requirement rewritten, one added.
- `openspec/specs/desktop-session-declaration/spec.md` — rationale correction, no scenario changes.
- Packages: none installed or removed. `footclient` ships with foot, which is already required.
- Behaviour a reader should expect to change: launcher entries marked `Terminal=true` start working, and the bar loses two percentages. The bar's `power-profiles-daemon` module still renders nothing because that service is not installed on this machine — not caused by this change and not fixed by it.
