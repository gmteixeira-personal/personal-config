## 1. Bootstrap documentation

- [x] 1.1 Add a bootstrap step covering authentication to the forge, placed after the identity step, and verify it names how the remote is moved from the clone URL
- [x] 1.2 State in that step why the clone URL stays HTTPS, and verify the ordering reads correctly for a machine with no keys

## 2. Multi-account convention

- [x] 2.1 Document the alias-per-account convention — one SSH host alias and one key per account, with the remote written against the alias — and verify it describes the shape rather than naming this machine's alias as required
- [x] 2.2 State that the file holding the aliases is deliberately not tracked, and verify it appears in the README's not-tracked table or the ignore policy's reasoning

## 3. Credential helper

- [x] 3.1 Document that no global credential helper is configured and why, and verify `git config --global --get-all credential.helper` returns nothing on this machine

## 4. Verification

- [x] 4.1 Verify no key material or SSH client configuration is tracked, by inspecting `git ls-files` for anything under `.ssh/`
- [x] 4.2 Verify this repository's remote names an account the default key authenticates as, and that its identity is set per repository rather than globally
