## Context

See `proposal.md` — Why. The mechanism matters here, so the relevant part of fish 4.8's own `fish_greeting` is worth having in front of the decisions:

```fish
function fish_greeting
    if not set -q fish_greeting
        # ... composes the two-line "Welcome to fish" banner into $fish_greeting
    end

    if set -q fish_private_mode && set -q fish_greeting[1]
        set -g fish_greeting $fish_greeting\n(_ "fish is running in private mode, history will not be persisted.")
    end

    test -n "$fish_greeting"
    and echo $fish_greeting
end
```

Three consequences shape everything below. The banner exists because the variable is *unset*, not because anything asked for it. The function prints nothing when the variable is set but empty. And the private-mode notice is delivered through the same variable, gated on `fish_greeting[1]` existing — so *how* the variable is emptied decides whether that notice survives.

Two constraints come from the repository rather than from fish. `.config/fish/fish_variables` is untracked on purpose — it is where fish records universal variables, and those are properties of a machine — so nothing this change relies on may live there. And `openspec/specs/fish-startup-files` governs where a startup setting goes: one kind of setting per file, a new kind gets a file of its own, and interactive-only configuration carries its own `status is-interactive` guard.

## Goals / Non-Goals

**Goals:**
- The banner is gone for every interactive shell, from a file a clone gets.
- The mechanism is the one fish documents, so a fish upgrade does not quietly restore the banner or break the shell.

**Non-Goals:**
- Replacing the banner with something else. Nothing takes its place.
- Silencing the prompt's own first-draw behaviour, tide's transient prompt, or any other start-up output.
- Changing what `set -U` means on this machine, or tracking `fish_variables`.

## Decisions

### Empty the variable rather than replace the function

`fish_greeting` can also be silenced by defining an empty `functions/fish_greeting.fish`, which fish would autoload in place of its own.

Emptying the variable is the documented switch and the smaller one. Replacing the function would shadow a shell built-in behaviour permanently: the private-mode notice, and anything a future fish adds to that function, would disappear with no line in this repository saying so. The layout spec also reserves `functions/` for functions this configuration *provides*; a stub whose only purpose is to suppress an upstream one is not that.

### `set -g` in `conf.d/`, not `set -U`

`set -U fish_greeting ''` is the advice most commonly given, and it is wrong for this repository: it writes to `fish_variables`, which is untracked, so the greeting would be silent here and loud on a clone — the failure mode the tracked-configuration requirement exists to prevent.

`set -g` in a snippet keeps the setting in the file, where an edit to the file is the whole change. `conf.d/env.fish` already makes this argument for `fish_add_path -g`.

Verified: a global shadows a universal of the same name when the variable is read, so a `fish_greeting` left behind in some machine's `fish_variables` cannot resurrect the banner.

### Its own file, `conf.d/greeting.fish`

A greeting is not environment, a key binding, a shorthand, or a function — the four categories the layout spec names — so it takes a file of its own rather than a line in `env.fish`. `conf.d/tide.fish` and `conf.d/direnv.fish` are the existing precedents for that rule, and the filename is what makes the setting findable from its kind alone.

### Guarded on `status is-interactive`

The variable is inert in a non-interactive shell: nothing there calls `fish_greeting`. The guard is still there, because the layout spec requires interactive-only configuration to carry its own, and because leaving it out would mean every script's fish carries a variable set for a prompt it will never draw.

### Empty string, not empty list

`set -g fish_greeting ''` and `set -g fish_greeting` (no value) both silence the banner. They differ in private mode, and the difference is not cosmetic:

| | normal shell | `fish --private` |
|---|---|---|
| `set -g fish_greeting ''` | silent | blank line, then `fish is running in private mode, history will not be persisted.` |
| `set -g fish_greeting` | silent | silent |

Both measured on fish 4.8.1. The empty string is chosen: the private-mode notice is a warning about where history goes, not a greeting, and this configuration's prompt has no private-mode indicator — `tide_right_prompt_items` does not include `private_mode` — so suppressing it would leave a private shell with nothing at all to distinguish it. The cost is one blank line in a mode this machine rarely starts.

## Risks / Trade-offs

- **A blank line ahead of the private-mode notice** → Accepted. It is the consequence of the notice being appended to an empty greeting rather than printed on its own, it appears only under `fish --private`, and the alternative that removes it also removes the notice. If the notice is ever unwanted, the change is one character: drop the `''`.
- **A future fish routes something new through `fish_greeting`** → Accepted and preferred. Setting the variable is fish's own switch, so anything new it composes there is silenced or shown by the same rule as the private-mode notice — visible in the upstream function rather than hidden behind a stub this repository owns.
- **A universal `fish_greeting` on some machine** → Neutralised by `set -g`, which is read in preference to a universal. Verified rather than assumed.
- **Snippet order** → Not a risk. The variable is read when the greeting is printed, which is after every `conf.d/` snippet has been read, and this snippet depends on nothing another snippet defines.
