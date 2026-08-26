-- The single icon provider. Never add nvim-tree/nvim-web-devicons: the mock below stands in for it.
return {
  "echasnovski/mini.icons",
  lazy = false, -- eager, so the mock is registered before any plugin asks for icons
  priority = 900, -- after the colorscheme, ahead of everything else
  opts = {},
  config = function(_, opts)
    require("mini.icons").setup(opts)
    MiniIcons.mock_nvim_web_devicons() -- serves plugins that hard-require nvim-web-devicons
  end,
}
