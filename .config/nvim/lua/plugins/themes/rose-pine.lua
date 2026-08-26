-- Colorscheme, installed to be switched to rather than started in: themery.lua owns startup.
-- lazy = true does not hide it from the theme switcher -- themery.lua globs colors/* under
-- lazy.nvim's unloaded plugins, and lazy.nvim loads the owning plugin on ColorSchemePre.
--
-- No opts: rose-pine's colors/*.lua call its own setup when applied, so nothing is needed first.
-- The variant is chosen by picking it -- rose-pine-main, -moon or -dawn are separate entries.
return {
  "rose-pine/neovim",
  name = "rose-pine", -- lazy.nvim would otherwise call this plugin "neovim", after the repository
  lazy = true,
}
