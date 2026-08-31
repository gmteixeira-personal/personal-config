## 1. Establish which key the terminal delivers

- [x] 1.1 Run `fish_key_reader` in the terminal this configuration is used from, press Ctrl+Enter, and record what it prints; verify the output names a key — it will report either `ctrl-enter` or `enter`, and that answer decides every binding below
- [x] 1.2 In the same `fish_key_reader` session press Enter on its own and record what it prints, verifying the two keystrokes are distinguishable (`ctrl-enter` versus `enter`) rather than both printing `enter` — if both print `enter`, Ctrl+Enter is unreachable on this terminal and the fallback key in task 3.2 applies
- [x] 1.3 Write the measured result into a comment in `.config/fish/conf.d/key-bindings.fish` naming the terminal it was measured on, so the next reader does not repeat the measurement; verify with `grep -n "fish_key_reader\|ctrl-enter" .config/fish/conf.d/key-bindings.fish` that the note is present

## 2. Add the accept-and-run function

- [x] 2.1 Create `.config/fish/functions/accept-autosuggestion-and-run.fish` defining a function of the same name that runs `commandline -f accept-autosuggestion`, then calls `_tide_enter_transient` when `functions -q _tide_enter_transient` succeeds and `commandline -f execute` otherwise (see design.md — Decisions); verify with `fish -c "functions -q accept-autosuggestion-and-run; echo \$status"` that it prints `0`, confirming fish autoloads it by name
- [x] 2.2 Verify the fallback path works without tide by running `fish --no-config -c "source .config/fish/functions/accept-autosuggestion-and-run.fish; functions accept-autosuggestion-and-run"` and confirming it defines without error and its body reaches `commandline -f execute` when the tide function is absent
- [x] 2.3 Verify the file holds only this function, per the existing convention that a function is defined by being named, by checking `grep -c "^function " .config/fish/functions/accept-autosuggestion-and-run.fish` returns `1`

## 3. Bind the key

- [x] 3.1 Not applicable — this branch was conditional on task 1 reporting `ctrl-enter`, and it reported `ctrl-j`. Recorded rather than deleted so the branch that was not taken stays visible. Verified separately that fish 4.8.1 *would* have supported it: sending the kitty-protocol encoding `CSI 13;5u` to a fish with `bind ctrl-enter` installed fires that binding, so the key name is real and the only obstacle is that this terminal does not emit that sequence
- [x] 3.2 Since task 1 reported `ctrl-j`: bind `ctrl-j` to `accept-autosuggestion-and-run` in `fish_user_key_bindings` for both modes, and add a `--on-event fish_prompt` handler to the same file that forces `functions/fish_prompt.fish` to autoload with `functions fish_prompt >/dev/null 2>&1`, binds over tide's `\n` binding, and erases itself — the forced load is required because the first prompt event precedes the autoload, so binding without it lands ahead of tide and is overwritten (see design.md — Decisions); verify by checking `bind -M insert ctrl-j` and `bind -M default ctrl-j` at the *first* prompt of a fresh interactive shell both report `accept-autosuggestion-and-run`, and that `functions -q _accept_and_run_after_tide` then returns non-zero
- [x] 3.3 Remove the superseded `bind -M default \cj accept-autosuggestion execute` and `bind -M insert \cj accept-autosuggestion execute` pair, which the new bindings replace on the same key, since leaving them would put two different actions on `ctrl-j` in one function and describe behavior the shell does not have; verify with `grep -c "accept-autosuggestion execute" .config/fish/conf.d/key-bindings.fish` that it returns `0`
- [x] 3.4 Verify no vendored file was touched by checking `git status --porcelain .config/fish/functions/` lists no `_tide_*` file and no `fish_prompt.fish`

## 4. Verify the binding is actually in effect

- [x] 4.1 In an interactive shell started fresh, run `bind <key>` for the key chosen in task 3 and verify it reports `accept-autosuggestion-and-run` rather than `_tide_enter_transient` or a `--preset` action — this is the check that failed before this change and is the whole point of it
- [x] 4.2 Verify the same for vi normal mode by running `bind -M default <key>` and confirming it reports the same action
- [x] 4.3 Run `fish_vi_key_bindings` in a live shell, then re-run the checks in 4.1 and 4.2, verifying the bindings are still in effect after fish reinstalls its binding set

## 5. Verify the behavior at a prompt

- [x] 5.1 Run a distinctive command so it enters history, type a prefix of it long enough that fish offers the rest as an autosuggestion, press the key, and verify the full suggested command ran rather than the prefix alone
- [x] 5.2 Type a command for which no autosuggestion is offered, press the key, and verify the line ran exactly as typed with nothing appended
- [x] 5.3 Repeat 5.1 in vi normal mode and verify the same accept-and-run behavior
- [x] 5.4 Run one command with Enter and the next with the key, and verify both leave the same collapsed transient prompt in scrollback, with neither leaving a full-height prompt among the collapsed ones
- [x] 5.5 Verify Enter itself is unchanged — a plain Enter with a suggestion pending SHALL still run only what was typed, not the suggestion

## 6. Verify scope and track

- [x] 6.1 Verify `git status --porcelain` shows only the intended paths for this feature — the new `functions/accept-autosuggestion-and-run.fish`, the modified `conf.d/key-bindings.fish`, and the extra `conf.d/` snippet if task 3.2 was taken — with no other fish file changed
- [x] 6.2 Verify every new file is tracked rather than left untracked, since a file fish loads that git does not carry would work on this machine and be absent on the next one
- [x] 6.3 Not triggered — task 1 found Ctrl+Enter *reachable*, arriving as `ctrl-j` and distinguishable from plain `enter`, so no WezTerm setting is needed and none was changed; verify with `git status --porcelain` that no terminal configuration file appears, which also holds because that file lives outside this repository
