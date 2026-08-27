## 1. Diagnosis

- [x] 1.1 Confirm which of the named directories exist on this machine, and which `PATH` entries were therefore dead
- [x] 1.2 Confirm `~/.dotnet` exists but holds only sentinels and a cache, making the directory test a false positive for a per-user SDK
- [x] 1.3 Confirm `.profile` re-adds `$HOME/.local/bin` after sourcing `.bashrc`, and that the live `PATH` carried it twice

## 2. Shell configuration

- [x] 2.1 Add a `prepend_path` helper to `.bashrc` that tests for the directory and for an existing entry before prepending
- [x] 2.2 Route the dotnet, bob, cargo and `~/.local/bin` entries through it, keeping the dotnet and bob blocks above the non-interactive early return
- [x] 2.3 Remove the duplicate `~/.local/bin` assignment and order the remaining calls so the previous resolution order is preserved
- [x] 2.4 Guard `DOTNET_ROOT` on `-x "$HOME/.dotnet/dotnet"` rather than on the directory
- [x] 2.5 Give `.profile`'s `$HOME/bin` and `$HOME/.local/bin` blocks the same dedupe check, written out rather than calling the helper
- [x] 2.6 Apply the same binary test to `.profile`'s dotnet block

## 3. Verification

- [x] 3.1 Confirm `bash -n` and `sh -n` both pass on the edited files
- [x] 3.2 Confirm sourcing `.bashrc` twice in one shell leaves `PATH` unchanged after the second pass
- [x] 3.3 Confirm a login shell carries `~/.local/bin` exactly once
- [x] 3.4 Confirm `DOTNET_ROOT` is unset on this machine and `dotnet --version` still reports the system SDK
