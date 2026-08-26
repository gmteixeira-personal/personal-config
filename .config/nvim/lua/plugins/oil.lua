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
      function()
        require("oil").toggle_float() -- same key closes the float again
      end,
      desc = "Toggle Oil (float)",
    },
  },
}
