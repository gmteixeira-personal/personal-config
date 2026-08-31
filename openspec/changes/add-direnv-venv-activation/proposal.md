## Why

A Python virtual environment activated in a project directory outlives leaving it: `VIRTUAL_ENV` and the `PATH` entry stay set until the shell ends, so `python` in an unrelated directory silently resolves to another project's interpreter. This home directory is in that state right now — `VIRTUAL_ENV` names `~/repos/ycrm/.venv` while the working directory is `~`.

Entering a project should activate its environment and leaving it should undo that, in both shells this configuration supports, without the shell executing code it found in a directory it happened to walk into.

## What Changes

- Adopt `direnv` as the mechanism. It is packaged in Arch `extra`, hooks officially into both bash and fish, walks up parent directories for its marker file, and restores the exact environment it captured on entry. The prompt already accounts for it: `_tide_item_direnv` is in `tide_right_prompt_items`.
- Add a tracked `~/.config/direnv/direnvrc` defining a `layout_venv` helper. It declares `VIRTUAL_ENV` and prepends the virtual environment's `bin` directory, rather than sourcing the environment's own `activate` script — so no project-supplied code runs, in any shell. A missing `.venv` is reported in one line.
- Hook direnv into fish from a new `~/.config/fish/conf.d/direnv.fish`, carrying its own interactivity guard.
- Hook direnv into bash from `~/.bashrc`, after the non-interactive early return and before the `exec fish` at the end of that file.
- Allowlist `~/.config/direnv/direnvrc` in `.gitignore`. direnv's approval state under `~/.local/share/direnv/allow/` stays ignored: it records which `.envrc` files a person approved on one machine, and carrying those approvals to a clone would grant trust nobody granted there.
- Name direnv's install command in `README.md`, alongside the other machine-level tools the bootstrap already lists.
- No fallback for machines without direnv. With direnv absent the hooks do nothing and environments are activated by hand, which is the behaviour today.

Per project, once: `echo 'layout venv' > .envrc && direnv allow`.

## Capabilities

### New Capabilities

- `python-venv-activation`: entering a directory whose tree contains a Python virtual environment puts that environment on `PATH`, leaving it takes it back off, the same way in bash and fish; a directory's environment takes effect only after it has been approved on that machine; and no project-supplied script is executed to make any of it happen.

### Modified Capabilities

- `dotfiles-ignore-policy`: adds a rule that a tool's per-machine approval or trust state is never tracked. The existing derived-state rule ignores what a tool can rebuild from a tracked declaration; approval state is the opposite case — it must not be reproducible on another machine, because reproducing it would grant trust that was never given there.

## Impact

- **New tracked files**: `.config/direnv/direnvrc`, `.config/fish/conf.d/direnv.fish`
- **Modified tracked files**: `.bashrc`, `.gitignore`, `README.md`
- **New machine-level dependency**: `direnv` (Arch `extra`, currently 2.37.1). Absent, the configuration still loads and does nothing.
- **Untracked, per machine**: `~/.local/share/direnv/allow/`, and each project's own `.envrc`.
- **Not affected**: the prompt, which already renders the active environment through `_tide_item_python` and `_tide_item_direnv`; and non-interactive shells, which gain nothing from this change.
