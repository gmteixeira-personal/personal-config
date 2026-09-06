## 1. The check

- [x] 1.1 Write `.config/fish/conf.d/commit-guard.fish`: interactive-only, skipped when `$HOME/.git` is absent, reporting through `fish_color_error` when `core.hooksPath` is not `.githooks` or `.githooks/pre-commit` is not executable, and naming `git config core.hooksPath .githooks`; verify `fish -n` parses it
- [x] 1.2 Verify the silent case: with the guard active, a new interactive fish prints nothing about it
- [x] 1.3 Verify the unconfigured case in a throwaway repository whose `core.hooksPath` is unset, and confirm the quoted `"$(...)"` substitution reports rather than erroring
- [x] 1.4 Verify the unrunnable case: with `core.hooksPath` set but the hook's executable bit cleared, the same report appears; restore the bit afterwards
- [x] 1.5 Verify a non-interactive fish prints nothing
- [x] 1.6 Measure the added shell startup cost and confirm it is the single `git config` call

## 2. Documentation

- [x] 2.1 Add a line to README bootstrap step 2 saying an interactive shell reports the guard being inactive, so the check is discoverable from the step it backs up; verify it reads consistently with the verification snippet already there

## 3. Close-out

- [x] 3.1 Run `openspec validate detect-inactive-commit-guard --strict` and verify it passes
- [x] 3.2 Verify `git status` names only the intended paths, then commit
