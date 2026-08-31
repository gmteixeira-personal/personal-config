## 1. Add the configuration

- [x] 1.1 Write `.config/direnv/direnv.toml` with `[global] log_filter = "^$"`, and a comment saying that it drops `log_status` output only and that `log_error` is deliberately left alone
- [x] 1.2 Add an allowlist entry for the new file to `.gitignore`, beside the existing `!/.config/direnv/direnvrc`, and verify `git check-ignore -v .config/direnv/direnv.toml` reports it as not ignored
- [x] 1.3 Verify `git status --porcelain` still lists nothing under `.local/share/direnv/`, confirming the approval records stayed ignored

## 2. Success path is silent

- [x] 2.1 In a fresh interactive fish, `cd` into a project with an approved `.envrc` naming an existing `.venv`, and verify no output is printed
- [x] 2.2 Verify the environment is nonetheless active: `VIRTUAL_ENV` names the project's `.venv` and `python` resolves inside it
- [x] 2.3 `cd` into a subdirectory and back out of the tree, and verify neither move prints anything and that `VIRTUAL_ENV` is unset on leaving
- [x] 2.4 Repeat 2.1 and 2.3 in an interactive bash and verify the same silence, confirming the setting is direnv's rather than a shell's

## 3. Failure paths stay loud

- [x] 3.1 In a scratch directory with an unapproved `.envrc`, verify entering it still prints the line naming the file and the `direnv allow` command that approves it
- [x] 3.2 In a scratch directory with an approved `.envrc` whose `layout venv` names a `.venv` that does not exist, verify the single line naming the missing path is still printed
- [x] 3.3 Verify `direnv status` still answers in full, since it is run deliberately rather than by the hook. `direnv allow` prints nothing on success on this version — that is its own behaviour, not the filter's, and its failures still report

## 4. Portability

- [x] 4.1 Verify the setting is read from the tracked file and not from the environment, by confirming `DIRENV_LOG_FORMAT` is set nowhere in the tracked startup files — it is not honoured on this direnv version and must not be mistaken for the mechanism
- [x] 4.2 Verify `direnv status` reports `DIRENV_CONFIG` as `~/.config/direnv`, the directory the new file is in, so a clone picks it up with no further step

## 5. Documentation

- [x] 5.1 Added a paragraph to the README's Python virtual environments section. It was needed: the section describes what entering a project does, and silence is now part of that, with the errors that survive it named so the file is findable from the behaviour

## 6. Commit

- [x] 6.1 Stage `.config/direnv/direnv.toml`, `.gitignore`, any README edit, and this change's artifacts by name; verify `git diff --cached --stat` lists nothing else, and commit
- [x] 6.2 Verify the commit is on `main` and push it
