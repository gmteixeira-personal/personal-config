## 1. Diagnosis

- [x] 1.1 Confirm which per-user tools live in `~/.local/bin` and `~/.cargo/bin`, verified by listing both directories
- [x] 1.2 Confirm the pre-change `.bashrc` gives a non-interactive shell neither directory, verified by sourcing `git show HEAD:.bashrc` under `env -i` and inspecting `PATH`
- [x] 1.3 Confirm the `bash-completion` loader is absent on this machine, verified by the absence of `/usr/share/bash-completion/bash_completion` and `/etc/bash_completion`, so the eager loop is what makes completions work

## 2. Shell configuration

- [x] 2.1 Move the `~/.cargo/bin` and `~/.local/bin` `prepend_path` calls above the non-interactive early return in `.bashrc`, keeping their relative order, and verify `bash -n .bashrc` passes
- [x] 2.2 Update the comment on that block to say why it sits above the return, matching the wording style of the `~/.dotnet` and bob blocks
- [x] 2.3 Rewrite the literal `/home/gmteixeira` in the `OPENSPEC:START`/`OPENSPEC:END` completion block to `$HOME`, leaving the block below the early return, and verify `bash -n .bashrc` passes

## 3. Verification

- [x] 3.1 Confirm a non-interactive shell sourcing `.bashrc` resolves `openspec`, `claude`, `herdr` and `bob`, verified with `command -v` under `env -i HOME=$HOME bash -c`
- [x] 3.2 Confirm `~/.local/bin` precedes `~/.cargo/bin` in the resulting `PATH`, and that neither appears twice
- [x] 3.3 Confirm a login shell still carries each directory exactly once, verified by `PATH` from `bash -lc` under `env -i`
- [x] 3.4 Confirm a non-interactive shell sources no completion script, verified by the openspec completion function being undefined after sourcing `.bashrc` non-interactively
- [x] 3.5 Confirm an interactive shell defines the openspec completion function and that `openspec` completion is registered, verified with `declare -F` and `complete -p openspec` under `bash -i`
