## 1. Establish what the editor already provides

- [x] 1.1 List the grammars and queries the editor ships and the commands it defines; verify there are seven of each and no parser-management command
- [x] 1.2 Ask the editor for each language the capability wants; verify both the grammar and the highlighting query are absent for the two it reports missing

## 2. Install the two languages

- [x] 2.1 Read the revisions nvim-treesitter pins for those grammars and fetch each at that revision; verify the checkout is at the pinned commit
- [x] 2.2 Build each grammar into the editor's site parser directory; verify the editor loads both through `vim.treesitter.language.add`
- [x] 2.3 Install each language's highlighting query beside it; verify `vim.treesitter.query.get` returns a query for both and parses without error
- [x] 2.4 Re-run the capability's health report; verify it reports no warnings

## 3. Record it where the repository can hold it

- [x] 3.1 Rewrite the configuration's tree-sitter comment with both installed paths, both grammar sources and revisions, the build command, the query URL and the editor's ABI range; verify the file still loads with `loadfile`
- [x] 3.2 Remove the two claims in it that were false -- that extra parsers already lived in the site directory, and that the grammar alone fixes it; verify by reading against what the machine actually has
