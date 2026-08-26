## 1. Diagnosis

- [x] 1.1 Confirm the program displaying the beam does not itself set a cursor shape, by searching its binary for DECSCUSR sequences
- [x] 1.2 Confirm readline is the source, by checking `bind -V` for `editing-mode`, `show-mode-in-prompt` and the two mode strings

## 2. Shell configuration

- [x] 2.1 Add a `PS0` assignment to `.bashrc` carrying a cursor-shape reset, placed with the prompt configuration
- [x] 2.2 Use the terminal-default reset rather than naming a shape, matching `vi-cmd-mode-string`

## 3. Verification

- [x] 3.1 Confirm `bash -n .bashrc` passes
- [x] 3.2 Confirm `PS0` resolves to the escape sequence in an interactive shell, by inspecting its bytes
- [x] 3.3 Confirm the vi mode indicator still switches between beam and the terminal's own shape at the prompt
