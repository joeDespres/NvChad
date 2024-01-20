local opt = vim.opt

opt.scrolloff = 10
opt.colorcolumn = "80"
opt.relativenumber = true

vim.api.nvim_create_augroup("AutoFormat", {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  group = "AutoFormat",
  callback = function()
    local current_filename = vim.fn.expand "%"

    local format = "silent! !stylua " .. current_filename
    vim.api.nvim_command(format)
    -- Simulate pressing the Enter key
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
  end,
})
