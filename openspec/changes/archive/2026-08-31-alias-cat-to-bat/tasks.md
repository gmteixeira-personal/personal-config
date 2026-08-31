## 1. Bind the name

- [x] 1.1 In `.config/fish/conf.d/aliases.fish`, add `alias cat bat` guarded on `type -q bat`, inside the existing `status is-interactive` block, with a comment saying it is a deliberate override and that `command cat` reaches the original
- [x] 1.2 In `.bashrc`, add the same alias guarded on `command -v bat`, beside the existing `cls` alias

## 2. Verification

- [x] 2.1 Verify `cat` on a source file prints highlighting and line numbers in an interactive fish, and the same in an interactive bash
- [x] 2.2 Verify `cat file | cat` and `cat file > /dev/null` produce plain, undecorated output, confirming the non-terminal path is unchanged
- [x] 2.3 Verify `command cat` prints the file plainly in both shells
- [x] 2.4 Verify a non-interactive shell running `cat` gets the original executable
- [x] 2.5 Verify the guard: with `bat` masked off `PATH`, a fresh interactive shell starts silently and `cat` runs the original

## 3. Documentation

- [x] 3.1 Add `bat` to the README's optional-software list, in the same shape as the `direnv` and `fzf` entries — what is gained, that absence is silent, and how it is installed
