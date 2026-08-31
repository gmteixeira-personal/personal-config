## Why

Pressing Ctrl+Enter at a fish prompt is supposed to accept the autosuggestion and run it in one keystroke — type `git com`, see the rest of the last `git commit` command greyed out ahead of the cursor, and run it without first pressing an accept key and then Enter. This was set up on another machine and does not work here.

It is not missing configuration. `conf.d/key-bindings.fish` already binds it, and that file is tracked and committed:

```fish
bind -M default \cj accept-autosuggestion execute
bind -M insert \cj accept-autosuggestion execute
```

The binding is dead. Tide's transient prompt binds the same key later in start-up and wins — `\n` and `\cj` are the same byte, `0x0A`, and `functions/fish_prompt.fish` ends with `bind \n _tide_enter_transient`, which runs after `fish_user_key_bindings` has already installed the binding above. Measured in a real terminal after a full start-up, `bind ctrl-j` reports:

```
bind ctrl-j _tide_enter_transient
bind -M insert ctrl-j _tide_enter_transient
```

So the key runs the line without accepting the suggestion, which is indistinguishable from plain Enter — the symptom that reads as "it was never set up". Two things are therefore wrong at once: the binding is on a key another component claims, and it is installed at a moment that lets that component overwrite it.

## What Changes

- Bind Ctrl+Enter to accept the pending autosuggestion and run the resulting command line, in both vi modes, so the key does what it does on the other machine.
- Move the binding off `\cj`. fish 4.8 knows `ctrl-enter` as a key in its own right, and tide binds only `\r` and `\n`, so a binding on `ctrl-enter` is not in tide's way at all — the collision is designed out rather than worked around.
- Establish what this machine's terminal actually sends for Ctrl+Enter before relying on it. A terminal only reports Ctrl+Enter as distinct from Enter when it encodes keys in the kitty keyboard protocol; a terminal that does not sends a bare `\r`, and no `ctrl-enter` binding can ever fire. Whatever the answer, the outcome is a key that accepts and runs — the finding decides which key that is, not whether the feature ships.
- Keep the transient prompt. Running a command through this key SHALL collapse the prompt the way Enter does, so scrollback does not end up with one full-height prompt among the collapsed ones.
- Keep the existing accept-and-run behavior reachable at all times, so this change cannot leave the shell with no such key.

## Capabilities

### New Capabilities
- `fish-key-bindings`: what the interactive fish command line's keys do — which editing mode the shell starts in, which keys this configuration binds on top of that, and how those bindings survive a plugin that installs its own.

### Modified Capabilities

<!-- none -->

## Impact

- `.config/fish/conf.d/key-bindings.fish` — the whole change. Its `fish_user_key_bindings` function gains the accept-and-run binding on the key the investigation settles on, and loses the dead `\cj` pair if that key turns out to be a different one.
- Possibly a second `conf.d/` snippet, if the binding has to be re-installed after tide rather than beside the others. Which file, and whether one is needed at all, is a design question rather than a settled one.
- `functions/fish_prompt.fish` and the rest of `functions/_tide_*` are vendored tide files and SHALL NOT be edited. Tide is installed by fisher and rewrites them on update, so a fix that edits them would be lost silently — the binding has to win without touching them.
- Nothing outside fish is affected. No terminal configuration in this repository changes, and the WezTerm configuration this machine uses lives on the Windows side and is not tracked here — if the terminal turns out to need a setting, that is a finding to report rather than a file this change can commit.
- No new plugin, no new dependency. `accept-autosuggestion` and `execute` are fish built-ins and `bind` is a fish built-in.
