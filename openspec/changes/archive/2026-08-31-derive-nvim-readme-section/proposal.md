## Why

`~/README.md` carries a 140-line Neovim orientation — layout and load order, editor conventions, keymap families, the plugins grouped by job — written and maintained by hand from outside the directory it describes. `.config/nvim/` has had no README of its own, so the root section had nowhere to draw from and became the only prose description of that configuration anywhere in the repository.

`.config/nvim/openspec/changes/add-readme` is giving the configuration its own `README.md`, written from inside the workspace by whoever changes the configuration. Once it exists, the root section is a second document about one subject, maintained from the wrong side of the boundary and free to drift from the first. It should become a condensation of that README rather than an independent account of the same thing.

A reader who wants only the editor configuration is also poorly served today. The Neovim directory is self-contained — its own `.gitignore`, `.claude/`, and OpenSpec workspace, and `lazy-lock.json` pinning every plugin revision — but nothing in the documentation says it can simply be copied into another machine's `~/.config/nvim`.

## What Changes

- Make the root README's Neovim section a condensation of `.config/nvim/README.md` rather than an independent description. It keeps its current depth and structure; what changes is where its content comes from and what keeps it honest.
- Have the section say so. It names `.config/nvim/README.md` as the document it is drawn from, so a reader who wants more than an orientation knows where to go next and an editor knows which document to change first.
- State that the directory can be taken on its own: copying the contents of `.config/nvim/` into another machine's `~/.config/nvim` yields the same editor configuration, without the rest of this repository.
- Reconcile the rule that governs the section. `dotfiles-repo` currently requires detail beyond orientation to live in `.config/nvim/openspec/specs/` and names that workspace as *the only* location the documentation may name for such detail — a rule written when no Neovim README existed. It has to distinguish the two: `openspec/specs/` stays authoritative for per-capability behaviour, and `.config/nvim/README.md` becomes the named source for the orientation itself.
- **Not** in this change: writing `.config/nvim/README.md`. That is `add-readme`, in the Neovim workspace, and this change is not applied until it has landed.

## Capabilities

### New Capabilities

<!-- none. The section and the rule governing it already exist; both are amended. -->

### Modified Capabilities

- `dotfiles-repo`: the requirement governing the documented Neovim section gains three rules — that the section is a condensation of `.config/nvim/README.md`, that it names that README as its source, and that it states the configuration directory can be copied on its own. The existing "only location" rule is narrowed to per-capability detail, so naming the Neovim README as the orientation source is not an exception to it.

## Impact

- **Depends on**: `.config/nvim/openspec/changes/add-readme`, which creates `.config/nvim/README.md`. Every task here reads that file; applying this change before it exists would produce a section derived from nothing and a spec naming a file that is not there.
- **Modified tracked files**: `README.md` — the Neovim section rewritten as a condensation, with the source named and the copy-out instruction added. `openspec/specs/dotfiles-repo/spec.md`, via this change's delta.
- **Not affected**: `.config/nvim/` in its entirety. No file under it is read for anything but its README, and none is written. No `.lua` file, no spec in the Neovim workspace, and no `.gitignore` entry — `!/README.md` and `!/openspec/**` already cover both paths this change touches.
- **Ongoing**: a change to the Neovim configuration updates `.config/nvim/README.md` under that workspace's own `documentation` capability; the root section follows from it rather than being maintained in parallel.
