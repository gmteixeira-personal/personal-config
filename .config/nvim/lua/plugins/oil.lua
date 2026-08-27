-- File explorer: browse and edit directories as ordinary buffers.
return {
  "stevearc/oil.nvim",
  lazy = false, -- must load before the first buffer to take over netrw for `nvim <directory>`
  dependencies = { "echasnovski/mini.icons" },
  opts = {
    default_file_explorer = true, -- replaces netrw
    columns = { "icon" }, -- icons supplied by mini.icons

    -- Upstream's default, stated outright rather than inherited. A delete here is a real delete:
    -- the file does not go to a trash can it could be fished back out of, so the confirmation
    -- below is the only thing between the keystroke and the file being gone. That is the whole
    -- reason to say it here -- a reader working out how recoverable a deletion is should find the
    -- answer in this file rather than in oil's defaults, and flipping it to true is a decision
    -- someone should have to make on purpose.
    delete_to_trash = false,

    -- Write-confirmation defaults left untouched, so deletions are previewed and confirmed.
  },
  keys = {
    {
      "<leader>e",
      -- Oil ships `toggle_float` but no in-window equivalent, so the toggle is assembled here out
      -- of the two halves it does expose. `close` restores the buffer and the scroll position the
      -- window held before, both recorded by an autocmd oil installs at setup -- so this side has
      -- nothing to track. The filetype is oil's own, and nothing else here sets it.
      function()
        local oil = require("oil")
        if vim.bo.filetype == "oil" then
          oil.close()
        else
          oil.open()
        end
      end,
      desc = "Toggle Oil",
    },
  },
}
