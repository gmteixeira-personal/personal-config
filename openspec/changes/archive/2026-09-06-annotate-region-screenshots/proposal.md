## Why

The session had no reachable screenshot at all. niri's own screenshot actions are bound to `Print`, `Ctrl+Print` and `Alt+Print` in `config.kdl`, and the keyboard on this machine has no `Print` key — so all three binds exist and none of them can be pressed. The capability was configured and unusable at the same time, which is the worst of the two states: nothing reports it, and the configuration reads as though screenshots work.

The screenshots that are actually wanted are annotated ones. A screenshot that goes straight to the clipboard is finished only when the whole point was the raw pixels; the common case is a screenshot with an arrow on it, or a redacted line, pasted into a message. niri's built-in action captures, saves and copies in one step and offers no point at which to draw on the result, so reaching the wanted behaviour means giving up that integration rather than configuring it.

A second failure surfaced while testing the first and is fixed here because it has the same cause and the same one-package remedy: no file chooser dialog opened anywhere in the session. `xdg-desktop-portal-gnome` implements no file chooser of its own and delegates to `org.gnome.Nautilus`, which was not installed, so every request failed with `Delegated FileChooser call failed: The name is not activatable` and the calling application showed nothing at all. That broke the annotator's Save As and Chrome's file attach button identically, and would have broken every future file dialog in the session the same silent way.

## What Changes

- `binds` gains `Mod+Shift+S`, which selects a screen region, opens it in an annotation editor, and puts the annotated result on the clipboard. It is the Windows Snipping Tool chord, which is the muscle memory that already exists for this.
- Screenshots taken this way are **not** written to disk. The clipboard is the only output, deliberately: the overwhelming majority of these are pasted once and never wanted again, and a screenshot directory that fills up with them is a chore this session does not need to acquire.
- The three `Print` binds stay. They are dead on this keyboard, but this configuration is shared across machines and the next one may have the key.
- The session gains a working file chooser. Applications that ask the desktop portal for a file dialog get one, instead of getting silence.
- Four programs join the required-software documentation: the region selector, the capturer, the annotator and the file manager whose file chooser the portal delegates to.

## Capabilities

### New Capabilities

- `screen-capture`: How a screenshot is taken, annotated and delivered — that a region can be selected from a keyboard chord, that the result is annotatable before it goes anywhere, that the clipboard is where it lands, and that cancelling produces nothing rather than an error.
- `file-chooser`: That an application asking the session for a file dialog gets a working one. The portal backend that answers on this compositor delegates rather than implements, so the delegate is part of what the session must provide.

### Modified Capabilities

<!-- None. `desktop-session-declaration` already requires that every program the session depends on be named in the tracked documentation; the four new programs satisfy that existing requirement rather than changing it. -->

## Impact

- `.config/niri/config.kdl` — one binding in `binds`, with a comment recording why the unreachable `Print` binds are kept and why the chord is not `Mod+Alt+S`.
- `README.md` — four entries in **Software this configuration expects**. The annotator is the one that is not a system package on this distribution and needs its own installation note.
- `.local/bin/satty` — the annotator's binary. `.gitignore:323` already ignores `/.local/bin/*`, so it is untracked and `git status` stays clean; no ignore rule changes.
- Behaviour: `Mod+Shift+S` captures a region. No existing chord is taken or rebound. `Mod+Alt+S` was rejected as the alternative because it is `Super+Alt+S`, the screen-reader toggle.
- Session-wide: installing the file chooser delegate fixes every file dialog in the session, not only the annotator's. Chrome's attach button was failing for this reason before the change and works after it.
- Machines: this one only. The binding is compositor configuration and the WSL machine runs no compositor.
- Reload: niri re-reads `config.kdl` on save, so the binding is live without restarting the session.
