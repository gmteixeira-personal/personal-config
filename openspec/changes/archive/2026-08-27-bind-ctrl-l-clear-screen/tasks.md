## 1. Diagnosis

- [x] 1.1 Confirm that with only the system defaults in place `clear-screen` is bound to `\C-l` in the vi command keymap and to no key in the vi insert keymap

## 2. Readline configuration

- [x] 2.1 Select the vi command keymap and bind `Control-l` to `clear-screen`
- [x] 2.2 Select the vi insert keymap and bind the same key to the same function
- [x] 2.3 Place both with the editing-mode setting, leaving the mode-indicator settings below unchanged

## 3. Verification

- [x] 3.1 Confirm `bind -m vi-insert -q clear-screen` reports `\C-l` in an interactive shell
- [x] 3.2 Confirm `bind -m vi-command -q clear-screen` reports the same
- [x] 3.3 Confirm no `bind` call for this key exists in `.bashrc`, `.profile`, or `.bash_logout`
