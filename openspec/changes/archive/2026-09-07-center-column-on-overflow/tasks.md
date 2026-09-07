## 1. Compositor configuration

- [x] 1.1 Change `center-focused-column` in the `layout` block of `.config/niri/config.kdl` from `"never"` to `"on-overflow"`, and verify `niri validate` reports the config as valid
- [x] 1.2 Rewrite the comment above that setting so it records why the session centres on overflow rather than leaving the column at the edge, and why it does not centre every focused column — verify by reading the block back and checking both rejected values are accounted for
- [x] 1.3 Correct the tail of the `always-center-single-column` comment, which asserts that `center-focused-column` stays at `"never"` and that setting it to centre would make the two look like alternatives; ground the distinction in the cases the two settings decide instead, noting that a lone column has no previously focused column to overflow against — verify by reading the block back and checking no claim about the focus setting's value remains

## 2. Verification

- [x] 2.1 Reload the config and move focus to an off-screen column that cannot share the output with the previously focused one; verify it lands centred rather than against an edge
- [x] 2.2 Move focus between two columns that already fit on the output together and verify the view does not move
- [x] 2.3 Verify a workspace holding one column is still centred, and that a single column of stacked windows is still treated as one column
