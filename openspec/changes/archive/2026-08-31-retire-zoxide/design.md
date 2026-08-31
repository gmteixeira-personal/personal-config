## Context

See proposal.md — Why. The relevant state is that the investigation already ran, and the repository is cleaner than the error suggests:

- No tracked file names or mentions zoxide, outside two archived OpenSpec changes that only cite it as prior art.
- No fish startup file under `.config/fish/conf.d/` and no bash startup file initializes it.
- `zoxide` does not resolve on `PATH`, and `.config/zoxide/`, `.local/share/zoxide/`, and `.cache/zoxide/` are all absent.
- A fish shell started now defines no `__zoxide_hook`: `functions -q __zoxide_hook` exits non-zero.

So the error the user sees comes from one long-lived fish session that was started while zoxide was still installed. fish keeps the hook function in that session's memory, and its `--on-variable PWD` event handler fires on every directory change, calling a binary that no longer exists. This is session state, not configuration state, which is what shapes the whole approach: there is essentially nothing to fix in the repository, and the work is to prove that and write it down.

## Goals / Non-Goals

**Goals:**

- Verify the retirement against both the repository and the machine, rather than trusting the earlier removal.
- Record it as a requirement under `retired-tooling`, so the tool cannot return quietly.
- Stop the error in the affected session.

**Non-Goals:**

- Replacing zoxide with another jump tool. Nothing fills the gap; `cd`, the shell's directory history, and `mkcd` already cover it.
- Adding a defensive shim, stub function, or guard so that a stale hook fails quietly (see Decisions).
- Rewriting the existing lazygit requirement or restructuring the `retired-tooling` spec.

## Decisions

**Fix the live session by restarting it, not by defining a compatibility stub.**

The tempting shortcut is to define an empty `zoxide` function or erase `__zoxide_hook` from the running session and commit something that keeps doing so. Both are wrong here. Erasing the function with `functions --erase __zoxide_hook` fixes the session but is a one-off command, not a change — and committing it would mean tracked configuration that exists only to paper over a tool the same commit declares retired. A stub `zoxide` command is worse: it makes the retirement invisible, so the next stale hook anywhere would silently do nothing instead of announcing itself. Restarting the shell (`exec fish`, or simply opening a new terminal) resolves it completely and leaves no trace, because the configuration is already correct.

Alternative considered: erase the function in the running session as a convenience, without committing anything. This is fine and the user may do it, but it is not part of the change — it produces no artifact and needs no record.

**Extend `retired-tooling` rather than create a new capability.**

The capability already exists and already documents exactly this shape of retirement for lazygit. A second requirement alongside it keeps every retired tool in one place, which is the point of the capability. The delta uses ADDED, not MODIFIED: the lazygit requirement is untouched.

**Write a scenario about the hook specifically.**

The other retired tool, lazygit, is a standalone binary — removing it removes it. zoxide installs itself into the shell, so its retirement has a second surface: a startup file that still calls `zoxide init`, which would reintroduce the hook on every new shell. The spec covers that surface explicitly, and asserts that a fresh shell defines no hook, because that is the condition a future check can actually test.

**Verify the package manager state rather than assume it.**

`zoxide` not resolving on `PATH` is good evidence but not proof — a package can be installed with its binary somewhere unusual, and zoxide is commonly installed through cargo as well as through a system package manager. The tasks check both, so the requirement's "not installed" scenario rests on a real answer.

## Risks / Trade-offs

**The user restarts the shell before the change lands, and the visible symptom disappears** → The symptom is not the deliverable; the record is. The verification tasks read the repository and the filesystem, not the running session, so they stay meaningful either way.

**Muscle memory for `z <dir>` outlives the tool** → Accepted, and untreated. No alias is added: an alias mapping `z` onto `cd` would take a fuzzy-matching jump and give it exact-path behavior, which fails confusingly rather than cleanly. An unknown command is the clearer signal.

**A zoxide install could return as a transitive dependency of some other tool** → Low, and the requirement is the mitigation: it states that the package must be absent, so a future check catches it rather than a surprise `z` command working again.
