-- Theme switcher, and the one file in this configuration that applies a colorscheme. lazy = false
-- so it runs before the first frame is drawn, priority 1000 so it runs ahead of every other plugin.
-- Every theme file alongside this one must stay a bare install that sets no colorscheme of its own:
-- a second caller of vim.cmd.colorscheme is not an error but a load-order race, whose symptom is an
-- intermittently wrong theme. Changing the default below is the supported way to change which theme
-- an unrecorded machine starts in.
--
-- Persistence is Themery's, not ours. require("themery") calls controller.bootstrap() at module
-- level, which reads stdpath("data")/themery/state.json and applies the colorscheme named there;
-- accepting an entry in the picker writes that file back. The state lives outside this repository,
-- so a switch never dirties the working tree and no theme choice travels in a clone. Do not set
-- themeConfigFile -- it is deprecated in this version and only prints a notice at every startup.
return {
  "zaldih/themery.nvim",
  lazy = false,
  priority = 1000,
  keys = {
    -- Moved here from telescope.lua, which could preview a theme but had nowhere to record one.
    -- <leader>f stays a prefix only, never bound in its own right, so nothing under it waits out
    -- 'timeoutlen'.
    { "<leader>ft", "<cmd>Themery<cr>", desc = "Find colorscheme" },
  },
  config = function()
    -- Order matters: requiring the module applies the recorded colorscheme as a side effect, so
    -- discovery, setup() and the default below all have to happen inside priority = 1000 for the
    -- first frame to be themed.

    -- Names of the colorschemes Neovim itself ships, read off the running Neovim rather than
    -- hardcoded, so the exclusion cannot drift as Neovim adds or drops one.
    local bundled = {}
    for _, file in ipairs(vim.fn.globpath(vim.env.VIMRUNTIME, "colors/*", true, true)) do
      bundled[vim.fn.fnamemodify(file, ":t:r")] = true
    end

    local themes, seen = {}, {}
    local function add(name)
      if not seen[name] and not bundled[name] then
        seen[name] = true
        themes[#themes + 1] = name
      end
    end

    -- kanagawa-wave first, deliberately. When a recorded theme can no longer be applied -- its
    -- plugin uninstalled since it was chosen -- Themery falls back to the first entry of this list
    -- that works, so leading with the default is what makes that fallback agree with the default
    -- named by the colorscheme capability instead of landing on whichever name sorts first.
    add("kanagawa-wave")

    -- What is on the runtimepath: bundled colorschemes and those of already-loaded plugins.
    vim.tbl_map(add, vim.fn.getcompletion("", "color"))

    -- lazy.nvim keeps lazy = true plugins off the runtimepath, so getcompletion misses every theme
    -- that has not been loaded -- three of the four installed here. Glob their colors/* directly,
    -- which is what Telescope's own colorscheme picker does. Guarded because get_unloaded_rtp is
    -- lazy.nvim internal API: if it goes away, discovery quietly narrows to the runtimepath rather
    -- than erroring out of config before anything is themed.
    local ok, lazy_util = pcall(require, "lazy.core.util")
    if ok and lazy_util.get_unloaded_rtp then
      local paths = table.concat(lazy_util.get_unloaded_rtp(""), ",")
      for _, file in ipairs(vim.fn.globpath(paths, "colors/*", true, true)) do
        add(vim.fn.fnamemodify(file, ":t:r"))
      end
    end

    require("themery").setup({
      themes = themes,
      livePreview = true, -- repaint the buffer as the selection moves, so a theme is judged against real code
    })

    -- Themery's loadState is silent when its state file is absent, leaving no colorscheme applied.
    -- That is a machine on which no theme has been accepted yet, so fall through to the default.
    if not vim.g.colors_name then
      vim.cmd.colorscheme("kanagawa-wave") -- explicit variant; bare "kanagawa" follows &background
    end
  end,
}
