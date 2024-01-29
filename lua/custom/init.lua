local opt = vim.opt

opt.scrolloff = 10
opt.colorcolumn = "80"
opt.tabstop = 4
opt.relativenumber = true
opt.wrap = false
opt.swapfile = false
opt.shell = "/bin/bash"

vim.api.nvim_create_autocmd({ "FocusLost" }, {
  command = "silent! wa",
})

vim.api.nvim_create_augroup("AutoFormat", {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  group = "AutoFormat",
  callback = function()
    local current_filename = vim.fn.expand "%"

    local format = "silent! !stylua " .. current_filename
    vim.api.nvim_command(format)
    -- Simulate pressing the Enter key
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<CR>", true, false, true),
      "n",
      true
    )
  end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.json",
  group = "AutoFormat",
  callback = function()
    vim.api.nvim_command "%!jq"
    -- Simulate pressing the Enter key
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<CR>", true, false, true),
      "n",
      true
    )
  end,
})
