-- Colorscheme, installed to be switched to rather than started in: themery.lua owns startup.
-- lazy = true does not hide it from the theme switcher -- themery.lua globs colors/* under
-- lazy.nvim's unloaded plugins, and lazy.nvim loads the owning plugin on ColorSchemePre.
--
-- No opts: tokyonight's colors/*.lua call its own setup when applied, so nothing is needed first.
return {
  "folke/tokyonight.nvim",
  lazy = true,
}
