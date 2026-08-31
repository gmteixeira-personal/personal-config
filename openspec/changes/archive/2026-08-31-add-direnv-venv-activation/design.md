## Context

See proposal.md — Why.

Four constraints shape the approach:

- **Two shells, asymmetric hooks.** fish has `--on-variable PWD`. bash 5.3 has no `chpwd` equivalent, so a bash implementation has to drive off `PROMPT_COMMAND` or wrap `cd` — and wrapping `cd` misses `pushd`/`popd`, and misses zoxide, whose `z` calls `builtin cd` and so bypasses a `cd` function.
- **bash is the fallback shell here.** `~/.bashrc` ends with `exec fish` for interactive shells. Interactive bash is reached only through the `FISH_LAUNCHED` sub-shell, `ssh`, `sudo -s`, or a machine without fish.
- **fish will not autoload an event handler.** Verified: a function carrying `--on-variable PWD` placed in `functions/` is never registered. Any hook has to be sourced from `conf.d/`, which is what `fish-startup-files` already prescribes for a new kind of setting given its own file.
- **The prompt is already done.** `_tide_item_python` renders on `VIRTUAL_ENV` and resolves `.venv` to its parent directory name; `_tide_item_direnv` is already in `tide_right_prompt_items`; tide sets `VIRTUAL_ENV_DISABLE_PROMPT` universally.

## Goals / Non-Goals

**Goals:**

- One declaration per project, read identically by both shells.
- The set of environment variables a project contributes is data this configuration writes, not code the project supplies.
- Nothing in the tracked configuration is machine-specific, and nothing machine-specific becomes tracked.

**Non-Goals:**

- Detecting environments by name other than `.venv`, or supporting poetry/pdm/conda layouts. `layout_venv` can grow later; nothing here forecloses it.
- Creating a virtual environment that does not exist. A missing one is reported, not built.
- A shorthand for writing and approving an `.envrc`. It would sit with the other abbreviations in `conf.d/aliases.fish` and is a separate concern from the activation behaviour; left out so this change stays one subject.
- Any behaviour for non-interactive shells.

## Decisions

### direnv, over the tools that match the ask more literally

`pyautoenv` and `pyruve` activate a `.venv` on `cd` with no per-project file — closer to the original request. Neither survives inspection:

| | packaged | bash hook | last activity | executes project code |
|---|---|---|---|---|
| direnv 2.37.1 | Arch `extra` | `PROMPT_COMMAND` | current | only what `.envrc` says, after approval |
| pyautoenv | no | redefines `cd` | Oct 2025 | yes, unconditionally |
| pyruve | cargo only | — | 13 commits total | yes, unconditionally |
| fish plugins | — | none — fish only | — | yes |

`mise` was considered and rejected for the same reason as direnv's per-project cost without direnv's advantages here: it also requires a `mise.toml`, and brings a version manager this configuration does not otherwise want.

The tools that need a marker file need one deliberately. Auto-sourcing whatever `.venv/bin/activate` a directory happens to contain is the behaviour direnv exists to gate. The per-project `.envrc` is not overhead that direnv failed to remove — it is the trust boundary.

### `layout_venv` declares variables; it does not source `activate`

The helper sets `VIRTUAL_ENV` and calls `PATH_add`. It does not `source .venv/bin/activate`.

Two things follow. Nothing the project ships is executed even inside direnv's own subprocess, which is the stronger form of the property the approval gate already gives. And the shell dialect stops mattering: direnv computes an environment diff and applies it, so there is no `activate` vs `activate.fish` branch anywhere, and a `.venv` built on a machine whose Python omitted `activate.fish` still works in fish.

What is given up: the `pydoc` alias, `VIRTUAL_ENV_PROMPT`, and any hook a non-stdlib venv tool writes into its activate script. None is in use, and `VIRTUAL_ENV_PROMPT` is unread because tide derives its label from `VIRTUAL_ENV` directly.

### `layout venv` as the call, `layout_venv` as the definition

direnv's stdlib pairs `layout <type>` with a `layout_<type>` function and `use <program>` with `use_<program>`. A virtual environment is a project layout in that vocabulary, and the name reads correctly beside the built-in `layout python`, which builds `.direnv/python-$version` rather than using the project's own `.venv` — ours is the one that uses `.venv`.

The dispatch from `layout <type>` to `layout_<type>` is stdlib behaviour rather than something `direnv-stdlib(1)` states outright. If it ever changes, the helper becomes a plain function called by its own name and each `.envrc` loses one word. Sourcing custom code from `direnvrc` is documented; only the dispatcher is inferred.

### Hook placement

| | where | why |
|---|---|---|
| fish | new `conf.d/direnv.fish`, own `status is-interactive` guard | `fish-startup-files` gives a new kind of setting its own file and requires the guard to live in it. `conf.d/tide.fish` is the precedent for a file outside the four named categories. |
| bash | `~/.bashrc`, after the non-interactive early return, before `exec fish` | Prompt-driven, so it belongs after the return per `shell-environment`. Before the `exec`, since that line is last and nothing after it runs. |

### `direnvrc` is tracked; approvals are not

`.gitignore` gains `!/.config/direnv/direnvrc` — the file, not `/.config/direnv/**`. direnv keeps approvals in `$XDG_DATA_HOME/direnv/allow`, already covered by the existing `.local/` denylist, but the narrow allowlist entry means the tracked set is correct even on a direnv old enough to keep them under `$XDG_CONFIG_HOME/direnv/`.

Approval records are keyed to the content of the `.envrc`, so an edit revokes the approval and the file has to be approved again. That is the property the spec's "approval is required again after an edit" scenario rests on.

## Risks / Trade-offs

- **`direnv allow` becomes a reflex, and the gate stops gating.** → The one-word `.envrc` helps: a project whose `.envrc` is anything other than `layout venv` is visibly not the ordinary case and is worth reading. The gate is only as good as the habit; nothing in the configuration can enforce that.
- **Per-project friction on every new project.** → `echo 'layout venv' > .envrc && direnv allow`, once. Accepted deliberately; see the decision above.
- **The `layout_<type>` dispatch is not documented.** → Fallback is a plain `direnvrc` function called by name; each `.envrc` changes by one word. Low cost, and the failure is loud rather than silent.
- **direnv's fish hook registers on `fish_prompt` as well as `PWD`, and tide runs with `tide_prompt_transient_enabled true`.** → Verify at implementation that transient prompt redraw does not re-fire the hook or produce duplicate output. Both are widely used together, so this is a check rather than an expected problem.
- **Existing shells keep the leaked `VIRTUAL_ENV` from before this change.** → Not repaired by the hook, which only restores state it captured. New shells are clean; existing ones need `exec fish` or a `deactivate`.
- **A machine without direnv silently gets no activation.** → Accepted, and specified: hand activation is the documented behaviour there, and `README.md` names the install command.

## Migration Plan

1. `pacman -S direnv` on this machine.
2. Add the tracked files and the two hooks, then start a fresh shell of each kind.
3. `cd ~/repos/ycrm`, write `.envrc`, observe the blocked-file message, `direnv allow`, confirm activation and that leaving restores.
4. Confirm the same in bash via `FISH_LAUNCHED=1 bash`.

Rollback is removing the two hooks; `direnvrc` and any `.envrc` become inert without them.
