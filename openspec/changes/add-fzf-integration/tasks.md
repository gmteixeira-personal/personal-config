## 1. fish

- [x] 1.1 Add `~/.config/fish/conf.d/fzf.fish` sourcing `fzf --fish`, guarded by `status is-interactive; and type -q fzf`, with a comment recording what was measured about the bindings surviving the vi set. Verify with `fish -i -c 'functions -q fzf-file-widget; and echo yes'` printing `yes`.
- [x] 1.2 Verify the bindings hold without help from `key-bindings.fish`: in an interactive fish, `bind ctrl-t`, `bind ctrl-r`, and `bind shift-tab` report the fzf widgets in both modes, and report the same after running `fish_vi_key_bindings` by hand.
- [x] 1.3 Confirm no existing binding was displaced: at a fresh prompt, Ctrl+F still moves forward a word, Ctrl+B still kills the word before the cursor, and Ctrl+Enter still accepts and runs the autosuggestion.
- [x] 1.4 Exercise the three widgets in both vi modes — Ctrl+T inserts a path at the cursor without running the line, Ctrl+R replaces the line with a history entry without running it, Alt+C changes directory — and confirm dismissing each leaves the command line and working directory untouched.
- [x] 1.5 Confirm a non-interactive fish is unaffected: `fish -c 'functions -q fzf-file-widget; and echo leaked'` prints nothing.
- [x] 1.6 Correct the stale claim in `~/.config/fish/conf.d/key-bindings.fish` that fish re-runs `fish_user_key_bindings` after every binding-set install, replacing it with what was measured. Verify the file's own bindings still resolve at a prompt.

## 2. bash

- [x] 2.1 Add the fzf block to `~/.bashrc` **below** the `exec fish` block — `eval "$(fzf --bash)"` behind a `command -v` guard — with a comment explaining that this position is what keeps a bash about to be replaced by fish from paying for it.
- [x] 2.2 Verify the placement does not cost the common path: open a normal terminal and confirm it lands in fish, and that the block after the `exec` line never runs.
- [x] 2.3 Verify a bash that stays gets the pickers: with `FISH_LAUNCHED=1 bash -i`, confirm `bind -X` reports the fzf widgets on Ctrl+R and Ctrl+T.
- [x] 2.4 Verify a non-interactive bash is unaffected: `bash -c 'bind -X'` installs nothing.

## 3. Absence

- [x] 3.1 Verify graceful absence: start fish and bash with `fzf` made unreachable on `PATH` and confirm both shells start silently, with every other binding, shorthand, and environment setting still in effect.

## 4. Repository

- [x] 4.1 Confirm the new `conf.d` file shows as untracked with no ignore-rule edit, and commit it together with the `key-bindings.fish` and `.bashrc` edits.
- [x] 4.2 Note fzf in the README's list of software the configuration expects, alongside the other optional per-machine tools.
- [x] 4.3 Drop zoxide from this change: remove `conf.d/zoxide.fish`, the `.bashrc` block, the README entry, and the `directory-jumping` spec, and trim the now-dangling mention of `zoxide's z` from the direnv comment in `~/.bashrc`. Verify `grep -r zoxide` over the tracked shell configuration and README returns nothing.
