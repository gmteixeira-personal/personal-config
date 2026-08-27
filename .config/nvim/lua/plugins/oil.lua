-- File explorer: browse and edit directories as ordinary buffers.
return {
  "stevearc/oil.nvim",
  lazy = false, -- must load before the first buffer to take over netrw for `nvim <directory>`
  dependencies = { "echasnovski/mini.icons" },
  opts = {
    default_file_explorer = true, -- replaces netrw
    columns = { "icon" }, -- icons supplied by mini.icons
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
