## 1. Verification tooling

- [x] 1.1 Install `libxkbcommon-utils` for `xkbcli`, and verify `xkbcli compile-keymap --help` runs; it is a verification tool, not a runtime dependency, and is deliberately not added to the README's expected-software list

## 2. The xkb half

- [x] 2.1 Write `.config/xkb/symbols/custom` with a `capslock_shift_f12` section doing `replace key <FK12> { [ F12, Caps_Lock ] }`, and record in the file why one group is correct rather than per-group stanzas
- [x] 2.2 Write `.config/xkb/rules/evdev` declaring `custom:capslock_shift_f12 = +custom(capslock_shift_f12)` and ending with `! include %S/evdev`; record in the file that libxkbcommon takes the first rules file found rather than merging, so omitting the include would discard every stock layout and option
- [x] 2.3 Verify with `xkbcli compile-keymap --layout us --options ctrl:nocaps,custom:capslock_shift_f12` that `<CAPS>` yields `Control_L` and is in the `Control` modifier map, and that `<FK12>` has `F12` at level 1 and `Caps_Lock` at level 2
- [x] 2.4 Verify the compiled keymap carries an interpret binding `Caps_Lock` to `LockMods(modifiers=Lock)`, so the level-2 keysym actually locks
- [x] 2.5 Verify layout-independence with `--layout us,pt`: `<CAPS>` still yields `Control_L` and `<FK12>` still yields `Caps_Lock` at level 2 with the second group active
- [x] 2.6 Verify plain `F12` is unchanged in both cases, and that no tracked file binds `Shift+F12` — grep `.config/niri/config.kdl`, `.config/fish/`, `.config/herdr/`, `.config/nvim/`
- [x] 2.7 Add `!/.config/xkb/**` to `.gitignore` and verify `git status --porcelain` names both new files

## 3. Applying it to the session

- [x] 3.1 Fill in the `xkb` block in `.config/niri/config.kdl` with `layout "us"` and `options "ctrl:nocaps,custom:capslock_shift_f12"`, keeping the block's existing explanatory comments and adding why the layout is named explicitly rather than left to `locale1`; verify with `niri validate`
- [ ] 3.2 Confirm niri picked it up after the next login: the running compositor's xkb context predates `~/.config/xkb` and cannot see it, which was diagnosed and recorded in the design; `niri msg keyboard-layouts` reports the layout and the Caps Lock key produces Control in a new window
- [ ] 3.3 Confirm `Shift+F12` locks and unlocks, and that plain `F12` is unaffected

## 6. The second layout and its switch key

- [x] 6.1 Change the `xkb` block's `layout` to `"eu,pt"`, leaving `eu` (EurKEY) first and so active at login, and record in the comment that EurKEY is shipped as a first-class layout so no `xmodmap` is involved, that it carries its own `level3(ralt_switch)`, and that the physical keyboard is pt-PT so the default is a stated preference rather than an oversight; verify with `niri validate`
- [x] 6.2 Replace the two commented-out `switch-layout` examples with one real bind, `Mod+Alt+Space { switch-layout "next"; }`, giving it a `hotkey-overlay-title` in the style the launcher and terminal binds use; verify `niri validate` and that no other binding claims the chord
- [x] 6.3 Add `Mod+Space` as a second launcher bind alongside `Mod+D`, with the same `hotkey-overlay-title`; verify no other binding claims it
- [x] 6.4 Verify no `grp:` option is present on the `options` line, so switching cannot happen twice for one keypress
- [x] 6.5 Verify with `xkbcli compile-keymap --layout eu,pt --options ctrl:nocaps,custom:capslock_shift_f12` that `<CAPS>` is still `Control_L`, that `<FK12>` still carries only `symbols[1]`, and that a layout-dependent key such as `<AD01>` gains `symbols[2]` — the contrast that shows the remap is not per-group
- [x] 6.6 Confirm `niri msg keyboard-layouts` lists both and marks the active one — it reports `* 0 EurKEY (US)` and `1 Portuguese`, so the layouts went live on reload; only the custom option is still refused by the stale context
- [ ] 6.7 Confirm by hand that `Mod+Alt+Space` switches layout and `Mod+Space` opens the launcher, both of which are live now, and after the next login that `Shift+F12` locks in either layout

## 4. The console half

- [x] 4.1 Write the tracked console keymap with an absolute `include`, `keycode 58 = Control` and `shift keycode 88 = Caps_Lock`; verify offline with `loadkeys --parse --tkeymap=4` that keycode 58 is `Control` in every column and keycode 88 is `F12 Caps_Lock ...`
- [x] 4.2 Choose and record the tracked path for that copy, and add its `.gitignore` allow entry; verify `git status --porcelain` names it
- [ ] 4.3 Install it: copy to `/usr/lib/kbd/keymaps/xkb/` and set `KEYMAP` in `/etc/vconsole.conf`, then verify `loadkeys` resolves it by bare name
- [ ] 4.4 Verify at a virtual console that the Caps Lock key produces Control and `Shift+F12` locks and unlocks

## 5. Documentation and close-out

- [x] 5.1 Add the console install step to `README.md`, naming the command and saying that until it is run the remap applies in the graphical session and not at the consoles; verify it follows the shape of the herdr plugin-registration step
- [x] 5.2 Run `openspec validate caps-lock-as-control --strict` and verify it passes
- [ ] 5.3 Verify `git status` names only the intended paths, then commit
