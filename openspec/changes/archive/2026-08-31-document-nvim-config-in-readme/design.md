## Context

See proposal.md — Why.

Two constraints shape the approach.

**The Neovim tree already has its own specification workspace.**
`.config/nvim/openspec/specs/` holds twenty-seven capability specs —
`editor-options`, `editor-keymaps`, `plugin-management`, `language-servers`,
`completion`, `formatting`, `git-integration`, `fuzzy-finder`,
`session-management`, `theme-switcher`, and the rest. Each is normative and each
is maintained by its own changes. Anything the README states about Neovim
behaviour is therefore a second copy of something already specified elsewhere,
and every sentence it adds is a sentence that can drift.

**The root workspace also carries Neovim specs.**
`openspec/specs/nvim-markdown-rendering/` and `openspec/specs/nvim-scrolling/`
live in the root repository, not in the nested one. The Neovim configuration is
consequently specified from two places, and the README section is written for a
reader who has landed in the root repository and does not yet know either
workspace exists.

**The README's existing register.** Every section is prose that explains *why*
the arrangement is what it is — block 2 of `.gitignore` is load-bearing, `:xall`
rather than `:wqall`, `settings.local.json` does not help. Tables appear only
where the content is genuinely a mapping (key → effect, path → reason). A
Neovim section written as a bare plugin inventory would be the first section
that lists without explaining.

## Goals / Non-Goals

**Goals:**

- A reader who opens the root repository and wonders what `.config/nvim/`
  is gets a truthful answer without opening a single Lua file.
- The section survives ordinary Neovim changes. Adding a plugin should touch it
  only when the grouping it belongs to is named there.
- One authority per fact. Where the nested specs are normative, the README
  points rather than restates.

**Non-Goals:**

- Documenting individual keymaps. `.config/nvim/openspec/specs/editor-keymaps/`
  is normative for those, and a README copy would be stale within a change or
  two.
- Explaining the *rationale* behind Neovim decisions. The Lua files carry
  unusually thorough comments — the clipboard provider block, the H/L expression
  mappings, the `%bd` buffer-list reasoning — and those comments are where that
  reasoning belongs.
- Touching any other README section, or any file under `.config/nvim/`.
- Recording the deletion of the `nvim-config` remote anywhere else. The archived
  `2026-08-26-setup-dotfiles-repo` change still names it as the recovery path;
  archived changes are a record of what was decided at the time and are not
  rewritten when the world moves.

## Decisions

**Describe by grouping, not by inventory.**
The alternative is a table with one row per plugin, twenty-eight rows long. It
would be complete, unreadable, and wrong within a month. Grouping by job —
language support, completion, formatting, git, navigation, editing, interface,
sessions, themes — gives a reader the shape of the configuration in a paragraph
each, and a new plugin usually joins an existing group without changing a word.
The cost is accepted: a reader who wants to know whether one specific plugin is
present has to open `lua/plugins/`, which is a directory listing away and is
where that question is answered accurately anyway.

**Point at `.config/nvim/openspec/specs/`, and say why it exists.**
A reader who does not know the nested workspace exists will not find it — it is
three levels down and shares a name with the root one. Naming it turns the
README from a partial duplicate into an index, and makes the delegation in the
spec's third scenario enforceable rather than aspirational. Mention that the
root workspace also holds two Neovim specs, so the split is discoverable rather
than a trap.

**State the load order, because it is the one structural fact that is not
guessable.** `init.lua` requires `config.options` before `config.lazy` because
`mapleader` must exist before any plugin spec is evaluated, and `lua/plugins/`
is auto-imported while `lua/plugins/themes/` needs its own explicit import line
— a subdirectory without an `init.lua` contributes nothing and reports no error.
Both facts cost a sentence and both are the kind of thing a reader otherwise
discovers by having something silently not load.

**Keep the absorption sentence, drop the URL.** That `.config/nvim` was once a
separate repository explains why it carries its own `.gitignore`, its own
`.claude/`, and its own `openspec/` — a reader who does not know that will read
the nested workspace as a mistake. The remote URL is the only part that has
stopped being true, so it is the only part removed.

**One table, for the file layout.** Path → what lives there is a genuine
mapping and matches how `## What is deliberately not tracked` and `## herdr pane
equalizing` already present the same shape. The plugin groups stay prose,
because a group's entry is a sentence about what the group is *for*, not a
lookup key.

**Requirement on `dotfiles-repo` rather than a new capability.**
The subject is a property of this repository's tracked documentation, which is
what `dotfiles-repo` already governs — it is the spec that says a bootstrap
procedure must be documented. A new capability for one README section would
fragment that. Considered and rejected: extending `retired-tooling` instead,
which records *tools* withdrawn from the configuration; a deleted git remote is
not a tool, and Neovim itself has not been retired.

## Risks / Trade-offs

**The description drifts as the Neovim configuration changes.** → The spec's
fourth scenario makes updating it part of the change that moves the
configuration, rather than a separate cleanup nobody schedules. The grouping
decision above also limits how often that is triggered: only a change that
alters a named group, a keymap prefix, or a global convention reaches the
README at all.

**The two OpenSpec workspaces stay confusing.** → Naming both in the README is a
mitigation, not a fix; consolidating them is a larger change and is deliberately
out of scope here.

**The section grows into a second copy of the nested specs.** → The delegation
scenario is written as a prohibition (`SHALL NOT restate those specifications'
scenarios`), so growth in that direction fails review rather than passing
unnoticed.

**Someone genuinely wanted the old history.** → It is gone; the remote was
deleted, and no local copy survives — the scratch `.git` backup taken during the
absorption lived in an ephemeral scratchpad. Removing the pointer does not
destroy anything that a reader could still have reached, which is the whole
reason the pointer is worth removing.

## Migration Plan

Not applicable. A documentation edit with no runtime component; reverting is
`git revert` on one commit.
