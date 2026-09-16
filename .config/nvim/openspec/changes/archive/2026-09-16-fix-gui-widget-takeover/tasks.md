## 1. Establish what the front end actually declares

- [x] 1.1 Wrap `vim.ui_attach` from a `--cmd` script and poll `nvim_list_uis()` every 50 ms from launch; verify the flags read true at `--cmd`, `VimEnter` and `UIEnter` and false about 100 ms later
- [x] 1.2 Read the options noice passes to `vim.ui_attach` in that trace; verify it is `{ ext_popupmenu = true }` alone
- [x] 1.3 Compare `noice.ui._handlers` between the front end and the terminal; verify cmdline and msg are false under the front end and true in the terminal

## 2. Re-take the widgets

- [x] 2.1 Confirm by hand in a running instance that `noice.ui.disable()` followed by `noice.ui.enable()` flips all three handlers to true
- [x] 2.2 Add the poll that does it once the flags clear, guarded on the front end and giving up after five seconds; verify the file still loads with `loadfile`
- [x] 2.3 Start under the front end and read `_handlers`; verify all three are true and that the terminal is unchanged

## 3. Verify what the user sees

- [x] 3.1 Press `:` under both front ends and compare the floating windows; verify a `noice` float of the same size appears in each and no bottom row is used
- [x] 3.2 Re-check the notification backend's history, the command-line height and the grid under both; verify no reports, height zero, and the row counts still match

## 4. Correct the record

- [x] 4.1 Rewrite the comment so the suppression reads as downstream of the re-take rather than as a fix in its own right; verify by reading that neither block can be removed without the other looking wrong
