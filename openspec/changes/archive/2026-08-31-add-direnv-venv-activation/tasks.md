## 1. Dependency

- [x] 1.1 Install direnv with `pacman -S direnv` and verify `direnv version` prints 2.37.1 or later

## 2. The tracked helper

- [x] 2.1 Write `~/.config/direnv/direnvrc` defining `layout_venv`: set `VIRTUAL_ENV` to `$PWD/.venv`, `export` it, and `PATH_add "$VIRTUAL_ENV/bin"` — sourcing no script the environment supplies. Verify by grepping the file for `source` and `activate` and finding neither
- [x] 2.2 Make `layout_venv` report a missing environment in one line naming the path it looked for, and return without changing anything. Verify by running it in a directory with no `.venv` and seeing exactly one line of output and an unchanged `VIRTUAL_ENV`
- [x] 2.3 Add `!/.config/direnv/direnvrc` to `.gitignore` block 3, naming the file rather than the directory. Verify `git check-ignore -v .config/direnv/direnvrc` reports no match, and that `git status --porcelain` lists nothing under `.local/share/direnv/`

## 3. Shell hooks

- [x] 3.1 Create `~/.config/fish/conf.d/direnv.fish` holding a `status is-interactive` guard and `direnv hook fish | source`, and nothing else. Verify a fresh interactive fish has the hook registered (`functions --handlers | grep direnv`) and that `fish -c 'true'` produces no direnv output
- [x] 3.2 Add the bash hook to `~/.bashrc` after the `case $- in *i*` early return and before the `exec fish` block. Verify `FISH_LAUNCHED=1 bash -i -c 'declare -p PROMPT_COMMAND'` shows the direnv entry, and that `bash -c 'true'` produces no direnv output

## 4. Behaviour verification

- [x] 4.1 In `~/repos/ycrm`, write `.envrc` containing `layout venv`, enter the directory in a fresh fish, and verify direnv reports the file as blocked and that `VIRTUAL_ENV` is unchanged
- [x] 4.2 Run `direnv allow`, then verify `VIRTUAL_ENV` names `~/repos/ycrm/.venv` and `command -v python` resolves inside it
- [x] 4.3 `cd` to `~/repos/ycrm/src` (creating it if absent) and verify the environment stays active; `cd ~` and verify `VIRTUAL_ENV` is unset and `command -v python` no longer resolves into the venv
- [x] 4.4 Activate a different environment by hand, walk into and back out of `~/repos/ycrm`, and verify the hand-activated one is restored
- [x] 4.5 Edit `.envrc` (add a comment) and verify direnv blocks it again until `direnv allow` is run
- [x] 4.6 Repeat 4.2 and 4.3 in `FISH_LAUNCHED=1 bash` and verify the same `VIRTUAL_ENV` and interpreter path as fish reported
- [x] 4.7 Verify the tide prompt renders the python item as the project directory name (`ycrm`) rather than `.venv`, and that the direnv item appears, with no duplicated or doubled prompt output under `tide_prompt_transient_enabled`

## 5. Documentation and commit

- [x] 5.1 Add direnv's install command to `README.md` beside the other machine-level tools the bootstrap names. Verify the README states both the install command and that without it environments are activated by hand
- [x] 5.2 Stage the new and modified paths by name — `.config/direnv/direnvrc`, `.config/fish/conf.d/direnv.fish`, `.bashrc`, `.gitignore`, `README.md` — and verify `git status --porcelain` shows nothing staged from `.local/` or from any project's `.envrc`
