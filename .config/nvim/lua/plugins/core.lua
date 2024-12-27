return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine" },
  { "neanias/everforest-nvim", priority = 1000 },

  -- Configure LazyVim to load catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- change catppuccin config
  {
    "catppuccin/nvim",
    -- opts will be merged with the parent spec
    opts = { transparent_background = true },
  },
}
