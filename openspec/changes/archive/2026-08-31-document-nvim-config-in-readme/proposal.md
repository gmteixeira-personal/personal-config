## Why

The README's `## Neovim` section points a reader at
`https://github.com/gmteixeira-personal/nvim-config` for the configuration's
independent history. That repository has been deleted, so the section's only
substantive content is a dead link — and the section says nothing at all about
what the tracked `.config/nvim/` tree actually configures. A reader arriving at
the one part of this repository large enough to need an orientation is given a
404 instead of one.

## What Changes

- Remove the reference to the deleted `nvim-config` remote from the README's
  `## Neovim` section. The absorption is a settled fact of this repository's
  history; a recovery path that no longer exists is not worth recording.
- Replace it with a description of what the tracked Neovim configuration
  contains: its load order and file layout, the plugin manager and how a fresh
  machine gets its plugins, the editor conventions that are set globally, the
  keymap families, and the plugins grouped by the job they do.
- Point the reader at `.config/nvim/openspec/specs/` as the authoritative
  per-capability detail, so the README stays an orientation rather than a second
  copy of twenty-seven specifications that will drift from the first.
- Add a `dotfiles-repo` requirement fixing both properties, so the section
  cannot silently regress to a stale pointer and cannot be left behind when the
  Neovim configuration changes shape.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-repo`: adds a requirement that the tracked repository documentation
  describe the Neovim configuration it carries and reference no retired remote.

## Impact

- `README.md` — the `## Neovim` section is rewritten; every other section is
  untouched.
- `openspec/specs/dotfiles-repo/spec.md` — gains one requirement when this
  change is archived.
- No code, no shell configuration, and no Neovim file changes. The
  `.config/nvim/` tree is the subject of the documentation, not a target of it,
  and its own OpenSpec workspace under `.config/nvim/openspec/` is unaffected.
