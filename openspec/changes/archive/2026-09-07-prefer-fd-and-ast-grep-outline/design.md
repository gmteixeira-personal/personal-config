## Context

See proposal.md — Why.

`.claude/CLAUDE.md` currently holds one section, `## ast-grep`, added by `1cfd56e`. It is the only tooling note there and it was written without a spec, so the file has a precedent for its shape — a heading per tool, a sentence naming the tool and the case it wins, fenced examples, then a `Notes:` list holding the details and the fallback — and no written rule about what a note has to contain. This change adds a second tool to that file, which is the point at which the shape has to become a rule rather than an accident of one section.

Both tools are cargo builds: `~/.cargo/bin/fd` (10.5.0) and `~/.cargo/bin/ast-grep`. `~/.cargo/bin` is on `PATH` through `conf.d/env.fish`. Neither is a Fedora package here — `rpm -qf ~/.cargo/bin/fd` reports the file as owned by no package — which matters for the README entry, whose requirement is to name where software comes from without prescribing a package-manager command line.

`README.md` groups the inventory as **Required**, **Optional**, **Carried by the repository**, and **Must not be installed**. The `dotfiles-repo` specification requires every dependency of the tracked configuration to appear there and requires each entry to state what is lost in its absence. `.claude/CLAUDE.md` is tracked configuration, so naming a tool inside it creates an inventory entry that is owed.

The implementation of the instruction file itself landed ahead of this change, in `ba630ae`. What remains unimplemented is the README half.

## Goals / Non-Goals

**Goals:**
- Give the second tooling note the same shape as the first, and write down what that shape is, so a third note has a rule to follow.
- Record `ast-grep`'s existing note as a requirement at the same time, so the capability's main spec describes the whole file rather than only the half this change touched.
- Have the README entries say what is actually lost, which for both tools is speed and noise rather than function.

**Non-Goals:**
- Any project-level `CLAUDE.md`. Nothing here writes an instruction into a repository's own file, and the spec forbids duplicating a machine-wide preference into one.
- Configuring either tool. `fd` reads `~/.config/fd/ignore` if it exists and `ast-grep` reads an `sgconfig.yml`; neither is created here, and neither is needed for the note to be correct.
- Aliasing `find` to `fd` in a shell. The preference is an instruction to an agent, not a change to what a command does at a prompt, and rebinding `find` would break scripts that rely on its predicates.
- Teaching the agent every flag. The note carries what a `find` or `grep` habit gets wrong; the rest is `--help`.

## Decisions

**Put the note in the user-level file rather than this repository's `CLAUDE.md`.**
The alternative is a project-level file, which is what a repository normally uses. It is wrong here for the reason the spec states: whether `fd` is installed is a fact about the machine, not about the repository being edited, and an agent working in some unrelated checkout needs the answer just as much. The user-level file is read in every session in every project, and it is tracked here, so it travels with the configuration without pretending to be a property of it.

**Carry the flags, not only the preference.**
A note reading "prefer `fd` over `find`" would be shorter and would be wrong more often than it is right. The differences are all silent: a pattern that matches the file name where `find -name` also matched the name but `find -path` did not; a default that skips `.gitignore`d paths, so a search for a build artefact comes back empty rather than erroring. An agent that carries a `find` habit into `fd` gets a plausible wrong answer, which is worse than a failure. The flags that fix each of those are what the note holds, and nothing else.

**Name the cases that stay with `find` and with `grep`.**
This is the half that makes the preference usable rather than dogmatic, and it is also what stops the note from being re-litigated on the first search that needs `-newer`. The `ast-grep` section already ends this way — "reach for plain `grep` only when the target is not syntax" — so the `fd` section ending the same way is the existing shape, not a new idea.

**Record the `ast-grep` search and rewrite behaviour as requirements here, though it was implemented earlier.**
`1cfd56e` added that section with no spec, so `openspec/specs/` has nothing describing it. A new capability spec that covered only `fd` and `outline` would leave the main spec describing two thirds of one file and silently implying the rest was not required. Writing all four requirements makes the main spec true of the file as it stands. The alternative — a separate retroactive change for the `ast-grep` half — buys a cleaner history for a file that has been in its final state since before this change opened.

**`outline` is a requirement of its own rather than a line in the `ast-grep` requirement.**
They are the same binary and different work: one searches and rewrites, the other decides how much of a file to read. Folding the second into the first would bury it under a heading an agent reads only when it already knows it wants a rewrite, which is exactly when it does not need it.

**File both README entries under Optional, not Required.**
The configuration does not stop working without either tool. An agent falls back to `find`, to `grep`, and to reading a file whole, and the work completes — slower, with more output, and with more context spent. That is a loss, and the entry has to say so, but calling it Required would put it beside the entries whose absence leaves the session unable to start.

**Do not name a package-manager command line for either.**
`dotfiles-repo` requires the source without the command, and here the honest source is `cargo install` or a release binary — neither tool is packaged for Fedora on this machine. The `vivid` entry already sets the pattern for a tool acquired outside the distribution.

## Risks / Trade-offs

- **An agent applies `fd` where `find`'s predicates are needed and silently gets a narrower answer** → The note names those predicates explicitly, and the spec requires it to. This is the one failure mode the note exists to prevent, so it is stated rather than mitigated by leaving `fd` unrecommended.
- **A search misses a file because it is `.gitignore`d and the agent forgot `-I`** → Stated in the note and required by a scenario. It stays a real risk; the mitigation is that the default is written down where the tool is introduced rather than discovered from an empty result.
- **The instruction file grows a section per tool and eventually costs more context than it saves** → Two sections is not that. The shape the spec fixes — the preference, its counter-case, and only the flags a wrong habit needs — is what keeps a section short; if the file later needs splitting, the rule for what belongs in a section is already written.
- **The `ast-grep` requirements describe a note nobody has revisited since it was written** → Verified against the file as it stands rather than against the commit message, and `ast-grep --help` was checked to confirm `outline` is a real subcommand rather than a plausible one.

## Migration Plan

Nothing to deploy. The instruction file is already in place; adding the README entries completes the change. Verification is reading both back: the file for the four requirements, `README.md` for two entries under **Optional** that each name what is lost and where the tool comes from. Rollback is reverting the two files; nothing reads either at runtime, so no session, shell, or editor state depends on the state of this change.
