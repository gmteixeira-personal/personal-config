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

## 4. The console half

- [x] 4.1 Write the tracked console keymap with an absolute `include`, `keycode 58 = Control` and `shift keycode 88 = Caps_Lock`; verify offline with `loadkeys --parse --tkeymap=4` that keycode 58 is `Control` in every column and keycode 88 is `F12 Caps_Lock ...`
- [x] 4.2 Choose and record the tracked path for that copy, and add its `.gitignore` allow entry; verify `git status --porcelain` names it
- [ ] 4.3 Install it: copy to `/usr/lib/kbd/keymaps/xkb/` and set `KEYMAP` in `/etc/vconsole.conf`, then verify `loadkeys` resolves it by bare name
- [ ] 4.4 Verify at a virtual console that the Caps Lock key produces Control and `Shift+F12` locks and unlocks

## 5. Documentation and close-out

- [x] 5.1 Add the console install step to `README.md`, naming the command and saying that until it is run the remap applies in the graphical session and not at the consoles; verify it follows the shape of the herdr plugin-registration step
- [x] 5.2 Run `openspec validate caps-lock-as-control --strict` and verify it passes
- [ ] 5.3 Verify `git status` names only the intended paths, then commit
