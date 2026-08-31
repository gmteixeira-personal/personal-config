## Why

zoxide was removed from this machine because it was not being used and carried more upkeep than it earned, but the removal was never recorded and was never verified end to end. A running fish session still holds the `__zoxide_hook` function it defined before the binary went away, so every directory change prints an error before the real prompt work happens:

```
fish: Unknown command: zoxide
- (line 39):
    and command zoxide add -- (__zoxide_pwd)
                ^~~~~^
in function '__zoxide_hook' with arguments 'VARIABLE SET PWD'
```

Nothing in the tracked configuration asks for zoxide any more, so a fresh shell is already clean. What is missing is the record: without a requirement stating that zoxide is retired and what must be absent, the tool can drift back in through a stale init line, an allowlist entry, or a state directory nobody thought to remove — exactly the failure mode the `retired-tooling` capability exists to prevent.

## What Changes

- Record zoxide as retired under the existing `retired-tooling` capability, stating what must be absent: no tracked configuration, no shell initialization line in fish or bash, no allowlist entry, no installed package, and no leftover state, cache, or data directory.
- Verify the retirement against the machine and the repository rather than assuming it: confirm no tracked file names zoxide, no `zoxide init` line remains in any startup file, the binary is not on `PATH`, the package is not installed, and no `zoxide` directory survives under `.config/`, `.local/share/`, or `.cache/`.
- Clear the stale hook from the affected live fish session by restarting it, so the error stops appearing without editing any configuration.
- No change to how directories are entered: `cd`, the fish `cd` builtin, and the `mkcd` function keep working exactly as they do now. This retires a tool, not a capability.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `retired-tooling`: adds a requirement that zoxide is retired, with scenarios covering tracked configuration, shell startup files, the allowlist, package installation, leftover state on the machine, and the deliberate act required to bring it back.

## Impact

- `openspec/specs/retired-tooling/spec.md` — gains one requirement alongside the existing lazygit one.
- Shell startup files (`.config/fish/conf.d/`, `.bashrc`) — inspected for a `zoxide init` line; the investigation so far found none, so the expected outcome is verification rather than edits.
- The running fish session that prints the error — resolved by restarting the shell, not by a tracked change.
- No dependency, alias, or key binding changes. `fisher` plugins, fzf integration, and direnv behavior are untouched.
