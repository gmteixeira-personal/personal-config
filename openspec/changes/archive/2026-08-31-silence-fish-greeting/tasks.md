## 1. The snippet

- [x] 1.1 Create `~/.config/fish/conf.d/greeting.fish` holding a `status is-interactive` guard, `set -g fish_greeting ''`, and a comment saying why the value is a global rather than a universal and why the file is its own. Verify the file contains exactly one `set` and no other setting

## 2. Behaviour verification

- [x] 2.1 Start a fresh interactive fish and verify the first output is the prompt, with neither `Welcome to fish` nor `Type help` printed
- [x] 2.2 Open a new terminal window so bash hands over with `exec fish`, and verify no greeting appears there either
- [x] 2.3 Run `exec fish` inside an existing shell and verify the replacement shell prints no greeting
- [x] 2.4 Run `fish -c 'set -S fish_greeting'` in an interactive shell and verify the variable is reported as a global set to the empty string, with no universal of the same name
- [x] 2.5 Verify a non-interactive shell is unchanged: `fish -c 'echo hi'` prints `hi` and nothing else, and `set -S fish_greeting` from it reports no global
- [x] 2.6 Start `fish --private` and verify it still reports that history will not be persisted
- [x] 2.7 Verify `help` still works from the prompt

## 3. Machine-local state does not override it

- [x] 3.1 Set a universal greeting by hand (`set -U fish_greeting 'x'`), start a fresh interactive fish, and verify it still prints no greeting — then erase the universal with `set -e -U fish_greeting` and verify `grep fish_greeting ~/.config/fish/fish_variables` finds nothing

## 4. Commit

- [x] 4.1 Verify `git status --porcelain` offers `.config/fish/conf.d/greeting.fish` as untracked with no `.gitignore` edit, then stage that path by name and verify nothing else is staged
