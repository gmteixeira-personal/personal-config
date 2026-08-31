## Context

See `proposal.md` — Why. The constraints that shape the approach are in the shells as they already stand:

- `~/.config/fish/conf.d/key-bindings.fish` calls `fish_vi_key_bindings`, and fish reads `conf.d` in filename order, so `fzf.fish` is read first and the vi set is installed over whatever it bound. **Measured on fish 4.8.1**, that turns out not to matter: `fish_vi_key_bindings` opens with `bind --erase --all --preset`, which erases preset bindings only, and a user binding outranks a preset on the same key. A binding made in `fzf.fish` therefore survives both the vi set and any later mode switch. (The comment in `key-bindings.fish` claiming fish re-runs `fish_user_key_bindings` after every binding-set install was wrong, and is corrected as part of this change; `__fish_config_interactive` calls it once, at the end of start-up.)
- `fish-startup-files` requires each snippet to be self-contained and order-independent, and requires `fish_user_key_bindings` to hold `bind` calls and nothing else.
- `~/.bashrc` ends by `exec fish` for interactive sessions, guarded on `FISH_LAUNCHED`. Every line before that runs in a bash that is about to be replaced.
- Installed here: fzf 0.74.3 (has `--fish` and `--bash`), fish 4.8.1.

## Goals / Non-Goals

**Goals:**

- The integration generated from fzf's own init output, never transcribed into a tracked file, so an upgrade that changes a default key or adds a widget arrives with the upgrade.
- Bindings in effect at a real prompt, not merely issued at start-up.
- Zero cost in the bash sessions that immediately hand off to fish.

**Non-Goals:**

- Tuning fzf's appearance, layout, or `FZF_DEFAULT_OPTS`. Defaults first; a preference file can come later.
- Directory jumping. An earlier draft of this change added zoxide alongside fzf; it was dropped and the tool uninstalled, so `z`, `c`, and the frecency database are out of scope and no spec describes them.
- Installing fzf. It stays optional at run time, as direnv already is.

## Decisions

### Generate, never transcribe

`fzf --fish | source` in fish and `eval "$(fzf --bash)"` in bash. Alternative considered: paste the generated code into the tracked snippet. Rejected — it is hundreds of lines that fzf rewrites on every release, and it would pin the key choices and widget set to whichever version happened to generate it.

### fzf's fish bindings stay in `conf.d/fzf.fish`

`conf.d/fzf.fish` sources `fzf --fish` and stops there. That defines the widget functions (`fzf-file-widget`, `fzf-history-widget`, `fzf-cd-widget`, `fzf_complete`) and binds Ctrl+T, Ctrl+R, Alt+C and Shift+Tab in both vi modes, and those bindings are the ones in effect at a prompt — verified by applying the vi binding set again by hand and re-reading `bind ctrl-r`, `bind ctrl-t`, and `bind shift-tab`.

One self-contained snippet, no coupling between two files, and nothing this repo has to restate about fzf's key choices.

Alternatives considered:

- **Re-issue the bindings from `fish_user_key_bindings` in `key-bindings.fish`** — `fzf_key_bindings` plus two explicit `shift-tab` binds, guarded on `type -q`. This was the original design here, on the belief that `fish_vi_key_bindings` clears the whole table. It does not, so the block is redundant: it re-does at start-up what already holds, costs a coupling between two snippets, and adds a second place to look for an fzf key. Rejected once measured.
- **A one-shot `--on-event fish_prompt` re-bind, as `key-bindings.fish` already does for tide.** Solves an ordering problem that does not exist. The tide precedent is for a binding installed by an autoload after start-up, which is a different problem.
- **Paste fzf's `bind` lines into `fish_user_key_bindings` by hand.** Hard-codes Ctrl+T, Ctrl+R and Alt+C into this repo and silently diverges the day fzf changes them.

### bash's block goes *after* the `exec fish` line

`~/.bashrc` ends by replacing itself with fish. Anything above that line is paid for by every interactive bash and then thrown away — and `fzf --bash` is on the order of a thousand lines to evaluate. Placed below `exec fish`, the block is reached exactly when bash stays: `FISH_LAUNCHED` already set, or no fish installed. That is the only case where it is wanted.

Alternative considered: put it above the `exec`, with the rest of the interactive section. Costs a full fzf evaluation on every terminal that opens, all of it discarded microseconds later.

### The integration is its own file, guarded in itself

`conf.d/fzf.fish` — a new kind of setting gets its own file, as `direnv.fish` and `tide.fish` already do. It carries its own `status is-interactive; and type -q fzf`, following `direnv.fish` exactly: no prompt-only machinery for scripts, no error on a machine that lacks the tool.

## Risks / Trade-offs

- **A future fish erases user bindings along with preset ones on a mode switch, or the vi set starts binding a key fzf uses** → the fzf keys would go quiet. This is the risk the rejected `fish_user_key_bindings` block was insuring against; it is not paid for now, on the grounds that the erase is explicitly `--preset` and that a user binding outranking a preset is long-standing fish behaviour. The failure is loud the first time Ctrl+R does nothing, and the fix is the rejected alternative.
- **The measurement is version-specific** → it was taken on fish 4.8.1, and the comments in the snippet say so, so a future maintainer knows what to re-check rather than trusting a bare assertion.
- **Alt+C in a terminal that sends Meta as an Escape prefix** → fzf's directory picker may not fire. Ctrl+T and Ctrl+R are unaffected, and the directory picker is the least-used of the three.

## Migration Plan

Nothing to migrate: no configuration is being replaced. Rollback is deleting `conf.d/fzf.fish` and reverting the `.bashrc` block; the shells return to exactly their current behaviour, since nothing else here depends on fzf.
