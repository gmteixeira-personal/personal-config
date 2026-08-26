## Context

See proposal.md — Why. The suite is twelve markdown command files plus `conventions.md`, each with YAML frontmatter carrying `description`, `model`, `effort`, `allowed-tools`, and sometimes `argument-hint`. Every command already opens by reading `conventions.md`, which is where the rules shared across the suite live. `status.md` currently holds the whole render contract — legend, entry-line field widths, the emoji table, the colour rules, the status line — as part of its own instructions, because until now it was the only command that printed a tree.

Current frontmatter: `conventions`, `cleanup`, `commit`, `fetch`, `init`, `merge`, `mergeinto`, `pull`, `status`, and `switch` name `sonnet`; `append`, `push`, and `squash` name no model and therefore inherit the session's.

## Goals / Non-Goals

**Goals:**

- One render contract, reachable by every command, so `/git:status` and a closing block cannot diverge.
- A model assignment per command that is written down and justified, rather than inherited.

**Non-Goals:**

- Changing what any command does to the repository.
- Changing the rendered format itself. The block that closes a command is the block `/git:status` prints today.
- Tuning the `effort` field. It is a separate axis and is left as it stands.

## Decisions

**Move the render contract into `conventions.md`, and leave `status.md` holding only what is specific to `/git:status`.** Every command already reads `conventions.md` as its first instruction, so the contract arrives without a second read, and there is no per-command copy to drift. `status.md` keeps its read-only precondition, its "print the block and stop" rule, and its rule against trailing prose. Alternatives considered: a separate `render.md` that commands read on demand — rejected, since it adds a second read to every mutating command to save a section in a file they already read; and duplicating the contract into each command — rejected outright, as twelve copies is the failure mode this change exists to prevent.

**The block goes last, after the prose report.** The report says what the command did; the block says where the repository ended up. Reading order matches: the action, then the result. It also puts the block directly above the next prompt, where the eye lands.

**Only on success, and only after any confirmation.** A stopped command's value is its stop report and git's own decisive line; a tree beneath it invites reading the failure as a completed operation. A command waiting on confirmation has not changed anything yet, so there is nothing to render.

**`/git:fetch` renders the block.** It changes no file, but it moves the remote-tracking refs, and the status line's ahead and behind counts are measured against exactly those refs. The status block is the fastest statement of what a fetch means for the branch. This is the one command where "changes what the block shows" is broader than "changes the working tree".

**Three model tiers, chosen by what a wrong answer costs.** The fast tier takes the command that only prints text. The middle tier takes bounded operations and message writing — a bad commit message is edited, a bad merge is aborted, a bad fetch is inert. The top tier takes the four commands that can destroy committed work: `squash` and `append` rewrite history and can force-push, `mergeinto` moves work between branches and pushes, and `cleanup` deletes local and remote branches. Alternatives considered: pushing the whole suite down a tier for cost — rejected, since the expensive failure is not the token bill; and leaving the three unset commands to inherit — rejected, since `push`, `append`, and `squash` then behave differently depending on which model the session happens to be running.

**`/git:status` stays on the middle tier.** It is read-only, but the render contract is the most detail-dense instruction in the suite — fixed column widths, an emoji table with a width caveat, colour selected by first character — and it is the thing every other command's closing block is judged against. Rendering it is the wrong place to save a tier.

## Risks / Trade-offs

- **Twelve files carry a near-identical closing line, which is itself a form of duplication** → the line points at the contract instead of restating it, so the drift risk stays in one place; the requirement that no per-command file needs editing when the contract changes is what holds this.
- **Output grows on every mutating command** → one line when the tree is clean, which is the common case after a successful `commit` or `push`.
- **A closing block on a command that ends on a different branch, like `mergeinto`, could be misread as describing the branch the user started on** → the block's status line names the branch, which is exactly the case where that field earns its place.
- **The model tiers are written against today's tier names** → they are expressed as fast, middle, and top tier so that a rename of the underlying models is a substitution, not a redesign.
