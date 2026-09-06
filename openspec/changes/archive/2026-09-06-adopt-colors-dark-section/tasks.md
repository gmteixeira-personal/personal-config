## 1. The section

- [x] 1.1 Rename `[colors]` to `[colors-dark]` in `.config/foot/foot.ini`; verify with `grep -n '^\[colors' .config/foot/foot.ini` that `[colors-dark]` is the only colour section and that no `[colors]` or `[colors-light]` heading remains
- [x] 1.2 Verify `foreground=aaaaaa` and the comment above it explaining foot's own `839496` default are byte-for-byte unchanged, so this change touches the heading and nothing the heading governs
- [x] 1.3 Add the comment under the heading naming foot 1.27 as the version that split `[colors]` into `[colors-dark]` and `[colors-light]`, and `initial-color-theme` as the setting that selects between them, defaulting to `dark`
- [x] 1.4 Verify `initial-color-theme` is not set in `[main]`, so the documented default of `dark` is what actually applies rather than an override this comment would misdescribe
- [x] 1.5 Verify every other section — `[main]`, `[cursor]`, `[mouse]`, `[csd]` — is untouched, and in particular that the `shell=` line the terminal-emulator spec requires is unchanged

## 2. Applying and checking

- [x] 2.1 Run `foot --check-config` and verify it reports the configuration valid with no deprecation line
- [x] 2.2 Verify `foot --check-config` is sensitive to the heading at all, by running it against a copy of the file with the old `[colors]` name and confirming it reports `[colors]: deprecated; use [colors-dark] instead` — a silent check on the new file proves nothing unless the check is known to speak up on the old one
- [x] 2.3 Start a standalone `foot` — not a client, so it reads the tracked file fresh rather than inheriting the running server's reading — and verify it opens with no deprecation notice on stderr
- [ ] 2.4 Restart the server with `systemctl --user restart foot-server.service`, then open a terminal with `Mod+T` and verify the prompt is the first line and uncoloured text renders at its usual intensity. Left for the operator: the restart closes every open foot window at once, this change was made from inside one, and the standalone start above already proves what the restarted server will read

## 3. Documentation

- [x] 3.1 Verify `README.md` needs no change — its one mention of a `[colors]` section is fuzzel's, and it does not describe foot's foreground
- [x] 3.2 Verify `.gitignore` needs no change — `.config/foot/foot.ini` is already allowlisted and tracked

## 4. Close-out

- [x] 4.1 Run `openspec validate adopt-colors-dark-section --strict` and verify it passes
- [x] 4.2 Verify `git status` names only `.config/foot/foot.ini` and the change's own files among the paths to be staged, then commit
