## Why

The change that added the Bluetooth and Wi-Fi menus left four files on disk and out of the repository: `bluetooth.desktop` and `wifi.desktop` under `.local/share/applications`, and the two icons they name under `.local/share/icons`. They are what makes the menus reachable — without them the scripts exist and nothing opens them — and its own Impact section recorded them as an open gap rather than closing it.

The reason given was correct as far as it went. Block 4 of `.gitignore` ignores `.local/` wholesale, and git will not re-include a file whose parent directory is excluded, so the block 3 entry the ignore policy prescribes is not outranked by block 4 — it is never consulted. The file's own header says not to loosen block 4, and the change honoured that.

What the header is protecting is narrower than what it was read as protecting. Block 4 holds two lists with different jobs: a secret denylist, where loosening anything is a security failure, and a bulk list whose entries are there to keep the repository small and `git status` fast. `.local/` is on the bulk list. The spec states this too, in two requirements that never meet: `Security denylist overrides the allowlist` and `Bulk and machine-local trees are excluded`. Refusing to narrow a size rule for four files totalling 20 KB is not caution; it is treating both lists as though they were the secret one.

There is a second problem, and it is a live breach rather than an omission. `dotfiles-ignore-policy` requires that no tracked file a different environment must reuse verbatim names this machine's home directory — the repository has an archived change whose entire purpose was rewriting one such literal to `$HOME`, and a task in the change that created the repository verifies the property holds. Both new desktop entries carry `Exec=/home/gmteixeira/.config/fuzzel/fuzzel-…`, and the bar's two click handlers, which are tracked and were committed, carry the same path. A desktop entry cannot say `$HOME`: `$` is a reserved character in `Exec` and the field takes an absolute path or a command name. So closing the tracking gap and fixing the breach are the same piece of work — the entries can only be tracked once they stop naming this machine.

## What Changes

- `.gitignore` gains a fifth block, after block 4, re-including three directories inside `.local/` and six files within them. Each ancestor is re-included and its contents immediately re-excluded, so opening `.local/` to reach 20 KB does not open the 2.2 GB beside it, and does not make git descend into `.local/share/keyrings`.
- The header's four-block description becomes five, and its instruction is narrowed from "never loosen block 4" to never loosening block 4's secret half, with the reason block 5 has to exist at all — that a block 3 entry inside a bulk-ignored tree is unreachable rather than outranked.
- The two desktop entries, the two icons, and two symbolic links are tracked.
- The desktop entries' `Exec` becomes the bare command name, and the bar's two click handlers become the same. Both then depend on `.local/bin` being on `PATH`, which `shell-environment` already requires and `.profile` already does.
- The symbolic links in `.local/bin` become tracked files with relative targets rather than untracked ones with absolute targets. They stop being derived the moment something names the scripts by command name rather than by path.
- `dotfiles-ignore-policy` gains a requirement governing when a carve-out inside a bulk tree is allowed, and its bulk-exclusion requirement is restated so that `.local/` is no longer described as ignored in its entirety.
- `radio-management` gains a requirement that the menus are reproducible from tracked files alone.

## Capabilities

### New Capabilities

<!-- None. Both capabilities already exist. -->

### Modified Capabilities

- `dotfiles-ignore-policy`: The spec describes block 4 as a single denylist and lists `.local/` among directories that are ignored outright, which is no longer true. It gains a requirement stating what a carve-out may do — narrow the bulk half only, name every path it opens, and exist only where the path cannot be moved somewhere the allowlist already reaches — and its bulk requirement is restated to match the file.
- `radio-management`: The capability says what the menus do and nothing about whether a second machine could have them. Its own change shipped with a third of its files untracked, so this is worth stating rather than assuming: everything the menus need is tracked, and nothing tracked names the machine it was written on.

## Impact

- `.gitignore` — a new block 5 of 20 pattern lines and 6 allowlist entries, and an amended header. Blocks 1 through 4 are unchanged; the secret half of block 4 is untouched.
- `.local/share/applications/bluetooth.desktop`, `.local/share/applications/wifi.desktop` — now tracked, `Exec` changed to a bare command name.
- `.local/share/icons/hicolor/scalable/apps/fuzzel-bluetooth.svg`, `fuzzel-wifi.svg` — now tracked.
- `.local/bin/fuzzel-bluetooth`, `.local/bin/fuzzel-wifi` — now tracked symbolic links, retargeted from `/home/gmteixeira/.config/fuzzel/…` to `../../.config/fuzzel/…`.
- `.config/waybar/config.jsonc` — two `on-click` values shortened to the bare command name. This removes the last two occurrences of `/home/gmteixeira` this session's work introduced into tracked files.
- `.local/share/applications/claude-code-url-handler.desktop` and `mimeapps.list` sit in a directory block 5 now opens and remain ignored, because block 5 names files rather than admitting a directory's contents. `.claude/settings.json` still carries an absolute path to a hook; it predates this change and is not touched by it.
- Behaviour: none. The menus open from the same places by the same keys and clicks. What changes is that a clone into a differently named home directory gets working menus instead of two scripts nothing invokes.
