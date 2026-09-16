## Context

See proposal.md — Why. The constraints that shape the approach:

- Neovide is installed with `cargo install --git`, which copies out the binary and leaves the upstream repository's assets behind. There is no packaged desktop entry, no icon, and no default configuration to override — only files this repository writes.
- The repository is `$HOME` under a deny-by-default ignore policy. A new tracked file needs an allowlist entry before git will see it at all.
- The comparison target is foot, configured in `.config/foot/foot.ini` with `font=JetBrainsMono Nerd Font Mono:size=11` and `pad=8x8`.
- foot rasterizes through FreeType and inherits fontconfig; Neovide rasterizes through Skia and inherits nothing. `fc-match -v` reports this machine's answer as `hintstyle: 1` — hintslight — with `antialias: True` and no `rgba` subpixel order.
- Neovide's own `config.toml` is read for some settings and silently ignores tables it does not know, so an unsupported setting there fails without saying so.

## Goals / Non-Goals

**Goals:**

- One route in — the launcher — with the entry tracked, so a checkout reproduces it.
- Two windows showing the same buffer that read as one program.
- Every value that restates another file's value says so in its own comment, since nothing enforces the pairing.

**Non-Goals:**

- A MIME association. `nvim-foot.desktop` remains the handler for text, through `.config/mimeapps.list`, and nothing here competes with it.
- Shipping an icon. The packaged Neovim icon is already in the hicolor theme.
- Matching foot to the pixel. The cell width differs by about 2% for a reason no setting reaches; see Risks.
- The Neovim message-UI change. It belongs to the Neovim configuration's own OpenSpec project.

## Decisions

**The entry lives in `.local/share/applications/`, not in `.config/`.** That is the XDG path a launcher reads and the only one it reads; `yazi.desktop` and `nvim-foot.desktop` are already there for the same reason. The ignore file's block 5 already reaches into that directory, so the entry needs one line rather than a new carve-out.

**`Terminal=false` with a bare `Exec`, against `yazi.desktop`'s shape.** yazi is a terminal program and has to be given a terminal; Neovide draws its own window. `TryExec=neovide` rather than an absolute path: `~/.cargo/bin` is already on the path the session runs with, and an absolute path would hard-code an install location that differs per machine.

**`Icon=nvim`, not a downloaded Neovide icon.** Neovide's own icon is not installed and fetching one would add an untracked binary to a repository whose policy is to track what it ships. The packaged Neovim icon is present, correct and already in the theme. Naming a name no theme provides would leave the entry blank.

**Font settings in `.config/neovide/config.toml`, mirroring `foot.ini`.** The alternative was `vim.o.guifont` in the Neovim configuration, which is the canonical Neovim interface and would put a GUI setting into the editor's own configuration. Keeping it in Neovide's file makes the pairing with `foot.ini` legible — two files, one value each, each naming the other.

**`hinting` and `edging` stated explicitly.** Verified against the metrics rather than by eye: the grid is unchanged at 108x52 with the keys added, so they change rasterization and nothing else. Leaving them out is what made the same glyph come out bolder than foot's.

**Padding in `.config/nvim/lua/config/options.lua`, guarded by `if vim.g.neovide`.** Not a preference. A `[padding]` table in `config.toml` is accepted and then ignored — measured: the grid does not change — and `vim.g.neovide_padding_*` is the only interface the program exposes. The choice was between a guarded four-line block in the Neovim configuration and losing the setting, and the block is annotated on both ends so neither file is a dead end for the reader.

**8 on every side, because `foot.ini` says `pad=8x8`.** Measured in one 957x1052 niri tile: Neovide goes from 108x52 to 106x51, and foot reports 104x51. The row count matches and the grid area is foot's 941x1036 exactly.

## Risks / Trade-offs

- **The two font settings are a pair with nothing enforcing it.** Changing `foot.ini` silently leaves Neovide behind. → Each file's comment names the other and says the values are halves of one setting. There is no better mechanism; the formats have no shared include.
- **Neovide still fits two more columns than foot, 106 against 104.** foot rounds its cell width up to a whole pixel and Neovide does not, so Neovide's cells are about 2% narrower. → No setting reaches it; recorded in the comment so it is not rediscovered as a fault.
- **A GUI-specific branch now exists in the Neovim configuration**, which `options.lua` opens by declaring it holds general editor options. → One guarded block, with the comment stating that it is the exception and why the setting cannot live with the rest of them.
- **`config.toml` ignores what it does not understand.** A future setting added there may do nothing and say nothing. → The padding comment records this as observed behaviour rather than as a guess, so the next reader tests before trusting the file.
