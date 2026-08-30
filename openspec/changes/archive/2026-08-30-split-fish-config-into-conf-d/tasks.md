## 1. Capture the baseline

- [x] 1.1 Record what a fresh interactive fish provides today — `abbr --list`, `alias`, `functions`, `bind`, and `set -S fish_key_bindings` — to a file outside the repository, and verify the capture is non-empty and lists `mkcd`, `cl`, and `e`

## 2. Move the configuration

- [x] 2.1 Create `.config/fish/conf.d/key-bindings.fish` holding `fish_vi_key_bindings` and a `fish_user_key_bindings` that contains only the six `bind` calls, wrapped in an `if status is-interactive` block, and verify a fresh interactive fish reports `fish_key_bindings` as `fish_vi_key_bindings` with all six bindings present in `bind -M default` and `bind -M insert`
- [x] 2.2 Create `.config/fish/conf.d/aliases.fish` holding the twelve abbreviations and `alias e nvim`, guarded the same way, and verify `abbr --list` in a fresh interactive fish matches the baseline and `functions -q e` succeeds
- [x] 2.3 Create `.config/fish/functions/mkcd.fish` and `.config/fish/functions/cl.fish`, one function each, and verify each is reported by `functions --details --verbose` as `autoloaded` from its own file rather than defined during startup, then runs correctly when called. (`functions` lists an autoloadable name before its file is read, so the absence check the task first described is not one fish can answer; the autoload flag is the property that was actually wanted.)
- [x] 2.4 Delete `.config/fish/config.fish` and verify a fresh interactive fish starts with no error and no missing setting against the baseline

## 3. Track the new files

- [x] 3.1 Add `!/.config/fish/functions/**` to `.gitignore` beside the existing `conf.d/**` line and remove the `!/.config/fish/config.fish` line, then verify `git status --porcelain` lists both function files and the two new snippets, and that `git check-ignore -v .config/fish/completions/x.fish` still reports it ignored

## 4. Verify the change as a whole

- [x] 4.1 Compare a fresh interactive shell against the baseline captured in 1.1 and confirm the abbreviations, aliases, functions, bindings and key-binding mode are identical
- [x] 4.2 Verify a non-interactive shell gets the environment and none of the prompt configuration: `fish -c 'abbr --query ll'` fails, `fish -c 'functions -q e'` fails, and `fish -c 'echo $EDITOR'` still reports `nvim`
- [x] 4.3 Verify order independence by reading the snippets in reverse filename order in a scratch fish configuration and confirming the resulting bindings, shorthands and environment are unchanged
- [x] 4.4 Run `openspec validate split-fish-config-into-conf-d --strict` and confirm it passes
- [x] 4.5 Sync the delta spec into the main specs once the implementation is verified, so `openspec/specs/fish-startup-files/spec.md` exists
