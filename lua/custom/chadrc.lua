local M = {}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
M.ui = {
  telescope = { style = "bordered" }, -- borderless / bordered
  statusline = {
    theme = "vscode_colored",
  },
  theme = "catppuccin",
  hl_override = {
    Visual = {
      bg = "#5c3005",
    },
    -- works
    DiffChange = { fg = "orange" },
    DiffAdded = { fg = "purple" },
    -- not sure
  },
}

return M
