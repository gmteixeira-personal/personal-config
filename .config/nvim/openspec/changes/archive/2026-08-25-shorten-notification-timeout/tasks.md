## 1. The timeout

- [x] 1.1 In `lua/plugins/noice.lua`, add a `views` table to `opts` holding exactly one entry: `notify = { timeout = 1500 }`. Nothing else goes in it — no `split`, no `cmdline_popup`, no second view.
- [x] 1.2 Leave the `presets` table, the `lsp` table, the `keys` table and the `dependencies` list untouched. nvim-notify stays a bare name with no `opts`.

## 2. Comments

- [x] 2.1 Beside the `views` entry, record that one timeout governs both `vim.notify` notifications and short editor messages, because noice's defaults route `messages.view` and every notification through the same `notify` view — and that this is the intended scope, not a side effect.
- [x] 2.2 Record that the value is set on noice's view rather than as an `opts` table on nvim-notify, so that the dependency stays a bare name as `plugin-management` and this file's own dependency comment require, and so every decision about how noice presents things stays in noice's options.
- [x] 2.3 Record that `long_message_to_split = true` sends anything too long for the view to the untimed `split` view, so this timeout cannot truncate long output.
- [x] 2.4 Record that `<leader>nl` and `<leader>nh` are how a message missed inside the shorter window is recovered.
- [x] 2.5 Amend the existing `presets` comment — the one saying an expanded `views` table would pin today's layout — so it no longer reads as contradicted: presets stay the layout mechanism, and this single entry is a duration no preset carries. Do not delete the original reasoning.
