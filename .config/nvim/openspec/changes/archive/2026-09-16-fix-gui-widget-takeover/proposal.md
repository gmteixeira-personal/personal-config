## Why

The report `fix-gui-message-suppression` silenced was accurate, and silencing it hid the fault it named. Under the graphical front end this capability was not driving the command line at all: pressing `:` dropped to the bottom screen row exactly as a stock editor does, while the same configuration in the terminal opened the floating input. The component had attached with the popup-menu widget alone and left the command-line and message handlers off for the whole session.

The cause is a window, not a disagreement. The front end attaches its UI claiming the command line and the messages, and releases both about a tick later. The component reads the claim once, while it is still standing, and writes off the two widgets permanently. The health report saying it could not work was describing that, correctly, and the previous change treated it as a false alarm because every later reading of the same flags says the opposite.

## What Changes

- The capability re-takes the command line and the message widgets once the front end releases them, so the floating input works under the GUI as it does in the terminal.
- The suppression requirement is replaced. A self-diagnosis may be silenced only after the condition it names has been corrected, and never as a way of dealing with the condition.
- Both requirements are stated so that a later reading of the flags cannot be mistaken for evidence about the reading that mattered.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `message-ui`: added — the command line and message widgets are taken under a front end that claims them only while it starts; added — a self-diagnosis is silenced only after the condition is corrected; removed — the requirement that treated the report as demonstrably false.

## Impact

- `lua/plugins/noice.lua` — a poll that re-attaches the capability's UI once the front end's flags clear, and the comment that now says the suppression is not a substitute for it.
- Nothing in the terminal. Both blocks are guarded on the front end, and the terminal already took all three widgets.
