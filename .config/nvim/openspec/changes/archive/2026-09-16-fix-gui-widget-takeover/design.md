## Context

See proposal.md — Why. The measurements the approach rests on, all taken with a `--cmd` probe that wraps `vim.ui_attach` and polls `nvim_list_uis()` every 50 ms from the earliest point a script can run:

- `ext_cmdline` and `ext_messages` read true at `--cmd` time, at `VimEnter` and at `UIEnter`, and false from the second poll — roughly 100 ms later — onwards.
- The wrapped `vim.ui_attach` shows noice attaching with `{ ext_popupmenu = true }` and nothing else.
- `noice.ui._handlers` afterwards is `{ cmdline = false, msg = false, popupmenu = true }` under the front end and all three true in the terminal.

## Goals / Non-Goals

**Goals:**

- The floating command line under the GUI, identical to the terminal's.
- A record of why every later reading says the opposite, so the next person does not repeat the previous conclusion.

**Non-Goals:**

- Changing the front end's attach sequence, or asking it not to claim the widgets. Upstream.
- Capturing the startup messages that pass before the re-take. They already were not being captured.

## Decisions

**Re-take by detaching and enabling again, not by deferring setup.** `noice.ui.enable()` re-runs `noice.ui.setup()`, which is the function that reads the flags, so `disable()` then `enable()` is the whole correction and everything else noice set up — routes, views, commands, the notify source — is left alone. Deferring `noice.setup` instead would also work and would cost the same startup messages, but it would move a decision about noice's load order into a GUI branch.

**Polled, not hooked.** Neovim raises no event when a UI option changes, so there is nothing to hook. The poll runs every 50 ms, stops on the first clear reading, and gives up after five seconds; on giving up it does nothing, leaving the capability exactly as the front end's declaration left it.

**The suppression stays and is re-grounded.** It is now downstream of the correction rather than a substitute for it, and the requirement is written so it cannot be read the other way round. The previous framing — that later readings prove the report false — is the thing being removed, because those readings are of a different moment.

## Risks / Trade-offs

- **A future front end that never withdraws the claim gets nothing.** → The poll gives up and leaves the capability as found; the health report still says what it says, and `:checkhealth noice` is where it is read.
- **The re-take happens after `VimEnter`, so anything the message widget would have captured before it is lost.** → It was lost for the whole session before this; the window is now about 100 ms.
- **`noice.ui.disable()` and `enable()` are not the documented entry points.** → They are what `noice.setup` itself calls, and the failure mode of a rename is the command line reverting to the bottom row, which is visible immediately.
