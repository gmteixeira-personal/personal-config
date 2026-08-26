## Context

See proposal.md — Why. The constraint that shapes everything below is the existing treatment of destructive commands in `lua/config/keymaps.lua`: the buffer deletions run `:confirm bdelete`, never a bare `:bdelete` and never `:bdelete!`. A bare command fails with an error in exactly the situation the user needs to be told about; a banged one throws the work away. Quitting has the same shape, so it gets the same answer.

`<leader>q` is unbound today, and no mapping in the configuration begins with it. `<leader>wq` — quit window — is a different sequence and is not affected by claiming the prefix.

## Goals / Non-Goals

**Goals:**

- Two mappings and a group name, in the two files that already own mappings and group names.
- The same prompt-rather-than-fail behaviour the buffer deletions established.

**Non-Goals:**

- Any session behaviour, and any plugin. Deciding on a session manager is a separate change; `qs`, `ql` and `qd` are left free for it.
- Any force variant. Nothing added here ends the session without asking about work that would be lost.
- Replacing `:qa` or `:wq` as typed commands. Both keep working; these are an additional route.

## Decisions

**`:confirm qall` rather than `:qa`.**

`:qa` with a modified buffer aborts with `E37: No write since last change`, which reports a problem without offering a way through it — the user then has to find the buffer themselves. `:confirm qall` turns that error into a save/discard/cancel dialog, once per modified buffer, and cancelling leaves the session untouched. `:qa!` was rejected outright: a two-key sequence that silently discards every unsaved buffer is the one outcome this configuration has consistently refused.

**`:confirm xall` rather than `:wqall` for `<leader>qw`.**

`:xall` writes only the buffers that were modified; `:wqall` writes every buffer whether or not it changed, which updates modification times on untouched files and can trip file watchers and build tools for no reason. `:confirm` still matters on top of `:xall`: a modified buffer with no filename, a read-only file, or a failed write would otherwise abort the whole quit with an error, and with `:confirm` the user is asked about that one buffer while the rest are already written.

**Both as `<cmd>` mappings, not `:` mappings.**

`<cmd>` matches every other mapping in the file and needs no `<silent>`; nothing here needs a Lua function, since the whole behaviour is one built-in Ex command in each case.

**No confirmation wrapper of our own, unlike `<leader>rc`.**

The restart mapping asks `vim.fn.confirm` first, because `:restart` discards the session even when every buffer is saved, so a mistyped `<leader>r` sequence would be unrecoverable. Quitting with nothing modified is not the same: the files are on disk and reopening the editor costs a moment. Adding a second dialog on top of `:confirm`'s would mean two prompts for the case that actually risks work — so the built-in's prompt is the only one.

**`q` for the prefix, matching the LazyVim layout the request came from.**

`q` is free, and no built-in `<leader>`-adjacent meaning competes with it. The letters under it are chosen so the session mappings LazyVim puts on `s`, `l` and `d` can be added later without moving `qq` or `qw`.

**`w` for save-and-quit.**

It is the letter `:wq` and `:x` already carry for "write, then leave", so the sequence reads as what it does. It does not collide with `<leader>w` — that is a different prefix, one key earlier in the sequence.

## Risks / Trade-offs

- **`<leader>q` is now a prefix, so `<leader>` followed by `q` and nothing else waits out `timeoutlen` (1000ms here) before doing nothing** → This is how every other prefix in the configuration behaves, and the prefix runs no command of its own, which is what keeps the wait from executing something unintended. which-key lists the continuations at 300ms, well inside the timeout.
- **Two keystrokes now end the entire session** → `:confirm` is what stands between a mistyped sequence and lost work, which is why no bang variant is added and why the prompt requirement is written into the spec rather than left to the command's default.
- **`:confirm` prompts once per modified buffer, so quitting a session with many of them means several dialogs** → Correct behaviour rather than a cost to remove: the alternative is one decision applying to buffers the user has not looked at. `<leader>qw` is the way to avoid the prompts, by writing them first.
- **`:xall` leaves a modified unnamed buffer unwritten and prompts for it** → Intended; there is no filename to write to, and inventing one would be worse than asking.
