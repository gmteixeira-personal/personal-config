## Context

See `proposal.md` — Why. What shapes the approach is what `openspec` will and will not do to a spec.

The CLI resolves the *nearest* workspace from the working directory: `openspec status` run in `~` reports `root: { path: /home/gmteixeira, source: "nearest" }`, and the same command run in `~/.config/nvim` reports that directory instead. Both workspaces are inside one git repository — `.config/nvim/` has its own `openspec/` and its own `.claude/commands/`, but no `.git`, and all 282 of its files are tracked by the home repository.

One mechanic was measured in a scratch repository rather than assumed. Removing a capability's last requirement makes `openspec archive` abort: *"Spec must have at least one requirement … To retire the capability and delete its spec, add `retire_capabilities: true` to the change's `.openspec.yaml`"*. With that key added, the same archive reports `Retiring openspec/specs/<cap>/spec.md: all requirements removed.` and deletes the file. A change whose deltas are only removals is otherwise valid.

## Goals / Non-Goals

**Goals:**
- One home per capability, chosen by what produces the behaviour.
- The relocated text is the text that was there — a move, not a rewrite.
- The Neovim workspace stops contradicting its own configuration.

**Non-Goals:**
- Routing future proposals. No note, no hook, no store registration; keeping Neovim work in the Neovim workspace is handled by hand.
- Changing any Neovim behaviour. No `.lua` file is touched.
- Rewriting archived changes into the naming this change introduces.
- Auditing the remaining home capabilities for other misfilings. `dotfiles-repo` names Neovim in "Tracked documentation describes the Neovim configuration" and stays where it is: the README it governs is the home repository's.

## Decisions

### `scrolling` as its own capability, not folded into `editor-options`

`editor-options` already owns the `scrolloff` line in `lua/config/options.lua`, so folding the moved requirements into it is defensible. It is not what the Neovim workspace does elsewhere: `cursor-animation`, `jump-motions`, and `selection-movement` are each their own capability rather than sections of a general one, and the moved text is four requirements with eleven scenarios — a section that size inside `editor-options` would bury it.

Keeping it separate also keeps this change a move: the text arrives as written, and the only edit is to the requirement it supersedes.

`markdown-rendering` has no such question — the Neovim workspace has no markdown capability to fold into.

### The superseded requirement is removed, not modified

`editor-options` requires eight lines of context above and below the cursor. That requirement is not merely narrower than the centered one — it is false today, and has been since `scrolloff = 999` landed on 2026-08-27. Its two scenarios describe behaviour the editor does not have.

It is removed rather than reworded because `scrolling` states the replacement in full, and a rewritten stub in `editor-options` would be a second description of one option — the arrangement this change exists to end.

### The README caveat is deleted, and the requirement behind it tightened

`README.md` ends its Neovim section by naming the two misfiled capabilities and telling the reader to check both workspaces. That paragraph is the split written down; deleting it is part of correcting the split, not separate documentation work.

The requirement in `dotfiles-repo` that governs the section is tightened at the same time, because as written it does not forbid what the paragraph does. It says detail lives in `.config/nvim/openspec/specs/` and that the documentation names it — both of which the current README satisfies while also naming a second location. Adding *only* closes that: the next capability found in the wrong workspace has to be moved rather than documented around.

This is the one piece of prevention the change carries, and it is deliberately the cheapest kind — a rule about what the README may say, enforced by whoever reads the spec, not a hook or a router. Routing stays a matter of hand.

### Retire through `openspec archive`, not by deleting files

The home spec files stay in place through implementation and are deleted by `openspec archive` reading this change's REMOVED deltas, with `retire_capabilities: true` in `.openspec.yaml`. Deleting them by hand would leave the archive step trying to edit files that are gone, and would put the deletion outside the record that explains it.

The consequence is that the destination files are written while the source files still exist, so each capability is momentarily in both workspaces, and the deletion lands in the archive commit rather than the implementation commit. Git detects renames by content similarity at commit time, so a move split across two commits is not tracked as a rename by `git log --follow`. Accepted: the moved archives and this change record the provenance in prose, which is where a reader looks for it.

### Archives move verbatim

`2026-08-27-add-nvim-scrolloff-center` and `2026-08-31-add-markdown-rendering` move with their capabilities, keeping their `specs/nvim-scrolling/` and `specs/nvim-markdown-rendering/` delta directories and every mention of the old names.

Renaming inside them would make the record say something that did not happen. An archive is a statement about a past proposal; the rename belongs to this change.

They move rather than staying because each is planning for `.config/nvim/` alone — both proposals list only files under that directory in Impact — and because moving them is what gives the Neovim workspace the record of why its eight-line scrolloff requirement stopped being true.

## Risks / Trade-offs

- **`openspec archive` refuses at the end because `retire_capabilities` was not set** → It fails safe: the message names the fix and writes nothing. The key is added during implementation and `openspec validate --strict` is run before the archive step.
- **The Neovim workspace's `editor-options` is edited without a change record in that workspace** → Mitigated by moving `2026-08-27-add-nvim-scrolloff-center` into that archive, which is the record of why the eight-line requirement stopped being true. Raising a second change inside the Neovim workspace to delete one stale requirement would cost more than it documents.
- **The README's Neovim section is summarised from specs in a workspace the home README cannot see from its own tree** → Unchanged by this move, and slightly improved by it: the section was already summarising 28 capabilities from `.config/nvim/openspec/specs/` and only 2 from beside it. After this change there is one source to write it from rather than two.
- **The next Neovim proposal raised from `~` lands in the home workspace exactly as these two did** → Accepted deliberately, and out of scope by request. Nothing in this change makes a repeat less likely; it makes the current state correct. The correction, if it happens again, is this change run a second time.
