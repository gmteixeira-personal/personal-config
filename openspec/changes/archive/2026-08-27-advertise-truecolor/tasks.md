## 1. Diagnosis

- [x] 1.1 Confirm `COLORTERM` is unset in the running environment
- [x] 1.2 Confirm terminfo reports 256 colors for the current `TERM`, and that the direct-color entries are a local-only answer unsuitable for a variable that travels over `ssh`
- [x] 1.3 Confirm Neovim is unaffected, because `termguicolors` is set in its own configuration

## 2. Shell configuration

- [x] 2.1 Add a guarded `COLORTERM=truecolor` export to `.bashrc`, placed with the colour configuration and below the non-interactive early return
- [x] 2.2 Condition it on markers for terminals known to render 24-bit colour, `WT_SESSION` among them
- [x] 2.3 Skip the export when `COLORTERM` already carries a value

## 3. Verification

- [x] 3.1 Confirm `bash -n .bashrc` passes
- [x] 3.2 Confirm an interactive shell with the terminal marker present exports `truecolor`
- [x] 3.3 Confirm an interactive shell with no marker leaves the variable unset
- [x] 3.4 Confirm a pre-set value survives unchanged
