## 1. Establish that the reported conflict is not real

- [x] 1.1 Sample `nvim_list_uis()` repeatedly from launch onward under the front end, including a start through its desktop entry; verify `ext_cmdline`, `ext_popupmenu` and `ext_messages` read false on every sample
- [x] 1.2 Run the component's own health report inside the running front end; verify it answers that the GUI should work ok

## 2. Suppress the one false notification

- [x] 2.1 Add a `routes` entry to `lua/plugins/noice.lua` filtering the invariant half of the two message strings, scoped by a `cond` on the front-end variable, with `skip` set; verify the file still loads with `loadfile`
- [x] 2.2 Check the route against synthetic messages inside the running front end; verify both warnings match, an unrelated error does not, and none match with the front-end variable unset
- [x] 2.3 Rewrite the comment above `views` that claimed no route was present, keeping its `msg_showmode` reasoning; verify by reading that the file no longer contradicts itself

## 3. Give the front end its padding

- [x] 3.1 Confirm the front end ignores padding in its own configuration file by setting it there and re-measuring the grid; verify the grid does not change
- [x] 3.2 Add the four padding variables to `lua/config/options.lua` behind a guard on the front-end variable, commented with why they are not in the front end's own file; verify the file still loads with `loadfile`
- [x] 3.3 Start the front end and the session's terminal at the same window size; verify the reported row counts match
