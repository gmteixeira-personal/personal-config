## 1. Confirm the prerequisite set against the configuration

- [x] 1.1 Re-derive which managed tools need a runtime by inspecting each package under `stdpath("data")/mason/packages/`, and verify the result matches design.md's evidence table: a `node_modules/` directory means Node.js, a `venv/` directory means Python 3, and the remaining packages are prebuilt binaries needing nothing
- [x] 1.2 Confirm the non-mason prerequisites are still declared where design.md says they are — `ripgrep` at the `<leader>fg` binding in `lua/plugins/telescope.lua`, `fish_indent` in `lua/plugins/conform.lua`, the .NET SDK in `lua/plugins/roslyn.lua` — and verify each file still contains that declaration
- [x] 1.3 Run `:checkhealth mason` and `:checkhealth telescope` and verify they report the runtime and fetch-tool prerequisites by name, so the README can point a reader at them as the in-editor check

## 2. Rewrite the README's Requirements section

- [x] 2.1 Replace the three-row Requirements table with the three consequence groups from design.md — startup and installation blockers, per-language runtimes, and degradations — and verify every prerequisite named in design.md's evidence table and its non-mason list appears in exactly one group
- [x] 2.2 State for each entry what the reader observes without it, drawn from the configuration's own code path rather than from a guess, and verify no entry claims a consequence the code does not produce
- [x] 2.3 Name which languages or capabilities each runtime carries, so a reader wanting only a subset can tell what to skip, and verify Node.js names the web, shell and fish servers plus prettier; Python 3 names `basedpyright`; the .NET SDK names C# and Razor; `fish` names `fish_indent` and `fish_lsp`
- [x] 2.4 Fold the .NET SDK paragraph into the table and delete the now-duplicated prose, verifying the SDK is stated once and the section reads without a leftover reference to it
- [x] 2.5 Name `:checkhealth mason` and `:checkhealth telescope` as the in-editor check, and verify a reader can go from the README to a per-prerequisite present/absent answer without leaving the editor

## 3. Reconcile the surrounding claims

- [x] 3.1 Remove the sentence "Every other language works without anything installed by hand", and verify no remaining sentence in the README asserts that installing a tool is sufficient to run it
- [x] 3.2 Narrow the opening's self-provisioning claim to what the configuration actually does — installs plugins and tool binaries, not the runtimes they execute on — and verify the opening no longer implies a bare machine reaches a fully working editor
- [x] 3.3 Check the "Language servers and formatters" bullet and the Plugins section for the same overstatement, and verify each either states the runtime dependency or defers to the Requirements section rather than contradicting it
- [x] 3.4 Verify the table of contents and any in-document links to the Requirements section still resolve after the rewrite

## 4. Verify against the spec

- [x] 4.1 Walk each scenario in `specs/documentation/spec.md` against the rewritten README and verify all eight hold, including that no prerequisite the configuration installs for itself is listed as a manual step
- [x] 4.2 Run `openspec validate document-install-prerequisites --strict` and verify it reports the change as valid
