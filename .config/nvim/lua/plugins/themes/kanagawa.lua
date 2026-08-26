-- Colorscheme, and the default one: themery.lua applies the startup colorscheme, and falls back to
-- kanagawa wave where no theme has been accepted in the switcher yet. Like every theme file here,
-- this is a bare install that applies nothing of its own -- see themery.lua for why that matters.
--
-- No opts: kanagawa's colors/*.lua call its own setup when applied, so nothing is needed first.
return {
  "rebelot/kanagawa.nvim",
  lazy = true,
}
