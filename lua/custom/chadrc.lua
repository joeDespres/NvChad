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
    Comment = { italic = true },
    Visual = {
      bg = "#FFD8A6",
      fg = "#191828",
      bold = true,
      italic = false,
    },
    -- works
    DiffChange = { fg = "#FF6F00" },
    DiffAdded = { fg = "#8A2BE2" },
    -- not sure
  },
}

return M
