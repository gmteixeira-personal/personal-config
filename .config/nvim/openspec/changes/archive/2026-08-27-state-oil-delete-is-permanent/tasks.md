## 1. State the setting

- [x] 1.1 In `lua/plugins/oil.lua`, state `delete_to_trash = false` outright rather than inheriting oil's default, with a comment on why a reader should find how recoverable a deletion is in this file.

## 2. Verification

- [x] 2.1 Confirm the effective value at runtime is `false`, so the explicit setting matches what was already in force and nothing changed.
- [x] 2.2 In a throwaway directory, delete a file through the explorer, confirm the write, and check that the file is gone from disk and is not in the system trash.
