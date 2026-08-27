## REMOVED Requirements

### Requirement: The whole file's difference from the index can be opened with one key

**Reason**: Seeing one file's whole difference is now diffview's, on the same `<leader>gd` key, alongside the repository-wide view on `<leader>gm` and the file's history on `<leader>gh`. Two plugins each answering "show me this file's difference" meant two sets of in-view keys and two ways to dismiss the result; one plugin answering it means one of each. The capability is not lost — it moves to `repository-diff-view`, which states it against the last commit rather than against the index.

**Migration**: `<leader>gd` still opens the current file's difference and is still a toggle; it opens diffview's view rather than a `:diffsplit` against the index, so the two sides are the working file and the last commit. Where the difference from the *index* specifically is wanted, `:Gitsigns diffthis` is unchanged and still does exactly what the mapping used to.
