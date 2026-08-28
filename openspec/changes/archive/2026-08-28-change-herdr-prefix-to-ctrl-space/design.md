## Context

See proposal.md — Why. The relevant state: `.config/herdr/config.toml` is tracked and its `[keys]` table holds `prefix = "ctrl+f"` and `focus_agent = "prefix+shift+1..9"`, followed by four `[[keys.command]]` blocks whose `key` values are all written as `prefix+…`. Because every binding names the prefix symbolically, the whole rebind is one value.

The constraint that shapes the work is delivery, not configuration. `ctrl+space` is not a distinct code in a terminal's input stream: the terminal encodes it as NUL (`\0`, `ctrl+@`), and some terminals send nothing at all for that chord. herdr sees whatever the terminal sends. So the binding can be correct in the file and still be dead in this environment — a WSL session inside a Windows terminal emulator, with the Flow Launcher hotkey having just been moved off the same chord on the host side.

## Goals / Non-Goals

**Goals:**

- One-value change in the tracked file, with every existing prefixed action inherited unchanged.
- Confirm the chord actually reaches herdr in this terminal before the old prefix is given up.

**Non-Goals:**

- Rebinding, adding, or removing any second key. `\`, `e`, `=`, `+`, and `shift+1..9` are untouched.
- Keeping `ctrl+f` as a second prefix. herdr's `[keys]` table takes one `prefix`, and carrying two would defeat the point of releasing the key.
- Changing anything on the Windows host. The Flow Launcher move already happened and is the user's; this change only consumes its result.

## Decisions

**Rebind the single `prefix` value rather than touching the command blocks.** The blocks are written against the symbol, so editing them would be both unnecessary and a chance to break a working binding. The edit is one line, and the verification that matters is behavioural (does a prefixed action still fire?) rather than textual.

Alternative considered: rewriting each `key` to a literal chord and dropping the prefix indirection. Rejected — it multiplies the edit by five, loses the ability to rebind again in one place, and gains nothing.

**Verify delivery in the live terminal before the change is considered done, and treat a non-delivering terminal as a stop rather than a workaround.** The task list therefore checks the chord in the running server first. If the terminal swallows `ctrl+space`, the honest outcome is to report that and leave `ctrl+f` in place, not to invent a substitute prefix the user did not ask for.

Alternative considered: configuring the terminal to send an escape sequence for `ctrl+space` and binding that. Rejected as premature — it is host-side configuration outside this repository, and it is only worth proposing if the plain chord is shown not to arrive.

**Apply through a configuration reload rather than a restart.** The capability already requires that a prefix change take effect on reload with open sessions surviving; using the reload path both honours that and keeps the running sessions in this workspace alive while the change is tested.

**Take the REMOVED + ADDED shape in the delta rather than MODIFIED.** The requirement's name carries the key value (`The prefix key is ctrl+f`), so the new behaviour needs a new heading; a MODIFIED block whose heading no longer matches the main spec would not merge cleanly at archive time.

## Risks / Trade-offs

- **The terminal does not deliver `ctrl+space` to herdr** → verify in the running server before reloading away the old prefix; if it does not arrive, revert the line and report, rather than substituting another key.
- **A program inside a pane wanted `ctrl+space`** → readline is the main candidate and `.inputrc` here binds only `Control-l`, leaving `C-@` (set-mark) at its system default; losing an unused set-mark is acceptable, and no other tracked configuration claims the chord.
- **Muscle memory is trained on `ctrl+f`** → nothing technical to mitigate; the cost is short-lived and is the reason the user asked for the change.
- **The reload leaves the server with no working prefix** → the terminal check runs before the reload, so the failure mode is caught while `ctrl+f` still works; if the reload nonetheless breaks input, restoring the line and reloading again is the rollback, and herdr can be driven from `herdr` CLI commands in a plain shell meanwhile.
