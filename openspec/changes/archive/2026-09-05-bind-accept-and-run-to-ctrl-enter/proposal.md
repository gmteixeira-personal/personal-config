## Why

Ctrl+Enter no longer accepts the autosuggestion and runs it. The line runs as typed, which is indistinguishable from plain Enter — the exact symptom the binding was written to fix, arrived at by a different route.

Nothing about the binding changed. The terminal did. `conf.d/key-bindings.fish` binds `ctrl-j`, and its comment says why: measured with `fish_key_reader` **in WezTerm**, Ctrl+Enter arrived as a bare LF, `0x0A`, because that terminal did not encode the modifier — and `0x0A` is `ctrl-j`. Adopting foot replaced the terminal that made that true. foot 1.27 speaks the kitty keyboard protocol and fish 4.6 negotiates it, so Ctrl+Enter now arrives as a key of its own, which fish names `ctrl-enter` and already carries a preset for: `bind --preset -M insert ctrl-enter execute`. Nothing in this configuration binds that name, so the preset is what the key resolves to, and `execute` runs the line without accepting the suggestion.

The capability is therefore absent under the terminal actually in use, while the configuration still reads as though it were present. That is the failure mode the `fish-key-bindings` spec already names for a binding replaced by a plugin, and the terminal is a second way to reach it that the spec does not yet close.

## What Changes

- Bind `ctrl-enter` alongside `ctrl-j`, in both places the accept-and-run action is installed: `fish_user_key_bindings`, and the `_accept_and_run_after_tide` handler that re-binds after tide's autoload. Keeping `ctrl-j` is not redundancy for its own sake — it is the literal Ctrl+J chord, and the encoding any terminal without the kitty keyboard protocol still sends for Ctrl+Enter.
- Rewrite the comment block that explains the binding. It currently names WezTerm as the machine's terminal and presents `ctrl-j` as what Ctrl+Enter delivers, both of which are now wrong; it should name the two encodings and say which terminal class produces each.
- Add a requirement to `fish-key-bindings` making the terminal an explicit source of binding loss, so that a key reached through a terminal-dependent encoding must also be bound under the name a protocol-speaking terminal reports.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fish-key-bindings`: the existing accept-and-run requirement is met by binding whichever single key the terminal delivers; it does not require covering both encodings at once, so a terminal swap silently removes the capability. A new requirement makes the binding independent of the terminal's key encoding.

## Impact

- `.config/fish/conf.d/key-bindings.fish` — two added bindings in each of two places, and the comment block that documents them.
- No change to `functions/accept-autosuggestion-and-run.fish`. The action is correct; only the keys that reach it are wrong.
- No change to foot's configuration. The kitty keyboard protocol is negotiated between fish and the terminal at runtime and is not something `foot.ini` opts into.
- Ctrl+J keeps doing the same thing it does today, on every terminal.
