## Why

Entering a project prints two lines that are never read:

```
❯ cd repos/ycrm/
direnv: loading ~/repos/ycrm/.envrc
direnv: export +VIRTUAL_ENV ~PATH
```

They report that the ordinary thing happened. Every `cd` into a project with an approved `.envrc` produces them, and the state they announce is already on screen: the prompt names the environment and its interpreter version, and `python` resolves to it. So the lines are noise on the success path — and worse than idle noise, because they occupy the two lines directly above the prompt, which is where a message that does need reading would appear. Output that is present every single time is output nobody reads, including on the run where it says something new.

What does need reading is the failure path: an `.envrc` that has not been approved on this machine, and a `layout venv` naming a `.venv` that is not there. Both are conditions the shell cannot act on and the person must.

## What Changes

- Silence direnv's routine status output. Entering, moving within, and leaving a project with an approved, working declaration SHALL produce no output at all.
- Keep every error. A blocked `.envrc` still prints the line naming it and the `direnv allow` that approves it; a `layout venv` with no `.venv` still prints the line naming the path it looked for. These are `log_error`, which the filtering does not touch.
- Add `.config/direnv/direnv.toml` as tracked configuration, alongside the `direnvrc` already there, so the setting travels with the repository rather than being re-set per machine.

## Capabilities

### New Capabilities

<!-- none. -->

### Modified Capabilities

- `python-venv-activation`: adds a requirement that activation is silent on the success path. The capability already requires that the two failure conditions be reported; it said nothing about the ordinary case, which is how routine output came to sit above every prompt.

## Impact

- `.config/direnv/direnv.toml` — new tracked file, one setting.
- `.gitignore` — one allowlist entry for the new file. This is an application of the existing allowlist rule, not a change to it, so `dotfiles-ignore-policy` needs no delta.
- `.config/direnv/direnvrc` is untouched. Its `log_error` call is what reports a missing `.venv`, and that path stays loud.
- `.config/fish/conf.d/direnv.fish` is untouched. The hook still installs the same way, and bash is unaffected in the same direction — the setting is direnv's own, not a shell's, so both shells go quiet together.
- `README.md` — the software list already names direnv; whether the new file needs a mention is a documentation question settled during implementation, not a behaviour change.
