-- Colorscheme, installed to be switched to rather than started in: themery.lua owns startup.
-- lazy = true does not hide it from the theme switcher -- themery.lua globs colors/* under
-- lazy.nvim's unloaded plugins, and lazy.nvim loads the owning plugin on ColorSchemePre.
--
-- No opts: catppuccin's colors/*.lua call its own setup when applied, so nothing is needed first.
return {
  "catppuccin/nvim",
  -- Unlike the two specs alongside this one, the repository's last path segment is "nvim", which
  -- is what lazy.nvim would otherwise call the plugin. Named explicitly for the same reason
  -- rose-pine/neovim is.
  name = "catppuccin",
  lazy = true,
}
