## 1. The module

- [x] 1.1 Add `niri/language` to `modules-left` in `.config/waybar/config.jsonc`, between `niri/workspaces` and `niri/window`; verify the file still parses as JSON with comments stripped
- [x] 1.2 Add a `"niri/language"` options block setting `format` to `{short}`, restating only that key so the packaged file keeps supplying the rest, and record why `{short}` rather than `{long}` or `{shortDescription}`
- [x] 1.3 Verify no module in either list is one the compositor cannot drive — the existing requirement the list is subject to

## 2. The styling

- [x] 2.1 Add `#language` to the shared no-fill, white-text, padded rule in `.config/waybar/style.css` alongside the other modules
- [x] 2.2 Add `#language.eu` and `#language.pt` colour rules so the active layout is distinguishable without reading the label, and record that the label carries the name so a class mismatch degrades to a shared colour rather than to a wrong reading
- [x] 2.3 Verify the stylesheet still names every module the config lists, since waybar loads exactly one stylesheet and anything unstated is unstyled

## 3. Applying and checking

- [x] 3.1 Reload with `pkill -SIGUSR2 waybar` rather than through systemd, which would start a second bar beside the compositor-spawned one; verify only one waybar process is running afterwards
- [x] 3.2 Verify the bar shows the active layout and that `Mod+Alt+Space` changes the reading without the bar being restarted
- [x] 3.3 Verify the two layouts render in different colours — confirmed by hand; the class matched `pt` as expected and no selector correction was needed

## 4. Close-out

- [x] 4.1 Run `openspec validate keyboard-layout-indicator --strict` and verify it passes
- [x] 4.2 Verify `git status` names only the intended paths, then commit
