## Why

The Neovim configuration has its own OpenSpec workspace at `.config/nvim/openspec/`, holding 28 capabilities and 34 archived changes. Two Neovim capabilities were nevertheless written into the home workspace at `openspec/specs/`:

- `nvim-markdown-rendering` — how a markdown buffer is displayed
- `nvim-scrolling` — where the cursor sits vertically as a buffer scrolls

Both describe `.config/nvim/` and nothing else; their proposals list only files under `.config/nvim/` in Impact. They are here because the change was proposed from `~`, and `openspec` resolves the *nearest* workspace from the working directory. The `nvim-` prefix on both names is the tell: no capability in the Neovim workspace carries one, because there it would be redundant.

The split has already produced a contradiction. `.config/nvim/openspec/specs/editor-options/spec.md` still requires:

> The editor SHALL keep at least eight lines visible above and below the cursor

while `openspec/specs/nvim-scrolling/spec.md` requires the cursor to be held at the middle of the window, and `lua/config/options.lua` sets `scrolloff = 999`, which is the centered behaviour. The Neovim workspace has stated a requirement its own configuration has not met since 2026-08-27, and the spec that superseded it is invisible from there.

## What Changes

- Move both capabilities into the Neovim workspace, renamed to that workspace's convention — `nvim-markdown-rendering` becomes `markdown-rendering`, `nvim-scrolling` becomes `scrolling`. The requirement text is carried over unchanged.
- Retire both capabilities from the home workspace, so each capability has exactly one home.
- Resolve the contradiction: drop the superseded eight-line scrolloff requirement from the Neovim workspace's `editor-options`, which the relocated `scrolling` capability now covers and has covered in the configuration since August.
- Move the two archived changes that produced these specs into the Neovim workspace's archive, so a capability's planning history sits beside the capability.
- Delete the caveat the split forced into `README.md`. Its "Where the detail lives" section currently tells the reader that two Neovim capabilities are specified from the root workspace and to "check both places before concluding a behaviour is unspecified" — a sentence that exists only because of this misfiling and becomes false once it is corrected.
- Tighten the requirement that governs that section, so the Neovim workspace is named as the *only* place its detail lives. A Neovim capability found specified elsewhere is to be relocated, not documented as an exception. The README's Neovim section is written from that workspace's specs, and after this change every capability it summarises is in it.
- Nothing is added to route future proposals. Keeping Neovim work in the Neovim workspace is handled by hand from here on; this change only corrects what is already misfiled.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities
- `dotfiles-repo`: the requirement governing the documented Neovim section gains the rule that `.config/nvim/openspec/specs/` is the only location the documentation may name for per-capability detail.
- `nvim-markdown-rendering`: every requirement removed from the home workspace; the capability continues unchanged as `markdown-rendering` in the Neovim workspace.
- `nvim-scrolling`: every requirement removed from the home workspace; the capability continues unchanged as `scrolling` in the Neovim workspace.

## Impact

- `openspec/specs/nvim-markdown-rendering/`, `openspec/specs/nvim-scrolling/` — retired. Archiving this change deletes both, which requires `retire_capabilities: true` in this change's `.openspec.yaml`; without it `openspec archive` refuses with "Spec must have at least one requirement" and writes nothing.
- `.config/nvim/openspec/specs/markdown-rendering/spec.md`, `.config/nvim/openspec/specs/scrolling/spec.md` — new, carrying the moved text.
- `.config/nvim/openspec/specs/editor-options/spec.md` — loses one requirement and its two scenarios.
- `openspec/changes/archive/2026-08-27-add-nvim-scrolloff-center/`, `openspec/changes/archive/2026-08-31-add-markdown-rendering/` — moved under `.config/nvim/openspec/changes/archive/`, contents untouched.
- `README.md` — the closing paragraph of "Where the detail lives" is removed; the sentence naming `.config/nvim/openspec/` as authoritative stays. Nothing else in the Neovim section changes: the conventions it states that came from the two moved capabilities — the cursor held at the vertical middle of the window, `render-markdown` drawing markdown as formatted text — remain true, and only the workspace they are specified in moves.
- No Neovim behaviour changes. No `.lua` file is touched: `scrolloff` is already 999 and the markdown plugin is already installed. This change moves and reconciles descriptions of behaviour that already exists.
- No `.gitignore` change. `!/openspec/**` and `!/.config/nvim/**` already cover every path involved.
