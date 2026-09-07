## 1. Bindings

- [x] 1.1 Add a `[key-bindings]` section at the end of `.config/fuzzel/fuzzel.ini`, after `[colors]`, and verify the three keys sit under that header rather than under `[colors]`
- [x] 1.2 Bind `prev=Up Control+p Control+k` and `next=Down Control+n Control+j`, and verify the packaged keys are still named in each list
- [x] 1.3 Bind `cursor-left=Left Control+b Control+h` and `cursor-right=Right Control+f Control+l`, and verify the packaged keys are still named in each list
- [x] 1.4 Free the keys those bindings took over: `delete-prev=BackSpace` and `delete-next=Delete KP_Delete`, and verify neither list still names `Control+h` or `Control+d`
- [x] 1.5 Set `delete-line-backward=none` and `delete-line-forward=none`, and bind `delete-line=Control+Shift+BackSpace Control+d`

## 2. Comment block

- [x] 2.1 Write the comment block above the section in the voice of the file's existing comments, and verify it names each action that was displaced, the key it now answers to or that it is unbound, and that the `Mod`-prefixed compositor bindings do not collide

## 3. Verification

- [x] 3.1 Run `fuzzel --check-config` and verify it exits 0, which is what catches a duplicate binding or an unknown keysym
- [x] 3.2 Open the launcher and verify `Control+j` and `Control+k` move the selection, and that `Control+j` moves it rather than launching the entry the way `Return` would
- [x] 3.3 Type a query and verify `Control+h` and `Control+l` move the cursor without deleting, `BackSpace` still deletes a character backward, and `Control+d` clears the whole query from a cursor position in the middle of it
- [x] 3.4 Verify the packaged keys still work: `Up`/`Down`, `Control+p`/`Control+n`, `Control+b`/`Control+f`, `Delete`, and `Control+w`
