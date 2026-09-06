## 1. The programs

- [x] 1.1 Install `grim` and `slurp` from the distribution's packages and verify both resolve on `PATH`
- [x] 1.2 Install the annotator from the upstream `x86_64-unknown-linux-gnu` release archive into `~/.local/bin/satty`, and verify `satty --version` prints the expected version and `ldd` reports no unresolved library
- [x] 1.3 Verify the binary is ignored rather than newly tracked — `git check-ignore -v .local/bin/satty` names the existing `/.local/bin/*` rule and no ignore rule is added
- [x] 1.4 Verify `grim` can capture under this compositor at all, with a fixed-geometry grab that writes a valid PNG

## 2. The binding

- [x] 2.1 Confirm the chosen chord is free — verify no existing bind in `config.kdl` names it, and that `Mod+Alt+S` is rejected because `Super+Alt+S` is the screen-reader toggle
- [x] 2.2 Add the bind to `binds`, piping the region capture into the annotator with the clipboard as its only output and no save path
- [x] 2.3 Record in a comment why the `Print` binds are kept, why this chord and not the alternative, and that cancelling the selection is the intended silent abort
- [x] 2.4 Verify the compositor accepts the edited file with `niri validate`

## 3. The file chooser

- [x] 3.1 Identify why file dialogs never appeared — read the portal backend's own log line and the delegated bus name it names
- [x] 3.2 Install the delegate the portal backend requires and verify the dialog now opens from the annotator's Save As
- [x] 3.3 Verify the same fix reaches other applications — open the browser's file attach dialog and confirm a chooser appears

## 4. Documentation

- [x] 4.1 Add the region selector, the capturer and the annotator to **Software this configuration expects** in `README.md`, each stating what is lost without it, and place them by whether the session degrades or breaks
- [x] 4.2 Add the file manager to the same list, stating that it is what the portal delegates file dialogs to and that without it every file dialog in the session silently fails to appear
- [x] 4.3 State in the annotator's entry that it is not a distribution package on this machine, naming the release version installed and where it came from, so a newer one is a defined thing to check for
- [x] 4.4 Verify the documentation satisfies `desktop-session-declaration` — every newly required program is named, and no entry describes a program as running on defaults when a tracked file configures it

## 5. Verification

- [x] 5.1 Press the chord, select a region, annotate it, and verify the annotated image reaches the clipboard by pasting it into an application that accepts images
- [x] 5.2 Take a capture with nothing drawn on it and verify the pasted image is the selected region unchanged
- [x] 5.3 Cancel the region selection and verify the clipboard still holds what it held before, that no file was written, and that nothing was reported
- [x] 5.4 Verify no screenshot file is produced by the chord in the normal path — the capture directory named by `screenshot-path` is not created or added to by it
- [x] 5.5 Verify the `Print` binds are untouched and still validate, so the capability survives on a keyboard that has the key

## 6. Close-out

- [x] 6.1 Run `openspec validate annotate-region-screenshots --strict` and verify it passes
- [x] 6.2 Verify `git status` names only `.config/niri/config.kdl`, `README.md` and the change's own files, then commit
