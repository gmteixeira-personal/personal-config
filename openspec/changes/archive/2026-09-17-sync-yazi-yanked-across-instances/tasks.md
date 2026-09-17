## 1. Turn the sharing on

- [x] 1.1 Write `.config/yazi/init.lua` calling `require("session"):setup { sync_yanked = true }`, and verify `yazi --version` reports 26.9.1 or later so the built-in `session` plugin is present
- [x] 1.2 Add the comment block recording that the whole yank list is shared, that a cut left pending in one window completes on a paste in another, and that `Esc` clears it, and verify the file names `Esc` as the clear
- [x] 1.3 Add the comment recording that the file is read at startup and that already-running windows must be restarted, and verify no comment in the file claims the setting reaches a running instance
- [x] 1.4 Verify the file installs nothing: `.config/yazi/package.toml` is unchanged and `.config/yazi/flavors/` has gained no entry

## 2. Track the file

- [x] 2.1 Add `!/.config/yazi/init.lua` to `.gitignore` block 3 beside `!/.config/yazi/theme.toml`, with its own comment stating what it turns on, and verify `git check-ignore -q .config/yazi/init.lua` exits 1 so the path is no longer ignored
- [x] 2.2 Rewrite the existing yazi comment in block 3 — it says the theme is the only yazi file tracked — so it no longer asserts that, and verify the reasons keeping `flavors/` and `package.toml` ignored are still stated
- [x] 2.3 Verify nothing else was let through: `git status --porcelain` lists `.config/yazi/init.lua` and no other file under `.config/yazi/`

## 3. Verify the behaviour end to end

- [x] 3.1 Drive the checks below against yazi instances started after `init.lua` was written, on their own DDS bus and state dir (`XDG_RUNTIME_DIR`, `XDG_STATE_HOME`), and verify the bus path stays under the 107-byte unix-socket limit — overrun it and yazi creates the directory, no socket, and every instance runs standalone, which makes the whole section pass by proving nothing
- [x] 3.2 Yank a file in one window, paste in the second at another directory, and verify the file arrives there
- [x] 3.3 Cut a file in one window, paste in the second, and verify the file moves rather than copies
- [x] 3.4 Yank in one window, open a third window afterwards, and verify the third can paste that file
- [x] 3.5 Yank a file, close every yazi window on the test bus, open a new one, and verify the yank is still pending — the sharing stores it in `~/.local/state/yazi/.dds` rather than losing it with the last window
- [x] 3.6 Run the same yank against a yazi given no `init.lua`, and verify its `.dds` holds no `@yank`, so the storage is shown to come from this change rather than from yazi's defaults
- [x] 3.7 Verify `init.lua` records the durability: it states that a pending yank survives closing every window and a reboot, names `Esc` as the clear, and names `~/.local/state/yazi/.dds` as where a pending one can be read

## 4. Confirm nothing else moved

- [x] 4.1 Verify `.config/yazi/theme.toml` is unchanged and the status bar renders as before
- [x] 4.2 Verify the launcher still starts yazi from `.local/share/applications/yazi.desktop` with no change to that entry
- [x] 4.3 Verify the verification left nothing pending in the real session: `~/.local/state/yazi/.dds` holds no `@yank` naming a scratch path
