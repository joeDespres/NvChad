local M = {}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
M.ui = {
  telescope = { style = "bordered" }, -- borderless / bordered
  theme = "catppuccin",
  hl_override = {
    DiffChange = { fg = "orange" },
    DiffAdded = { fg = "purple" },
    DiffRemoved = { fg = "red" },
  },
}

return M
