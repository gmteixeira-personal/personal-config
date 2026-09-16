## 1. Establish that the previous suppression never fired

- [x] 1.1 Start the editor under the front end and read `require("notify").history()`; verify both reports are present despite the route
- [x] 1.2 Set `health.checker` false and repeat; verify both reports still arrive, which rules the option out as the lever

## 2. Suppress the reports where they are actually raised

- [x] 2.1 Seed the component's `_once` table with the three level-plus-message keys before `setup`, guarded on the front end; verify the file still loads with `loadfile`
- [x] 2.2 Start under the front end and read the notification history; verify it is empty and that the component still reports itself running
- [x] 2.3 Start in a terminal; verify the history is empty, the component runs, and the health checker is still enabled there

## 3. Reclaim the command-line row

- [x] 3.1 Log every `OptionSet` on the command-line height through startup under the front end; verify the front end writes the value back more than once and that the writes carry no Lua stack
- [x] 3.2 Add the `OptionSet` correction guarded on the front end and torn down after startup; verify by sampling the option from launch that it reads zero throughout
- [x] 3.3 Screenshot both windows at the same size and compare the bands below the status line; verify the status line ends on the same pixel row and the band below it is the same height
