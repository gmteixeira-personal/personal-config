## Context

See proposal.md — Why. What the approach has to work within:

- Neovim 0.12.5 here ships seven grammars in `/usr/lib64/nvim/parser/` — `c lua markdown markdown_inline query vim vimdoc` — and highlighting queries for exactly those seven. It gained `vim.pack`, but no parser manager and no `:TS` commands.
- The capability asks for `regex` for the `/` and `?` input and `bash` for `:!`. Neither is bundled.
- `noice/text/treesitter.lua` fetches the language's `highlights` query and returns early when it is absent, so the grammar and the query are both load-bearing.
- The editor's grammar ABI range is 13 to 15; the `tree-sitter` CLI installed here builds 15.

## Goals / Non-Goals

**Goals:**

- State the requirement at the level the repository can actually hold: what must exist on the machine, not the bytes themselves.
- Make the difference between "the health check passes" and "the input is highlighted" explicit, because a grammar alone satisfies the first and not the second.

**Non-Goals:**

- Tracking the built objects or the queries. Neither belongs in this repository.
- Automating the install. A script to build them would be a parser manager with fewer features, and this configuration's position on parser managers is the point.
- Requiring any particular pair of languages. The requirement is about what the capability asks for, so a future one is covered by the same words.

## Decisions

**Stated as a requirement on the record rather than on the files.** The repository cannot assert that a machine has a compiled object, so a requirement written that way would be untestable from a checkout. What it can assert is that the configuration names both halves, their sources and the build command — which is exactly what a person rebuilding needs and what was missing when the two languages were absent for the life of the capability.

**Both halves named explicitly, in the requirement and not only in the design.** The failure that made this worth writing is specific: the previous comment named only the `.so`, so following it would have produced a passing health check and an input still rendered as plain text. A requirement that names only the grammar reproduces that.

**Pinning stated with its reason.** The queries come from nvim-treesitter and are written against the grammar revisions it pins. Tracking a grammar's default branch instead is the quiet failure mode — a renamed node leaves the query matching nothing, with no error anywhere.

**Absence is a degradation, and the health report is what announces it.** Making it a fault would mean a check at startup for something the configuration deliberately does not manage. The editor already reports it on demand.

## Risks / Trade-offs

- **The record can go stale.** A grammar or query URL that moves leaves instructions that do not work. → The failure appears the moment someone follows them, not silently; the revisions in the record are what a reader compares against.
- **Nothing enforces that a machine has the files.** → By design; the requirement is that the configuration says what is needed, and `:checkhealth noice` is what says whether this machine has them.
