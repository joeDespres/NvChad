local plugins = {
  {
    "EdenEast/nightfox.nvim",
    lazy = false, -- make sure we load this during startup as it is our main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = function()
      return require "custom.configs.carbon-fox"
    end,
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd "colorscheme carbonfox"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
    opts = function()
      return require "custom.configs.rust-tools"
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },
}
return plugins
