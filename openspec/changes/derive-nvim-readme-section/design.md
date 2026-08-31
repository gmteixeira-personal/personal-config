## Context

See `proposal.md` — Why. What shapes the approach is the boundary between the two workspaces and the ordering it forces.

`.config/nvim/` is inside this git repository but is its own OpenSpec workspace, with its own `.claude/` and its own edit root. `add-readme`, open in that workspace, declares the root README and the home `dotfiles-repo` spec out of scope for exactly that reason: it cannot reach across the boundary, so it writes `.config/nvim/README.md` and stops. This change is the other half, and it can only be written from `~`.

The dependency runs one way and is hard. Every task here reads `.config/nvim/README.md`; that file does not exist yet. The user has stated this change is not applied until `add-readme` has landed.

The root section is 140 lines across five subsections — `## Neovim`, then `Layout and load order`, `Editor conventions`, `Keymaps`, `Plugins`, `Where the detail lives`. It is well written and, as far as anything here can tell, currently correct. The change is to its provenance, not to its quality.

## Goals / Non-Goals

**Goals:**

- One prose account of the Neovim configuration, written where the configuration is, with the root section a shorter view of it.
- A reader of the root section can tell it is a condensation and where the fuller document is.
- A reader who wants only the editor configuration is told they can take the directory.

**Non-Goals:**

- Writing `.config/nvim/README.md`, or reviewing what `add-readme` puts in it. This change reads that file; it does not shape it.
- Shortening the root section. The user chose to keep its depth; the change is where the content comes from.
- Any mechanism that checks the derivation — no generator, no test, no hook. The rule is enforced by whoever reads the spec.
- Touching the Neovim workspace at all, including its `documentation` capability, which governs its own README.

## Decisions

### Rewritten from the source, not diffed against it

At apply time the root section is written afresh from `.config/nvim/README.md`, then compared with what was there before. The alternative — keeping the current text and patching where the two disagree — sounds smaller and is worse: it preserves phrasing whose only justification is that it was written first, and it cannot tell a claim the source supports from a claim it never made.

Writing it afresh makes the derivation real on the first pass rather than aspirational. Where the previous text says something better than the source does, that is a signal to fix `.config/nvim/README.md` under `add-readme`'s own `documentation` capability — not to keep a better sentence at the root that the source does not carry.

The expected outcome is that the section stays close to what it is today, because both documents describe one configuration. A large diff means the two accounts disagreed, which is the thing this change exists to end.

### The "only location" rule is narrowed rather than dropped

`dotfiles-repo` currently says `.config/nvim/openspec/specs/` is "the only location the documentation names for such detail". That was written last, against a repository with no Neovim README, and taken literally it forbids what this change does.

It is narrowed to *specifying* rather than *naming for detail*: the specs workspace stays the only place the documentation names as specifying a Neovim capability, and the requirement says outright that naming the README as the orientation source is not an exception to it. Dropping the rule instead would give back the loophole it was added to close — a capability found in the wrong workspace being documented around rather than moved.

The distinction the wording rests on: a README describes, a spec specifies. The reader is sent to the README for the fuller description and to the specs for exact behaviour, and neither errand is a substitute for the other.

### The source is named inside the section

"Where the detail lives" already closes the section and already names `.config/nvim/openspec/`, so the source line goes there rather than at the top. A reader who has just finished the orientation is the one who wants to know where more of it is; a reader at the heading has not yet found out whether they need it.

The copy-out instruction goes in the section's opening paragraph instead, beside the sentence about the directory carrying its own `.gitignore`, `.claude/` and `openspec/`. That paragraph is already about the directory being self-contained; that it can therefore be lifted out belongs in the same breath.

### Nothing enforces the derivation

The spec states the section is a condensation and introduces no claim the source does not make. Nothing checks it. A generator would have to decide what to drop, which is editorial; a test comparing the two would fail on every rewording of either.

Accepted deliberately, and the cheapest thing that could work: the obligation already exists in the neighbouring scenario — a change that repurposes something the documentation names updates the description in the same change — and this adds which document to change first.

## Risks / Trade-offs

- **`add-readme` lands with a README shallower than the root section, and condensing it loses content.** → The loss is visible in the diff at apply time. The fix is to raise it against `add-readme`'s `documentation` capability rather than to keep the depth at the root, which would recreate the split. If the gap is large, this change waits.
- **Two documents still have to be kept in step, and the rule is prose.** → Reduced, not removed: before this change they were two independent accounts; after it, one is derived and there is a stated order to change them in. Enforcement stays human, by choice.
- **The narrowed "only location" rule is subtler than the one it replaces, and a future reader may take the README as a second place to specify.** → The requirement says which is which in the same sentence, and the `One place to look` scenario is untouched.
- **The dependency is recorded only in prose.** → `openspec` has no cross-workspace dependency mechanism, and the two changes are in different workspaces. The proposal's Impact names it, this document names it, and the user has said they will not apply this change first.

## Migration Plan

1. `add-readme` is implemented and archived in the Neovim workspace, leaving `.config/nvim/README.md` in place.
2. This change is applied: the root section is rewritten from it and the `dotfiles-repo` delta is synced.
3. Rollback is `git revert` of the single commit. Nothing outside `README.md` and `openspec/specs/dotfiles-repo/spec.md` is touched, and no Neovim behaviour depends on either.
