## Context

See proposal.md — Why. The constraints that shape the approach were measured on this machine rather than assumed:

- fish is 4.8.1. It knows `ctrl-enter` as a key name in its own right and already ships a `--preset` binding for it, so the fish half of "bind Ctrl+Enter" needs no escape-sequence literal and no compatibility shim.
- `\cj` and `\n` are one byte, `0x0A`. `bind \cj` and `bind \n` address the same key, and fish 4 reports both as `ctrl-j`. Any binding on one is a binding on the other.
- Tide's `bind \r`/`bind \n` pair sits at **file scope** in `functions/fish_prompt.fish`, guarded by `test "$tide_prompt_transient_enabled" = true`, which `conf.d/tide.fish` sets to `true`. That file is autoloaded when `fish_prompt` is first called — after every `conf.d/` snippet and after `fish_user_key_bindings` — which is why tide wins today. Measured after a full start-up in a real terminal: `bind ctrl-j` reports `_tide_enter_transient`.
- That autoload happens later than the first `fish_prompt` event, not earlier. Measured with a handler that reports whether `_tide_enter_transient` is defined: at the first event it is not, and at the second it is — fish loads the file in between, to draw prompt one. Any fix that binds at the first event therefore binds *ahead* of tide and is overwritten moments later.
- `conf.d/` snippets are read in filename order, and `tide.fish` sorts after `key-bindings.fish`. So `tide_prompt_transient_enabled` is still unset while `key-bindings.fish` runs, and is set by the time any prompt is drawn.
- Tide binds `\r` and `\n` and nothing else. It does not bind `ctrl-enter`.
- `functions/fish_prompt.fish` and every `functions/_tide_*` file is vendored by fisher and rewritten on update.
- `fish_key_reader` 4.8.1 is installed, so what the terminal actually sends for a keystroke is observable rather than a matter of opinion.
- The terminal stack is WezTerm on the Windows side, through WSL, through herdr. Only the herdr and fish halves are tracked in this repository; the WezTerm configuration is not.

## Goals / Non-Goals

**Goals:**

- Reach the accept-and-run action from Ctrl+Enter where the terminal can express it, and from a documented key where it cannot, without the choice being silent.
- Win the binding without editing a vendored file, so a `fisher update` cannot revert the fix.
- Keep the transient prompt, so scrollback does not record which key ran which command.

**Non-Goals:**

- Changing what Enter does. Enter keeps tide's transient binding exactly as it is.
- Rebinding anything else in `key-bindings.fish`. The word-motion bindings on `\cf` and `\cb` are on keys tide does not touch and are working; they are out of scope.
- Making the terminal emit Ctrl+Enter. If the terminal turns out not to encode it, that is reported, not fixed here — the WezTerm configuration is not tracked in this repository, and adding it is a separate change.
- Replacing tide, or configuring the transient prompt itself.

## Decisions

### Measure the key before binding it

Task 1 is `fish_key_reader` and pressing Ctrl+Enter. Everything else follows from what it prints, so it comes first rather than being assumed.

A terminal reports Ctrl+Enter as distinct from Enter only when it encodes keys in the kitty keyboard protocol. Without that, Ctrl+Enter *is* Enter on the wire — one byte, `\r` — and no fish binding can separate them, because there is nothing to separate. Guessing here would produce a binding that silently never fires, which is precisely the failure this change exists to remove.

Two outcomes, both specified so neither is a decision deferred to implementation time:

- **The terminal reports `ctrl-enter`** — bind that, and there is no collision to fight, because tide binds neither.
- **The terminal reports `enter`** — Ctrl+Enter is unreachable. Bind `ctrl-j` instead, which is a real distinct key and the one the previous configuration was already reaching for, and record in the file that Ctrl+Enter was measured unreachable on this terminal so the next reader does not re-litigate it.

**Measured:** neither. `fish_key_reader` reports **`ctrl-j`** for Ctrl+Enter on this machine's terminal, while plain Enter reports `enter`. The terminal sends a bare LF for the chord rather than encoding the modifier, and LF is `ctrl-j` — so Ctrl+Enter *is* reachable and distinguishable from Enter, it simply is not spelled `ctrl-enter`. This vindicates the key the previous configuration chose and locates the whole fault in the ordering, and it means Ctrl+J necessarily does the same thing, one byte serving two chords.

The consequence is that the collision with tide is unavoidable rather than designable-around: `ctrl-j` is exactly the key tide takes.

### Bind a named function, not a chain of built-ins

The binding calls one function of this configuration's own, in `functions/` per the existing convention that a function is defined by being named:

```fish
commandline -f accept-autosuggestion
if functions -q _tide_enter_transient
    _tide_enter_transient
else
    commandline -f execute
end
```

Two things fall out of this that a bare `bind ... accept-autosuggestion execute` does not give:

