local plugins = {

{
    "EdenEast/nightfox.nvim",
  lazy = false,    -- make sure we load this during startup as it is our main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function() vim.cmd("colorscheme nightfox") end
  },
 {
  "neovim/nvim-lspconfig",
  config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
  end,
  }, {
    "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "rust-analyzer",
    },
  },
  },
}
return plugins

