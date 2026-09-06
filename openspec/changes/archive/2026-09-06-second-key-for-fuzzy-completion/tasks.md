## 1. The binding

- [x] 1.1 Bind Ctrl+P to the fuzzy completion function in fish's default binding set and in vi insert mode, leaving the existing Shift+Tab binding in place
- [x] 1.2 Verify both keys open the same picker, and that fish's own completion key still completes by prefix
- [x] 1.3 Confirm the binding survives the vi binding set being reapplied, since `conf.d/key-bindings.fish` is read after this file and opens by erasing preset bindings

## 2. The cost

- [x] 2.1 Identify what Ctrl+P was bound to before — the preset `up-line` — and confirm the function it provided is still reachable by another key
- [x] 2.2 Record the displacement and its reasoning in the file's own comment block, rather than leaving a reader to discover it by losing the key

## 3. Close-out

- [x] 3.1 Run `openspec validate second-key-for-fuzzy-completion --strict` and verify it passes
- [x] 3.2 Verify `git status` names only the intended path, then commit
