-- Bootstraps lazy.nvim on first launch, so a fresh clone needs no manual install step.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  -- --branch=stable pins to a release instead of tracking the default branch.
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  -- Fail loudly: falling through would leave a half-configured session with confusing errors.
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim into " .. lazypath .. ":\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath) -- lazy.nvim has to be on the runtimepath before it can be required

require("lazy").setup({
  spec = {
    -- Every .lua file directly in lua/plugins/ is imported automatically. Subdirectories are not:
    -- lazy.nvim descends into one only if it holds an init.lua, so a directory left unnamed here
    -- contributes nothing and reports no error. Each subdirectory needs its own line below.
    { import = "plugins" },
    { import = "plugins.themes" },
  },
  install = { colorscheme = { "kanagawa-wave", "habamax" } }, -- themes the first-run install UI
  checker = { enabled = false }, -- no background update checks
  change_detection = { notify = false }, -- no popup when a config file is edited
  rocks = { enabled = false }, -- nothing here needs luarocks
})
