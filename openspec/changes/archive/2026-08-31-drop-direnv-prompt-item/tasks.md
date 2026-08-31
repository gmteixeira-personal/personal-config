## 1. Set the universal

- [x] 1.1 In fish, set `tide_right_prompt_items` to the current list minus `direnv`, and verify `set -S tide_right_prompt_items` reports the universal without it — the global from `conf.d/tide.fish` still shadows it at this point, which is expected until step 2.1
- [x] 1.2 Verify `tide_direnv_bg_color`, `tide_direnv_color`, `tide_direnv_color_denied`, and `tide_direnv_icon` are all still set, so the item keeps its appearance for a later reversal

## 2. Regenerate the tracked file

- [x] 2.1 Run `tide-save-config` and verify it reports the same settings count the file already held (159), so nothing was added or dropped
- [x] 2.2 Verify `git diff -- .config/fish/conf.d/tide.fish` is exactly one changed line, `tide_right_prompt_items` losing `direnv`, and that no other tide setting moved
- [x] 2.3 Verify `git status --porcelain` does not list `fish_variables`, confirming it stayed ignored

## 3. Behaviour verification

- [x] 3.1 Verify a fresh fish reads the tracked file rather than the universal: `$tide_right_prompt_items` in a new shell contains no `direnv`
- [x] 3.2 Verify the machine-filtered cache agrees — `_tide_cache_variables` in a fresh shell leaves `$_tide_right_items` as `status cmd_duration context jobs node python rustc go time`, with `direnv` gone and `python` kept
- [x] 3.3 Verify the environment is still reported once, from a working directory inside a project with an approved `.envrc`: the right prompt shows `󰌠 <version> (<env>)` and no `▼`
- [x] 3.4 Verify direnv itself is unaffected — `VIRTUAL_ENV` still names the project's environment on entering it, and is unset on leaving

## 4. Commit

- [x] 4.1 Stage `.config/fish/conf.d/tide.fish` by name plus this change's `openspec/changes/drop-direnv-prompt-item/` artifacts, verify `git diff --cached --stat` lists nothing else, and commit
- [x] 4.2 Verify the commit is on `main` and push it
