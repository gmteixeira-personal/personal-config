## 1. Shared render contract

- [x] 1.1 Move the render contract out of `status.md` into `conventions.md` — the legend, the entry-line fields and their widths, the emoji table, the colour rules, the status line, the rename form, and the untracked-directory cap
- [x] 1.2 Rewrite `status.md` to keep only what is specific to `/git:status`: the read-only precondition, the reads it makes, session ownership, the empty-tree case, "print the block and stop", and the rule against trailing prose
- [x] 1.3 Confirm `status.md` no longer restates any part of the contract

## 2. Closing status rule

- [x] 2.1 Add the closing-status rule to `conventions.md`: which commands render the block, that it goes last after the report, that a stopped or still-confirming run renders nothing, and that the report must not restate what the block shows
- [x] 2.2 Add the closing line to each of `init.md`, `fetch.md`, `commit.md`, `push.md`, `pull.md`, `switch.md`, `squash.md`, `append.md`, `merge.md`, `mergeinto.md`, and `cleanup.md`, pointing at the contract rather than describing the format
- [x] 2.3 Confirm `conventions.md` and `status.md` do not themselves gain a closing block

## 3. Model tiers

- [x] 3.1 Set `conventions.md` to the fast tier
- [x] 3.2 Set `init.md`, `fetch.md`, `status.md`, `commit.md`, `push.md`, `pull.md`, `switch.md`, and `merge.md` to the middle tier
- [x] 3.3 Set `squash.md`, `append.md`, `mergeinto.md`, and `cleanup.md` to the top tier
- [x] 3.4 Confirm every command file's frontmatter now carries an explicit `model` field and that `effort` is unchanged throughout

## 4. Verification

- [x] 4.1 Run a mutating command in a dirty repository and confirm the block closes it, matching what `/git:status` prints for the same state
- [x] 4.2 Confirm by inspection that each command's closing line withholds the block on a stopped run, and that the conventions state the same rule in one place
- [x] 4.3 Run `/git:fetch` and confirm the block reflects the updated ahead and behind counts
