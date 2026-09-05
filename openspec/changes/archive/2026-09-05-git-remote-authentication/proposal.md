## Why

The README's bootstrap ends at a repository that can commit. It cannot push. Following it produces an HTTPS remote with no credential helper, and the first push fails with `fatal: could not read Username for 'https://github.com'` — a message that names neither the cause nor the fix.

The machine already had the answer, undocumented: this account authenticates over SSH, and a second account on the same machine reaches the same forge through an SSH host alias with its own key. None of that is written down, and none of it can be, in the usual way — the file holding the aliases is `~/.ssh/config`, which the ignore policy denylists along with the rest of `.ssh/`. So the one piece of configuration that makes a second account work is both essential and untrackable.

## What Changes

- The bootstrap gains the step after identity: how the machine authenticates to the forge in order to push.
- The convention for a machine carrying more than one account is documented — an SSH host alias per account, each with its own key, and the remote written against the alias rather than the host.
- It is stated that a global credential helper is not used, and why: it answers for every repository on the machine, which is precisely wrong where accounts differ per repository.
- The HTTPS clone URL in step 1 stays as it is. A fresh machine has no keys yet, so cloning over HTTPS and moving the remote afterwards is the correct order, and that is now said rather than implied.

## Capabilities

### New Capabilities

- `git-remote-authentication`: how a machine authenticates to the forge for a repository whose account differs from other repositories beside it, and what has to be documented because the file that configures it cannot be tracked.

### Modified Capabilities

None. `dotfiles-repo` already requires a tracked bootstrap procedure; it currently stops at the commit guard and identity, and extending it to cover pushing is implementation against the existing requirement rather than a change to it. `dotfiles-ignore-policy` already denylists `.ssh/`, which this change relies on rather than alters.

## Impact

- `README.md` — a bootstrap step on authenticating to the forge, and the multi-account alias convention.
- Not changed and not trackable: `~/.ssh/config`, `~/.ssh/` keys, and `.git/config`. All three are machine-local by policy; the documentation is the only carrier.
- Machine state already in this shape: this repository's remote was moved from HTTPS to SSH, and its identity is set per repository rather than globally.
