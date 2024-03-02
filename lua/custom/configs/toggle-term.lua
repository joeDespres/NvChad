local options = {
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 1,
  start_in_insert = true,
  insert_mappings = true,
  on_open = function()
    vim.cmd "silent! write"
  end,
  persist_size = true,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  auto_scroll = true,
  float_opts = {
    border = "double",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
}

return options
