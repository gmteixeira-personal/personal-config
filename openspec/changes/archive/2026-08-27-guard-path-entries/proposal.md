## Why

`.bashrc` named four per-machine install locations unconditionally — `~/.dotnet` and its tools directory, bob's `nvim-bin`, `~/.cargo/bin`, and `~/.local/bin` — and `.profile` re-added its own copies of two of them after sourcing `.bashrc`. This repository is one configuration for every environment, so those paths describe how the machine it was written on happened to install its tools, not how the next one will.

On a machine that installs those tools from its package manager instead, the result was four `PATH` entries pointing at directories that do not exist, `~/.local/bin` named twice, and a second copy of everything on a login shell. Re-sourcing the file grew `PATH` again each time.

One of them was not merely inert. A system-packaged dotnet creates `~/.dotnet` on first run to hold its first-use sentinels and a corefx cache, so the directory exists on a machine with no per-user SDK at all — and `DOTNET_ROOT` was pointing at it, overriding the correct root with one that holds no runtime.

Deleting the entries would have been the wrong fix: the machines where bob, rustup, or a per-user SDK are the real installation still need them.

## What Changes

- Add a helper in `.bashrc` that prepends a directory to `PATH` only when it exists, and only when it is not already there.
- Route every per-machine entry through it, preserving the order the entries previously produced.
- Test for `~/.dotnet/dotnet` rather than for the `~/.dotnet` directory before exporting `DOTNET_ROOT`, so a system-packaged dotnet keeps locating its own root.
- Give `.profile`'s own `$HOME/bin` and `$HOME/.local/bin` blocks the same duplicate check, and the same binary test for dotnet, so a login shell does not undo the fix.

## Capabilities

### Modified Capabilities

<!-- None. -->

### New Capabilities

- `shell-environment`: what a shell exports about the machine it is running on — how `PATH` is composed from per-machine install locations, and when a tool-root variable such as `DOTNET_ROOT` is named at all.

## Impact

- `.bashrc` and `.profile` only. No tool is installed, removed, or relocated by this.
- `PATH` on the current machine loses four dead entries and one duplicate; `DOTNET_ROOT` becomes unset here, and `dotnet` resolves its own root as it should.
- Sourcing either file repeatedly is now idempotent, where it previously grew `PATH` on each pass.
- A directory created after a shell started is not picked up until that shell re-sources the file. That is the cost of testing at source time and is accepted.
