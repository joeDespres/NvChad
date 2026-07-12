local M = {}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
M.ui = {
  telescope = { style = "bordered" }, -- borderless / bordered
  -- Disabled NvChad statusline to use lualine instead
  statusline = { enabled = false },
  tabufline = { enabled = false }, -- Using bufferline.nvim instead
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
    DiffChange = { fg = "orange" },
    DiffAdded = { fg = "#ABE9B3" },
    -- not sure
  },
}

local function set_molten_highlights()
  local highlights = {
    MoltenVirtualText = { fg = "#c7d1ff", bg = "#191828" },
    MoltenOutputWin = { fg = "#D9E0EE", bg = "#191828" },
    MoltenOutputWinNC = { fg = "#bfc6d4", bg = "#191828" },
    MoltenOutputBorder = { fg = "#89B4FA", bg = "#191828" },
    MoltenOutputBorderSuccess = { fg = "#ABE9B3", bg = "#191828" },
    MoltenOutputBorderFail = { fg = "#F38BA8", bg = "#191828" },
    MoltenOutputFooter = { fg = "#605f6f", bg = "#191828", italic = true },
  }
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

local molten_hl_group = vim.api.nvim_create_augroup("MoltenHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = molten_hl_group,
  callback = set_molten_highlights,
})
vim.api.nvim_create_autocmd("User", {
  group = molten_hl_group,
  pattern = "FilePost",
  callback = set_molten_highlights,
})
set_molten_highlights()

vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

return M
