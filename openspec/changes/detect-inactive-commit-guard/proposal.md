## Why

`core.hooksPath` was unset in this repository. The pre-commit hook — which
`openspec/specs/dotfiles-repo/spec.md` calls the commit-time secret guard, and
which `README.md` calls the bootstrap step that matters most — was not running,
and had not been for an unknown length of time: `.git/config` carried no
`core.hooksPath` entry at all, so it was either never set on this machine or
lost without trace. Two commits landed on `main` while it was off.

An audit of the whole history against the hook's own checks found nothing: 842
paths ever committed, 2121 objects, no hit on either the path denylist or the
content patterns. Nothing leaked. That is luck, not design.

Git clones neither hooks nor repository-local config, so the guard has to be
switched on by hand in every clone. The spec already requires that this be
possible — "Guard survives a fresh clone" — and the README already documents the
command. What neither provides is any way to notice that the step was missed.
An inactive guard looks exactly like an active one: commits succeed either way,
and the only difference shows up on a public remote after the fact.

## What Changes

- A new tracked `conf.d/commit-guard.fish` reports, at interactive shell start,
  that the home repository's commit guard is not active — naming the command
  that activates it.
- It is silent when the guard is active, which is the state after bootstrap, so
  a correctly set-up machine sees nothing at any prompt, ever.
- It checks that the guard would actually run, not merely that a configuration
  key exists: `core.hooksPath` names the tracked hooks directory *and* the
  `pre-commit` hook in it is executable.
- `README.md`'s bootstrap step 2 gains a line saying the shell reports the
  failure, so the check is discoverable from the document that asks for the
  step.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-repo`: the **Commit-time secret guard** requirement gains the
  obligation that an inactive guard is reported rather than silent. Today the
  requirement covers what the guard rejects and that it is installable in a
  fresh clone; it says nothing about the case where it was never installed,
  which is the case that actually occurred.

## Impact

- `.config/fish/conf.d/commit-guard.fish` — new.
- `README.md` — one line in bootstrap step 2.
- No change to `.githooks/pre-commit` itself. It was verified to reject a
  denylisted staged path correctly; it was simply not being invoked.
- fish only. `.bashrc` ends by `exec fish` for interactive sessions, so an
  interactive bash becomes fish and inherits the check; the paths that stay bash
  are non-interactive, where a warning has no reader.
