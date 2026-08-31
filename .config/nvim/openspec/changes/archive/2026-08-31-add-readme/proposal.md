## Why

`.config/nvim/` is a self-contained workspace — it carries its own `.gitignore`, its own `.claude/`, and its own OpenSpec workspace — and it is published as part of a public repository, but it has no README. A reader who lands in this directory, whether through the GitHub tree or a fresh clone, finds `init.lua` and thirty plugin files with nothing at the entry point explaining what the configuration does, how it is laid out, or which key does what.

The repository root README carries a Neovim orientation section today, written and maintained by hand from the other side of the boundary. Giving the configuration its own README makes this directory the source of that description, so the root section can later be derived from it rather than being a second document about the same subject that drifts from the first.

## What Changes

- Add `README.md` at the root of the Neovim configuration, describing the setup for someone who has just arrived: what it is, how a fresh machine reaches a working state, the file layout and the load order, the editor conventions that hold regardless of filetype, the keymaps, and the plugins grouped by the job each does.
- Introduce a `documentation` capability that fixes what that README must cover, at what depth, and where it stops — detail beyond the README's level stays in `openspec/specs/`, which the README names as authoritative rather than restating.
- Require that a change which adds, removes, or repurposes something the README names updates the README in the same change, so the description cannot outlive the configuration it describes.

Out of scope, deliberately: the repository-root `README.md` and the home workspace's `dotfiles-repo` spec that governs it. Both live outside this workspace's edit root and are the user's to change separately, so this change leaves the root section untouched and does not depend on it.

## Capabilities

### New Capabilities

- `documentation`: The tracked README at the root of the Neovim configuration — that it exists, what it must describe, the depth it works at, its relationship to `openspec/specs/` as the authoritative source of detail, and the obligation to keep it current as the configuration changes.

### Modified Capabilities

None. No Lua behaviour changes: this change adds a description of the configuration, not a change to it.

## Impact

- **New file**: `README.md` at `.config/nvim/README.md`, tracked (the root `.gitignore` allowlists `/.config/nvim/**`, so no ignore-rule change is needed).
- **New spec**: `openspec/specs/documentation/spec.md`.
- **No code changes**: nothing under `lua/`, `init.lua`, or `lazy-lock.json` is touched.
- **Ongoing obligation**: future changes to plugins, keymaps, or editor-wide conventions acquire a documentation task. Existing specs are unaffected — the README delegates to them and does not duplicate them.
- **Downstream, not in this change**: once this README exists, the home workspace's requirement that tracked documentation describe the Neovim configuration can be rewritten to draw from it.
