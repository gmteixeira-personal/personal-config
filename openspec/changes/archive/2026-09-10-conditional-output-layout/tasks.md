## 1. Dependency

- [x] 1.1 Install `kanshi` from the Fedora repository and verify `command -v kanshi` resolves to a path

## 2. Profiles

- [x] 2.1 Write `~/.config/kanshi/config` with a `docked` profile — the two externals matched by make, model and serial at `0,0` and `1920,0`, the laptop matched as `eDP-1` at `scale 1.5` and `position 1280,1080` — and verify the file records the arithmetic tying the offset to the scale
- [x] 2.2 Add a `mobile` profile placing `eDP-1` alone at `scale 1.25`, `position 0,0`, and verify it lists only that one output so it matches the undocked set exactly
- [x] 2.3 Start kanshi and verify its output reports `applying profile 'docked'` with no parse error, and that `niri msg outputs` then shows eDP-1 at scale 1.5, logical size 1280x800, position 1280,1080, with the externals at 0,0 and 1920,0

## 3. Compositor configuration

- [x] 3.1 Remove the `output` blocks from `~/.config/niri/config.kdl`, leaving a comment that names `~/.config/kanshi/config` as where geometry now lives and why it is not in both, and verify `niri validate` reports the config valid
- [x] 3.2 Add `spawn-at-startup "kanshi"` alongside the existing bar, notification daemon and idle manager spawns, and verify `niri validate` still passes and `grep` finds the line

## 4. Verification

- [x] 4.1 Verify the pointer crosses down into the laptop from a point on either external within x 1280..2560, and stops at the bottom edge outside that range
- [x] 4.2 Verify `Mod+Shift+Down` moves focus to the laptop from either external regardless of pointer position
