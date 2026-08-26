## 1. Readline configuration

- [x] 1.1 Create `~/.inputrc` with `$include /etc/inputrc` as its first line
- [x] 1.2 Add `set editing-mode vi`
- [x] 1.3 Add `set show-mode-in-prompt on` with `vi-ins-mode-string` set to a blinking beam and `vi-cmd-mode-string` set to a cursor-shape reset, which the terminal profile renders as an empty box, each wrapped in the `\1` / `\2` non-printing markers

## 2. Tracking

- [x] 2.1 Add an `!/.inputrc` allowlist entry to `.gitignore` beside the existing shell configuration entries
- [x] 2.2 Confirm `git check-ignore -v .inputrc` attributes the path to that entry and `git status` lists the file as untracked

## 3. Verification

- [x] 3.1 Reload the configuration in a running shell with `bind -f ~/.inputrc` and confirm `bind -V` reports vi editing mode
- [x] 3.2 Confirm the cursor turns into an empty box on Escape and back to a beam on `i`, and that the prompt text and alignment are unchanged
- [x] 3.3 Confirm a setting from `/etc/inputrc` is still in effect, verifying the include took
