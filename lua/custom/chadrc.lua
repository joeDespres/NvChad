local M = {}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
M.ui = {
  theme = "catppuccin",
  hl_override = {
    DiffChange = { fg = "orange" },
    DiffAdded = { fg = "purple" },
    DiffRemoved = { fg = "red" },
  },
}
local utils = require "core.utils"
M.gitsigns = {
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "⤷" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┋" },
  },
  on_attach = function(bufnr)
    utils.load_mappings("gitsigns", { buffer = bufnr })
  end,
}

return M
