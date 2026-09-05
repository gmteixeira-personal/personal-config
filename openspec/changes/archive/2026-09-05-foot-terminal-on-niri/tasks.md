## 1. Terminal server

- [x] 1.1 Enable the `foot-server.socket` and `foot-server.service` user units and verify `systemctl --user is-enabled` reports both enabled
- [x] 1.2 Start the socket in the running session and verify the foot socket appears in the runtime directory

## 2. Compositor binding

- [x] 2.1 Point the compositor's terminal binding at `footclient` and update its hotkey-overlay title to name foot, verifying `niri validate` accepts the file
- [x] 2.2 Verify no binding in the compositor configuration still names alacritty

## 3. Session startup

- [x] 3.1 Add an autoloaded fish function so a bare `niri` execs `niri-session` while any argument form runs `command niri`, and verify `niri --version` still reports the binary's version
- [x] 3.2 Verify the function file parses with `fish -n`

## 4. foot configuration

- [x] 4.1 Create `.config/foot/foot.ini` naming fish explicitly as the shell, and verify `foot --check-config` accepts it
- [x] 4.2 Record in that file that the server reads it only at startup, naming the restart command, and verify the statement is present in the file

## 5. fish completions

- [x] 5.1 Install openspec's completions from its own generator and verify `complete -C 'openspec '` offers its subcommands
- [x] 5.2 Populate the manual-page-derived completion cache with `fish_update_completions` and verify a tool covered only by it, such as `playerctl`, completes its options
- [x] 5.3 Write completions for `waybar` and `npx` from their `--help` output, each recording why it was hand-written, and verify `complete -C '<tool> -'` returns options rather than filenames for both
- [x] 5.4 Give the npx completion a helper that offers executables from the nearest `node_modules/.bin`, and verify it resolves from both a project root and a nested subdirectory

## 6. Tracking

- [x] 6.1 Add allowlist entries for `.config/foot/foot.ini` and `.config/niri/config.kdl`, and verify `git check-ignore -v` reports an allowlist rule rather than the deny-by-default `*` for each
- [x] 6.2 Add allowlist entries naming `.config/fish/completions/waybar.fish` and `npx.fish` individually, and verify `openspec.fish` in the same directory remains ignored
- [x] 6.3 Extend the ignore file's fish comment to record why two completions are named there while the directory stays machine-local, and verify the comment reads correctly against the entries below it
- [x] 6.4 Stage the newly allowlisted files and verify `git status --short` lists each of them and no manual-page-derived completion
