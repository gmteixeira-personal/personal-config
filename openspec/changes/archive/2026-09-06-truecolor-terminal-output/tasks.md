## 1. Install vivid

- [x] 1.1 Download `vivid-v0.11.1-x86_64-unknown-linux-gnu.tar.gz` from the `sharkdp/vivid` v0.11.1 release and verify its sha256 is `7060e45ba1fc5b25d521704e65d2e5d92c1b219c06b7183ec120a87e1fc376d7`
- [x] 1.2 Install the `vivid` binary from that tarball into `~/.local/bin` and verify `vivid --version` reports `vivid 0.11.1` in a new shell
- [x] 1.3 Confirm nothing of the install is tracked: verify `git status --porcelain` names no path under `.local/`

## 2. The vivid theme

- [x] 2.1 Write `.config/vivid/themes/starlight.yml` with a `colors:` block holding foot 1.27's starlight-V4 values, and a comment recording that they are transcribed from the palette rather than chosen; verify `vivid generate starlight` exits 0
- [x] 2.2 Map `core:` — directory `5dc5f8`, symlink `24dfc4`, executable `35d450`, and the device, setuid, setgid, sticky and other-writable entries — to the same foreground/background pairs today's `LS_COLORS` produces; verify by diffing the decoded colour of each `di ln ex pi bd cd or su sg tw ow st` entry against the current `LS_COLORS`
- [x] 2.3 Map `archives` to `ff4d51`, `media` to `feabf2`, audio to `13c299`, and `unimportant` to `616161`; verify a listing of a directory holding a `.tar.gz`, a `.png`, a `.mp3` and a `file~` renders each in the colour it renders today
- [x] 2.4 Leave `text`, `markup`, `programming` and `office` as `{}` so those files stay the default foreground, and verify `vivid generate starlight` emits no colour for a `.md`, a `.py` and a `.docx`
- [x] 2.5 Add `!/.config/vivid/themes/*.yml` to `.gitignore` and verify `git status --porcelain` now names the theme

## 3. LS_COLORS in fish

- [x] 3.1 Replace the `dircolors -b` + `01;3X` → `01;9X` block in `.config/fish/conf.d/env.fish` with a `type -q vivid` branch that sets `LS_COLORS` from `vivid generate starlight`, keeping the existing `dircolors` build as the else branch; verify `echo $LS_COLORS` in a new fish contains no `;3` or `;9` palette index and every entry is `38;2`
- [x] 3.2 Verify the fallback: with `vivid` shadowed off `PATH`, a new fish still starts silently and `LS_COLORS` is the `dircolors` value including the bright-slot rewrite
- [x] 3.3 Rewrite the comment above the block so it explains naming the colour rather than asking for the bright slot, and states why the fallback keeps the rewrite

## 4. LS_COLORS and the prompt in bash

- [x] 4.1 Apply the same `vivid`-with-`dircolors`-fallback change to `.bashrc`, guarded with `command -v vivid`; verify `bash -ic 'echo $LS_COLORS'` matches what fish reports on the same machine
- [x] 4.2 Change `PS1`'s `01;92` and `01;94` to the hex equivalents `35d450` and `5dc5f8` as `38;2` sequences, keeping the `\[ \]` non-printing wrappers intact; verify the prompt renders in the same colours and that line wrapping on a long command line is unbroken
- [x] 4.3 Update the `LS_COLORS` and `PS1` comments to match, and correct the `COLORTERM` comment's claim that `TERM` is `xterm-256color`

## 5. fish syntax highlighting

- [x] 5.1 Create `.config/fish/conf.d/colors.fish` setting every `fish_color_*` with a colour to its hex equivalent — `comment f62b5a`, `cwd 47b413`, `cwd_root f62b5a`, `end 47b413`, `error ff4d51`, `escape 24dfc4`, `operator 24dfc4`, `param 13c299`, `quote e3c401`, `redirection 13c299 --bold`, `host_remote e3c401`, `status f62b5a`, `user 35d450`, `autosuggestion 616161`, `search_match`/`selection` as `e6e6e6` on `616161` bold — using `set -g`, and leave the attribute-only defaults (`cancel`, `command`, `history_current`, `host`, `normal`, `valid_path`) as they are; verify a new fish shows the same highlighting colours as before
- [x] 5.2 Set the four `fish_pager_color_*` variables on the same basis and verify the completion pager renders unchanged
- [x] 5.3 Verify no colour resolves through the palette: with foot's `regular*`/`bright*` slots temporarily overridden to obviously wrong values, the prompt, the highlighting and a listing SHALL be unchanged

## 6. foot

- [x] 6.1 Correct the `[colors]` comment in `.config/foot/foot.ini`: foot 1.27 defaults to `839496` foreground on `002b36` background, not `dcdccc`; keep `foreground=aaaaaa` and add nothing else to the section
- [x] 6.2 Verify no foot server restart is needed: the only edit to `foot.ini` was comment text, `foreground=aaaaaa` was already in force in the running server, and every other file in this change is read fresh by each new shell rather than by the server

## 7. Documentation and close-out

- [x] 7.1 Add `vivid` to README's **Optional** section, saying what its absence costs — the `dircolors` fallback, palette indices, and silence — and naming the tarball install into `~/.local/bin`; verify the entry follows the shape of the `openspec` CLI and `fzf` entries
- [x] 7.2 Run `openspec validate truecolor-terminal-output --strict` and verify it passes
- [x] 7.3 Verify `git status` shows only the intended paths, then commit
