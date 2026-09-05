## Context

See proposal.md — Why. Constraints that shape the approach:

- `.ssh/` is denylisted in the ignore policy's block 4, correctly: it holds private keys. `~/.ssh/config` sits inside it and is excluded with the rest.
- A repository's remote lives in its own `.git/config`, which is never tracked in any repository.
- `gh` is authenticated on this machine and reports its git protocol as `ssh`, which is why no credential helper was ever configured for HTTPS.
- The README's step 1 clones over HTTPS, and must keep doing so: a machine being bootstrapped has no keys yet.
- The machine already carries two accounts — a default one and a second reached through an alias — so the convention this documents is being described, not invented.

## Goals / Non-Goals

**Goals:**

- A bootstrap that ends at a repository which can push.
- One place that says how a second account is reached, since the file that configures it cannot be tracked.

**Non-Goals:**

- Tracking any part of `~/.ssh/`. The denylist is right and this change depends on it.
- Prescribing which forge or which key type. The convention is the alias-per-account shape, not the specific names on this machine.
- Managing keys: generating, rotating or registering them is outside what a dotfiles repository should be doing.

## Decisions

**SSH with an alias per account, rather than a credential helper.**
A helper is keyed by host, and both accounts live on the same host, so a helper cannot distinguish them — it would answer with one account's token for the other's repositories, and succeed, which is the failure mode that does not announce itself. An SSH alias moves the distinction into the remote URL, where it is visible in `git remote -v` and cannot be silently wrong. This also matches what the machine already did for its second account before this change.

**Leave the HTTPS clone URL in the bootstrap.**
It was tempting to change step 1 to the SSH URL for consistency with the working remote. That would break the bootstrap it belongs to: the reader has no keys at that point, and an SSH clone would fail before anything else could be tried. HTTPS to clone, SSH to push, with the move documented as a step, is the order that actually works.

**Document the shape rather than this machine's names.**
The specification says alias-per-account with a key each; it does not name `github-ads` or a key file. Naming them would put one machine's arrangement into a requirement that other machines must satisfy, and the ignore policy already forbids machine-absolute paths in tracked files for the same reason. The README may show this machine's arrangement as an example; the requirement stays at the shape.

**Say that a global helper is not used, rather than leaving its absence to chance.**
There is currently no global git configuration at all on this machine, so the requirement is satisfied by an empty set. That is a fragile way to satisfy anything — a single `gh auth setup-git`, run for an unrelated reason, would configure one globally and quietly break the second account. Stating it makes the absence deliberate and checkable.

## Risks / Trade-offs

- **Documentation is the only carrier, so it drifts with no way to detect it.** → Unavoidable while the underlying files are denylisted, which they should be. The mitigation is that the arrangement is small and the failure is loud: the wrong key produces an authentication failure, not a wrong-account push.
- **A reader on a single-account machine gets a step they do not need.** → The requirement makes the alias conditional on more than one account, and says the default account may use the host directly.
- **The `gh` CLI can configure a global helper as a side effect of an unrelated command.** → Now stated as a requirement rather than left implicit, so it is at least written down as something not to do.
