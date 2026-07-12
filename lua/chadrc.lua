-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",

  hl_override = {
    Comment = { italic = true },
    Visual = {
      bg = "#FFD8A6",
      fg = "#191828",
      bold = true,
      italic = false,
    },
    DiffChange = { fg = "orange" },
    DiffAdded = { fg = "#ABE9B3" },
  },
}

M.ui = {
  telescope = { style = "bordered" },
  -- lualine replaces the NvChad statusline; bufferline.nvim replaces tabufline
  statusline = { enabled = false },
  tabufline = { enabled = false },
}

return M
