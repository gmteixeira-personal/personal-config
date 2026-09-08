## Context

See proposal.md — Why. The relevant history is three commits on one question. `f583ef9` (2026-08-31) bound `cat` to `bat` in both shells, guarded on `bat` being installed, and amended `A shorthand does not shadow an existing command` to permit a deliberate override and say what one owes. `b9343e9` (2026-09-05) reverted the binding — 13 deletions across `.bashrc` and `.config/fish/conf.d/aliases.fish`, no spec edit, no change proposal. The requirement and the amendment both survived the revert.

The current state was verified rather than assumed: `cat` is unbound in both startup files, `type -t cat` reports `file` in fish and in bash, and `bat` 0.26.1 is installed at `/usr/bin/bat`.

## Goals / Non-Goals

**Goals:**

- Bring the spec to the code, and record why the code is what it is, so the question reads as settled rather than unasked.

**Non-Goals:**

- Touching any shell startup file. This change writes no code; the configuration is already correct.
- Uninstalling `bat`, or changing how it is invoked. It is wanted under its own name.
- Reverting the deliberate-override rules in `A shorthand does not shadow an existing command`. See the Decisions below.

## Decisions

**Replace the requirement rather than delete it.**
A plain deletion returns the spec to the state it was in before `f583ef9`, which is the state in which binding `cat` to `bat` looked like a reasonable thing to propose. The proposal was reasonable — it was tried and it was judged wrong in use, which is information the spec should hold. Stating the decision costs one requirement and closes the question; deleting it costs nothing and reopens it.

**Keep the deliberate-override rules, and say so in the proposal.**
`f583ef9` added a paragraph and two scenarios to the no-shadowing requirement describing what an override owes: a guard on the replacement being installed, and the original still reachable. Those were written for `cat` and, with `cat` gone, describe nothing this configuration currently does. They are kept anyway. The escape-hatch clause they refine — "unless the intent is explicitly to change that command's default behavior" — was in the requirement before `f583ef9` and is untouched by this change, so removing only the refinement would leave the permission standing with the conditions on it stripped off, which is worse than either keeping both or removing both. Removing both is a real option and a separate decision; it is not part of correcting a drift about `cat`.

**Write no code and let the tasks be verification.**
There is nothing to implement. The tasks confirm the code already matches, so that the spec sync is made against a checked state rather than an assumed one, and so a later reader can see the check was done.

## Risks / Trade-offs

- **The new requirement forbids something a future change might genuinely want** → it is a requirement like any other, and a change that wants the binding back amends it through the same process, with the argument written down. That is the point: the objection is on the record for it to answer, rather than absent.
- **Two scenarios remain in the spec that nothing exercises** → accepted, and named in the proposal's Impact so it is a known state rather than a second drift. They constrain a future override rather than describe a current one.