- The transient prompt is preserved. `execute` runs the line but leaves the full prompt in scrollback, so commands run by this key would look different from commands run by Enter. Delegating the run to `_tide_enter_transient` makes them identical, which is the spec's uniform-scrollback requirement.
- It degrades without tide. `functions -q` means the file is correct on a machine where tide is not installed or the transient prompt is switched off, rather than referring to a function that is not there.

Alternatives considered:

- **`bind ctrl-enter accept-autosuggestion execute`** — one line, no new file. Rejected: it loses the transient prompt, and the inconsistency is subtle enough to be noticed weeks later as "some prompts in my scrollback are tall".
- **`bind ctrl-enter accept-autosuggestion _tide_enter_transient`** — also one line, and keeps the transient prompt. Rejected on the fallback alone: with no `functions -q` guard it breaks the prompt entirely on a machine without tide, and this repository is checked out onto more than one machine.

### Depend on `_tide_enter_transient` by name, and guard the dependency

`_tide_enter_transient` is tide-private. Calling it couples this configuration to a name upstream does not promise to keep.

The coupling is accepted because the alternative is worse: reproducing what that function does means copying tide's `commandline --is-valid`, paging-mode and repaint logic into this repository, frozen at the version it was copied from. The `functions -q` guard turns an upstream rename from a broken prompt into a silent fall back to plain `execute` — the key still accepts and still runs, and only the transient collapse is lost.

### Force the autoload rather than wait for it

Since the measured key is `ctrl-j`, the collision with tide has to be won rather than avoided. The binding has to be installed after `fish_prompt.fish` is autoloaded — and the timing measurement above rules out the obvious mechanism.

A plain one-shot `--on-event fish_prompt` handler that binds and erases itself does not work: the first prompt event precedes the autoload, so it binds ahead of tide and is overwritten before the prompt is even drawn. Waiting instead — staying registered until `_tide_enter_transient` appears, then binding over it — does work, but only from the *second* prompt onward, which leaves the first prompt of every session with tide's binding. Both were built and measured; the second is a real improvement that still fails the spec's requirement that the binding be in effect at the prompt, without qualification about which prompt.

So the handler pulls the load forward instead of waiting for it. Asking for the function's definition — `functions fish_prompt >/dev/null 2>&1` — is what makes fish autoload the file, and once it has, tide's bindings exist and can be bound over immediately, inside the same first prompt event. The handler then erases itself, since the ordering is a start-up problem and nothing re-creates it.

This has to run at the first prompt rather than in `conf.d/`. Snippets are read in filename order, `tide.fish` sorts after `key-bindings.fish`, and `tide.fish` is what sets `tide_prompt_transient_enabled` — so forcing the load from `conf.d/` would source `fish_prompt.fish` while that variable was unset, skip the block guarded on it, and leave tide's transient prompt never bound to Enter at all. By the first prompt every snippet has run.

The handler lives in `conf.d/key-bindings.fish` beside the static bindings, not in a snippet of its own. It installs key bindings, which is the kind of setting that file is named for, and the existing rule is one kind per file rather than one mechanism per file. Splitting it out would leave the file named `key-bindings.fish` not containing the binding that actually ends up in effect, which is the opposite of what that naming is for.

Alternatives considered:

- **Setting `tide_prompt_transient_enabled false`** — makes tide's binds disappear, so ours survive. Rejected: it removes the transient prompt from Enter as well, trading a feature the user configured deliberately for a key binding.
- **Editing `functions/fish_prompt.fish`** — the direct fix, and reverted by the next `fisher update` with no message. Rejected outright.
- **Re-binding from a prompt event on every prompt** — never stops paying for a problem that exists once, and papers over the timing rather than resolving it.

## Risks / Trade-offs

- **The terminal may not encode Ctrl+Enter** → Measured in task 1 rather than discovered later, with the fallback key already specified so the change still lands. The finding is reported to the user, since fixing it means a WezTerm setting outside this repository.
- **`_tide_enter_transient` is a private name upstream may rename** → `functions -q` degrades to plain `execute`; the key keeps working and only the prompt collapse is lost.
- **A binding set reinstall drops tide's binds but keeps ours** → After `fish_vi_key_bindings` runs again mid-session, `fish_user_key_bindings` reinstalls this configuration's bindings while tide's file-scope binds do not re-run, so Enter reverts to plain `execute` until the next session. This predates the change and is not made worse by it, but it is the reason to test the mode-switch scenario rather than assume it.
- **The accept-and-run key bypasses a confirmation the user might want** → Accepting a suggestion and running it in one keystroke will run a long recalled command without a chance to read it. That is the requested behavior, and Enter remains the two-step path.

## Migration Plan

Not applicable in the deployment sense — an additive local shell configuration change. Rollback is deleting the new function file and the binding line, and restoring the `\cj` pair if it was removed; nothing else depends on either.

## Open Questions

- Whether to track the WezTerm configuration in this repository at all. It is the one part of the terminal stack that is not tracked, and if task 1 finds Ctrl+Enter unreachable, the fix for that lives there. Answering it does not change this change's specs, approach, or tasks — it is a separate proposal either way.
